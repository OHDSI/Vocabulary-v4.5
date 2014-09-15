-- Run before snomed_domain, hcpcs_domain, cpt4_domain
-- drop table concept_domain;
create table concept_domain as
select 
  concept_id,
  concept_name as domain_name 
from concept where 1=0;

-- Checks
select v.vocabulary_name, d.domain_name, count(8) from vocabulary v, concept_domain d, concept c
where v.vocabulary_id=c.vocabulary_id and c.concept_id=d.concept_id
group by v.vocabulary_name, d.domain_name order by 1,2;

select d.domain_name, c.concept_class, count(8) from concept_domain d, concept c where c.concept_id=d.concept_id and c.vocabulary_id=1 and c.invalid_reason is null
group by d.domain_name, c.concept_class
order by 1,2;
