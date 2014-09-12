/* Script to update all mapping_type to records in SNOMED
*/

-- Load table (later build)
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
*/

-- Write into concept_domain
insert into concept_domain
select * from snomed_domain;

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