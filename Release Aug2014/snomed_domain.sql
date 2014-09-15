/* Script to update all mapping_type to records in SNOMED */

/* -- Load table (later build)
-- drop table snomed_domain;
create table snomed_domain as
select 
  concept_id,
  concept_name as domain_name 
from concept where 1=0;

/* Use SQLLDR to load the file snomed_domain.txt
* the control file is snomed_domain.ctl
options (skip=0)
load data
infile snomed_domain.txt
into table snomed_domain
replace
fields terminated by ','
optionally enclosed by '"'
trailing nullcols
(
concept_id,
domain_name
)

-- Write into concept_domain
insert into concept_domain
select * from snomed_domain;
*/

/******************************************************************/
-- Create domains
-- drop table peak;
create table peak (
	peak_id bigint, --the id of the top ancestor
	peak_domain varchar(40), -- the domain to assign to all its children
	ranked integer -- number for the order in which to assign 
);
/*
-- Figure out the non-connected top concepts
insert into peak
select distinct
	c.concept_id as peak_id,
	case 
		when c.concept_class='Clinical finding' then 'Condition'
		when c.concept_class='Model component' then 'Metadata'
		when c.concept_class='Observable entity' then 'Observation'
		when c.concept_class='Organism' then 'Observation'
		when c.concept_class='Pharmaceutical / biologic product' then 'Drug'
		else 'Manual'
	end as peak_domain
from concept_ancestor a, concept c
where a.ancestor_concept_id not in (
	select distinct descendant_concept_id from concept_ancestor where ancestor_concept_id!=descendant_concept_id
)
and c.concept_id=a.ancestor_concept_id and c.vocabulary_id=1
;
*/
-- List any parent-less concept not assigned above
select p.*, concept_name, concept_class from peak p, concept c where c.concept_id=p.peak_id and peak_domain='Manual';
-- Fix those
delete from peak where peak_domain='Manual';

-- add the various peak concepts
insert into peak (peak_id, peak_domain) values (4086921, 'Observation'); -- 'Context-dependent category' that has no ancestor
insert into peak (peak_id, peak_domain) values (4008453, 'Observation'); -- root
insert into peak (peak_id, peak_domain) values (4320145, 'Provider');
insert into peak (peak_id, peak_domain) values (4185257, 'Provider');	  -- Site of care
insert into peak (peak_id, peak_domain) values (4169112, 'Drug'); -- Aromatherapy agent
insert into peak (peak_id, peak_domain) values (4162709, 'Drug'); -- Pharmaceutical / biologic product
insert into peak (peak_id, peak_domain) values (4254051, 'Drug'); --	Drug or medicament
insert into peak (peak_id, peak_domain) values (4169265, 'Device');
insert into peak (peak_id, peak_domain) values (4128004, 'Device'); -- Surgical material
insert into peak (peak_id, peak_domain) values (4124754, 'Device'); -- Graft
insert into peak (peak_id, peak_domain) values (4303529, 'Device'); -- Adhesive agent
insert into peak (peak_id, peak_domain) values (441840, 'Condition'); -- Clinical Finding
insert into peak (peak_id, peak_domain) values (438949, 'Condition'); -- Adverse reaction to primarily systemic agents
insert into peak (peak_id, peak_domain) values (4196732, 'Condition'); -- Calculus observation
insert into peak (peak_id, peak_domain) values (4041436, 'Measurement'); -- 'Finding by measurement'
insert into peak (peak_id, peak_domain) values (443440, 'Observation'); -- 'History finding'
insert into peak (peak_id, peak_domain) values (4040739, 'Observation'); -- 'Finding of activity of daily living'
insert into peak (peak_id, peak_domain) values (4146314, 'Observation');-- 'Administrative statuses'
		-- 40416814, 'Observation'); Causes of injury and poisoning'
		-- 40418184,  -- '[X]External causes of morbidity and mortality'
insert into peak (peak_id, peak_domain) values (4037321, 'Observation'); -- Symptom description
-- insert into peak (peak_id, peak_domain) values (4084137,	'Observation');-- Sample observation
insert into peak (peak_id, peak_domain) values (4022232, 'Observation'); -- 'Health perception, health management pattern'
insert into peak (peak_id, peak_domain) values (4037706, 'Observation'); --'Patient not aware of diagnosis'
insert into peak (peak_id, peak_domain) values (4279142, 'Observation'); --'Victim status'
insert into peak (peak_id, peak_domain) values (4037705, 'Observation'); --'Patient aware of diagnosis'
insert into peak (peak_id, peak_domain) values (4167037, 'Observation'); --Patient condition finding
insert into peak (peak_id, peak_domain) values (4231688, 'Observation'); --'Staff member inattention'
insert into peak (peak_id, peak_domain) values (4236719, 'Observation'); --'Staff member ill'
insert into peak (peak_id, peak_domain) values (4225233, 'Observation'); --'Staff member distraction'
insert into peak (peak_id, peak_domain) values (4134868, 'Observation'); --Staff member fatigued
insert into peak (peak_id, peak_domain) values (4134549, 'Observation'); --Staff member inadequately assisted
insert into peak (peak_id, peak_domain) values (4134412, 'Observation'); --Staff member inadequately supervised
insert into peak (peak_id, peak_domain) values (4037137, 'Observation');--'Family not aware of diagnosis'
insert into peak (peak_id, peak_domain) values (4038236, 'Observation'); --'Family aware of diagnosis'
insert into peak (peak_id, peak_domain) values (4170588, 'Observation'); --Acceptance of illness
insert into peak (peak_id, peak_domain) values (4028922, 'Observation'); --	Social context condition
insert into peak (peak_id, peak_domain) values (4202797, 'Observation'); -- Drug therapy observations
insert into peak (peak_id, peak_domain) values (444035, 'Condition'); --Incontinence
-- insert into peak (peak_id, peak_domain) values (4025202, 'Condition'); --Elimination pattern
-- insert into peak (peak_id, peak_domain) values (4186437, 'Condition'); -- Urinary elimination alteration
--		4266236, 'Observation'); --'Cancer-related substance' - 4228508
insert into peak (peak_id, peak_domain) values (4028908, 'Measurement'); --'Laboratory procedures'
insert into peak (peak_id, peak_domain) values (4048365, 'Measurement'); --'Measurement'
-- 		4236002, 'Observation'); --'Allergen class'
-- 		4019381, 'Observation'); --'Biological substance'
--		4240422 -- 'Human body substance'
insert into peak (peak_id, peak_domain) values (4038503, 'Measurement');	-- 'Laboratory test finding' - child of excluded Sample observation
insert into peak (peak_id, peak_domain) values (4322976, 'Procedure'); --'Procedure'
insert into peak (peak_id, peak_domain) values (4126324, 'Procedure'); -- Resuscitate
insert into peak (peak_id, peak_domain) values (4119499, 'Procedure'); --DNR
insert into peak (peak_id, peak_domain) values (4013513, 'Procedure'); -- Cardiovascular measurement
insert into peak (peak_id, peak_domain) values (4175586, 'Observation'); --Family history of procedure
insert into peak (peak_id, peak_domain) values (4033224, 'Observation'); --Administrative procedure
insert into peak (peak_id, peak_domain) values (4215685, 'Observation'); --Past history of procedure
insert into peak (peak_id, peak_domain) values (4082089, 'Observation');-- Procedure contraindicated
insert into peak (peak_id, peak_domain) values (4231195, 'Observation');-- Administration of drug or medicament contraindicated
insert into peak (peak_id, peak_domain) values (40484042, 'Observation'); --Evaluation of urine specimen
insert into peak (peak_id, peak_domain) values (4260907, 'Observation'); -- Drug therapy status
insert into peak (peak_id, peak_domain) values (4271693, 'Procedure'); --Blood unit processing - inside Measurements
insert into peak (peak_id, peak_domain) values (4070456, 'Procedure'); -- Specimen collection treatments and procedures - - bad child of 4028908	Laboratory procedure
insert into peak (peak_id, peak_domain) values (4268709, 'Gender'); -- Gender
insert into peak (peak_id, peak_domain) values (4155301, 'Race'); --Ethnic group
insert into peak (peak_id, peak_domain) values (4216292, 'Race'); -- Racial group
insert into peak (peak_id, peak_domain) values (40642546, 'Metadata'); -- SNOMED CT Model Component
insert into peak (peak_id, peak_domain) values (4024728, 'Observation'); -- Linkage concept


-- Get them in the right order by counting the number of ancestors each of them has (could go wront if a parallel fork happens)
update peak p set p.ranked=r.rnk
from (
	select ranked.pd as peak_id, count(8) rnk from (
		select distinct pa.peak_id as pa, pd.peak_id as pd 
		from peak pa
		join concept_ancestor a on a.ancestor_concept_id=pa.peak_id 
		join peak pd on a.descendant_concept_id=pd.peak_id
	) ranked
	group by ranked.pd
) r
where r.peak_id=p.peak_id
;

-- Find true clashes. Currently they are dealt wtih by precedence, not rank. 
-- This might need to change
-- Also, this script needs to do this within a rank. Not done yet.
select conflict.concept_name, min_levels_of_separation min, d.snomed_domain, c.concept_name, c.concept_class 
from concept_ancestor a, concept c, snomed_domain d, concept conflict 
where a.descendant_concept_id in (
	select concept_id from (
		select child.concept_id, count(8)
		from (
			select distinct p.peak_domain, a.descendant_concept_id as concept_id from peak p, concept_ancestor a 
			where a.ancestor_concept_id=p.peak_id
		) child
		group by child.concept_id having count(8)>1
	) clash
) 
and c.concept_id=a.ancestor_concept_id and c.concept_id=d.concept_id and c.concept_id in (select peak_id from peak)
and conflict.concept_id=a.descendant_concept_id
order by conflict.concept_name, min_levels_of_separation, c.concept_name;
limit 1000;





-- Figure out the non-connected top concepts
insert into peak;
select distinct
	c.concept_id as peak_id,
	case 
		when c.concept_class='Clinical finding' then 'Condition'
		when c.concept_class='Model component' then 'Metadata'
		when c.concept_class='Observable entity' then 'Observation'
		when c.concept_class='Organism' then 'Observation'
		when c.concept_class='Pharmaceutical / biologic product' then 'Drug'
		else 'Manual'
	end as peak_domain
from concept_ancestor a, concept c
where a.ancestor_concept_id not in (
	select distinct descendant_concept_id from concept_ancestor where ancestor_concept_id!=descendant_concept_id
)
and c.concept_id=a.ancestor_concept_id and c.vocabulary_id=1
;

-- Start building domains
-- drop table domain;
create table domain as 
select concept_id, 'Not assigned' as snomed_domain from concept_stage where vocabulary_id=1 and invalid_reason is null;

-- Method 1: Assign domains to children of peak concepts in the order rank, and within of precedence
-- Assign the top peaks
update domain d set
	d.snomed_domain=child.peak_domain
from (
	select distinct 
		-- if there are two conflicting domains in the rank (both equally distant from the ancestor) then use precedence
		first_value(p.peak_domain) over (partition by a.descendant_concept_id order by decode(peak_domain,
			'Measurement', 1,
			'Procedure', 2,
			'Device', 3,
			'Condition', 4,
			'Provider', 5,
			'Drug', 6,
			'Gender', 7,
			'Race', 8,
			10) -- everything else is Observation
		) as peak_domain,
		a.descendant_concept_id as concept_id 
	from peak p, concept_ancestor a 
	where a.ancestor_concept_id=p.peak_id and p.ranked=1
) child
where child.concept_id=d.concept_id
;

select distinct peak_domain from peak;

-- Secondary in precedence
update domain d set
	d.snomed_domain=child.peak_domain
from (
	select distinct 
		first_value(p.peak_domain) over (partition by a.descendant_concept_id order by decode(peak_domain,
			'Measurement', 1,
			'Procedure', 2,
			'Device', 3,
			'Condition', 4,
			'Provider', 5,
			'Drug', 6,
			'Gender', 7,
			'Race', 8,
			10) -- everything else is Observation
		) as peak_domain,
		a.descendant_concept_id as concept_id 
	from peak p, concept_ancestor a 
	where a.ancestor_concept_id=p.peak_id and p.ranked=2
) child
where child.concept_id=d.concept_id
;

-- Tertiary
update domain d set
	d.snomed_domain=child.peak_domain
from (
	select distinct 
		first_value(p.peak_domain) over (partition by a.descendant_concept_id order by decode(peak_domain,
			'Measurement', 1,
			'Procedure', 2,
			'Device', 3,
			'Condition', 4,
			'Provider', 5,
			'Drug', 6,
			'Gender', 7,
			'Race', 8,
			10) -- everything else is Observation
		) as peak_domain,
		a.descendant_concept_id as concept_id 
	from peak p, concept_ancestor a 
	where a.ancestor_concept_id=p.peak_id and p.ranked=3
) child
where child.concept_id=d.concept_id
;

-- 4th
update domain d set
	d.snomed_domain=child.peak_domain
from (
	select distinct 
		first_value(p.peak_domain) over (partition by a.descendant_concept_id order by decode(peak_domain,
			'Measurement', 1,
			'Procedure', 2,
			'Device', 3,
			'Condition', 4,
			'Provider', 5,
			'Drug', 6,
			'Gender', 7,
			'Race', 8,
			10) -- everything else is Observation
		) as peak_domain,
		a.descendant_concept_id as concept_id 
	from peak p, concept_ancestor a 
	where a.ancestor_concept_id=p.peak_id and p.ranked=4 -- currently only 4 ranks
) child
where child.concept_id=d.concept_id
;

-- 5th
update domain d set
	d.snomed_domain=child.peak_domain
from (
	select distinct 
		first_value(p.peak_domain) over (partition by a.descendant_concept_id order by decode(peak_domain,
			'Measurement', 1,
			'Procedure', 2,
			'Device', 3,
			'Condition', 4,
			'Provider', 5,
			'Drug', 6,
			'Gender', 7,
			'Race', 8,
			10) -- everything else is Observation
		) as peak_domain,
		a.descendant_concept_id as concept_id 
	from peak p, concept_ancestor a 
	where a.ancestor_concept_id=p.peak_id and p.ranked=5 -- currently only 4 ranks
) child
where child.concept_id=d.concept_id
;

-- check orphans whether they contain mixed children. Watch for multipe concept_classes and domains in children. 
-- Add those to the peak table (including assigning domains to the various descendants) and let the standard method take care of the rest
select distinct orphan.concept_id, orphan.concept_name, child.concept_class, d.snomed_domain from (
	select distinct
		c.concept_id, concept_name
	from concept_ancestor a, concept c
	where a.ancestor_concept_id not in (
		select distinct descendant_concept_id from concept_ancestor where ancestor_concept_id!=descendant_concept_id
	)
	and c.concept_id=a.ancestor_concept_id and c.vocabulary_id=1
	and c.concept_id not in (select distinct peak_id from peak)
)	orphan
join concept_ancestor a on a.ancestor_concept_id=orphan.concept_id
join domain d on d.concept_id=a.descendant_concept_id
join concept child on child.concept_id=a.descendant_concept_id
order by 1;

-- Last resort method of assigning domains
update domain d set
	d.snomed_domain=decode(c.concept_class,
		'Clinical finding', 'Condition',
		'Procedure', 'Procedure',
		'Pharmaceutical / biological product', 'Drug',
		'Physical object', 'Device',
		'Model component', 'Metadata',
		'Observation'
	)
from concept c
where c.concept_id=d.concept_id and d.snomed_domain='Not assigned'
;

select  sd.snomed_domain sd, d.snomed_domain d, c.* from
concept c, snomed_domain sd, domain d
where c.concept_id=d.concept_id and c.concept_id=sd.concept_id
and d.snomed_domain!=sd.snomed_domain and sd.snomed_domain!='Not assigned'
;


select count(8) from domain where snomed_domain='Not assigned';

select c.* from domain d, concept c where c.concept_id=d.concept_id and d.snomed_domain='Not assigned' limit 100;
select * from concept where concept_id in (4310843, 4008453, 4309685);



create external table 'c:\Users\krfw864\Downloads\dump\snomed_domain.txt' 
using (delimiter ',' SkipRows 1 RemoteSource ODBC LogDir 'c:\Users\krfw864\Downloads\dump') as
select d.* from snomed_domain d 
;

create external table 'c:\Users\krfw864\Downloads\dump\concept_ancestor' 
using (delimiter ',' SkipRows 1 RemoteSource ODBC LogDir 'c:\Users\krfw864\Downloads\dump\') as
select * from concept_ancestor
;

/* below this is QA material
/******************************************************************************/

select snomed_domain,  count(8) from snomed_domain d, concept_stage c where c.CONCEPT_ID=d.concept_id and c.valid_start_date!='20140401' 
group by snomed_domain order by 2 desc;
select d.*, c.* from concept c, snomed_domain d where c.concept_id=d.concept_id 
and d.snomed_domain='Not assigned' 
limit 1000;

-- orphan concepts not in hierarchy
select * from concept_stage c 
where concept_id not in (
	select distinct ancestor_concept_id from concept_ancestor)
--and concept_class='Clinical finding' 
and invalid_reason is null
and vocabulary_id=1
and valid_start_date!='20140401'
limit 100;

-- check how often the hierarchy switches classes
select an.concept_class ancestor, de.concept_class descendant, count(8) 
from concept an, concept de, concept_ancestor a
where a.ancestor_concept_id=an.concept_id and a.descendant_concept_id=de.concept_id
and an.concept_class!=de.concept_class
and an.valid_start_date!='20140401' and de.valid_start_date!='20140401'
and an.vocabulary_id=1 and de.vocabulary_id=1
group by an.concept_class, de.concept_class
order by 3 desc;

-- check how often the hierarchy witches domains
select ad.snomed_domain ancestor, ed.snomed_domain descendant, count(8) 
from concept_stage an, snomed_domain ad, concept_stage de, snomed_domain ed, concept_ancestor a
where an.concept_id=ad.concept_id and de.concept_id=ed.concept_id
and a.ancestor_concept_id=an.concept_id and a.descendant_concept_id=de.concept_id
and ad.snomed_domain!=ed.snomed_domain
and an.valid_start_date!='20140401' and de.valid_start_date!='20140401' and ad.snomed_domain!='Observation'
group by ad.snomed_domain, ed.snomed_domain
order by 3 desc;

-- see where it changes domain
select distinct
 an.concept_name, an.concept_id, ad.snomed_domain, 
	de.concept_name, de.concept_id, ed.snomed_domain
from concept an, snomed_domain ad, concept de, snomed_domain ed, concept_ancestor a
where an.concept_id=ad.concept_id and de.concept_id=ed.concept_id
and a.ancestor_concept_id=an.concept_id and a.descendant_concept_id=de.concept_id
and ad.snomed_domain='Procedure' and ed.snomed_domain='Measurement'
-- and an.concept_name not in ('SNOMED CT July 2002 Release: 20020731 [R]', 'Special concept', 'Navigational concept', 'Context-dependent category', 'Context-dependent finding', 'Procedure', 'Procedure by method', 'Patient evaluation procedure')
order by de.concept_name
limit 1000;

select * from concept where concept_id=40484042;
select * from snomed_domain d, concept_stage c where d.concept_id=c.concept_id limit 100; --and d.snomed_domain='Clinical finding';

-- hierarchy down and up
select min_levels_of_separation min, d.snomed_domain, c.* from concept_ancestor a, concept c, snomed_domain d where a.ancestor_concept_id in (4022675) and c.concept_id=a.descendant_concept_id and c.concept_id=d.concept_id order by min_levels_of_separation, concept_name limit 1000;
select min_levels_of_separation min, d.snomed_domain, c.* from concept_ancestor a, concept c, snomed_domain d where a.descendant_concept_id in (4189436) and c.concept_id=a.ancestor_concept_id and c.concept_id=d.concept_id order by min_levels_of_separation limit 100;
-- relationships down and up
select d.snomed_domain, c.concept_id, c.concept_name, r.relationship_id 
from concept c, concept_relationship_stage r, snomed_domain d, relationship s
where r.concept_id_1 in (4114975) and c.concept_id=r.concept_id_2 and d.concept_id=c.concept_id 
and s.reverse_relationship=r.relationship_id and r.invalid_reason is null and s.defines_ancestry=1;
select d.snomed_domain, c.concept_id, c.concept_name, r.relationship_id, s.relationship_name
from concept c, concept_relationship_stage r, snomed_domain d, relationship s
where r.concept_id_1 in (4254514) and c.concept_id=r.concept_id_2 and d.concept_id=c.concept_id 
and s.relationship_id=r.relationship_id and r.invalid_reason is null and s.defines_ancestry=1;

select * from concept where concept_code='270999004';
select m.source_code, m.source_code_description, m.mapping_type, c.concept_id, c.concept_name, c.concept_class, d.snomed_domain
from icd9_to_snomed_fixed m
join snomed_domain d on d.concept_id=m.target_concept_id
join concept_stage c on c.concept_id=m.target_concept_id
where m.mapping_type='CONDITION' and d.snomed_domain='Clinical finding' 
;

-- find the chain
select up.min_levels_of_separation up, d.snomed_domain, c.* from concept c, concept_ancestor up, concept_ancestor down, snomed_domain d
where up.descendant_concept_id=4059164
and down.ancestor_concept_id=4008453 -- root-- 4322976 -- Procedure -- 441840 -- Clinical finding --  4008453 -- root
and up.ancestor_concept_id=down.descendant_concept_id
and c.concept_id=up.ancestor_concept_id
and d.concept_id=c.concept_id 
order by up.min_levels_of_separation;

-- check classes against domains
select s.concept_class, d.snomed_domain, count(8) from concept_stage s, snomed_domain d
where s.concept_id=d.concept_id
and s.valid_start_date < '2014-01-01' and s.invalid_reason=''
group by s.concept_class, d.snomed_domain
order by 3 desc
limit 100;

select s.*, d.snomed_domain from concept_stage s, snomed_domain d
where s.concept_id=d.concept_id
and s.valid_start_date < '2014-01-01' and s.invalid_reason=''
and s.concept_class='Clinical finding' and d.snomed_domain='Observation';

select oben.ancestor_concept_id top, r.concept_id_1 middle, r.concept_id_2 bottom, min_levels_of_separation top_to_middle from concept_ancestor oben
join concept_relationship_stage r on r.concept_id_1=oben.descendant_concept_id and r.invalid_reason is null
join concept_stage c on c.concept_id=r.concept_id_2 and c.invalid_reason is null and c.VOCABULARY_ID=1
join concept_stage m on m.CONCEPT_ID=r.concept_id_1 and m.INVALID_REASON is null and m.vocabulary_id=1
join relationship s on s.relationship_id=r.relationship_id and s.defines_ancestry=1
where not exists (
	select 1 from concept_ancestor unten where oben.ancestor_concept_id=unten.ancestor_concept_id and unten.descendant_concept_id=r.concept_id_2
	and unten.ancestor_concept_id!=unten.descendant_concept_id
)
and oben.ancestor_concept_id!=oben.descendant_concept_id
and oben.ancestor_concept_id=4008453
order by min_levels_of_separation;

select * from concept where concept_id in (4008453, 374009, 4182210);
select * from concept_ancestor where ancestor_concept_id=4008453 and descendant_concept_id in (374009, 4182210);
-- hierarchy down and up
select min_levels_of_separation min, d.snomed_domain, c.* from concept_ancestor a, concept c, snomed_domain d where a.ancestor_concept_id in (4138972) and c.concept_id=a.descendant_concept_id and c.concept_id=d.concept_id order by min_levels_of_separation, concept_name limit 1000;
select min_levels_of_separation min, d.snomed_domain, c.* from concept_ancestor a, concept c, snomed_domain d where a.descendant_concept_id in (4225025) and c.concept_id=a.ancestor_concept_id and c.concept_id=d.concept_id order by min_levels_of_separation limit 100;
-- relationships down and up
select d.snomed_domain, c.concept_id, c.concept_name, r.relationship_id 
from concept c, concept_relationship_stage r, snomed_domain d, relationship s
where r.concept_id_1 in (4225025) and c.concept_id=r.concept_id_1 and d.concept_id=c.concept_id 
and s.reverse_relationship=r.relationship_id and r.invalid_reason is null --and s.defines_ancestry=1
;
select d.snomed_domain, c.concept_id, c.concept_name, r.relationship_id, s.relationship_name
from concept c, concept_relationship_stage r, snomed_domain d, relationship s
where r.concept_id_1 in (4225025) and c.concept_id=r.concept_id_2 and d.concept_id=c.concept_id 
and s.relationship_id=r.relationship_id and r.invalid_reason is null -- and s.defines_ancestry=1
;
select * from relationship where relationship_id=227;




/*************************************************************/

-- check Read-to_snomed
select rts.source_code_description, rts.concept_name, rts.concept_code, rts.domain, d.snomed_domain
-- select count(8) 
from read_to_snomed rts, concept_stage c, snomed_domain d
where c.concept_id=d.concept_id and c.concept_code=rts.concept_code
and (case 
	when d.snomed_domain='observation' and rts.domain='observation' then 1
	when d.snomed_domain='condition_occurrence' and rts.domain='condition' then 1
	when d.snomed_domain='measurement' and rts.domain='lab test' then 1
	when d.snomed_domain='procedure_occurrence' and rts.domain='procedure' then 1
	else 0 end)=0
and c.valid_start_date!='01-APR-2014'
limit 1000;

-- find the chain
select up.min_levels_of_separation up, d.snomed_domain, c.concept_id, c.concept_name, c.concept_code 
from concept_stage c, concept_ancestor up, concept_ancestor down, snomed_domain d, concept_stage des
where des.concept_code='315364008'
-- and down.ancestor_concept_id=4322976 -- Procedure 
-- and down.ancestor_concept_id=441840 -- Clinical finding 
and down.ancestor_concept_id=4008453 -- root
-- and down.ancestor_concept_id=4196732 -- calculus observation
and up.ancestor_concept_id=down.descendant_concept_id
and c.concept_id=up.ancestor_concept_id
and d.concept_id=c.concept_id and des.concept_id=up.descendant_concept_id
order by up.min_levels_of_separation;




-- Create domain for those SNOMED concepts that have no domain assigned
insert into concept_domain
select 
  c.concept_id,
  case 
    when c.concept_class='Clinical finding' then 'Condition'
    when c.concept_class='Procedure' then 'Procedure'
    when c.concept_class='Pharmaceutical / biologic product' then 'Drug'
    when c.concept_class='Physical object' then 'Device'
    when c.concept_class='Model component' then 'Metadata'
    else 'Observation' 
  end as domain_name
from concept c where not exists (
  select 1 from concept_domain d where d.concept_id=c.concept_id
)
and vocabulary_id=1 and invalid_reason is null
;

select c.concept_class, c.valid_start_date, count(8) from concept c, snomed_domain d where d.concept_id=c.concept_id and d.domain_name='Not assigned'
group by c.concept_class, c.valid_start_date;

select d.domain_name, c.* from concept c, snomed_domain d where d.concept_id=c.concept_id and c.concept_class='Context-dependent category'
;

-- Manually fix 'Not assigned' 
update concept_domain d set
  d.domain_name=(select decode(c.concept_class,
    'Clinical finding', 'Condition',
    'Procedure', 'Procedure',
    'Pharmaceutical / biological product', 'Drug',
    'Physical object', 'Device',
    'Substance', 'Device',
    'Model component', 'Metadata',
    'Namespace concept', 'Metadata',
    'Observation'
  )
  from concept c
  where c.concept_id=d.concept_id 
)
where d.domain_name='Not assigned'
;

select * from concept_domain where domain_name='Not assigned';