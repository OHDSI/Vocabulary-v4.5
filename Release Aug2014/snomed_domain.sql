/* Script to update all mapping_type to records in SNOMED
*/

-- Load table (later build)
-- drop table concept_domain;
create table concept_domain as
select 
  concept_id,
  concept_name as domain_name 
from concept where 1=0;

/* Use SQLLDR to load the file snomed_domain.txt
* the control file is snomed_domain.ctl
options (skip=0)
load data
infile snomed_domain.txt
into table concept_domain
replace
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
concept_id,
domain_name
)
*/

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
and vocabulary_id=1
;

select * from concept_domain

-- Rename domain names 
update concept_domain set domain_name='Race' where domain_name='race';
update concept_domain set domain_name='Procedure' where domain_name='procedure_occurrence';
update concept_domain set domain_name='Observation' where domain_name='observation';
update concept_domain set domain_name='Provider specialty' where domain_name='provider';
update concept_domain set domain_name='Drug' where domain_name='drug_exposure';
update concept_domain set domain_name='Device' where domain_name='device_exposure';
update concept_domain set domain_name='Measurement' where domain_name='measurement';
update concept_domain set domain_name='Condition' where domain_name='condition_occurrence';

-- Now assign to all concept classes 

select distinct domain_name from concept_domain;
