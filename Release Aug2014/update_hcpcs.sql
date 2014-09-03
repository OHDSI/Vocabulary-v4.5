/* Script to update HCPCS mappings and relationships
* using Dima's corrections
* execute in dev
*/

-- add missiong HCPCS and fix descriptions
-- drop table hcpcs;
create table hcpcs as
select 
  source_code,  
  source_code_description,
  source_vocabulary_id as len -- the very long ones excel prints as "#######"
from source_to_concept_map where 1=0;

/* Use SQLLDR to load the file hcpcs.txt
* the control file is hcpcs.ctl
OPTIONS (SKIP=1)
LOAD DATA
INFILE hcpcs.txt
INTO TABLE hcpcs
REPLACE
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
SOURCE_CODE,  
SOURCE_CODE_DESCRIPTION CHAR(1000) SUBSTR(:SOURCE_CODE_DESCRIPTION,1,255),
LEN
)
*/

-- Undeprecate those that were deprecated 20-Apr-2014 are are in list
update concept c set
  c.valid_end_date='31-Dec-2099',
  c.invalid_reason=null
where exists (
  select 1 from hcpcs h where h.source_code=c.concept_code and c.vocabulary_id=5
)
and c.vocabulary_id=5
and c.valid_end_date='20-Apr-2014'
;
  

-- update the descriptions in concept
update source_to_concept_map m set
  m.source_code_description=(
    select distinct h.source_code_description from hcpcs h where h.source_code=m.source_code 
  )
where exists (
  select 1 from hcpcs h where h.source_code=m.source_code and m.source_vocabulary_id=5
  and h.len<256 -- the very long ones excel prints as "#######"
)
;

-- update the descriptions in source_to_concept_map
update concept c set
  concept_name=(
    select distinct source_code_description from hcpcs h where h.source_code=c.concept_code
  )
where exists (
  select 1 from hcpcs h where h.source_code=c.concept_code 
  and h.len<256 -- the very long ones excel prints as "#######"
)
and c.vocabulary_id=5
;

-- Add missing ones 
insert into concept
select 
  dev.seq_concept.nextval as concept_id,
  h.source_code_description as concept_name,
  1 as concept_level,
  'HCPCS' as concept_class,
  5 as vocabulary_id,
  source_code as concept_code,
  '31-Jul-2014' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from hcpcs h 
where not exists (
  select 1 from concept c where h.source_code=c.concept_code and c.vocabulary_id=5
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
 'PROCEDURE' as mapping_type, -- the default
 'Y' as primary_map,
 valid_start_date,
 valid_end_date,
 invalid_reason
from concept 
where vocabulary_id=5 
and concept_code not in (select source_code from source_to_concept_map where source_vocabulary_id=5 and target_vocabulary_id=5)
and invalid_reason is null
;

drop table hcpcs;

-- Load manual hcpcs_to_rxnorm_map
-- These are procedure drugs, and these maps are in additions to maps to self
-- drop table hcpcs_to_rxnorm_map;
create table hcpcs_to_rxnorm_map as
select 
  source_code,  
  source_vocabulary_id,
  source_code_description,
  target_concept_id,
  target_vocabulary_id,
  mapping_type,
  primary_map
from source_to_concept_map where 1=0;

/* Use SQLLDR to load the file hcpcs_to_rxnorm_map
* the control file is hcpcs_rxnorm_map.ctl
OPTIONS (SKIP=1)
LOAD DATA
INFILE hcpcs_to_rxnorm_map.txt
INTO TABLE hcpcs_to_rxnorm_map
REPLACE
FIELDS TERMINATED BY ','
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
  select 1 from hcpcs_to_rxnorm_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.source_vocabulary_id=nw.source_vocabulary_id
  and ol.invalid_reason is not null
)
;
/* Codes weren't worked off a complete list 
-- Deprecate those currently active target_concept_id that are no longer in the new list
update source_to_concept_map ol set
  ol.valid_end_date='31-JUL-2014',
  ol.invalid_reason='D'
where not exists (
  select 1 from hcpcs_to_rxnorm_map nw 
  where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id
)
and ol.source_vocabulary_id=5 and ol.target_vocabulary_id=8 and ol.invalid_reason is null
;
*/

-- Add new records with target_concept_ids that weren't mappped to
insert into source_to_concept_map
select distinct 
  nw.source_code, nw.source_vocabulary_id, nw.source_code_description, nw.target_concept_id, nw.target_vocabulary_id, 'PROCEDURE DRUG' as mapping_type, nw.primary_map, 
  '01-AUG-2014' as valid_start_date, '31-DEC-2099' as valid_end_date, null as invalid_reason
from hcpcs_to_rxnorm_map nw
where not exists (
  select 1 from source_to_concept_map ol where ol.source_code=nw.source_code and ol.target_concept_id=nw.target_concept_id and ol.invalid_reason is null 
  and ol.source_vocabulary_id=nw.source_vocabulary_id
)
;

drop table hcpcs_to_rxnorm_map;

-- Load manual hcpcs_to_snomed_condition_map
-- These are conditions. Maps are *replacing* hcpcs code maps to self
-- drop table hcpcs_to_snomed_condition_map;
create table hcpcs_to_snomed_condition_map as
select 
  source_code,  
  source_vocabulary_id,
  source_code_description,
  source_code as target_concept_code,
  target_vocabulary_id,
  mapping_type,
  primary_map
from source_to_concept_map where 1=0;

/* Use SQLLDR to load the file hcpcs_to_snomed_condition_map
* the control file is hcpcs_rxnorm_map.ctl
OPTIONS (SKIP=1)
LOAD DATA
INFILE hcpcs_to_snomed_condition_map.txt
INTO TABLE hcpcs_to_rxnorm_map
REPLACE
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
SOURCE_CODE,  
SOURCE_VOCABULARY_ID,
SOURCE_CODE_DESCRIPTION CHAR(1000) "SUBSTR(:SOURCE_CODE_DESCRIPTION,1,255)",
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
  select 1 from hcpcs_to_snomed_condition_map nw 
  join concept c on c.concept_code=nw.target_concept_code and c.vocabulary_id=1
  where ol.source_code=nw.source_code and ol.target_concept_id=c.concept_id and ol.source_vocabulary_id=nw.source_vocabulary_id
  and ol.invalid_reason is not null
)
;

-- Deprecate those currently active target_concept_id that are no longer in the new list
update source_to_concept_map ol set
  ol.valid_end_date='31-JUL-2014',
  ol.invalid_reason='D'
where not exists (
  select 1 from hcpcs_to_snomed_condition_map nw 
  join concept c on c.concept_code=nw.target_concept_code and c.vocabulary_id=1
  where ol.source_code=nw.source_code and ol.target_concept_id=c.concept_id
)
and ol.source_vocabulary_id=5 and ol.target_vocabulary_id=1 and ol.invalid_reason is null
;

/*
-- Deprecate those currently mapped to something other than snomed condition
update source_to_concept_map ol set
  ol.valid_end_date='31-JUL-2014',
  ol.invalid_reason='D'
where exists (
  select 1 from hcpcs_to_snomed_condition_map nw 
  where ol.source_code=nw.source_code
)
and ol.source_vocabulary_id=5 and ol.invalid_reason is null
;
*/

-- Add new records with target_concept_ids that weren't mappped to
insert into source_to_concept_map
select distinct 
  nw.source_code, nw.source_vocabulary_id, nw.source_code_description, c.concept_id as target_concept_id, nw.target_vocabulary_id, nw.mapping_type, nw.primary_map, 
  '01-AUG-2014' as valid_start_date, '31-DEC-2099' as valid_end_date, null as invalid_reason
from hcpcs_to_snomed_condition_map nw
join concept c on c.concept_code=nw.target_concept_code and c.vocabulary_id=1
where not exists (
  select 1 from source_to_concept_map ol where ol.source_code=nw.source_code and ol.target_concept_id=c.concept_id and ol.invalid_reason is null 
  and ol.source_vocabulary_id=nw.source_vocabulary_id
)
;

drop table hcpcs_to_snomed_condition_map;

-- Add relationship between HCPCS and SNOMED Procedures and Measurements
-- drop table hcpcs_to_procedure_relationship;
create table hcpcs_to_proc_relationship as
select 
  concept_id_1,
  concept_id_2
from concept_relationship where 1=0;

-- drop table hcpcs_to_measurement_relationship;
create table hcpcs_to_meas_relationship as
select 
  concept_id_1,
  concept_id_2
from concept_relationship where 1=0;

/* Use SQLLDR to load both files
* the control file are hcpcs_to_measurement_relationship.ctl and hcpcs_to_procedure_relationship.ctl
OPTIONS (SKIP=1)
LOAD DATA
INFILE hcpcs_to_measurement_relationship.txt
INTO TABLE hcpcs_to_meas_relationship
APPEND
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
concept_id_1,
concept_id_2
)
*/

-- Add and fix relationships for these
update relationship set 
  relationship_name='SNOMED procedure subsumes HCPCS (OMOP)',
  is_hierarchical=1,
  defines_ancestry=1
where relationship_id=283;

update relationship set 
  relationship_name='HCPCS is a SNOMED procedure (OMOP)'
where relationship_id=284;

insert into relationship (relationship_id, relationship_name, is_hierarchical, defines_ancestry, reverse_relationship)
values (357, 'SNOMED measurement subsumes HCPCS (OMOP)', 1, 1, 358);
insert into relationship (relationship_id, relationship_name, is_hierarchical, defines_ancestry, reverse_relationship)
values (358, 'HCPCS is a SNOMED measurement (OMOP)', 0, 0, null);

-- Add new procedure records to concept_relationship
insert into concept_relationship
select distinct 
  nw.concept_id_1,
  nw.concept_id_2,
  284 as relationship_id,
  '1-Aug-2014' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from hcpcs_to_proc_relationship nw
;

-- and reverse
insert into concept_relationship
select distinct 
  nw.concept_id_2 as concept_id_1,
  nw.concept_id_1 as concept_id_2,
  283 as relationship_id,
  '1-Aug-2014' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from hcpcs_to_proc_relationship nw
;

-- Add new measurement records to concept_relationship
insert into concept_relationship
select distinct 
  nw.concept_id_1,
  nw.concept_id_2,
  358 as relationship_id,
  '1-Aug-2014' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from hcpcs_to_meas_relationship nw
;

-- Add new records to concept_relationship
insert into concept_relationship
select distinct 
  nw.concept_id_2 as concept_id_1,
  nw.concept_id_1 as concept_id_2,
  357 as relationship_id,
  '1-Aug-2014' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from hcpcs_to_meas_relationship nw
;

-- Add injections
insert into concept_relationship
select 
  4241075 as concept_id_1,
  concept_id as concept_id_2,
  283 as relationship_id,
  '1-Jan-1970' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from concept hcpcs
where hcpcs.vocabulary_id=5 and lower(hcpcs.concept_name) like 'injection%'
and not exists (
  select 1 from concept_relationship r where r.concept_id_1=4241075 and concept_id_2=hcpcs.concept_id and r.invalid_reason is null
);

insert into concept_relationship
select 
  concept_id as concept_id_1,
  4241075 as concept_id_2,
  284 as relationship_id,
  '1-Jan-1970' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from concept hcpcs
where hcpcs.vocabulary_id=5 and lower(hcpcs.concept_name) like 'injection%'
and not exists (
  select 1 from concept_relationship r where r.concept_id_2=4241075 and concept_id_1=hcpcs.concept_id and r.invalid_reason is null
);

-- Add infusions
insert into concept_relationship
select 
  4269838 as concept_id_1,
  concept_id as concept_id_2,
  283 as relationship_id,
  '1-Jan-1970' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from concept hcpcs
where hcpcs.vocabulary_id=5 and lower(hcpcs.concept_name) like 'infusion%'
and not exists (
  select 1 from concept_relationship r where r.concept_id_1=4269838 and concept_id_2=hcpcs.concept_id and r.invalid_reason is null
);

insert into concept_relationship
select 
  concept_id as concept_id_1,
  4269838 as concept_id_2,
  284 as relationship_id,
  '1-Jan-1970' as valid_start_date,
  '31-Dec-2099' as valid_end_date,
  null as invalid_reason
from concept hcpcs
where hcpcs.vocabulary_id=5 and lower(hcpcs.concept_name) like 'infusion%'
and not exists (
  select 1 from concept_relationship r where r.concept_id_2=4269838 and concept_id_1=hcpcs.concept_id and r.invalid_reason is null
);

drop table hcpcs_to_proc_relationship;
drop table hcpcs_to_meas_relationship;
