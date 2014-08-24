spool 21_create_schema_atc_20140701.log;

create user atc_20140701
 identified by 123 -- <password>
 default tablespace users
 temporary tablespace temp
 profile default
 account unlock;

 -- 1 role for who_atc_20120131
 grant connect to atc_20140701 ; 
 alter user atc_20140701 default role all;
 
 -- 5 system privileges for who_atc_20120131
 grant create procedure to atc_20140701;
 grant create sequence to atc_20140701;
 grant create any index to atc_20140701;
 grant create database link to atc_20140701;
 grant create table to atc_20140701;
 
 grant create session to atc_20140701;
 
 -- 1 tablespace quotas for who_atc_20120131
 alter user atc_20140701 quota unlimited on users;
 
 -- 6 dev privileges for who_atc_20120131
 grant select, insert, update, delete on dev.concept to atc_20140701;            
 grant select, insert, update, delete on dev.concept_relationship to atc_20140701;
 grant select, insert, update, delete on dev.concept_ancestor to atc_20140701;
 grant select, insert, update, delete on dev.relationship to atc_20140701;
 grant select, insert, update, delete on dev.source_to_concept_map to atc_20140701;
 grant select, insert, update, delete on dev.vocabulary to atc_20140701;
 
 grant select on dev.seq_concept  to atc_20140701;

--drop table atc_20140701.concept_stage;
create table atc_20140701.concept_stage(
concept_id      integer     null,
concept_name        varchar2(256)   not null,
vocabulary_id integer not null,
concept_level       number(3)   null,
concept_code        varchar2(20)    not null,
concept_class       varchar2(60)    null);

--drop table atc_20140701.concept_ancestor_stage;
create table atc_20140701.concept_ancestor_stage(
concept_ancestor_map_id     integer     null,
ancestor_concept_id     integer     not null,
descendant_concept_id       integer     not null,
max_levels_of_separation    number(3)   null,
min_levels_of_separation    number(3)   null);

--drop table atc_20140701.concept_relationship_stage;
create table atc_20140701.concept_relationship_stage(
rel_id     integer     null,
concept_id_1        integer     not null,
concept_id_2        integer     not null,
relationship_id     integer not null);

--drop table atc_20140701.concept_synonym_stage;
create table atc_20140701.concept_synonym_stage(
concept_synonym_id  integer     null,
concept_id      integer     not null,
concept_synonym_name    varchar2(1000)  not null);

--drop table atc_20140701.relationship_type_stage;
create table atc_20140701.relationship_type_stage(
relationship_id       integer not null,
relationship_description    varchar2(256)   null);

--drop table atc_20140701.source_to_concept_map_stage;
create table atc_20140701.source_to_concept_map_stage(
source_to_concept_map_id    number(9)   null,
source_code         varchar2(20)    not null,
source_code_description     varchar2(256)   null,
mapping_type            varchar2(20)    not null,
target_concept_id       number(8)   not null,
target_vocabulary_id      integer not null,
source_vocabulary_id      integer not null);

--drop table atc_20140701.vocabulary_ref_stage;
create table atc_20140701.vocabulary_ref_stage(
vocabulary_name     varchar2(256)   not null,
vocabulary_code     varchar2(3) not null);

create table atc_20140701.concept_tree_stage
(
  concept_ancestor_map_id   integer,
  ancestor_concept_id       integer             not null,
  descendant_concept_id     integer             not null,
  max_levels_of_separation  number(3),
  min_levels_of_separation  number(3)
)
;

create index atc_20140701.xac on atc_20140701.concept_tree_stage
(descendant_concept_id, ancestor_concept_id)
;

create index atc_20140701.xf_concept_stage_id on atc_20140701.concept_stage (
        concept_id                       asc);

create index atc_20140701.xf_concept_stage_code2 on atc_20140701.concept_stage (
        vocabulary_id          asc,
        concept_code                     asc);

create index atc_20140701.xf_concept_stage_code on atc_20140701.concept_stage (
        vocabulary_id          asc,
        concept_level                    asc,
        concept_code                     asc);

create index atc_20140701.xf_cr_stage_ids on atc_20140701.concept_relationship_stage (
        concept_id_1                     asc,
        concept_id_2                     asc);

create index atc_20140701.xf_cr_stage_id on atc_20140701.concept_relationship_stage (
        relationship_id                  asc);

create index atc_20140701.xrel_stage_3cd on atc_20140701.concept_relationship_stage (
        concept_id_1, relationship_id,  concept_id_2);

create index atc_20140701.xrel_stage_2cd on atc_20140701.concept_relationship_stage (
        concept_id_2, concept_id_1);

create index atc_20140701.xmap_stage_4cd on atc_20140701.source_to_concept_map_stage (
    source_code 
   ,source_vocabulary_id 
   ,mapping_type           
   ,target_vocabulary_id);
   
   

create index atc_20140701.xac_2cd on atc_20140701.concept_ancestor_stage
(descendant_concept_id, ancestor_concept_id)
;

create index atc_20140701.xac_2cd_r on atc_20140701.concept_ancestor_stage
(ancestor_concept_id, descendant_concept_id)
;

--------------------------------
-- drop table atc_20140701.atc_code;
create table atc_20140701.atc_code
(
  atc_code varchar(7),
  atc_description varchar(100)
);

drop table atc_20140701.atc_relationship;
create table atc_20140701.atc_relationship
(
  atc_code varchar(7),    -- a 7-digit ATC code
  rxnorm_concept_id number(38), -- the equivalent RxNorm ingredient
  combination varchar(1) -- if a 7-digit ATC code is a combination
);


exit;

