/******* Script to create hieararchy tree *********/

-- Seed the table by loading all first-level (parent-child) relationships
create table full_concept_ancestor as
select 
	r.concept_id_1 as ancestor_concept_id,
	r.concept_id_2 as descendant_concept_id,
	case when s.is_hierarchical=1 and c1.concept_level>=1 then 1 else 0 end as min_levels_of_separation,
	case when s.is_hierarchical=1 and c1.concept_level>=1 then 1 else 0 end as max_levels_of_separation
from concept_relationship r 
join relationship s on s.relationship_id=r.relationship_id and s.defines_ancestry=1
join concept c1 on c1.concept_id=r.concept_id_1 and c1.invalid_reason is null
join concept c2 on c2.concept_id=r.concept_id_2 and c1.invalid_reason is null
where r.invalid_reason is null
;

-- copy full_concept_ancestor into concept_ancestor
create table concept_ancestor as select * from full_concept_ancestor;

/********** Repeat till no new records are written *********/

-- create all new combinations
create table new_concept_ancestor as
select 
	uppr.ancestor_concept_id,
	lowr.descendant_concept_id,
	uppr.min_levels_of_separation+lowr.min_levels_of_separation as min_levels_of_separation,
	uppr.min_levels_of_separation+lowr.min_levels_of_separation as max_levels_of_separation	
from concept_ancestor uppr 
join concept_ancestor lowr on uppr.descendant_concept_id=lowr.ancestor_concept_id
union all select * from concept_ancestor
;

drop table concept_ancestor purge;

-- Shrink and pick the shortest path for min_levels_of_separation, and the longest for max
create table concept_ancestor as
select 
	ancestor_concept_id,
	descendant_concept_id,
	min(min_levels_of_separation) as min_levels_of_separation,
	max(max_levels_of_separation) as max_levels_of_separation
from new_concept_ancestor
group by ancestor_concept_id, descendant_concept_id
;

drop table new_concept_ancestor purge;

/*********cycle till here *****************/

-- Remove all non-Standard concepts (concept_level=0) 

rename table concept_ancestor to new_concept_ancestor;

create table concept_ancestor as 
  select * from new_concept_ancestor a
    join concept_stage c1 on a.ancestor_concept_id=c1.concept_id
    join concept_stage c2 on a.descendant_concept_id=c2.concept_id
       where c1.concept_level>0 and c2.concept_level>0 -- both are standard concepts
;

-- Clean up
drop table new_concept_ancestor;
drop table full_concept_ancestor;

-- Add connections to self for those vocabs having at least one concept in the concept_relationship table
insert into concept_ancestor
select 
	concept_id as ancestor_concept_id,
	concept_id as descendant_concept_id,
	0 as min_levels_of_separation,
	0 as max_levels_of_separation
from concept_stage 
where vocabulary_id in (
	select c.vocabulary_id from concept_relationship_stage r, concept_stage c where c.concept_id=r.concept_id_1
	union
	select c.vocabulary_id from concept_relationship_stage r, concept_stage c where c.concept_id=r.concept_id_2
)
and invalid_reason is null and concept_level!=0;
;

