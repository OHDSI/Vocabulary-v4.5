-- Define new relationships. Defines ancestry is set to 0, because ancestry constructor was not used. That might change.
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

-- make race and provider inactive
update concept c set 
  c.concept_level=0
where c.vocabulary_id=1 
and exists (
  select 1 from concept_domain d where d.concept_id=c.concept_id and d.domain_name in ('Race', 'Provider')
)
;

-- make OCPS-4 all level 1
update concept c set 
  c.concept_level=1
where c.vocabulary_id=55
;

/*********** Create domain relationships **************/
-- Switch off constraints
alter table concept_relationship drop constraint xpkconcept_relationship;
alter table concept_relationship drop constraint concept_rel_child_fk;
alter table concept_relationship drop constraint concept_rel_parent_fk;
alter table concept_relationship drop constraint concept_rel_rel_type_fk;

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

-- Define Observation period type
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

-- Add OMOP Domain
insert into concept_relationship
select 
  7 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=59 and invalid_reason is null
;

-- Add OMOP Relationship
insert into concept_relationship
select 
  7 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=66 and invalid_reason is null
;

-- Add OMOP vocabulary
insert into concept_relationship
select 
  7 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=67 and invalid_reason is null
;

-- Add OMOP Concept Class
insert into concept_relationship
select 
  7 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=68 and invalid_reason is null
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

-- Add all of OCPS-4
insert into concept_relationship
select 
  10 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=55 and invalid_reason is null
;

-- Add Meddra (only those whose children are uniquely pointing to a single domain)
insert into concept_relationship
select 
  10 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept
where invalid_reason is null -- Conditions in HCPCS and CPT are obserations (usually quality metrics)
and concept_id in (
  select concept_id from (
    select distinct meddra.concept_id, 
      count(distinct d.domain_name) over (partition by meddra.concept_id) as num_domains,
      case when first_value(d.domain_name) over (partition by meddra.concept_id order by decode(d.domain_name,
        'Procedure', 1, 2))='Procedure' then 1 else 0 end as there
    from concept meddra, concept_ancestor a, concept_domain d
    where meddra.concept_id=a.ancestor_concept_id and d.concept_id=a.descendant_concept_id and meddra.vocabulary_id=15
  ) where num_domains=1 and there=1
)
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
where c.vocabulary_id in (7, 8, 19, 20, 21, 22, 32) and c.invalid_reason is null
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

-- Add Meddra (only those whose children are uniquely pointing to a single domain)
insert into concept_relationship
select 
  17 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept
where invalid_reason is null -- Conditions in HCPCS and CPT are obserations (usually quality metrics)
and concept_id in (
  select concept_id from (
    select distinct meddra.concept_id, 
      count(distinct d.domain_name) over (partition by meddra.concept_id) as num_domains,
      case when first_value(d.domain_name) over (partition by meddra.concept_id order by decode(d.domain_name,
        'Device', 1, 2))='Device' then 1 else 0 end as there
    from concept meddra, concept_ancestor a, concept_domain d
    where meddra.concept_id=a.ancestor_concept_id and d.concept_id=a.descendant_concept_id and meddra.vocabulary_id=15
  ) where num_domains=1 and there=1
)
;


-- Define Device Type
insert into concept_relationship
select 
  18 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=63 and invalid_reason is null
;

-- Define Condition - vocabulary
insert into concept_relationship
select 
  19 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
join concept_domain d on c.concept_id=d.concept_id and d.domain_name='Condition'
where c.vocabulary_id=1 and c.invalid_reason is null -- Conditions in HCPCS and CPT are observations (usually quality metrics)
;

-- Add Meddra (only those whose children are uniquely pointing to a single domain)
insert into concept_relationship
select 
  19 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept
where invalid_reason is null -- Conditions in HCPCS and CPT are obserations (usually quality metrics)
and concept_id in (
  select concept_id from (
    select distinct meddra.concept_id, 
      count(distinct d.domain_name) over (partition by meddra.concept_id) as num_domains,
      case when first_value(d.domain_name) over (partition by meddra.concept_id order by decode(d.domain_name,
        'Condition', 1, 2))='Condition' then 1 else 0 end as there
    from concept meddra, concept_ancestor a, concept_domain d
    where meddra.concept_id=a.ancestor_concept_id and d.concept_id=a.descendant_concept_id and meddra.vocabulary_id=15
  ) where num_domains=1 and there=1
)
;

-- add SMQ
insert into concept_relationship
select 
  19 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=31 and invalid_reason is null
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

-- Add Meddra (only those whose children are uniquely pointing to a single domain)
insert into concept_relationship
select 
  21 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept
where invalid_reason is null -- Conditions in HCPCS and CPT are obserations (usually quality metrics)
and concept_id in (
  select concept_id from (
    select distinct meddra.concept_id, 
      count(distinct d.domain_name) over (partition by meddra.concept_id) as num_domains,
      case when first_value(d.domain_name) over (partition by meddra.concept_id order by decode(d.domain_name,
        'Measurement', 1, 2))='Measurement' then 1 else 0 end as there
    from concept meddra, concept_ancestor a, concept_domain d
    where meddra.concept_id=a.ancestor_concept_id and d.concept_id=a.descendant_concept_id and meddra.vocabulary_id=15
  ) where num_domains=1 and there=1
)
;

-- Add LOINC 
insert into concept_relationship
select 
  21 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept
where vocabulary_id=6 and invalid_reason is null
;

-- Add LOINC hierarchy
insert into concept_relationship
select 
  21 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept
where vocabulary_id=49 and invalid_reason is null
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

-- Add Meddra (only those whose children are uniquely pointing to a single domain)
insert into concept_relationship
select 
  27 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept
where invalid_reason is null -- Conditions in HCPCS and CPT are obserations (usually quality metrics)
and concept_id in (
  select concept_id from (
    select distinct meddra.concept_id, 
      count(distinct d.domain_name) over (partition by meddra.concept_id) as num_domains,
      case when first_value(d.domain_name) over (partition by meddra.concept_id order by decode(d.domain_name,
        'Observation', 1, 2))='Observation' then 1 else 0 end as there
    from concept meddra, concept_ancestor a, concept_domain d
    where meddra.concept_id=a.ancestor_concept_id and d.concept_id=a.descendant_concept_id and meddra.vocabulary_id=15
  ) where num_domains=1 and there=1
)
;

-- Add DRG, MDC, APC
insert into concept_relationship
select 
  27 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id in (40, 41, 42) and invalid_reason is null
;

-- Define Observation Type
insert into concept_relationship
select 
  28 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=39 and invalid_reason is null
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

-- Add NUCC
insert into concept_relationship
select 
  33 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=47 and invalid_reason is null
;

-- Add HES Specialty
insert into concept_relationship
select 
  33 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=57 and invalid_reason is null
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

-- Define Generic 40 (only null)
insert into concept_relationship (concept_id_1, concept_id_2, relationship_id, valid_start_date, valid_end_date, invalid_reason)
values (40, 0, 359, '1-Jan-1970', '31-Dec-2099', null)
;

-- Define Route (after Procedure, Drug, Condition, Measurement, Device)
delete from concept_relationship where relationship_id=359 
and concept_id_2 in (4128792, 4128794, 4139962, 4136280, 4112421, 4231622, 4217202, 4115462, 4120036, 4157760, 4233974)
-- ('Intravenous','Oral','Rectal','Intramuscular use','Topical','Intravaginal','Inhalation','Intrathecal route','Nasal','Intraocular use','Subcutaneous','Urethral use')
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
 
insert into concept_relationship
select 24 as concept_id_1, c.concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
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

-- 39: Define Specimen disease status
delete from concept_relationship where relationship_id=359 
and concept_id_2 in (4069590, 4066212, 4135493) -- ('malignant', 'normal', 'abnormal')
;

insert into concept_relationship
select 
  39 as concept_id_1, concept_id as concept_id_2, 359 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept
where concept_id in (4069590, 4066212, 4135493)
;

-- check completeness
select domain.domain_num, domain.domain_name, domain.cnt, c.concept_name as example_name from (
  select r.concept_id_1 as domain_num, c.concept_name as domain_name, count(8) as cnt 
  from concept_relationship r, concept c, concept c2
  where r.relationship_id=359 and c.concept_id=r.concept_id_1 and c2.concept_id=r.concept_id_2
  group by r.concept_id_1, c.concept_name
) domain
join (
  select distinct concept_id_1 as domain_num, first_value(concept_id_2) over (partition by concept_id_1) as example_id
  from concept_relationship 
  where relationship_id=359
) example on domain.domain_num=example.domain_num
join concept c on c.concept_id=example.example_id
order by 1;

select count(8) from concept_relationship where relationship_id=359;

-------------------------------
-- Reverse relationships
-- drop constraints first
alter table concept_relationship drop constraint xpkconcept_relationship;
alter table concept_relationship drop constraint concept_rel_child_fk;
alter table concept_relationship drop constraint concept_rel_parent_fk;
alter table concept_relationship drop constraint concept_rel_rel_type_fk;

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

alter table concept_relationship add constraint xpkconcept_relationship primary key (concept_id_1,concept_id_2,relationship_id)
using index logging;
alter table concept_relationship add check (invalid_reason in ('D', 'U'));
alter table concept_relationship add constraint concept_rel_child_fk foreign key (concept_id_2) references concept (concept_id);
alter table concept_relationship add constraint concept_rel_parent_fk foreign key (concept_id_1) references concept (concept_id);
alter table concept_relationship add constraint concept_rel_rel_type_fk foreign key (relationship_id) references relationship (relationship_id);

/*
-- add to concept_ancestor
insert into concept_ancestor;
select 
  r.concept_id_1 as ancestor_concept_id
  r.concept_id_2 as descendant_concept_id
  1 as min_levels_of_separation
  1 as max_levels_of_separation
from concept_relationship r
where relationship_id=359;

-- write max_levels_of_separation (only possible after we have all links to the domains
update table concept_ancestor a
  set max_levels_of_separation=(
    select max(b.max_levels_of_separation)+1 from concept_ancestor b, concept_relationship r 
    where a.descendant_concept_id=b.descendant_concept_id and a.ancestor_concept_id=r.concept_id_1 and b.ancestor_concept_id=r.concept_id_2
    and r.relationship_id=359
  )
  where exists (-- only those connecting to domain
    select 1 from concept domain where domain.concept_id=a.ancestor_concept_id and domain.vocabulary_id=59
  )
;
select * from vocabulary order by 1;
-- ancestry to self
insert into concept_ancestor 
  concept_id as ancestor_concept_id
  concept_id as descendant_concept_id
  0 as min_levels_of_separation
  09 as max_levels_of_separation
from concept_relationship 
where relationship_id=359;
*/

-- Change domain for types to metadata
