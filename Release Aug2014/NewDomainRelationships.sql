--The only allowable concepts for the GENDER_CONCEPT_ID field are defined as any descendants of the domain 'GENDER' (CONCEPT_ID = 1)
--There is no enforcement of allowable concepts in the GENDER_SOURCE_CONCEPT_ID field, but it must be a valid value in the CONCEPT table.

-- load relationship table
-- truncate table relationship;
/* SQLLDR using following script
 options (skip=1)
load data
infile relationship.txt
into table relationship
replace
fields terminated by ','
trailing nullcols
(
relationship_id,relationship_name,is_hierarchical,defines_ancestry,reverse_relationship
) 
*/

-- Define new relationships
insert into relationship (relationship_id, relationship_name, reverse_relationship, is_hierarchical, defines_ancestry)
values (359, 'Domain subsumes (OMOP)', 360, 1, 0);
insert into relationship (relationship_id, relationship_name, reverse_relationship, is_hierarchical, defines_ancestry)
values (360, 'Is a domain (OMOP)', 359, 0, 0);

-- deprecate null flavors for sex and race;
update concept set 
  valid_end_date='31-Jul-2014',
  invalid_reason='D'
where concept_id in (8521, 8522, 8551, 8552, 8570, 9178);

-- make all snomed active except drugs (concept_level=1)
update concept c set 
  c.concept_level=1
where c.vocabulary_id=1 and c.concept_level=0
and c.concept_class not in ('Substance', 'Pharmaceutical / biologic product')
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_1=c.concept_id and s.defines_ancestry=1
);

-- make all snomed active except the drugs (concept_level=2)
update concept c set 
  c.concept_level=2
where c.vocabulary_id=1 and c.concept_level=0
and c.concept_class not in ('Substance', 'Pharmaceutical / biologic product')
and exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_1=c.concept_id and s.defines_ancestry=1
);

-- make drugs inactive (concept_level=2)
update concept c set 
  c.concept_level=0
where c.vocabulary_id=1 
and c.concept_class in ('Substance', 'Pharmaceutical / biologic product')
;

-- Clean up first
delete from concept_relationship where relationship_id in (359, 360);

-- Define gender
insert into concept_relationship
select 
  2 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=12 and invalid_reason is null
;

-- Define race
insert into concept_relationship
select 
  3 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=13 and invalid_reason is null
;

-- Define ethnicity
insert into concept_relationship
select 
  4 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=44 and invalid_reason is null
;

-- Define observation_period_type
insert into concept_relationship
select 
  5 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=61
;

-- Define Death Type
insert into concept_relationship
select 
  6 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=45 and invalid_reason is null
;

-- Define Metadata
insert into concept_relationship
select 
  7 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Metadata'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Define Visit
insert into concept_relationship
select 
  8 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=24 and invalid_reason is null
;

-- Define Visit Type
insert into concept_relationship
select 
  9 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=62 and invalid_reason is null
;

-- Define Procedure
-- Vocabs 1, 4 and 5 - where we have domains
insert into concept_relationship
select distinct -- for some reasons concepts (2617178, 2617179, 2617490, 2617177) are duplicated
  10 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Procedure'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Add all of vocab 3
insert into concept_relationship
select 
  10 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=3 and invalid_reason is null
;

-- Define Procedure Type
insert into concept_relationship
select 
  11 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=38 and invalid_reason is null
;

-- Define Modifiers

-- Define Drug
insert into concept_relationship
select 
  13 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
where c.vocabulary_id in (8, 19, 20, 21, 22, 32) and c.invalid_reason is null
;

-- SNOMED Drugs (non-Standard)
insert into concept_relationship
select 
  13 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Drug'
where c.vocabulary_id=1 and c.invalid_reason is null
;


-- Define Drug Type
insert into concept_relationship
select 
  14 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=36 and invalid_reason is null
;

-- Define Route (see below, because needs to happen after those defined in concept_domain

-- Define Unit
insert into concept_relationship
select 
  16 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=11 and invalid_reason is null
;

-- Define Device
insert into concept_relationship
select 
  17 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Device'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Define Device Type
insert into concept_relationship
select 
  18 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=63 and invalid_reason is null
;

-- Define Condition
insert into concept_relationship
select 
  19 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Condition'
where c.vocabulary_id=1 and c.invalid_reason is null -- Conditions in HCPCS and CPT are obserations (usually quality metrics)
;

-- Define Condition Type
insert into concept_relationship 
select 
  20 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where vocabulary_id=37 and invalid_reason is null
;

-- Define Measurement
insert into concept_relationship
select distinct
  21 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Measurement'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Define Measurement type
insert into concept_relationship
select 
  22 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=64 and invalid_reason is null
;

-- Define Note Type
insert into concept_relationship
select 
  26 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=58 and invalid_reason is null
;

-- Define Observation
insert into concept_relationship
select distinct
  27 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Observation'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Define Observation Period Type
insert into concept_relationship
select 
  28 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=61 and invalid_reason is null
;

-- Define 'Place of service'
insert into concept_relationship
select 
  32 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=14 and invalid_reason is null
;

-- Define 'Provider specialty'
insert into concept_relationship
select 
  33 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=48 and invalid_reason is null
;

-- Define Currency
insert into concept_relationship
select 
  34 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=65 and invalid_reason is null
;

-- define Revenue code
insert into concept_relationship
select 
  35 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=43 and invalid_reason is null
;

-- Define Specimen
delete from concept_relationship where relationship_id=359 
and concept_id_2 in (select concept_id from concept where vocabulary_id=1 and concept_class='Specimen' and invalid_reason is null)
;

insert into concept_relationship
select 
  36 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=1 and concept_class='Specimen' and invalid_reason is null
;

-- Define Specimen type 37

-- Define Specimen anatomic site
delete from concept_relationship where relationship_id=359 
and concept_id_2 in (select concept_id from concept where vocabulary_id=1 and concept_class='Body structure' and invalid_reason is null)
;

insert into concept_relationship
select 
  38 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=1 and concept_class='Body structure' and invalid_reason is null
;

-- Define Generic 40

-- Define Specimen disease status
/* 
select *
from concept
where vocabulary_id = 1
and concept_class = 'Qualifier value'
and concept_name in ('malignant', 'normal','abnormal')
and invalid_reason is null;
*/

-- Define Route (after Procedure, Drug, Condition, Measurement, Device)
delete from concept_relationship where relationship_id=359 
and concept_id_2 in (4128792, 4128794, 4139962, 4136280, 4112421, 4231622, 4217202, 4115462, 4120036, 4157760, 4233974)
-- ('Intravenous','Oral','Rectal','Intramuscular use', 'Topical','Intravaginal', 'Inhalation', 'Intrathecal route', 'Nasal','Intraocular use', 'Subcutaneous', 'Urethral use')
;
 
insert into concept_relationship
select 
  15 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept 
where vocabulary_id=1 and concept_id in (4128792, 4128794, 4139962, 4136280, 4112421, 4231622, 4217202, 4115462, 4120036, 4157760, 4233974)
;

-- Define Measurement value operator
delete from concept_relationship where relationship_id=359 
and concept_id_2 in (4171755, 4172704, 4171754, 4171756, 4172703) -- <, <=, >, >=, =
;
 
insert into concept_relationship
select 
  23 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=1 and concept_id in (4171755, 4172704, 4171754, 4171756, 4172703)
;

-- Define Measurement value
delete from concept_relationship r where r.relationship_id=359 
and exists (
  select 1 from concept_ancestor a where r.concept_id_2=a.descendant_concept_id and a.ancestor_concept_id=4126535
)
;
 
insert into concept_relationship;
select c.*
--   24 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c, concept_ancestor a
where c.concept_id=a.descendant_concept_id and a.ancestor_concept_id=4126535 
;

-- Define Relationship (after Procedure, Drug, Condition, Measurement, Device)
delete from concept_relationship r where r.relationship_id=359 
and exists (
  select 1 from concept_ancestor a where r.concept_id_2=a.descendant_concept_id and a.ancestor_concept_id=4054070 -- "Relative"
)
;
 
insert into concept_relationship
select 
  31 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c, concept_ancestor a
where c.concept_id=a.descendant_concept_id and a.ancestor_concept_id=4054070 
;

-------------------------------
-- Reverse relationships
-- delete from concept_relationship where relationship_id=360;
insert into concept_relationship
select 
  concept_id_2 as concept_id_1,
  concept_id_1 as concept_id_2,
  360 as relationship_id,
  valid_start_date,
  valid_end_date,
  invalid_reason
from concept_relationship where relationship_id=359;