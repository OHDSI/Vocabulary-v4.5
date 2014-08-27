/**************************************************************
* Script for creating ancestry tables and domain assignments for vocabulary 1
* SQL is in Netezza dialect
* Needs: 
- Expansion to other vocabularies
- Expansion to all relationship_ids that have the flag "defines_ancestry" set
- Change so that waling through a non-standard (but active) concept levels_of_separations are not incremented
- QA
- Addition and test of domain relationships

/* taking it from existing vocab
create view concept_relationship_stage as
select r.* from concept_relationship r, concept c1, concept c2 where c1.concept_id=r.concept_id_1 and c2.concept_id=concept_id_2 and c1.vocabulary_id=1 and c2.vocabulary_id=1;
drop view concept_stage;
create view concept_stage as
*/
drop view concept_relationship_stage;
drop view concept_stage;

-- Load from newest source
drop table concept_relationship_stage;
create table concept_relationship_stage as select concept_id_1, concept_id_2, relationship_id from concept_relationship where 1=0;
truncate table concept_relationship_stage;
insert into concept_relationship_stage
select * from external 'c:\Users\krfw864\Downloads\concept_relationship_stage.tsv' 
using (delimiter '\t' SkipRows 1 RemoteSource ODBC LogDir 'c:\Users\krfw864\Downloads' MaxErrors 10);

-- Load from newest source 
drop table concept_stage; 
create table concept_stage as 
select CONCEPT_ID,	CONCEPT_NAME,	CONCEPT_LEVEL,	CONCEPT_CLASS,	VOCABULARY_ID,	CONCEPT_CODE,	concept_code as VALID_START_DATE,	concept_code as VALID_END_DATE,	INVALID_REASON
from concept where 1=0; 

insert into concept_stage 
select * from external 'c:\Users\krfw864\Downloads\concept_stage.tsv'   
using (delimiter '\t' SkipRows 0 RemoteSource ODBC LogDir 'c:\Users\krfw864\Downloads' MaxErrors 10);

/********************************************/
-- Create SNOMED tree
drop table concept_tree_stage;
drop table new_leave;
drop table new_gen_new;
drop table new_gen_existing;
drop table new_tree;
create table concept_tree_stage as select * from concept_ancestor where 1=0;
create table new_gen_new as select * from concept_ancestor where 1=0;
create table new_gen_existing as select * from concept_ancestor where 1=0;
create table new_tree as select * from concept_ancestor where 1=0;

-- Build root entries from all concepts that have no parent
create table new_leave as
select 
  c.concept_id
from concept_stage c 
where not exists (
	select 1 from concept_relationship_stage r where r.concept_id_2=c.concept_id and r.relationship_id=10
) 
and c.invalid_reason = '' -- should be "is null"
and c.VALID_START_DATE!='01-APR-14'
;

/**************************************/
/* cycle till no new leaves are added */

-- Write latest additions of brand new leave records (to self)
insert into concept_tree_stage
select distinct
  concept_id as ancestor_concept_id,
  concept_id as descendant_concept_id,
  0 as min_levels_of_separation,
  0 as max_levels_of_separation
from new_leave l
;

-- Create new generation with existing descendants
insert into new_gen_existing
select distinct
	nl.concept_id as ancestor_concept_id,
	r.concept_id_2 as descendant_concept_id,
	1 as min_levels_of_separation,
	1 as max_levels_of_separation
from new_leave nl
join concept_relationship_stage r on nl.concept_id=r.concept_id_1 and r.relationship_id=10
where exists (select 1 from concept_tree_stage e where e.descendant_concept_id=r.concept_id_2)
;

-- Create new generation with new descendants
insert into new_gen_new
select distinct
	nl.concept_id as ancestor_concept_id,
	r.concept_id_2 as descendant_concept_id,
	1 as min_levels_of_separation,
	1 as max_levels_of_separation
from new_leave nl
join concept_relationship_stage r on nl.concept_id=r.concept_id_1 and r.relationship_id=10
where not exists (select 1 from concept_tree_stage e where e.descendant_concept_id=r.concept_id_2)
;

-- Build new full tree, and prune
truncate table new_tree;
insert into new_tree
select distinct
	ancestor_concept_id,
	descendant_concept_id,
	min(min_levels_of_separation) as min_levels_of_separation,
	max(max_levels_of_separation) as max_levels_of_separation
from (
-- existing tree
	select *
	from concept_tree_stage t
	union
-- add pairs through existing nodes
	select 
		t.ancestor_concept_id,
		d.descendant_concept_id,
		t.min_levels_of_separation+nge.min_levels_of_separation+d.min_levels_of_separation as min_levels_of_separation,
		t.max_levels_of_separation+nge.max_levels_of_separation+d.min_levels_of_separation as max_levels_of_separation
	from concept_tree_stage t
	join new_gen_existing nge on t.descendant_concept_id=nge.ancestor_concept_id 
	join concept_tree_stage d on nge.descendant_concept_id=d.ancestor_concept_id
	union
-- add pairs into new ones
	select 
		t.ancestor_concept_id,
		ngn.descendant_concept_id,
		t.min_levels_of_separation+ngn.min_levels_of_separation as min_levels_of_separation,
		t.max_levels_of_separation+ngn.max_levels_of_separation as max_levels_of_separation
	from concept_tree_stage t
	join new_gen_new ngn on t.descendant_concept_id=ngn.ancestor_concept_id 
	union
-- add pairs where the existing one is also giving new ones
	select 
		t.ancestor_concept_id,
		ngn.descendant_concept_id,
		t.min_levels_of_separation+nge.min_levels_of_separation+ngn.min_levels_of_separation as min_levels_of_separation,
		t.max_levels_of_separation+nge.min_levels_of_separation+ngn.max_levels_of_separation as max_levels_of_separation
	from concept_tree_stage t
	join new_gen_existing nge on t.descendant_concept_id=nge.ancestor_concept_id 
	join new_gen_new ngn on nge.descendant_concept_id=ngn.ancestor_concept_id 
) tree
group by tree.ancestor_concept_id, tree.descendant_concept_id
;

truncate table concept_tree_stage;
insert into concept_tree_stage
select * from new_tree;

-- create next generation of new_leave from new_generation_new
truncate table new_leave;
insert into new_leave
select distinct descendant_concept_id from new_gen_new
;

-- forget records with leaves
truncate table new_gen_new;
truncate table new_gen_existing;

/* cycle */

-- Clean up
drop table new_leave;
drop table new_gen_new;
drop table new_gen_existing;
drop table new_tree;

select * from concept_tree_stage where max_levels_of_separation-min_levels_of_separation =12;
select * from concept where concept_id in (441840, 4120936);
select * from concept_ancestor where ancestor_concept_id=441840 and descendant_concept_id=4120936;

select a.concept_id, a.concept_name, d.concept_id, d.concept_name, anc.min_levels_of_separation as anc_min, anc.max_levels_of_separation as anc_max, t.Min_LEVELS_OF_SEPARATION as t_min, t.Max_LEVELS_OF_SEPARATION as t_max
from concept_ancestor anc
join concept a on a.concept_id=anc.ancestor_concept_id join concept d on d.concept_id=anc.descendant_concept_id
join concept_tree_stage t on t.ancestor_concept_id=a.concept_id and t.descendant_concept_id=d.concept_id
where anc.max_levels_of_separation-anc.min_levels_of_separation=13 and a.vocabulary_id=1 and d.vocabulary_id=1
and a.concept_id=4322976 and d.concept_id=4210870
;

select c2.concept_id, c2.concept_name, c3.concept_id, c3.concept_name 
from concept_relationship_stage r1
join concept_relationship_stage r2 on r1.concept_id_2=r2.concept_id_1
join concept c2 on c2.concept_id=r1.concept_id_2
join concept c3 on c3.concept_id=r2.concept_id_2
where r1.concept_id_1 = 441840
order by 3;

/******************************************************************/
-- Create domains
drop table concept_domain;
create table concept_domain as 
select concept_id, 'Not assigned anything because ' as concept_domain from concept_stage;

-- The default is 'Observation', though a few organisms are not connected and stay that way
update concept_domain set
	concept_domain='observation'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4008453, -- root
		4086921 -- context dependent category		
	)
);

-- Providers
update concept_domain set
	concept_domain='provider'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4320145, 	-- Healthcare professional
		4185257	  -- Site of care
	)
);

-- Drugs
update concept_domain set
	concept_domain='drug_exposure'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4169112, -- Aromatherapy agent
		4162709, -- Pharmaceutical / biologic product
		4254051 --	Drug or medicament
	)
);

-- Device
update concept_domain set
	concept_domain='device_exposure'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4169265, -- Device
		4128004, -- Surgical material
		4124754, -- Graft
		4303529 -- Adhesive agent
	)
)
and concept_id not in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4124754 -- Graft
	)
);

-- Gender
update concept_domain set
	concept_domain='gender'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4268709  -- Gender
	)
);


-- Condition
update concept_domain set
	concept_domain='condition_occurrence'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		441840, -- Clinical Finding
		438949, -- Adverse reaction to primarily systemic agents
		40419271, -- Drugs, medicines and biological substances causing adverse effects in therapeutic use
		4196732 -- Calculus observation
	)
)
and concept_id not in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4041436, -- 'Finding by measurement'
		443440, -- 'History finding'
		4040739, -- 'Finding of activity of daily living'
		4146314, -- 'Administrative statuses'
		-- 40416814, -- 'Causes of injury and poisoning'
		-- 40418184,  -- '[X]External causes of morbidity and mortality'
		4037321, -- Symptom description
		4084137,	-- Sample observation
		4022232, -- 'Health perception, health management pattern'
		4037706, -- 'Patient not aware of diagnosis'
		4279142, -- 'Victim status'
		4037705, --'Patient aware of diagnosis'
		4167037, --	Patient condition finding
		4231688, --'Staff member inattention'
		4236719, -- 'Staff member ill'
		4225233, -- 'Staff member distraction'
		4134868, --	Staff member fatigued
		4134549, -- Staff member inadequately assisted
		4134412, --	Staff member inadequately supervised
		4231688, --	Staff member inattention
		4037137, --'Family not aware of diagnosis'
		4038236, -- 'Family aware of diagnosis'
		4170588, -- Acceptance of illness
		4028922, -- 	Social context condition
		4202797 -- Drug therapy observations
	)
);

-- More Condition 
update concept_domain set
	concept_domain='condition_occurrence'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4196732, -- Calculus observation - overriding Sample observation 
		444035, -- Incontinence
		4025202, -- Elimination pattern
		4186437 -- Urinary elimination alteration
	)
);

-- Measurement - has to come after Condition
update concept_domain set
	concept_domain='measurement'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
--		4266236, -- 'Cancer-related substance' - 4228508
		4028908, -- 'Laboratory procedures'
		4048365, -- 'Measurement'
		4041436 -- 'Finding by measurement'
-- 		4236002, -- 'Allergen class'
-- 		4019381, -- 'Biological substance'
--		4240422 -- 'Human body substance'
	)
)
and concept_id not in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4084137,	-- Sample observation
		4035436 -- Secondary gout
	)
);

-- More Measurement
update concept_domain set
	concept_domain='measurement'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4038503	-- 'Laboratory test finding' - child of excluded Sample observation
	)
);

-- Race - has to come after Condition
update concept_domain set
	concept_domain='race'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4155301, -- Ethnic group
		4216292  -- Racial group
	)
);

-- Procedure
update concept_domain set
	concept_domain='procedure_occurrence'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4322976, -- 'Procedure'
		4126324,	-- Resuscitate
		4119499, -- DNR
		4013513 -- Cardiovascular measurement
	)
)
and concept_id not in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4048365, -- 'Measurement'
		4028908, -- 'Laboratory procedures'
		4202797, -- Drug therapy observations
		4175586, -- Family history of procedure
		4033224, -- Administrative procedure
		4215685, -- Past history of procedure
		4082089,	-- Procedure contraindicated
		4231195,	-- Administration of drug or medicament contraindicated
		4260907 -- Drug therapy status
	)
);

-- More Procedure -- need to reinstantiate after exclusion above
update concept_domain set
	concept_domain='procedure_occurrence'
where concept_id in (
	select descendant_concept_id from concept_tree_stage where ancestor_concept_id in (
		4271693, -- Blood unit processing - inside Measurements
		4070456 -- Specimen collection treatments and procedures - - bad child of 4028908	Laboratory procedure
	)
);

create external table '\\americas.astrazeneca.net\us\Boston\Users 02\krfw864\Documents\OMOP\Vocab5.0\snomed_domains.txt' 
using (delimiter '\t' SkipRows 1 RemoteSource ODBC LogDir '\\americas.astrazeneca.net\us\Boston\Users 02\krfw864\Documents\OMOP\Vocab5.0') as
select d.* from concept_domain d 
;

create external table '\\americas.astrazeneca.net\us\Boston\Users 02\krfw864\Documents\OMOP\Vocab5.0\snomed_hierarchy.txt' 
using (delimiter '\t' SkipRows 1 RemoteSource ODBC LogDir '\\americas.astrazeneca.net\us\Boston\Users 02\krfw864\Documents\OMOP\Vocab5.0') as
select ancestor_concept_id, descendant_concept_id from concept_tree_stage
;

/* below this is QA material
/******************************************************************************/

select concept_domain,  count(8) from concept_domain d, concept_stage c where c.CONCEPT_ID=d.concept_id and c.valid_start_date!='01-APR-14' group by concept_domain order by 2 desc;
select * from concept_stage c, concept_domain d where c.concept_id=d.concept_id 
and d.concept_domain='Context-dependent category' and c.INVALID_REASON='' and valid_start_date!='01-APR-14'
limit 1000;

-- orphan concepts not in hierarchy
select * from concept_stage c 
where concept_id not in (
	select distinct ancestor_concept_id from concept_tree_stage)
--and concept_class='Clinical finding' 
-- and invalid_reason='' 
and valid_start_date!='01-APR-14'
limit 100;

-- check how often the hierarchy switches classes
select an.concept_class ancestor, de.concept_class descendant, count(8) 
from concept_stage an, concept_stage de, concept_tree_stage a
where a.ancestor_concept_id=an.concept_id and a.descendant_concept_id=de.concept_id
and an.concept_class!=de.concept_class
and an.valid_start_date!='01-APR-14' and de.valid_start_date!='01-APR-14'
group by an.concept_class, de.concept_class
order by 3 desc;

-- check how often the hierarchy switches domains
select ad.concept_domain ancestor, ed.concept_domain descendant, count(8) 
from concept_stage an, concept_domain ad, concept_stage de, concept_domain ed, concept_tree_stage a
where an.concept_id=ad.concept_id and de.concept_id=ed.concept_id
and a.ancestor_concept_id=an.concept_id and a.descendant_concept_id=de.concept_id
and ad.concept_domain!=ed.concept_domain
and an.valid_start_date!='01-APR-14' and de.valid_start_date!='01-APR-14' and ad.concept_domain!='Observation'
group by ad.concept_domain, ed.concept_domain
order by 3 desc;

-- see where it changes domain
select distinct
 an.concept_name, an.concept_id, ad.concept_domain, 
	de.concept_name, de.concept_id, ed.concept_domain
from concept_stage an, concept_domain ad, concept_stage de, concept_domain ed, concept_tree_stage a
where an.concept_id=ad.concept_id and de.concept_id=ed.concept_id
and a.ancestor_concept_id=an.concept_id and a.descendant_concept_id=de.concept_id
and ad.concept_domain='procedure_occurrence' and ed.concept_domain='measurement'
and an.CONCEPT_NAME not in ('SNOMED CT July 2002 Release: 20020731 [R]', 'Special concept', 'Navigational concept', 'Context-dependent category', 'Context-dependent finding')
order by de.concept_name
limit 1000;

select * from concept_stage where concept_id=43200000297;
select * from concept_domain d, concept_stage c where d.concept_id=c.concept_id limit 100; --and d.concept_domain='Clinical finding';

-- hierarchy up and down
select min_levels_of_separation min, d.concept_domain, c.* from concept_tree_stage a, concept_stage c, concept_domain d where a.ancestor_concept_id in (439664) and c.concept_id=a.descendant_concept_id and c.concept_id=d.concept_id order by min_levels_of_separation, concept_name limit 1000;
select max_levels_of_separation min, d.concept_domain, c.* from concept_tree_stage a, concept_stage c, concept_domain d where a.descendant_concept_id in (4041283, 4293175, 4094294) and c.concept_id=a.ancestor_concept_id and c.concept_id=d.concept_id order by max_levels_of_separation limit 100;
select min_levels_of_separation min, d.concept_domain, c.* from concept_ancestor a, concept_stage c, concept_domain d where a.descendant_concept_id=4030758 and c.concept_id=a.ancestor_concept_id and c.concept_id=d.concept_id order by min_levels_of_separation limit 100;
-- relationships up and down
select d.concept_domain, c.concept_id, c.concept_name, r.relationship_id from concept_stage c, concept_relationship_stage r, concept_domain d where r.concept_id_1 in (4021807, 4206460) and c.concept_id=r.concept_id_2 and d.concept_id=c.concept_id and r.relationship_id=144;
select d.concept_domain, c.concept_id, c.concept_name, r.relationship_id from concept_stage c, concept_relationship_stage r, concept_domain d  where r.concept_id_1 in (439664) and c.concept_id=r.concept_id_2 and d.concept_id=c.concept_id and r.relationship_id=10;


select m.source_code, m.source_code_description, m.mapping_type, c.concept_id, c.concept_name, c.concept_class, d.concept_domain
from icd9_to_snomed_fixed m
join concept_domain d on d.concept_id=m.target_concept_id
join concept_stage c on c.concept_id=m.target_concept_id
where m.mapping_type='CONDITION' and d.concept_domain='Clinical finding' 
;

-- find the chain
select up.min_levels_of_separation up, d.concept_domain, c.* from concept c, concept_tree_stage up, concept_tree_stage down, concept_domain d
where up.descendant_concept_id=4023307
and down.ancestor_concept_id=4267385 -- root-- 4322976 -- Procedure -- 441840 -- Clinical finding --  4008453 -- root
and up.ancestor_concept_id=down.descendant_concept_id
and c.concept_id=up.ancestor_concept_id
and d.concept_id=c.concept_id 
order by up.min_levels_of_separation;

-- check classes against domains
select s.concept_class, d.concept_domain, count(8) from concept_stage s, concept_domain d
where s.concept_id=d.concept_id
and s.valid_start_date < '2014-01-01' and s.invalid_reason=''
group by s.concept_class, d.concept_domain
order by 3 desc
limit 100;

select s.*, d.concept_domain from concept_stage s, concept_domain d
where s.concept_id=d.concept_id
and s.valid_start_date < '2014-01-01' and s.invalid_reason=''
and s.concept_class='Clinical finding' and d.concept_domain='Observation';


/*************************************************************/

-- check Read-to_snomed
select rts.source_code_description, rts.concept_name, rts.concept_code, rts.domain, d.concept_domain
-- select count(8) 
from read_to_snomed rts, concept_stage c, concept_domain d
where c.concept_id=d.concept_id and c.concept_code=rts.concept_code
and lower(d.concept_domain)!=lower(rts.domain)
limit 100;

-- find the chain
select up.min_levels_of_separation up, d.concept_domain, c.concept_id, c.concept_name, c.concept_code 
from concept_stage c, concept_tree_stage up, concept_tree_stage down, concept_domain d, concept_stage des
where des.concept_code='315364008'
-- and down.ancestor_concept_id=4322976 -- Procedure 
-- and down.ancestor_concept_id=441840 -- Clinical finding 
and down.ancestor_concept_id=4008453 -- root
-- and down.ancestor_concept_id=4196732 -- calculus observation
and up.ancestor_concept_id=down.descendant_concept_id
and c.concept_id=up.ancestor_concept_id
and d.concept_id=c.concept_id and des.concept_id=up.descendant_concept_id
order by up.min_levels_of_separation;
