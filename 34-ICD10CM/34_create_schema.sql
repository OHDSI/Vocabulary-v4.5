/**************************************************************************
* Copyright 2014 Observational Health Data Sciences and Informatics (OHDSI)
* OMOP Standard Vocabulary V4.4
* 
* This is free and unencumbered software released into the public domain.
* 
* Anyone is free to copy, modify, publish, use, compile, sell, or
* distribute this software, either in source code form or as a compiled
* binary, for any purpose, commercial or non-commercial, and by any
* means.
* 
* In jurisdictions that recognize copyright laws, the author or authors
* of this software dedicate any and all copyright interest in the
* software to the public domain. We make this dedication for the benefit
* of the public at large and to the detriment of our heirs and
* successors. We intend this dedication to be an overt act of
* relinquishment in perpetuity of all present and future rights to this
* software under copyright law.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
* 
* For more information, please refer to <http://unlicense.org/>
**************************************************************************/

spool 34_create_schema_icd10cm_20140701.log;

create user icd10cm_20140701
 identified by 123 -- <password>
 default tablespace users
 temporary tablespace temp
 profile default
 account unlock;

 -- Roles
grant connect to icd10cm_20140701 ; 
  alter user icd10cm_20140701 default role all;
 
 -- System privileges 
grant create procedure to icd10cm_20140701;
grant create sequence to icd10cm_20140701;
grant create any index to icd10cm_20140701;
grant create database link to icd10cm_20140701;
grant create table to icd10cm_20140701;

grant create session to icd10cm_20140701;
 
 -- Tablespace quotas 
alter user icd10cm_20140701 quota unlimited on users;
 
 -- Dev privileges 
grant select, insert, update, delete on dev.concept to icd10cm_20140701; 
grant select, insert, update, delete on dev.concept_relationship to icd10cm_20140701;
grant select, insert, update, delete on dev.concept_ancestor to icd10cm_20140701;
grant select, insert, update, delete on dev.relationship to icd10cm_20140701;
grant select, insert, update, delete on dev.source_to_concept_map to icd10cm_20140701;
grant select, insert, update, delete on dev.vocabulary to icd10cm_20140701;

grant select on dev.seq_concept to icd10cm_20140701;

--drop table icd10cm_20140701.concept_stage;
create table icd10cm_20140701.concept_stage (
 concept_id integer null,
 concept_name varchar2(256) not null,
 vocabulary_id integer not null,
 concept_level number(3) null,
 concept_code varchar2(20) not null,
 concept_class varchar2(60) null
);

--drop table icd10cm_20140701.concept_ancestor_stage;
create table icd10cm_20140701.concept_ancestor_stage (
  concept_ancestor_map_id integer null,
  ancestor_concept_id integer not null,
  descendant_concept_id integer not null,
  max_levels_of_separation number(3) null,
  min_levels_of_separation number(3) null
);

--drop table icd10cm_20140701.concept_relationship_stage;
create table icd10cm_20140701.concept_relationship_stage (
  rel_id integer null,
  concept_id_1 integer not null,
  concept_id_2 integer not null,
  relationship_id integer not null
);

--drop table icd10cm_20140701.concept_synonym_stage;
create table icd10cm_20140701.concept_synonym_stage (
  concept_synonym_id integer null,
  concept_id integer not null,
  concept_synonym_name varchar2(1000) not null
);

--drop table icd10cm_20140701.relationship_type_stage;
create table icd10cm_20140701.relationship_type_stage (
  relationship_id integer not null,
  relationship_description varchar2(256) null
);

--drop table icd10cm_20140701.source_to_concept_map_stage;
create table icd10cm_20140701.source_to_concept_map_stage (
  source_to_concept_map_id number(9) null,
  source_code varchar2(20) not null,
  source_code_description varchar2(256) null,
  mapping_type varchar2(20) not null,
  target_concept_id number(8) not null,
  target_vocabulary_id integer not null,
  source_vocabulary_id integer not null
);

--drop table icd10cm_20140701.vocabulary_ref_stage;
create table icd10cm_20140701.vocabulary_ref_stage (
  vocabulary_name varchar2(256) not null,
  vocabulary_code varchar2(3) not null
);

create table icd10cm_20140701.concept_tree_stage (
  concept_ancestor_map_id integer,
  ancestor_concept_id integer not null,
  descendant_concept_id integer not null,
  max_levels_of_separation number(3),
  min_levels_of_separation number(3)
)
;

create index icd10cm_20140701.xac on icd10cm_20140701.concept_tree_stage (
  descendant_concept_id, ancestor_concept_id
);

create index icd10cm_20140701.xf_concept_stage_id on icd10cm_20140701.concept_stage (
  concept_id asc
);

create index icd10cm_20140701.xf_concept_stage_code2 on icd10cm_20140701.concept_stage (
  vocabulary_id asc,
  concept_code asc
);

create index icd10cm_20140701.xf_concept_stage_code on icd10cm_20140701.concept_stage (
  vocabulary_id asc,
  concept_level asc,
  concept_code asc
);

create index icd10cm_20140701.xf_cr_stage_ids on icd10cm_20140701.concept_relationship_stage (
  concept_id_1 asc,
  concept_id_2 asc
);

create index icd10cm_20140701.xf_cr_stage_id on icd10cm_20140701.concept_relationship_stage (
  relationship_id asc
);

create index icd10cm_20140701.xrel_stage_3cd on icd10cm_20140701.concept_relationship_stage (
  concept_id_1, relationship_id, concept_id_2
);

create index icd10cm_20140701.xrel_stage_2cd on icd10cm_20140701.concept_relationship_stage (
  concept_id_2, concept_id_1
);

create index icd10cm_20140701.xmap_stage_4cd on icd10cm_20140701.source_to_concept_map_stage (
  source_code,
  source_vocabulary_id,
  mapping_type,
  target_vocabulary_id
);

create index icd10cm_20140701.xac_2cd on icd10cm_20140701.concept_ancestor_stage (
  descendant_concept_id, ancestor_concept_id
);

create index icd10cm_20140701.xac_2cd_r on icd10cm_20140701.concept_ancestor_stage (
  ancestor_concept_id, descendant_concept_id
);

--------------------------------
-- Local only tables
-- Table v10_marked contains all maps for ICD-10-CM, and those that appeared in two data sources were manually checked
-- drop table icd10cm_20140701.v10_marked;
create table icd10cm_20140701.v10_marked (
  source_code varchar(40),
  checked varchar(1), -- wheter code was manually checked
  source_code_description varchar(256),
  target_concept_code varchar(40),
  target_concept_name varchar(256)
);

commit;
exit;

