/* Script to update all mapping_type (and later concepts) to records in CPT4
*/

-- Load table
-- drop table concept_domain; -- unless already exists from snomed;
create table concept_domain as
select 
  concept_id,
  concept_name as domain_name 
from concept where 1=0;

-- load Dima's hcpcs domain assignment file
-- drop table hcpcs_domain;
create table hcpcs_domain as
select 
  concept_id, -- contains only fresh concepts
  concept_code,
  concept_class
from concept where 1=0;

/* Use SQLLDR to load the file snomed_domain.txt
* the control file is snomed_domain.ctl
options (skip=1)
load data
infile hcpcs_domain.txt
into table hcpcs_domain
replace
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
concept_id,
concept_code,
concept_class
)
*/

-- check for missing coverage 
select * from concept c where not exists (
  select 1 from hcpcs_domain d where c.concept_code=d.concept_code
)
and c.vocabulary_id=5 and c.invalid_reason is null;

-- write into concept_domain
insert into concept_domain
select 
  c.concept_id,
  case
    when d.concept_class='Medical service' then 'Observation'
    when d.concept_class='Quality metric' then 'Observation'
    when d.concept_class='Procedure drug' then 'Procedure'
    else d.concept_class
  end as domain_name
from hcpcs_domain d, concept c where c.concept_code=d.concept_code and c.vocabulary_id=5
;

