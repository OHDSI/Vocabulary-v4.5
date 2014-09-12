/* Script to update all mapping_type (and later concepts) to records in CPT4
*/

-- load Dima's cpt4 domain assignment file
-- drop table cpt4_domain;
create table cpt4_domain as
select 
  concept_id, -- contains the wrong concept_id > 600000000
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

-- check for missing coverage 
select * from concept c where not exists (
  select 1 from cpt4_domain d where c.concept_code=d.concept_code
)
and c.vocabulary_id=4 and c.invalid_reason is null;

-- write into concept_domain
insert into concept_domain
select c.concept_id, d.domain_name from cpt4_domain d, concept c 
where c.concept_code=d.concept_code and c.vocabulary_id=4
;


