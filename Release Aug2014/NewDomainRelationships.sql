--The only allowable concepts for the GENDER_CONCEPT_ID field are defined as any descendants of the domain 'GENDER' (CONCEPT_ID = 1)
--There is no enforcement of allowable concepts in the GENDER_SOURCE_CONCEPT_ID field, but it must be a valid value in the CONCEPT table.

-- Define new relationships
insert into relationship (relationship_id, relationship_name, reverse_relationship, is_hierarchical, defines_ancestry)
values (359, 'Domain subsumes (OMOP)', 360, 1, 0);
insert into relationship (relationship_id, relationship_name, reverse_relationship, is_hierarchical, defines_ancestry)
values (360, 'Is a domain (OMOP)', null, 0, 0);

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
from concept where vocabulary_id=12;

-- Define race
insert into concept_relationship
select 
  3 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=13
;

-- Define ethnicity
insert into concept_relationship
select 
  4 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=44
;

-- Define observation_period_type
insert into concept_relationship
select 
  5 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=61
;

-- Define Death Type
insert into concept_relationship
select 
  6 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=45
;

-- Define Metadata
insert into concept_relationship;
select 
  7 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Metadata'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Define Visit
insert into concept_relationship
select 
  8 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=24
;

-- Define Visit Type
insert into concept_relationship
select 
  9 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=62
;

-- Define Procedure
-- Vocabs 1, 4 and 5 - where we have domains
insert into concept_relationship;
select 
  10 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Procedure'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Add all of vocab 3
insert into concept_relationship;
select 
  10 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=3
;

-- Define Procedure Type
insert into concept_relationship;
select 
  11 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=38
;

-- Define Modifiers

-- Define Drug
insert into concept_relationship;
select 
  13 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
where c.vocabulary_id in (8, 19, 20, 21, 22, 32) and c.invalid_reason is null
;

-- Define Drug Type
insert into concept_relationship
select 
  14 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=36 and invalid_reason is null
;

-- Define Route (see below, because needs to happen after those defined in concept_domain

-- Define Unit
insert into concept_relationship
select 
  16 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=11
;

-- Define Device
insert into concept_relationship;
select 
  17 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Device'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Define Device Type
insert into concept_relationship; 
select 
  18 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=63 and invalid_reason is null
;

-- Define Condition
insert into concept_relationship;
select 
  19 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Condition'
where c.vocabulary_id in (1) and c.invalid_reason is null
;

-- Define Condition Type
insert into concept_relationship; 
select 
  20 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=37 and invalid_reason is null
;

-- Define Measurement
insert into concept_relationship;
select 
  21 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Measurement'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Define Measurement type
insert into concept_relationship; 
select 
  22 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=64 and invalid_reason is null
;

-- Define Note Type
insert into concept_relationship
select 
  26 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=58 and invalid_reason is null
;

-- Define Observation
insert into concept_relationship;
select 
  27 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Observation'
where c.vocabulary_id in (1, 4, 5) and c.invalid_reason is null
;

-- Define Observation Period Type
insert into concept_relationship;
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

34, 'Currency'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

35, 'Revenue code'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

36, 'Specimen'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

37, 'Specimen type'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

38, 'Specimen anatomic site'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

39, 'Specimen disease status'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

40, 'Generic'




______________________________


--official set of SNOMED concepts belonging to the ROUTE domain
select *
from concept
where vocabulary_id = 1
and concept_class = 'Qualifier value'
and concept_name in ('Intravenous','Oral','Rectal','Intramuscular use', 'Topical','Intravaginal', 'Inhalation', 'Intrathecal route','Nasal','Intraocular use', 'Subcutaneous', 'Urethral use')


--official operator concepts
select *
from concept
where vocabulary_id = 1
and concept_class = 'Qualifier value'
and concept_name in ('Equal symbol =','Greater-than-or-equal symbol >=','Less-than-or-equal symbol <=','Less-than symbol <','Greater-than symbol >')
 and invalid_reason is null;



--official concepts for specimen
select *
from concept
where vocabulary_id = 1
and concept_class = 'specimen' and invalid_reason is null;


--official concepts for specimen anatomic site
select *
from concept
where vocabulary_id = 1
and concept_class = 'body structure' and invalid_reason is null;


--official concepts for specimen disease status
select *
from concept
where vocabulary_id = 1
and concept_class = 'Qualifier value'
and concept_name in ('malignant', 'normal','abnormal')
and invalid_reason is null and invalid_reason is null;

----------------------
-- Define Route (after Procedure, Drug, Condition, Measurement, Device)
delete from concept_relationship where relationship_id=359 
and concept_id_2 in (4128792, 4128794, 4139962, 4136280, 4112421, 4231622, 4217202)
;
 
insert into concept_relationship
select 
  15 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept 
where vocabulary_id=1 and concept_id in (4128792, 4128794, 4139962, 4136280, 4112421, 4231622, 4217202)
;

-- Define Measurement value operator
delete from concept_relationship where relationship_id=359 
and concept_id_2 in (4171755, 4172704, 4171754, 4171756, 4172703) -- <, <=, >, >=, =
;
 
insert into concept_relationship
select 
  23 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept 
where vocabulary_id=1 and concept_id in (4171755, 4172704, 4171754, 4171756, 4172703)
;

-- Define Measurement value
delete from concept_relationship r where r.relationship_id=359 
and exists (
  select 1 from concept_ancestor a where r.concept_id_2=a.descendant_concept_id and a.ancestor_concept_id=4126535
)
;
 
insert into concept_relationship;
select 
  24 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c, concept_ancestor a
where c.concept_id==a.descendant_concept_id and a.ancestor_concept_id=4126535 
;

-- Define Relationship (after Procedure, Drug, Condition, Measurement, Device)
delete from concept_relationship r where r.relationship_id=359 
and exists (
  select 1 from concept_ancestor a where r.concept_id_2=a.descendant_concept_id and a.ancestor_concept_id=4054070 -- "Relative"
)
;
 
insert into concept_relationship;
select 
  31 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c, concept_ancestor a
where c.concept_id=a.descendant_concept_id and a.ancestor_concept_id=4054070 
;
