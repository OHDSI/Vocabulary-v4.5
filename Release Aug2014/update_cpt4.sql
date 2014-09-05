/* Script to update CPT4 mappings and relationships
* using Dima's corrections
* execute in dev
*/

-- add missiong CPT4 and fix descriptions
-- drop table cpt4;
create table cpt4 as
select 
  source_code,  
  source_code_description,
  source_vocabulary_id as len -- the very long ones excel prints as "#######"
from source_to_concept_map where 1=0;

/* Use SQLLDR to load the file cpt4.txt
* the control file is cpt4.ctl
OPTIONS (SKIP=1)
LOAD DATA
INFILE cpt4.txt
INTO TABLE cpt4
REPLACE
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
SOURCE_CODE,  
SOURCE_CODE_DESCRIPTION,
LEN
)
*/

-- update the descriptions in concept
update source_to_concept_map m set
  source_code_description=(
    select distinct source_code_description from cpt4 c where c.source_code=m.source_code
  )
where exists (
  select 1 from cpt4 c where c.source_code=m.source_code and m.source_vocabulary_id=4
  and c.len<256 -- the very long ones excel prints as "#######"
)
;

-- update the descriptions in source_to_concept_map
update concept c set
  concept_name=(
    select distinct source_code_description from cpt4 h where h.source_code=c.concept_code
  )
where exists (
  select 1 from cpt4 h where h.source_code=c.concept_code and c.vocabulary_id=4
  and h.len<256 -- the very long ones excel prints as "#######"
)
;

-- add missing ones 
insert into concept
select 
  dev.seq_concept.nextval as concept_id,
  h.source_code_description as concept_name,
  1 as concept_level,
  'CPT-4' as concept_class,
  4 as vocabulary_id,
  source_code as concept_code,
  '31-Jul-2014' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from cpt4 h 
where not exists (
  select 1 from concept c where h.source_code=c.concept_code and c.vocabulary_id=4
)
;

-- Create maps to self
insert into source_to_concept_map 
select 
 concept_code as source_code,
 4 as source_vocabulary_id,
 concept_name as source_code_desription,
 concept_id as target_concept_id,
 4 as target_vocabulary_id,
 'PROCEDURE' as mapping_type,
 'Y' as primary_map,
 valid_start_date,
 valid_end_date,
 invalid_reason
from concept 
where vocabulary_id=4 
and concept_code not in (select source_code from source_to_concept_map where source_vocabulary_id=4 and target_vocabulary_id=4)
and invalid_reason is null
;

drop table cpt4;

-- Load manual cpt4_to_rxnorm_map
-- These are procedure drugs, and these maps are in additions to maps to self
-- drop table cpt4_to_rxnorm_map;
create table cpt4_to_rxnorm_map as
select 
  source_code,  
  source_vocabulary_id,
  source_code_description,
  target_concept_id,
  target_vocabulary_id,
  mapping_type,
  primary_map
from source_to_concept_map where 1=0;

/* Use SQLLDR to load the file cpt4_to_rxnorm_map
* the control file is cpt4_rxnorm_map.ctl
OPTIONS (SKIP=1)
LOAD DATA
INFILE cpt4_to_rxnorm_map.txt
INTO TABLE cpt4_to_rxnorm_map
REPLACE
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
SOURCE_CODE,  
SOURCE_VOCABULARY_ID,
SOURCE_CODE_DESCRIPTION,
TARGET_CONCEPT_ID,
TARGET_VOCABULARY_ID,
MAPPING_TYPE,
PRIMARY_MAP NULLIF PRIMARY_MAP='NULL'
)
*/

-- 1. Undeprecate deprecated records
update source_to_concept_map ol set
  ol.valid_end_date='31-DEC-2099',
  ol.invalid_reason=null
where exists (
  select 1 from cpt4_to_rxnorm_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.source_vocabulary_id=nw.source_vocabulary_id
  and ol.invalid_reason is not null
)
;

-- Deprecate those currently active target_concept_id that are no longer in the new list
update source_to_concept_map ol set
  ol.valid_end_date='31-JUL-2014',
  ol.invalid_reason='D'
where not exists (
  select 1 from cpt4_to_rxnorm_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id
)
and ol.source_vocabulary_id=4 and ol.target_vocabulary_id=8 and ol.invalid_reason is null
;

-- Add new records with target_concept_ids that weren't mappped to
insert into source_to_concept_map
select distinct 
  nw.source_code, nw.source_vocabulary_id, nw.source_code_description, nw.target_concept_id, nw.target_vocabulary_id, 'PROCEDURE DRUG' as mapping_type, nw.primary_map, 
  '01-AUG-2014' as valid_start_date, '31-DEC-2099' as valid_end_date, null as invalid_reason
from cpt4_to_rxnorm_map nw
where not exists (
  select 1 from source_to_concept_map ol where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.invalid_reason is null and ol.source_vocabulary_id=nw.source_vocabulary_id
)
;

drop table cpt4_to_rxnorm_map;

-- Load manual cpt4_to_snomed_condition_map
-- These are conditions. Maps are *replacing* cpt4 code maps to self
-- drop table cpt4_to_snomed_condition_map;
create table cpt4_to_snomed_condition_map as
select 
  source_code,  
  source_vocabulary_id,
  source_code_description,
  target_concept_id,
  target_vocabulary_id,
  mapping_type,
  primary_map
from source_to_concept_map where 1=0
;

/* Use SQLLDR to load the file cpt4_to_snomed_condition_map
* the control file is cpt4_rxnorm_map.ctl
OPTIONS (SKIP=1)
LOAD DATA
INFILE cpt4_to_snomed_condition_map.txt
INTO TABLE cpt4_to_rxnorm_map
REPLACE
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
SOURCE_CODE,  
SOURCE_VOCABULARY_ID,
SOURCE_CODE_DESCRIPTION,
TARGET_CONCEPT_ID,
TARGET_VOCABULARY_ID,
MAPPING_TYPE,
PRIMARY_MAP NULLIF PRIMARY_MAP='NULL'
)
*/

-- 1. Undeprecate deprecated records
update source_to_concept_map ol set
  ol.valid_end_date='31-DEC-2099',
  ol.invalid_reason=null
where exists (
  select 1 from cpt4_to_snomed_condition_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.source_vocabulary_id=nw.source_vocabulary_id
  and ol.invalid_reason is not null
)
;

-- Deprecate those currently active target_concept_id that are no longer in the new list
update source_to_concept_map ol set
  ol.valid_end_date='31-JUL-2014',
  ol.invalid_reason='D'
where not exists (
  select 1 from cpt4_to_snomed_condition_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id
)
and ol.source_vocabulary_id=4 and ol.target_vocabulary_id=1 and ol.invalid_reason is null
;

/* Version 5 only
-- Deprecate those currently mapped to something other than snomed condition
update source_to_concept_map ol set
  ol.valid_end_date='31-JUL-2014',
  ol.invalid_reason='D'
where exists (
  select 1 from cpt4_to_snomed_condition_map nw 
  where ol.source_code=nw.source_code
)
and ol.source_vocabulary_id=4 and ol.target_vocabulary_id!=1 and ol.invalid_reason is null
;
*/

-- Add new records with target_concept_ids that weren't mappped to
insert into source_to_concept_map
select distinct 
  nw.source_code, nw.source_vocabulary_id, nw.source_code_description, nw.target_concept_id, nw.target_vocabulary_id, nw.mapping_type, nw.primary_map, 
  '01-AUG-2014' as valid_start_date, '31-DEC-2099' as valid_end_date, null as invalid_reason
from cpt4_to_snomed_condition_map nw
where not exists (
  select 1 from source_to_concept_map ol where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.invalid_reason is null and ol.source_vocabulary_id=nw.source_vocabulary_id
)
;

drop cpt4_to_snomed_condition_map;

-- Add relationship between CPT4 and SNOMED Procedures 
-- drop table cpt4_to_procedure_relationship;
create table cpt4_to_proc_relationship as
select 
  source_code as cpt4_code,
  source_code as snomed_code
from source_to_concept_map where 1=0;

/* Use SQLLDR to load both files
* the control file is cpt4_to_procedure_relationship.ctl
options (skip=1)
load data
infile cpt4_to_procedure_relationship.txt
into table cpt4_to_proc_relationship
append
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
cpt4_code,
snomed_code)
*/

-- Add to concept_relationship table unless exists
insert into concept_relationship
select 
  c1.concept_id as concept_id_1,
  c2.concept_id as concept_id_2,
  227 as relationship_id, /* SNOMED category to CPT-4 (OMOP) */
  '1-Aug-2014' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from cpt4_to_proc_relationship r
join concept c1 on c1.concept_code=r.snomed_code and c1.vocabulary_id=1
join concept c2 on c2.concept_code=r.cpt4_code and c2.vocabulary_id=4
where not exists (
  select 1 from concept_relationship o where o.concept_id_1=c1.concept_id and o.concept_id_2=c2.concept_id
);

-- and reverse
insert into concept_relationship
select 
  c2.concept_id as concept_id_1,
  c1.concept_id as concept_id_2,
  93 as relationship_id, /* SNOMED category to CPT-4 (OMOP) */
  '1-Aug-2014' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from cpt4_to_proc_relationship r
join concept c1 on c1.concept_code=r.snomed_code and c1.vocabulary_id=1
join concept c2 on c2.concept_code=r.cpt4_code and c2.vocabulary_id=4
where not exists (
  select 1 from concept_relationship o where o.concept_id_1=c2.concept_id and o.concept_id_2=c1.concept_id
);

drop table cpt4_to_proc_relationship;
