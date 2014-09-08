/* Script to update ICD9 to SNOMED mapping
* using Dima's corrections
* execute in dev
*/

-- Load manual icd9_to_concept_map
-- drop table icd9_to_concept_map;
create table icd9_to_concept_map as
select * from source_to_concept_map where 1=0;

/* Use SQLLDR to load the file icd9_to_concept_map
* the control file is icd9_to_concept_map.ctl
load data
infile icd9_to_concept_map.txt
into table icd9_to_concept_map
replace
fields terminated by '\t'
trailing nullcols
(
source_code,  
source_vocabulary_id,
source_code_description,
target_concept_id,
target_vocabulary_id,
mapping_type,
primary_map nullif primary_map='null',
valid_start_date date "yyyy-mm-dd",
valid_end_date date "yyyy-mm-dd",
invalid_reason nullif invalid_reason='null'
)
*/

-- remove duplicate entries, where source_code, target_concept_id and valid_end_date are the same. Pick the earliest
delete from icd9_to_concept_map k
where not exists (
  select 1 from (
    select distinct source_code, target_concept_id, 
    first_value(valid_start_date) over (
      partition by source_code, target_concept_id, valid_end_date order by valid_start_date
    ) as start_date, 
    valid_end_date
    from icd9_to_concept_map
  ) kep 
  where kep.source_code=k.source_code and kep.start_date=k.valid_start_date 
    and kep.target_concept_id=k.target_concept_id and kep.valid_end_date=k.valid_end_date
) 
;


-- 1. Undeprecate deprecated records
update source_to_concept_map ol set
  ol.valid_end_date='31-DEC-2099',
  ol.invalid_reason=null
where exists (
  select 1 from icd9_to_concept_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.source_vocabulary_id=nw.source_vocabulary_id
  and ol.valid_start_date=nw.valid_start_date
  and ol.invalid_reason is not null and nw.invalid_reason is null
)
;

-- Update valid_end_date and invalid_reason (mostly deprecating) for the ones with the same valid_start_date
update source_to_concept_map ol set
  ol.valid_end_date=(select nw.valid_end_date from icd9_to_concept_map nw where ol.source_vocabulary_id=2 and ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.valid_start_date=nw.valid_start_date),
  ol.invalid_reason=(select nw.invalid_reason from icd9_to_concept_map nw where ol.source_vocabulary_id=2 and ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.valid_start_date=nw.valid_start_date)
where exists (
  select 1 from icd9_to_concept_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.valid_start_date=nw.valid_start_date and ol.valid_end_date!=nw.valid_end_date
)
and ol.source_vocabulary_id=2 and ol.target_vocabulary_id in (0,1);
  
/*
-- Deprecate those currently active target_concept_id that are no longer in the new list
update source_to_concept_map ol set
  ol.valid_end_date=to_date('20140630', 'YYYYMMDD'),
  ol.invalid_reason='D';
select * from source_to_concept_map ol
where not exists (
  select 1 from icd9_to_concept_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and nw.source_vocabulary_id=2
  and nw.invalid_reason is null
)
and ol.source_vocabulary_id=2 and ol.target_vocabulary_id=1 and ol.invalid_reason is null ;
*/

-- Add new records with target_concept_ids that weren't mappped to
insert into source_to_concept_map
select nw.source_code, nw.source_vocabulary_id, nw.source_code_description, nw.target_concept_id, nw.target_vocabulary_id, nw.mapping_type, nw.primary_map, 
nw.valid_start_date, nw.valid_end_date, nw.invalid_reason
from icd9_to_concept_map nw
where not exists (
  select 1 from source_to_concept_map ol where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id 
    and ol.invalid_reason is null and ol.source_vocabulary_id=2
)
and nw.invalid_reason is null 
;

-- set target_vocabulary_id to 0 where target_concept_id=0
update source_to_concept_map set
  target_vocabulary_id=0
where target_concept_id=0;

-- Remove deprecated nulls
delete from source_to_concept_map isnull
where exists (
  select 1 from source_to_concept_map notnull 
  join concept cnotnull on cnotnull.concept_id=notnull.target_concept_id
  where isnull.source_code=notnull.source_code and notnull.source_vocabulary_id=2 and notnull.target_concept_id!=0
)
and isnull.target_concept_id=0 -- delete the null of the pair
and isnull.source_vocabulary_id=2 and isnull.target_vocabulary_id=0 -- ICD9 to null
;

drop table icd9_to_concept_map;

-- Add last minute additions of ICD-9-CM codes without an active mapping
-- drop table missing_icd9_to_concept_map;
create table missing_icd9_to_concept_map as
select
  concept_code as source_code,
  concept_code as target_code
from concept where 1=0;

/* SQLLDR using the following ctl file
options (skip=1)
load data
infile missing_icd9_to_concept_map.txt
into table missing_icd9_to_concept_map
append
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
source_code,
target_code
)
*/

-- add to table
insert into source_to_concept_map
select distinct
  m.source_code,  
  2 as source_vocabulary_id,
  first_value(n.source_code_description) over (partition by m.source_code order by n.source_code_description),
  case when c.concept_id is null then 0 else c.concept_id end as target_concept_id,
  case when c.concept_id is null then 0 else 1 end as target_vocabulary_id,
  'XXX' as mapping_type,
  'Y' as primary_map,
  to_date('20140801', 'YYYYMMDD') as valid_start_date,
  to_date('20991231', 'YYYYMMDD') as valid_end_date,
  null as invalid_reason 
from missing_icd9_to_concept_map m
left outer join source_to_concept_map n on n.source_code=m.source_code and n.source_vocabulary_id=2
left outer join concept c on c.concept_code=m.target_code and c.vocabulary_id in (0, 1)
;

drop table missing_icd9_to_concept_map;