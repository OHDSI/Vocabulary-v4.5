/******************************************************************************
*
*  OMOP - Cloud Research Lab
*
*  Observational Medical Outcomes Partnership
*  (c) Foundation for the National Institutes of Health (FNIH)
*
*  Licensed under the Apache License, Version 2.0 (the "License"); you may not
*  use this file except in compliance with the License. You may obtain a copy
*  of the License at http://omop.fnih.org/publiclicense.
*
*  Unless required by applicable law or agreed to in writing, software
*  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
*  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. Any
*  redistributions of this work or any derivative work or modification based on
*  this work should be accompanied by the following source attribution: "This
*  work is based on work by the Observational Medical Outcomes Partnership
*  (OMOP) and used under license from the FNIH at
*  http://omop.fnih.org/publiclicense.
*
*  Any scientific publication that is based on this work should include a
*  reference to http://omop.fnih.org.
*
*  Date:           2012/07/06
*
*  Temporary Vocabulary tables.
*  Usage: 
*  echo "EXIT" | sqlplus System/<SystemPass>@DEV_VOCAB @01_create_schema.sql <SNOMED_User> <Pass_SNOMED_Realise_User>
*
******************************************************************************/



SPOOL 01_create_schema_&1..log;

CREATE USER &1. --SNOMED_20120131
 IDENTIFIED BY &2. --<password>
 DEFAULT TABLESPACE USERS
 TEMPORARY TABLESPACE TEMP
 PROFILE DEFAULT
 ACCOUNT UNLOCK;
 -- 1 Role for SNOMED_20120131
 GRANT CONNECT TO &1. --SNOMED_20120131;
 ALTER USER &1. DEFAULT ROLE ALL;
 -- 5 System Privileges for SNOMED_20120131
 GRANT CREATE PROCEDURE TO &1.;
 GRANT CREATE SEQUENCE TO &1.;
 GRANT CREATE ANY INDEX TO &1.;
 GRANT CREATE DATABASE LINK TO &1.;
 GRANT CREATE TABLE TO &1.;
 GRANT CREATE VIEW TO &1.;
 -- 1 Tablespace Quotas for SNOMED_20120131
 ALTER USER &1. QUOTA UNLIMITED ON USERS;
 
 -- 6 Dev Privileges for SNOMED_20120131
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.CONCEPT TO &1.;            
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.CONCEPT_RELATIONSHIP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.CONCEPT_ANCESTOR TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.RELATIONSHIP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.SOURCE_TO_CONCEPT_MAP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.VOCABULARY TO &1.;
 
 
 /*
  -- 5 Prd Privileges for SNOMED_20120131
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.CONCEPT TO &1.;            
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.CONCEPT_RELATIONSHIP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.CONCEPT_ANCESTOR TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.RELATIONSHIP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.SOURCE_TO_CONCEPT_MAP TO &1.;
 --*/

 GRANT SELECT ON DEV.SEQ_CONCEPT  TO &1.;

--DROP TABLE &1..CONCEPT_STAGE;
CREATE TABLE &1..CONCEPT_STAGE(
CONCEPT_ID      INTEGER     NULL,
CONCEPT_NAME        VARCHAR2(256)   NOT NULL,
VOCABULARY_ID INTEGER NOT NULL,
CONCEPT_LEVEL       NUMBER(3)   NULL,
CONCEPT_CODE        VARCHAR2(20)    NOT NULL,
CONCEPT_CLASS       VARCHAR2(60)    NULL);

--DROP TABLE &1..CONCEPT_ANCESTOR_STAGE;
CREATE TABLE &1..CONCEPT_ANCESTOR_STAGE(
CONCEPT_ANCESTOR_MAP_ID     INTEGER     NULL,
ANCESTOR_CONCEPT_ID     INTEGER     NOT NULL,
DESCENDANT_CONCEPT_ID       INTEGER     NOT NULL,
MAX_LEVELS_OF_SEPARATION    NUMBER(3)   NULL,
MIN_LEVELS_OF_SEPARATION    NUMBER(3)   NULL);

--DROP TABLE &1..CONCEPT_RELATIONSHIP_STAGE;
CREATE TABLE &1..CONCEPT_RELATIONSHIP_STAGE(
REL_ID     INTEGER     NULL,
CONCEPT_ID_1        INTEGER     NOT NULL,
CONCEPT_ID_2        INTEGER     NOT NULL,
RELATIONSHIP_ID     INTEGER NOT NULL);

--DROP TABLE &1..CONCEPT_SYNONYM_STAGE;
CREATE TABLE &1..CONCEPT_SYNONYM_STAGE(
CONCEPT_SYNONYM_ID  INTEGER     NULL,
CONCEPT_ID      INTEGER     NOT NULL,
CONCEPT_SYNONYM_NAME    VARCHAR2(1000)  NOT NULL);

--DROP TABLE &1..RELATIONSHIP_TYPE_STAGE;
CREATE TABLE &1..RELATIONSHIP_TYPE_STAGE(
RELATIONSHIP_ID       INTEGER NOT NULL,
RELATIONSHIP_DESCRIPTION    VARCHAR2(256)   NULL);

--DROP TABLE &1..SOURCE_TO_CONCEPT_MAP_STAGE;
CREATE TABLE &1..SOURCE_TO_CONCEPT_MAP_STAGE(
SOURCE_TO_CONCEPT_MAP_ID    NUMBER(9)   NULL,
SOURCE_CODE         VARCHAR2(20)    NOT NULL,
SOURCE_CODE_DESCRIPTION     VARCHAR2(256)   NULL,
MAPPING_TYPE            VARCHAR2(20)    NOT NULL,
TARGET_CONCEPT_ID       NUMBER(8)   NOT NULL,
TARGET_VOCABULARY_ID      INTEGER NOT NULL,
SOURCE_VOCABULARY_ID      INTEGER NOT NULL,
 PRIMARY_MAP              CHAR(1 BYTE));

--DROP TABLE &1..VOCABULARY_REF_STAGE;
CREATE TABLE &1..VOCABULARY_REF_STAGE(
VOCABULARY_NAME     VARCHAR2(256)   NOT NULL,
VOCABULARY_CODE     VARCHAR2(3) NOT NULL);

CREATE TABLE &1..CONCEPT_TREE_STAGE
(
  CONCEPT_ANCESTOR_MAP_ID   INTEGER,
  ANCESTOR_CONCEPT_ID       INTEGER             NOT NULL,
  DESCENDANT_CONCEPT_ID     INTEGER             NOT NULL,
  MAX_LEVELS_OF_SEPARATION  NUMBER(3),
  MIN_LEVELS_OF_SEPARATION  NUMBER(3)
)
;

CREATE INDEX &1..XANC ON &1..CONCEPT_ANCESTOR_STAGE
(DESCENDANT_CONCEPT_ID, ANCESTOR_CONCEPT_ID)
;

CREATE INDEX &1..XAC ON &1..CONCEPT_TREE_STAGE
(DESCENDANT_CONCEPT_ID, ANCESTOR_CONCEPT_ID)
;


CREATE INDEX &1..XF_CONCEPT_STAGE_ID ON &1..CONCEPT_STAGE (
        CONCEPT_ID                       ASC);

CREATE INDEX &1..XF_CONCEPT_STAGE_CODE2 ON &1..CONCEPT_STAGE (
        VOCABULARY_ID          ASC,
        CONCEPT_CODE                     ASC);

CREATE INDEX &1..XF_CONCEPT_STAGE_CODE ON &1..CONCEPT_STAGE (
        VOCABULARY_ID          ASC,
        CONCEPT_LEVEL                    ASC,
        CONCEPT_CODE                     ASC);

CREATE INDEX &1..XF_CR_STAGE_IDS ON &1..CONCEPT_RELATIONSHIP_STAGE (
        CONCEPT_ID_1                     ASC,
        CONCEPT_ID_2                     ASC);

CREATE INDEX &1..XF_CR_STAGE_ID ON &1..CONCEPT_RELATIONSHIP_STAGE (
        RELATIONSHIP_ID                  ASC);

CREATE INDEX &1..xrel_STAGE_3cd ON &1..CONCEPT_RELATIONSHIP_STAGE (
        CONCEPT_ID_1, RELATIONSHIP_ID,  CONCEPT_ID_2);

CREATE INDEX &1..xrel_STAGE_2cd ON &1..CONCEPT_RELATIONSHIP_STAGE (
        CONCEPT_ID_2, CONCEPT_ID_1);

CREATE INDEX &1..xmap_STAGE_4cd ON &1..SOURCE_TO_CONCEPT_MAP_STAGE (
    SOURCE_CODE 
   ,SOURCE_VOCABULARY_ID 
   ,MAPPING_TYPE           
   ,TARGET_VOCABULARY_ID);
   
   
CREATE TABLE &1..SCT2_DESC_FULL_EN_INT
(
 ID                  INTEGER, --VARCHAR2(18 BYTE),
 EFFECTIVETIME       VARCHAR2(8 BYTE),
 ACTIVE              VARCHAR2(1 BYTE),
 MODULEID            VARCHAR2(18 BYTE),
 CONCEPTID           VARCHAR2(256 BYTE),
 LANGUAGECODE        VARCHAR2(2 BYTE),
 TYPEID              VARCHAR2(18 BYTE),
 TERM                VARCHAR2(256 BYTE),
 CASESIGNIFICANCEID  VARCHAR2(256 BYTE)
)
TABLESPACE USERS
;

CREATE INDEX &1..X_DESC_2CD ON &1..SCT2_DESC_FULL_EN_INT
(CONCEPTID, MODULEID)
LOGGING
TABLESPACE USERS
;

CREATE INDEX &1..X_DESC_3CD ON &1..SCT2_DESC_FULL_EN_INT
(CONCEPTID, MODULEID, TERM)
LOGGING
TABLESPACE USERS
;

CREATE TABLE &1..SCT2_RELA_FULL_INT
(
 ID                        INTEGER,
 EFFECTIVETIME         VARCHAR2(8 BYTE),
 ACTIVE                VARCHAR2(1 BYTE),
 MODULEID              VARCHAR2(256 BYTE),
 SOURCEID              VARCHAR2(256 BYTE),
 DESTINATIONID         VARCHAR2(256 BYTE),
 RELATIONSHIPGROUP     INTEGER,
 TYPEID                INTEGER,
 CHARACTERISTICTYPEID  VARCHAR2(256 BYTE),
 MODIFIERID            VARCHAR2(256 BYTE)
)
TABLESPACE USERS
;

CREATE TABLE &1..MRCONSO
(
  CUI       CHAR(8 CHAR)                        NOT NULL,
  LAT       CHAR(3 CHAR)                        NOT NULL,
  TS        CHAR(1 CHAR)                        NOT NULL,
  LUI       VARCHAR2(10 CHAR)                   NOT NULL,
  STT       VARCHAR2(3 CHAR)                    NOT NULL,
  SUI       VARCHAR2(10 CHAR)                   NOT NULL,
  ISPREF    CHAR(1 CHAR)                        NOT NULL,
  AUI       VARCHAR2(9 CHAR)                    NOT NULL,
  SAUI      VARCHAR2(50 CHAR),
  SCUI      VARCHAR2(50 CHAR),
  SDUI      VARCHAR2(50 CHAR),
  SAB       VARCHAR2(20 CHAR)                   NOT NULL,
  TTY       VARCHAR2(20 CHAR)                   NOT NULL,
  CODE      VARCHAR2(50 CHAR)                   NOT NULL,
  STR       VARCHAR2(3000 CHAR)                 NOT NULL,
  SRL       INTEGER                             NOT NULL,
  SUPPRESS  CHAR(1 CHAR)                        NOT NULL,
  CVF       INTEGER
)
;

CREATE INDEX &1..X_SAB_SCUI_TTY ON &1..MRCONSO
(SAB, SCUI, TTY);

CREATE INDEX &1..X_SCUI_SAB ON &1..MRCONSO
(SCUI, SAB);


CREATE TABLE &1..SCT1_CONCEPTS
(
  CONCEPTID           VARCHAR2(256 BYTE),
  CONCEPTSTATUS       VARCHAR2(256 BYTE),
  FULLYSPECIFIEDNAME  VARCHAR2(256 BYTE),
  CTV3ID              VARCHAR2(9 BYTE),
  SNOMEDID            VARCHAR2(256 BYTE),
  ISPRIMITIVE         VARCHAR2(256 BYTE)
);

CREATE INDEX &1..X_CONCEPTID ON &1..SCT1_CONCEPTS
(CONCEPTID);

CREATE TABLE &1..sct1_Relationships_Core_INT
(
RELATIONSHIPID            INTEGER           ,    
CONCEPTID1                INTEGER           ,    
RELATIONSHIPTYPE          INTEGER           ,    
CONCEPTID2                INTEGER           ,    
CHARACTERISTICTYPE        INTEGER           ,    
REFINABILITY              INTEGER           ,    
RELATIONSHIPGROUP         INTEGER            
)
;

CREATE INDEX &1..X_rel_3cd ON &1..sct1_Relationships_Core_INT
(RELATIONSHIPTYPE, CONCEPTID1, CONCEPTID2);

CREATE INDEX &1..X_rel_id ON &1..SCT2_RELA_FULL_INT
(ID);

--DROP table der2_cRefset_AssRefFull_INT;
CREATE table &1..der2_cRefset_AssRefFull_INT
(
id         CHAR(256),    
effectiveTime    CHAR(256),    
active         INTEGER,    
moduleId     INTEGER,    
refsetId     INTEGER,    
referencedComponentId        INTEGER,    
targetComponent     INTEGER
);


CREATE table &1..der2_cRefset_AssRefFull_UK
(
id         CHAR(256),
effectiveTime    CHAR(256),
active         INTEGER,
moduleId     INTEGER,
refsetId     INTEGER,
referencedComponentId        INTEGER,
targetComponent     INTEGER
);



CREATE TABLE &1..SCT2_CONCEPT_FULL_INT
(
  ID             VARCHAR2(18 BYTE),
  EFFECTIVETIME  VARCHAR2(8 BYTE),
  ACTIVE         VARCHAR2(1 BYTE),
  MODULEID       VARCHAR2(18 BYTE),
  STATUSID       VARCHAR2(256 BYTE)
);

CREATE INDEX &1..X_CID ON &1..SCT2_CONCEPT_FULL_INT
(ID);



CREATE TABLE &1..SCT2_DESC_FULL_UK
(
 ID                  INTEGER, --VARCHAR2(18 BYTE),
  EFFECTIVETIME       VARCHAR2(8 BYTE),
   ACTIVE              VARCHAR2(1 BYTE),
    MODULEID            VARCHAR2(18 BYTE),
     CONCEPTID           VARCHAR2(256 BYTE),
      LANGUAGECODE        VARCHAR2(2 BYTE),
       TYPEID              VARCHAR2(18 BYTE),
        TERM                VARCHAR2(256 BYTE),
         CASESIGNIFICANCEID  VARCHAR2(256 BYTE)
         )
         TABLESPACE USERS
         ;
         
         CREATE INDEX &1..X_DESC_2CD_UK ON &1..SCT2_DESC_FULL_UK
         (CONCEPTID, MODULEID)
         LOGGING
         TABLESPACE USERS
         ;
         
         CREATE INDEX &1..X_DESC_3CD_UK ON &1..SCT2_DESC_FULL_UK
         (CONCEPTID, MODULEID, TERM)
         LOGGING
         TABLESPACE USERS
         ;
         
         CREATE TABLE &1..SCT2_RELA_FULL_UK
         (
          ID                        INTEGER,
           EFFECTIVETIME         VARCHAR2(8 BYTE),
            ACTIVE                VARCHAR2(1 BYTE),
             MODULEID              VARCHAR2(256 BYTE),
              SOURCEID              VARCHAR2(256 BYTE),
               DESTINATIONID         VARCHAR2(256 BYTE),
                RELATIONSHIPGROUP     INTEGER,
                 TYPEID                INTEGER,
                  CHARACTERISTICTYPEID  VARCHAR2(256 BYTE),
                   MODIFIERID            VARCHAR2(256 BYTE)
                   )
                   TABLESPACE USERS
                   ;
                   
                   CREATE INDEX &1..X_rel_id_uk ON &1..SCT2_RELA_FULL_UK
                   (ID);
                   
                   CREATE TABLE &1..SCT2_CONCEPT_FULL_UK
                   (
                     ID             VARCHAR2(18 BYTE),
                       EFFECTIVETIME  VARCHAR2(8 BYTE),
                         ACTIVE         VARCHAR2(1 BYTE),
                           MODULEID       VARCHAR2(18 BYTE),
                             STATUSID       VARCHAR2(256 BYTE)
                             );
                             
                             CREATE INDEX &1..X_CID_UK ON &1..SCT2_CONCEPT_FULL_UK
                             (ID);
                             
                             
                             

create view sct2_concept_full_merged as select * from sct2_concept_full_int union select * from sct2_concept_full_uk;
create view sct2_desc_full_merged as select * from sct2_desc_full_en_int union select * from sct2_desc_full_uk;
create view sct2_rela_full_merged as select * from sct2_rela_full_int union select * from sct2_rela_full_uk;
create view der2_cRefset_AssRefFull_merged as select * from der2_cRefset_AssRefFull_INT union select * from der2_cRefset_AssRefFull_UK;

grant alter on dev.seq_concept to &1.;

exit;

