-- Fix all mapping types
-- drop table stcm;
create table stcm as
select distinct
  m.source_code, m.source_vocabulary_id, m.source_code_description, m.target_concept_id, m.target_vocabulary_id, 
    case
      when m.target_concept_id=0 then 'Unmapped'
      when source_vocabulary_id in (2, 3, 4, 5, 17, 18, 46) and target_vocabulary_id in (1, 4, 5) and d.domain_name is not null then d.domain_name
      when m.mapping_type='CONDITION-OBS' then 'Observation'
      when m.mapping_type='INDICATION' then 'Indication'
      when m.mapping_type='DRUG' then 'Drug'
      when m.mapping_type='PROCEDURE' then 'Procedure'
      when m.mapping_type='OBSERVATION' then 'Observation'
      when m.mapping_type='ETHNICITY' then 'Ethnicity'
      when m.mapping_type='COST' then 'Revenue code'
      when m.mapping_type='PROCEDURE DRUG' then 'Drug'
      when m.mapping_type='UNIT' then 'Unit'
      when m.mapping_type='RACE' then 'Race'
      when m.mapping_type='CONDITION' then 'Condition'
      when m.mapping_type='CONDITION-MEDDRA' then 'MedDRA'
      when m.mapping_type='OTHER' and source_vocabulary_id=17 then 'Drug' -- Read vaccinations
      when m.mapping_type='PLACE OF SERVICE' then 'Place of Service'
      when m.mapping_type='PROVIDER' then 'Provider'
      when m.mapping_type='CONDITION-PROCEDURE' then 'Procedure'
      when m.mapping_type='XXX' then 'Condition'
      when m.mapping_type='OTHER' then 'Condition'
      else m.mapping_type end
    as mapping_type, 
    m.primary_map, m.valid_start_date, m.valid_end_date, m.invalid_reason
from source_to_concept_map m
left outer join concept_domain d on d.concept_id=m.target_concept_id;

-- switch off indexes and constraints

-- replace source_to_concept_map
drop table source_to_concept_map;


create table source_to_concept_map as
select * from stcm;
-- drop table stcm;

select count(*) from source_to_concept_map;

create index source_to_concept_source_idx on source_to_concept_map (source_code asc) logging;
alter table source_to_concept_map add constraint xpksource_to_concept_map primary key (source_vocabulary_id,target_concept_id,source_code,valid_end_date)
using index logging;
alter table source_to_concept_map add check (primary_map in ('Y'));
alter table source_to_concept_map add check (invalid_reason in ('D', 'U'));
alter table source_to_concept_map add constraint source_to_concept_concept foreign key (target_concept_id) references concept (concept_id);
alter table source_to_concept_map add constraint source_to_concept_source_vocab foreign key (source_vocabulary_id) references vocabulary (vocabulary_id);

--Check out the resulting maps
select m.source_vocabulary_id, v.vocabulary_name, m.mapping_type, count(8) as cnt
from source_to_concept_map m, vocabulary v where m.source_vocabulary_id=v.vocabulary_id
group by m.source_vocabulary_id, v.vocabulary_name, m.mapping_type order by 1, 3;

