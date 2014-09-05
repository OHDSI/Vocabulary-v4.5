/* Script to update all mapping_type (and later concepts) to records in CPT4
*/

-- Load table
-- drop table concept_domain; -- unless already exists from snomed;
create table concept_domain as
select 
  concept_id,
  concept_name as domain_name 
from concept where 1=0;

-- load Dima's cpt4 domain assignment file
-- drop table cpt4_domain;
create table cpt4_domain as
select 
  concept_id,
  concept_code,
  concept_name as domain_name,
  concept_name as secondary_domain
from concept where 1=0;

-- make secondary nullable
alter table cpt4_domain modify (secondary_domain null);

/* Use SQLLDR to load the file snomed_domain.txt
* the control file is snomed_domain.ctl
options (skip=1)
load data
infile cpt4_domain.txt
into table cpt4_domain
replace
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
concept_id,
concept_code,
domain_name,
secondary_domain
)
*/

select * from concept c where not exists (
  select 1 from cpt4_domain d where c.concept_id=d.concept_id
)
and c.vocabulary_id=4 and c.invalid_reason is null;
select * from concept where concept_id=2110981;
select * from cpt4_domain where concept_code='90686';