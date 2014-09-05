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
LOAD DATA
INFILE icd9_to_concept_map.txt
INTO TABLE icd9_to_concept_map
REPLACE
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(
SOURCE_CODE,  
SOURCE_VOCABULARY_ID,
SOURCE_CODE_DESCRIPTION,
TARGET_CONCEPT_ID,
TARGET_VOCABULARY_ID,
MAPPING_TYPE,
PRIMARY_MAP NULLIF PRIMARY_MAP='NULL',
VALID_START_DATE DATE "YYYY-MM-DD",
VALID_END_DATE DATE "YYYY-MM-DD",
INVALID_REASON NULLIF INVALID_REASON='NULL'
)
*/


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

-- Deprecate those currently active target_concept_id that are no longer in the new list
update source_to_concept_map ol set
  ol.valid_end_date='31-JUL-2014',
  ol.invalid_reason='D'
where not exists (
  select 1 from icd9_to_concept_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and nw.source_vocabulary_id=2
  and nw.invalid_reason is null
)
and ol.source_vocabulary_id=2 and ol.target_vocabulary_id=1 and ol.invalid_reason is null ;

-- Add new records with target_concept_ids that weren't mappped to
insert into source_to_concept_map
select nw.source_code, nw.source_vocabulary_id, nw.source_code_description, nw.target_concept_id, nw.target_vocabulary_id, nw.mapping_type, nw.primary_map, '01-AUG-2014' as valid_start_date, nw.valid_end_date, nw.invalid_reason
from icd9_to_concept_map nw
where not exists (
  select 1 from source_to_concept_map ol where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.invalid_reason is null and ol.source_vocabulary_id=nw.source_vocabulary_id
)
and nw.invalid_reason is null 
;

-- Remove deprecated nulls
update source_to_concept_map isnull set
  isnull.valid_end_date='31-Jul-2014',
  isnull.invalid_reason='D'
where isnull.target_concept_id=0 -- delete the null of the pair
and exists (
  select 1 from source_to_concept_map notnull 
  join concept cnotnull on cnotnull.concept_id=notnull.target_concept_id
  where isnull.source_code=notnull.source_code and isnull.source_vocabulary_id=notnull.source_vocabulary_id and isnull.target_concept_id!=notnull.target_concept_id
)
and isnull.source_vocabulary_id=2 -- ICD9
;
