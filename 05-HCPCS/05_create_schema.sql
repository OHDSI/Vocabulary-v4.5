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
*  echo "EXIT" | sqlplus System/<SystemPass>@DEV_VOCAB @05_create_schema.sql <HCPCS_User> <Pass_HCPCS_Realise_User>
*
******************************************************************************/



SPOOL 05_create_schema_&1..log;

--/*

CREATE USER &1. --HCPCS_20120131
 IDENTIFIED BY &2. --<password>
 DEFAULT TABLESPACE USERS
 TEMPORARY TABLESPACE TEMP
 PROFILE DEFAULT
 ACCOUNT UNLOCK;
 -- 1 Role for HCPCS_20120131
 GRANT CONNECT TO &1. --HCPCS_20120131;
 ALTER USER &1. DEFAULT ROLE ALL;
 -- 5 System Privileges for HCPCS_20120131
 GRANT CREATE PROCEDURE TO &1.;
 GRANT CREATE SEQUENCE TO &1.;
 GRANT CREATE ANY INDEX TO &1.;
 GRANT CREATE DATABASE LINK TO &1.;
 GRANT CREATE TABLE TO &1.;
 -- 1 Tablespace Quotas for HCPCS_20120131
 ALTER USER &1. QUOTA UNLIMITED ON USERS;
--*/ 

 -- 6 Dev Privileges for HCPCS_20120131
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.CONCEPT TO &1.;            
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.CONCEPT_RELATIONSHIP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.CONCEPT_ANCESTOR TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.RELATIONSHIP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.SOURCE_TO_CONCEPT_MAP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON DEV.VOCABULARY TO &1.;
 
 GRANT SELECT ON UMLS.MRCONSO TO &1.;
 GRANT SELECT ON UMLS.MRSAT TO &1.;
 
 
 
 /*
  -- 5 Prd Privileges for HCPCS_20120131
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.CONCEPT TO &1.;            
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.CONCEPT_RELATIONSHIP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.CONCEPT_ANCESTOR TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.RELATIONSHIP TO &1.;
 GRANT SELECT, INSERT, UPDATE, DELETE ON PRD.SOURCE_TO_CONCEPT_MAP TO &1.;
 --*/

 GRANT SELECT ON DEV.SEQ_CONCEPT  TO &1.;
 
 GRANT SELECT  ON PRD.CONCEPT TO &1.;

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


CREATE INDEX XAC ON CONCEPT_TREE_STAGE
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

CREATE TABLE &1..TXXANWEB_V3
(
  HCPC              VARCHAR2(9 BYTE),
  SEQ_NUM           VARCHAR2(16 BYTE),
  RIC               VARCHAR2(9 BYTE),
  LONG_DESCRIPTION  VARCHAR2(256 BYTE)
)
;

------------------
DROP TABLE &1..HD_REFINED;

CREATE TABLE &1..HD_REFINED
(
  DRUG      VARCHAR2(256 BYTE),
  STRENGTH  VARCHAR2(256 BYTE),
  ROUTE     VARCHAR2(256 BYTE),
  CODE      VARCHAR2(256 BYTE),
  REC_NO    INTEGER
);

Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Levalbuterol', '0.5 mg', 'INH', 'J7615 ', 5730);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Levetiracetam', '10 mg', 'J1953 ', 5731);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Levocarnitine', '1 g', 'IV', 'J1955 ', 5732);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Levofloxacin', '250 mg', 'IV', 'J1956 ', 5733);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Levoleucovorin', '0.5 mg', 'J0641 ', 5734);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Levonorgestrel', 'J7306 ', 5735);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Levonorgestrel', '52 mg', 'OTH', 'J7302 ', 5736);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Levorphanol', '2 mg', 'SC, IV', 'J1960 ', 5737);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Lidocaine', '10 mg', 'IV', 'J2001 ', 5738);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Lincomycin', '300 mg', 'IV', 'J2010 ', 5739);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Linezolid', '200 mg', 'IV', 'J2020 ', 5740);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Lorazepam', '2 mg', 'IM, IV', 'J2060 ', 5741);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('anti-thymocyte', '250 mg', 'IV', 'J7504 ', 5742);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('anti-thymocyte', '25 mg', 'IV', 'J7511', 5743);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Magnesium', '500 mg', 'J3475 ', 5744);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Mannitol', '25% in 50 ml', 'IV', 'J2150', 5745);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Mannitol', '5 mg', 'INH', 'J7665', 5746);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Mecasermin', '1 mg', 'J2170 ', 5747);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Mechlorethamine', '10 mg', 'IV', 'J9230 ', 5748);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Medroxyprogesterone', '50 mg', 'IM', 'J1051 ', 5749);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Medroxyprogesterone', '150 mg', 'IM', 'J1055 ', 5750);
Insert into &1..HD_REFINED
   (DRUG, ROUTE, CODE, REC_NO)
 Values
   ('Medroxyprogesterone', 'IM', 'J1056 ', 5751);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Melphalan', '50 mg', 'IV', 'J9245 ', 5752);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Melphalan', '2 mg', 'ORAL', 'J8600 ', 5753);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Meperidine', '100 mg', 'IM, IV, SC', 'J2175 ', 5754);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Meperidine', '50 mg', 'IM, IV', 'J2180 ', 5755);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Mepivacaine', '10 ml', 'VAR', 'J0670 ', 5756);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Meropenem', '100 mg', 'J2185 ', 5757);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Mesna', '200 mg', 'IV', 'J9209 ', 5758);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Metaproterenol', '10 mg', 'INH', 'J7667', 5759);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Metaproterenol', '10 mg', 'INH', 'J7668 ', 5760);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Metaproterenol', '10 mg', 'INH', 'J7669', 5761);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Metaproterenol', '10 mg', 'INH', 'J7670 ', 5762);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Metaraminol', '10 mg', 'IV, IM, SC', 'J0380 ', 5763);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Methacholine', '1 mg', 'J7674 ', 5764);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methadone', '10 mg', 'IM, SC', 'J1230 ', 5765);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methocarbamol', '10 ml', 'IV, IM', 'J2800 ', 5766);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methotrexate', '2.5 mg', 'ORAL', 'J8610 ', 5767);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methotrexate', '5 mg', 'IV, IM, IT, IA', 'J9250 ', 5768);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methotrexate', '50 mg', 'IV, IM, IT, IA', 'J9260 ', 5769);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methyldopate', '250 mg', 'IV', 'J0210 ', 5770);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methylprednisolone', '4 mg', 'ORAL', 'J7509 ', 5771);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methylprednisolone', '20 mg', 'IM', 'J1020 ', 5772);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methylprednisolone', '40 mg', 'IM', 'J1030 ', 5773);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methylprednisolone', '80 mg', 'IM', 'J1040 ', 5774);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methylprednisolone', '40 mg', 'IM, IV', 'J2920', 5775);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Methylprednisolone', '125 mg', 'IM, IV', 'J2930 ', 5776);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Metoclopramide', '10 mg', 'IV', 'J2765 ', 5777);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Micafungin', '1 mg', 'J2248 ', 5778);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Midazolam', '1 mg', 'IM, IV', 'J2250 ', 5779);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Milrinone', '5 mg', 'IV', 'J2260 ', 5780);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Minocycline', '1 mg', 'J2265 ', 5781);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Mitomycin', '5 mg', 'IV', 'J9280', 5782);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Mitoxantrone', '5 mg', 'IV', 'J9293 ', 5783);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Monoclonal', '5 mg', 'IV', 'J7505 ', 5784);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Morphine', '10 mg', 'IM, IV, SC', 'J2270 ', 5785);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Morphine', '100 mg', 'IM, IV, SC', 'J2271 ', 5786);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Morphine', '10 mg', 'SC, IM, IV', 'J2275 ', 5787);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Moxifloxacin', '100 mg', 'J2280 ', 5788);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Muromonab-CD3', '5 mg', 'IV', 'J7505', 5789);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Mycophenolic', '180 mg', 'J7518 ', 5790);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Mycophenolate', '250 mg', 'ORAL', 'J7517 ', 5791);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Nabilone', '1 mg', 'ORAL', 'J8650 ', 5792);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Nalbuphine', '10 mg', 'IM, IV, SC', 'J2300 ', 5793);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Naloxone', '1 mg', 'IM, IV, SC', 'J2310 ', 5794);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Naltrexone', '1 mg', 'J2315 ', 5795);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Nandrolone', '50 mg', 'IM', 'J2320 ', 5796);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Natalizumab', '1 mg', 'J2323 ', 5797);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Nelarabine', '50 mg', 'J9261 ', 5798);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Neostigmine', '0.5 mg', 'IM, IV, SC', 'J2710 ', 5799);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Nesiritide', '0.1 mg', 'J2325 ', 5800);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Octagam', '500 mg', 'J1568 ', 5801);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Octreotide', '1 mg', 'IM', 'J2353 ', 5802);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Octreotide', '0.025 mg', 'IV,SQ', 'J2354 ', 5803);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ofatumumab', '10 mg', 'J9302 ', 5804);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Olanzapine', '1 mg', 'J2358 ', 5805);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Omalizumab', '5 mg', 'J2357 ', 5806);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('OnabotulinumtoxinA', '1 IU', 'J0585 ', 5807);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ondansetron', '1 mg', 'IV', 'J2405 ', 5808);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ondansetron', '1 mg', 'ORAL', 'Q0162 ', 5809);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Oprelvekin', '5 mg', 'SC', 'J2355 ', 5810);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Orphenadrine', '60 mg', 'IV, IM', 'J2360 ', 5811);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Orthovisc', 'J7324 ', 5812);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Oxacillin', '250 mg', 'IM, IV', 'J2700 ', 5813);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Oxaliplatin', '0.5 mg', 'J9263 ', 5814);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Oxymorphone', '1 mg', 'IV, SC, IM', 'J2410 ', 5815);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Oxytetracycline', '50 mg', 'IM', 'J2460 ', 5816);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Oxytocin', '10 IU', 'IV, IM', 'J2590 ', 5817);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Paclitaxel', '30 mg', 'IV', 'J9265 ', 5818);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Paclitaxel', '1 mg', 'J9264 ', 5819);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Palifermin', '0.05 mg', 'J2425 ', 5820);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Paliperidone', '1 mg', 'J2426 ', 5821);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Palonosetron', '0.025 mg', 'J2469 ', 5822);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Pamidronate', '30 mg', 'IV', 'J2430 ', 5823);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Panitumumab', '10 mg', 'J9303 ', 5824);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Papaverine', '60 mg', 'IV, IM', 'J2440 ', 5825);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Paricalcitol', '0.001 mg', 'IV, IM', 'J2501 ', 5826);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Pegademase', '25 iu', 'J2504 ', 5827);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Pegaptinib', '0.3 mg', 'J2503 ', 5828);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Pegaspargase', '1 dose', 'IM, IV', 'J9266 ', 5829);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Pegfilgrastim', '6 mg', 'J2505 ', 5830);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Pegloticase', '1 mg', 'J2507 ', 5831);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Pemetrexed', '10 mg', 'J9305 ', 5832);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Penicillin', '100000 IU', 'IM', 'J0561 ', 5833);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Penicillin', '100000 IU', 'IM', 'J0558 ', 5834);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Penicillin', '600000 IU', 'IM, IV', 'J2540 ', 5835);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Penicillin', '600000 IU', 'IM, IV', 'J2510 ', 5836);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Pentamidine', '300 mg', 'INH', 'J2545', 5837);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Pentamidine', '300 mg', 'INH', 'J7676', 5838);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Pentastarch', '100 ml', 'J2513 ', 5839);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Pentazocine', '30 mg', 'IM, SC, IV', 'J3070 ', 5840);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Pentobarbital', '50 mg', 'IM, IV, OTH', 'J2515 ', 5841);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Pentostatin', '10 mg', 'IV', 'J9268 ', 5842);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Perphenazine', '5 mg', 'IM, IV', 'J3310 ', 5843);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Perphenazine', '4 mg', 'ORAL', 'Q0175 ', 5844);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Perphenazine', '8 mg', 'ORAL', 'Q0176 ', 5845);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Phenobarbital', '120 mg', 'IM, IV', 'J2560 ', 5846);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Phentolamine', '5 mg', 'IM, IV', 'J2760 ', 5847);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Phenylephrine', '1 ml', 'SC, IM, IV', 'J2370 ', 5848);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Phenytoin', '50 mg', 'IM, IV', 'J1165 ', 5849);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Phytonadione', '1 mg', 'IM, SC, IV', 'J3430', 5850);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Piperacillin', '1.125 g', 'IV', 'J2543 ', 5851);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Plasma', '1 IU', 'P9044 ', 5852);
Insert into &1..HD_REFINED
   (DRUG, ROUTE, CODE, REC_NO)
 Values
   ('Plasma', 'IV', 'P9023 ', 5853);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Plerixafor', '1 mg', 'J2562 ', 5854);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Plicamycin', '2.5 mg', 'IV', 'J9270 ', 5855);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Porfimer', '75 mg', 'IV', 'J9600 ', 5856);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Potassium chloride', '2 mEq', 'IV', 'J3480 ', 5857);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Pralatrexate', '1 mg', 'J9307 ', 5858);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Pralidoxime', '1 g', 'IV, IM, SC', 'J2730 ', 5859);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Prednisone', '5 mg', 'ORAL', 'J7506 ', 5860);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Prednisolone', '5 mg', 'ORAL', 'J7510 ', 5861);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Prednisolone', '1 ml', 'IM', 'J2650 ', 5862);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Privigen', '500 mg', 'J1459 ', 5863);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Procainamide', '1 g', 'IM, IV', 'J2690 ', 5864);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Prochlorperazine', '10 mg', 'IM, IV', 'J0780', 5865);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Prochlorperazine', '5 mg', 'ORAL', 'Q0164 ', 5866);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Prochlorperazine', '10 mg', 'ORAL', 'Q0165 ', 5867);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Progesterone', '50 mg', 'J2675 ', 5868);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Promazine', '25 mg', 'IM', 'J2950 ', 5869);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Promethazine', '50 mg', 'IM, IV', 'J2550 ', 5870);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Promethazine', '12.5 mg', 'ORAL', 'Q0169 ', 5871);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Promethazine', '25 mg', 'ORAL', 'Q0170 ', 5872);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Propranolol', '1 mg', 'IV', 'J1800 ', 5873);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Protamine', '10 mg', 'IV', 'J2720 ', 5874);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Protein C', '10 IU', 'J2724 ', 5875);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Protirelin', '0.25 mg', 'IV', 'J2725 ', 5876);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Pyridoxine', '100 mg', 'J3415 ', 5877);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Quinupristin', '500 mg', 'IV', 'J2770 ', 5878);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ranibizumab', '0.1 mg', 'J2778 ', 5879);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ranitidine', '25 mg', 'IV, IM', 'J2780 ', 5880);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Rasburicase', '0.5 mg', 'J2783', 5881);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Reclast', '1 mg', 'J3488 ', 5882);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Regadenoson', '0.1 mg', 'J2785 ', 5883);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Reteplase', '18.8 mg', 'IV', 'J2993 ', 5884);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Rho', 'J2791 ', 5885);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Rho', '0.3 mg', 'IM', 'J2790 ', 5886);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Rho', '50 mg', 'J2788 ', 5887);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Rho', '100 IU', 'IV', 'J2792 ', 5888);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Rhophylac', '100 IU', 'J2791 ', 5889);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Rilonacept', '1 mg', 'J2793 ', 5890);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('RimabotulinumtoxinB', '100 IU', 'J0587', 5891);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Risperidone', '0.5 mg', 'J2794 ', 5892);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Rituximab', '100 mg', 'IV', 'J9310 ', 5893);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Romidepsin', '1 mg', 'J9315 ', 5894);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Romiplostim', '0.01 mg', 'J2796 ', 5895);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ropivacaine', '1 mg', 'J2795 ', 5896);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Saline', '5% dextrose, 500 ml', 'IV', 'J7042', 5897);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Saline', '500 ml', 'IV, OTH', 'J7040', 5898);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Sargramostim', '0.05 mg', 'IV', 'J2820 ', 5899);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Sermorelin', '0.001 mg', 'Q0515 ', 5900);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Sincalide', '0.005 mg', 'J2805 ', 5901);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Sirolimus', '1 mg', 'Oral', 'J7520 ', 5902);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Sodium ferricgluconate', '12.5 mg', 'J2916 ', 5903);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Euflexxa', 'J7323 ', 5904);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Hyalgan', 'J7321 ', 5905);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Orthovisc', 'J7324 ', 5906);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Supartz', 'J7321', 5907);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Somatrem', '1 mg', 'J2940 ', 5908);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Somatropin', '1 mg', 'J2941 ', 5909);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Spectinomycin', '2 g', 'IM', 'J3320 ', 5910);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Streptokinase', '250000 IU', 'IV', 'J2995 ', 5911);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Streptomycin', '1 g', 'IM', 'J3000 ', 5912);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Streptozocin', '1 g', 'IV', 'J9320 ', 5913);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Strontium-89', '1 millicurie', 'A9600 ', 5914);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Succinylcholine', '20 mg', 'IV, IM', 'J0330 ', 5915);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Sumatriptan', '6 mg', 'SC', 'J3030 ', 5916);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Supartz', 'J7321 ', 5917);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Synvisc', '1 mg', 'J7325 ', 5918);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tacrolimus', '1 mg', 'ORAL', 'J7507 ', 5919);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Tacrolimus', '5 mg', 'J7525 ', 5920);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Telavancin', '10 mg', 'J3095 ', 5921);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Temozolomide', '1 mg', 'J9328 ', 5922);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Temozolomide', '5 mg', 'ORAL', 'J8700 ', 5923);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Temsirolimus', '1 mg', 'J9330 ', 5924);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Tenecteplase', '1 mg', 'J3101 ', 5925);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Teniposide', '50 mg', 'Q2017 ', 5926);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Terbutaline', '1 mg', 'SC, IV', 'J3105 ', 5927);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Terbutaline', '1 mg', 'INH', 'J7680', 5928);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Terbutaline', '1 mg', 'INH', 'J7681', 5929);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Teriparatide', '0.01 mg', 'J3110 ', 5930);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Testosterone', '1 ml', 'IM', 'J0900 ', 5931);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Testosterone', '100 mg', 'IM', 'J3120', 5932);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Testosterone', '200 mg', 'IM', 'J3130 ', 5933);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Testosterone', '100 mg', 'IM', 'J1070 ', 5934);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Testosterone', '1 ml', 'IM', 'J1080 ', 5935);
Insert into &1..HD_REFINED
   (DRUG, ROUTE, CODE, REC_NO)
 Values
   ('Testosterone', 'IM', 'J1060 ', 5936);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Testosterone', '100 mg', 'IM', 'J3150 ', 5937);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Testosterone', '50 mg', 'IM', 'J3140 ', 5938);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tetanus', '250 IU', 'IM', 'J1670 ', 5939);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tetracycline', '250 mg', 'IM, IV', 'J0120 ', 5940);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Thallous', '1 MCI', 'A9505 ', 5941);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Theophylline', '40 mg', 'IV', 'J2810 ', 5942);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Thiamine', '100 mg', 'J3411 ', 5943);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Thiethylperazine', '10 mg', 'IM', 'J3280 ', 5944);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Thiethylperazine', '10 mg', 'ORAL', 'Q0174 ', 5945);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Thiotepa', '15 mg', 'IV', 'J9340 ', 5946);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Thyrotropin', '0.9 mg', 'IM, SC', 'J3240 ', 5947);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Tigecycline', '1 mg', 'J3243 ', 5948);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tinzaparin', '1000 IU', 'SC', 'J1655 ', 5949);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tirofiban', '0.25 mg', 'IM, IV', 'J3246 ', 5950);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tobramycin', '300 mg', 'INH', 'J7682', 5951);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tobramycin', '300 mg', 'INH', 'J7685 ', 5952);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tobramycin', '80 mg', 'IM, IV', 'J3260 ', 5953);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Tocilizumab', '1 mg', 'J3262 ', 5954);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Tolazoline', '25 mg', 'IV', 'J2670 ', 5955);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Topotecan', '0.25 mg', 'Oral', 'J8705 ', 5956);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Topotecan', '0.1 mg', 'IV', 'J9351', 5957);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Torsemide', '10 mg', 'IV', 'J3265 ', 5958);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Trastuzumab', '10 mg', 'IV', 'J9355 ', 5959);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Treprostinil', '1 mg', 'J3285 ', 5960);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Triamcinolone', '1 mg', 'INH', 'J7683 ', 5961);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Triamcinolone', '1 mg', 'INH', 'J7684', 5962);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Triamcinolone', '1 mg', 'J3300 ', 5963);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Triamcinolone', '10 mg', 'IM', 'J3301 ', 5964);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Triamcinolone', '5 mg', 'IM', 'J3302 ', 5965);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Triamcinolone', '5 mg', 'VAR', 'J3303 ', 5966);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Triflupromazine', '20 mg', 'IM, IV', 'J3400 ', 5967);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Trimethobenzamide', '200 mg', 'IM', 'J3250 ', 5968);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Trimethobenzamide', '250 mg', 'ORAL', 'Q0173 ', 5969);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Trimetrexate', '25 mg', 'IV', 'J3305 ', 5970);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Triptorelin', '3.75 mg', 'J3315 ', 5971);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Urea', '40 g', 'IV', 'J3350 ', 5972);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Urofollitropin', '75 iu', 'J3355 ', 5973);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Urokinase', '5000 IU', 'IV', 'J3364 ', 5974);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Urokinase', '250000 IU', 'IV', 'J3365 ', 5975);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ustekinumab', '1 mg', 'J3357 ', 5976);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Valrubicin', '200 mg', 'OTH', 'J9357 ', 5977);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Vancomycin', '500 mg', 'IV, IM', 'J3370 ', 5978);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Velaglucerase', '100 IU', 'J3385 ', 5979);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Verteporfin', '0.1 mg', 'IV', 'J3396 ', 5980);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Vinblastine', '1 mg', 'IV', 'J9360 ', 5981);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Vincristine', '1 mg', 'IV', 'J9370 ', 5982);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Vinorelbine', '10 mg', 'IV', 'J9390 ', 5983);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('menadiol', '1 mg', 'IM, SC, IV', 'J3430 ', 5984);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Vitamin B-12', '1 mg', 'IM, SC', 'J3420 ', 5985);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Von', '1 IU', 'IV', 'J7187 ', 5986);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Von', '100 IU', 'IV', 'J7183 ', 5987);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Voriconazole', '10 mg', 'J3465 ', 5988);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ziconotide', '0.001 mg', 'J2278 ', 5989);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Zidovudine', '10 mg', 'IV', 'J3485 ', 5990);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ziprasidone', '10 mg', 'J3486 ', 5991);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Zoledronic', '1 mg', 'J3487 ', 5992);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Zometa', '1 mg', 'J3487 ', 5993);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Abatacept', '10 mg', 'J0129 ', 5341);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Abciximab', '10 mg', 'IV', 'J0130 ', 5342);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('AbobotulinumtoxintypeA', '5 IU', 'J0586 ', 5343);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Acetaminophen', '10 mg', 'J0131 ', 5344);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Acetazolamide', '500 mg', 'IM, IV', 'J1120 ', 5345);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Acetylcysteine', '100 mg', 'J0132 ', 5346);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Acetylcysteine', '1 g', 'INH', 'J7604', 5347);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Acetylcysteine', '1 g', 'INH', 'J7608 ', 5348);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Acyclovir', '5 mg', 'J0133 ', 5349);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Adalimumab', '20 mg', 'J0135 ', 5350);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Adenosine', '6 mg', 'IV', 'J0150 ', 5351);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Adenosine', '30 mg', 'IV', 'J0152 ', 5352);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Adrenalin', '0.1 mg', 'SC, IM', 'J0171 ', 5353);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Agalsidase', '1 mg', 'J0180 ', 5354);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Alatrofloxacin', '100 mg', 'IV', 'J0200 ', 5355);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Albuterol', '0.5 mg', 'INH', 'J7620 ', 5356);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Albuterol', '1 mg', 'INH', 'J7610', 5357);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Albuterol', '1 mg', 'INH', 'J7611 ', 5358);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Albuterol', '1 mg', 'INH', 'J7609', 5359);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Albuterol', '1 mg', 'INH', 'J7613', 5360);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Aldesleukin', '1 use', 'IM, IV', 'J9015 ', 5361);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Alefacept', '0.5 mg', 'J0215 ', 5362);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Alemtuzumab', '10 mg', 'J9010 ', 5363);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Alglucerase', '10 IU', 'IV', 'J0205 ', 5364);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Alglucosidase', '10 mg', 'J0220', 5365);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Alglucosidase', '10 mg', 'J0221 ', 5366);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Alpha', '10 mg', 'IV', 'J0256', 5367);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Alpha', '10 mg', 'IV', 'J0257 ', 5368);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Alphanate', 'J7186 ', 5369);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Alprostadil', '0.00125 mg', 'OTH', 'J0270 ', 5370);
Insert into &1..HD_REFINED
   (DRUG, ROUTE, CODE, REC_NO)
 Values
   ('Alprostadil', 'OTH', 'J0275 ', 5371);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Alteplase', '1 mg', 'IV', 'J2997 ', 5372);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Amifostine', '500 mg', 'IV', 'J0207 ', 5373);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Amikacin', '100 mg', 'J0278 ', 5374);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Aminolevalinic', '1 IU', 'OTH', 'J7308 ', 5375);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Aminolevulinate', '1 g', 'OTH', 'J7309', 5376);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Aminophylline', '250 mg', 'IV', 'J0280 ', 5377);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Amiodarone', '30 mg', 'IV', 'J0282 ', 5378);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Amitriptyline', '20 mg', 'IM', 'J1320 ', 5379);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Amobarbital', '125 mg', 'IM, IV', 'J0300 ', 5380);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Amphotericin', '50 mg', 'IV', 'J0285 ', 5381);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Amphotericin', '10 mg', 'IV', 'J0287', 5382);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Amphotericin', '10 mg', 'IV', 'J0289 ', 5383);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ampicillin', '500 mg', 'IM, IV', 'J0290 ', 5384);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ampicillin', '1.5 g', 'IM, IV', 'J0295 ', 5385);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Anadulafungin', '1 mg', 'J0348 ', 5386);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Anistreplase', '30 IU', 'IV', 'J0350 ', 5387);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Anti-Inhibitor', '1 IU', 'IV', 'J7198 ', 5388);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Antithrombin', '1 IU', 'IV', 'J7197 ', 5389);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Antithrombin', '50 IU', 'J7196 ', 5390);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Apomorphine', '1 mg', 'J0364 ', 5391);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Aprotinin', '10000 kiu', 'J0365 ', 5392);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Arbutamine', '1 mg', 'IV', 'J0395 ', 5393);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Arformoterol', '0.015 mg', 'J7605 ', 5394);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Aripiprazole', '0.25 mg', 'J0400 ', 5395);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Arsenic', '1 mg', 'IV', 'J9017 ', 5396);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Asparaginase', '10000 IU', 'IV, IM', 'J9020 ', 5397);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Atropine', '1 mg', 'INH', 'J7635 ', 5398);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Atropine', '1 mg', 'INH', 'J7636 ', 5399);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Atropine', '0.01 mg', 'IV, IM, SC', 'J0461 ', 5400);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Aurothioglucose', '50 mg', 'IM', 'J2910 ', 5401);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Autologous', 'J7330 ', 5402);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Azacitidine', '1 mg', 'J9025 ', 5403);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Azathioprine', '50 mg', 'ORAL', 'J7500 ', 5404);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Azathioprine', '100 mg', 'IV', 'J7501 ', 5405);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Azithromycin', '1 g', 'ORAL', 'Q0144 ', 5406);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Azithromycin', '500 mg', 'IV', 'J0456 ', 5407);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Baclofen', '10 mg', 'IT', 'J0475 ', 5408);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Baclofen', '0.05 mg', 'OTH', 'J0476 ', 5409);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Basiliximab', '20 mg', 'J0480 ', 5410);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('BCG', '1 vial', 'IV', 'J9031', 5411);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Beclomethasone', '1 mg', 'INH', 'J7622', 5412);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Belimumab', '10 mg', 'J0490 ', 5413);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Bendamustine', '1 mg', 'J9033 ', 5414);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Benztropine', '1 mg', 'IM, IV', 'J0515 ', 5415);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('betamethasone', '3 mg', 'IM', 'J0702 ', 5416);
Insert into &1..HD_REFINED
   (DRUG, ROUTE, CODE, REC_NO)
 Values
   ('Betamethasone', 'INH', 'J7624 ', 5417);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Bethanechol', '5 mg', 'SC', 'J0520 ', 5418);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Bevacizumab', '10 mg', 'J9035 ', 5419);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Biperiden', '5 mg', 'IM, IV', 'J0190 ', 5420);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Bitolterol', '1 mg', 'INH', 'J7628', 5421);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Bitolterol', '1 mg', 'INH', 'J7629 ', 5422);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Bivalirudin', '1 mg', 'J0583 ', 5423);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Bleomycin', '15 IU', 'IM, IV, SC', 'J9040 ', 5424);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Bortezomib', '0.1 mg', 'J9041 ', 5425);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Brompheniramine', '10 mg', 'IM, SC, IV', 'J0945 ', 5426);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Budesonide', '0.25 mg', 'INH', 'J7633', 5427);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Budesonide', '0.25 mg', 'INH', 'J7634 ', 5428);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Budesonide', '0.5 mg', 'INH', 'J7626', 5429);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Budesonide', '0.5 mg', 'INH', 'J7627 ', 5430);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Buprenorphine', '0.1 mg', 'J0592', 5431);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Busulfan', '1 mg', 'J0594 ', 5432);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Busulfan', '2 mg', 'ORAL', 'J8510 ', 5433);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Butorphanol', '1 mg', 'J0595 ', 5434);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('C1', '10 IU', 'J0597', 5435);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('C1', '10 IU', 'J0598 ', 5436);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Cabazitaxel', '1 mg', 'J9043 ', 5437);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cabergoline', '.25 mg', 'ORAL', 'J8515 ', 5438);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Caffeine', '5 mg', 'IV', 'J0706 ', 5439);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Calcitonin-salmon', '400 IU', 'SC, IM', 'J0630 ', 5440);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Calcitriol', '0.0001 mg', 'IM', 'J0636 ', 5441);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Calcium gluconate', '10 ml', 'IV', 'J0610 ', 5442);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Calcium glycerophosphate', '10 ml', 'IM, SC', 'J0620 ', 5443);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Canakinumab', '1 mg', 'J0638 ', 5444);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Capecitabine', '150 mg', 'ORAL', 'J8520 ', 5445);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Capecitabine', '500 mg', 'ORAL', 'J8521 ', 5446);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Capsaicin', '10 sq', 'OTH', 'J7335 ', 5447);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Carboplatin', '50 mg', 'IV', 'J9045 ', 5448);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Carmustine', '100 mg', 'IV', 'J9050 ', 5449);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Caspofungin', '5 mg', 'IV', 'J0637 ', 5450);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cefazolin', '500 mg', 'IV, IM', 'J0690 ', 5451);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cefepime', '500 mg', 'IV', 'J0692 ', 5452);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cefotaxime', '1 g', 'IV, IM', 'J0698 ', 5453);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cefoxitin', '1 g', 'IV, IM', 'J0694 ', 5454);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ceftaroline', '1 mg', 'J0712 ', 5455);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ceftazidime', '500 mg', 'IM, IV', 'J0713 ', 5456);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ceftizoxime', '500 mg', 'IV, IM', 'J0715 ', 5457);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ceftriaxone', '250 mg', 'IV, IM', 'J0696 ', 5458);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cefuroxime', '750 mg', 'IM, IV', 'J0697', 5459);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cephalothin', '1 g', 'IM, IV', 'J1890 ', 5460);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cephapirin', '1 g', 'IV, IM', 'J0710 ', 5461);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Certolizumab', '1 mg', 'J0718 ', 5462);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Cetuximab', '10 mg', 'J9055 ', 5463);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chloramphenicol', '1 g', 'IV', 'J0720 ', 5464);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chlordiazepoxide', '100 mg', 'IM, IV', 'J1990 ', 5465);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chloroprocaine', '30 ml', 'VAR', 'J2400 ', 5466);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chlorpromazine', '10 mg', 'ORAL', 'Q0171 ', 5467);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chlorpromazine', '25 mg', 'ORAL', 'Q0172 ', 5468);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chloroquine', '250 mg', 'IM', 'J0390 ', 5469);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chlorothiazide', '500 mg', 'IV', 'J1205 ', 5470);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chlorpromazine', '50 mg', 'IM, IV', 'J3230 ', 5471);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Chorionic', '1000 USP', 'IM', 'J0725 ', 5472);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cidofovir', '375 mg', 'IV', 'J0740 ', 5473);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cilastatin', '250 mg', 'IV, IM', 'J0743 ', 5474);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ciprofloxacin', '200 mg', 'IV', 'J0706 ', 5475);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cisplatin', '10 mg', 'IV', 'J9060 ', 5476);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cladribine', '1 mg', 'IV', 'J9065 ', 5477);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Clofarabine', '1 mg', 'J9027 ', 5478);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Clonidine', '1 mg', 'epidural', 'J0735 ', 5479);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Codeine', '30 mg', 'IM, IV, SC', 'J0745 ', 5480);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Collagenase', '0.01 mg', 'J0775 ', 5481);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Colchicine', '1 mg', 'IV', 'J0760 ', 5482);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Colistimethate', '150 mg', 'IM, IV', 'J0770', 5483);
Insert into &1..HD_REFINED
   (DRUG, ROUTE, CODE, REC_NO)
 Values
   ('Copper', 'OTH', 'J7300 ', 5484);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Corticorelin', '0.001 mg', 'J0795 ', 5485);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Corticotropin', '40 IU', 'IV, IM, SC', 'J0800 ', 5486);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cosyntropin', '0.25 mg', 'IM, IV', 'J0833', 5487);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cosyntropin', '0.25 mg', 'IM, IV', 'J0834 ', 5488);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cromolyn', '10 mg', 'INH', 'J7631', 5489);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cromolyn', '10 mg', 'INH', 'J7632 ', 5490);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Crotalidae', '1 g', 'J0840 ', 5491);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cyclophosphamide', '100 mg', 'IV', 'J9070 ', 5492);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cyclophosphamide', '25 mg', 'ORAL', 'J8530 ', 5493);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cyclosporine', '25 mg', 'ORAL', 'J7515 ', 5494);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cyclosporine', '100 mg', 'ORAL', 'J7502 ', 5495);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cyclosporine', '250 mg', 'IV', 'J7516 ', 5496);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Cytarabine', '100 mg', 'SC, IV', 'J9100 ', 5497);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Cytarabine', '10 mg', 'J9098 ', 5498);
Insert into &1..HD_REFINED
   (DRUG, ROUTE, CODE, REC_NO)
 Values
   ('Cytomegalovirus', 'IV', 'J0850 ', 5499);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dacarbazine', '100 mg', 'IV', 'J9130 ', 5500);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Daclizumab', '25 mg', 'IV', 'J7513 ', 5501);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dactinomycin', '0.5 mg', 'IV', 'J9120 ', 5502);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dalteparin', '2500 IU', 'SC', 'J1645 ', 5503);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Daptomycin', '1 mg', 'J0878 ', 5504);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Darbepoetin', '0.001 mg', 'J0881', 5505);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Darbepoetin', '0.001 mg', 'J0882 ', 5506);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Daunorubicin', '10 mg', 'IV', 'J9151 ', 5507);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Daunorubicin', '10 mg', 'IV', 'J9150', 5508);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Decitabine', '1 mg', 'J0894 ', 5509);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Deferoxamine', '500 mg', 'IM, SC, IV', 'J0895 ', 5510);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Degarelix', '1 mg', 'J9155 ', 5511);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Denileukin', '0.3 mg', 'J9160 ', 5512);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Denosumab', '1 mg', 'J0897 ', 5513);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Depo-estradiol', '5 mg', 'IM', 'J1000 ', 5514);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Desmopressin', '0.001 mg', 'IV, SC', 'J2597', 5515);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dexamethasone', '1 mg', 'INH', 'J7637 ', 5516);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dexamethasone', '1 mg', 'INH', 'J7638 ', 5517);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dexamethasone', '0.1 mg', 'OTH', 'J7312 ', 5518);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Dexamethasone', '0.25 mg', 'J8540 ', 5519);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dexamethasone', '1 mg', 'IM', 'J1094 ', 5520);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dexamethasone', '1 mg', 'IM, IV, OTH', 'J1100 ', 5521);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dexrazoxane', '250 mg', 'IV', 'J1190 ', 5522);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dextran', '500 ml', 'IV', 'J7100 ', 5523);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dextran', '500 ml', 'IV', 'J7110 ', 5524);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dextrose', '500 ml', 'IV', 'J7042 ', 5525);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dextrose', '500 ml', 'IV', 'J7060 ', 5526);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Diazepam', '5 mg', 'IM, IV', 'J3360 ', 5527);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Diazoxide', '300 mg', 'IV', 'J1730 ', 5528);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dicyclomine', '20 mg', 'IM', 'J0500 ', 5529);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Diethylstilbestrol', '250 mg', 'IV', 'J9165 ', 5530);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Digoxin', '0.5 mg', 'IM, IV', 'J1160 ', 5531);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Digoxin', '1 vial', 'J1162 ', 5532);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dihydroergotamine', '1 mg', 'IM, IV', 'J1110 ', 5533);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dimenhydrinate', '50 mg', 'IM, IV', 'J1240 ', 5534);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dimercaprol', '100 mg', 'IM', 'J0470 ', 5535);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Diphenhydramine', '50 mg', 'IV, IM', 'J1200', 5536);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Diphenhydramine', '50 mg', 'ORAL', 'Q0163 ', 5537);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dipyridamole', '10 mg', 'IV', 'J1245 ', 5538);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('DMSO', '50%, 50 ml', 'OTH', 'J1212 ', 5539);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dobutamine', '250 mg', 'IV', 'J1250 ', 5540);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Docetaxel', '20 mg', 'IV', 'J9170 ', 5541);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dolasetron', '10 mg', 'IV', 'J1260 ', 5542);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dolasetron', '100 mg', 'ORAL', 'Q0180 ', 5543);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Dopamine', '40 mg', 'J1265 ', 5544);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Doripenem', '10 mg', 'J1267 ', 5545);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dornase', '1 mg', 'INH', 'J7639', 5546);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Doxercalciferol', '0.001 mg', 'IV', 'J1270 ', 5547);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Doxorubicin', '10 mg', 'IV', 'J9000 ', 5548);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Doxorubicin', '10 mg', 'IV', 'J9001 ', 5549);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dronabinol', '2.5 mg', 'ORAL', 'Q0167 ', 5550);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dronabinol', '5 mg', 'ORAL', 'Q0168 ', 5551);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Droperidol', '5 mg', 'IM, IV', 'J1790 ', 5552);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Droperidol', '2 ml', 'IM, IV', 'J1810 ', 5553);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Dyphylline', '500 mg', 'IM', 'J1180 ', 5554);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ecallantide', '1 mg', 'J1290 ', 5555);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Eculizumab', '10 mg', 'J1300 ', 5556);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Edetate', '1000 mg', 'IV, SC, IM', 'J0600 ', 5557);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Edetate', '150 mg', 'IV', 'J3520 ', 5558);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Elliotts', '1 ml', 'OTH', 'J9175', 5559);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Enfuvirtide', '1 mg', 'J1324 ', 5560);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Enoxaparin', '10 mg', 'SC', 'J1650 ', 5561);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Epinephrine', '0.1 mg', 'SC, IM', 'J0171 ', 5562);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Epirubicin', '2 mg', 'J9178 ', 5563);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Epoetin', '1000 IU', 'Q4081 ', 5564);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Epoprostenol', '0.5 mg', 'IV', 'J1325 ', 5565);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Eptifibatide', '5 mg', 'IM, IV', 'J1327 ', 5566);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ergonovine', '0.2 mg', 'IM, IV', 'J1330 ', 5567);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Eribulin', '0.1 mg', 'J9179 ', 5568);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ertapenem', '500 mg', 'J1335 ', 5569);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Erythromycin', '500 mg', 'IV', 'J1364 ', 5570);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Estradiol', '10 mg', 'IM', 'J1380 ', 5571);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Estrogen', '25 mg', 'IV, IM', 'J1410 ', 5572);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Estrone', '1 mg', 'IM', 'J1435 ', 5573);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Etanercept', '25 mg', 'IM, IV', 'J1438 ', 5574);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ethanolamine', '100 mg', 'J1430 ', 5575);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Etidronate', '300 mg', 'IV', 'J1436 ', 5576);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Etonogestrel', 'J7307 ', 5577);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Etoposide', '10 mg', 'IV', 'J9181 ', 5578);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Etoposide', '50 mg', 'ORAL', 'J8560 ', 5579);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Euflexxa', 'J7323 ', 5580);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Everolimus', '0.25 mg', 'J8561 ', 5581);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factor VIIa', '0.001 mg', 'IV', 'J7189 ', 5582);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factor VIII', '1 IU', 'IV', 'J7190 ', 5583);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factor VIII', '1 IU', 'IV', 'J7191 ', 5584);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factor VIII', '1 IU', 'IV', 'J7185', 5585);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factor VIII', '1 IU', 'IV', 'J7192 ', 5586);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factor IX', '1 IU', 'IV', 'J7193 ', 5587);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factor IX', '1 IU', 'IV', 'J7195 ', 5588);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factor IX', '1 IU', 'IV', 'J7194 ', 5589);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Factors', '1 IU', 'IV', 'J7196 ', 5590);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Fentanyl', '0.1 mg', 'IM, IV', 'J3010 ', 5591);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ferumoxytol', '1 mg', 'Q0138', 5592);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ferumoxytol', '1 mg', 'Q0139 ', 5593);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Filgrastim', '0.3 mg', 'SC, IV', 'J1440 ', 5594);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Filgrastim', '0.48 mg', 'SC, IV', 'J1441 ', 5595);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Flebogamma', '500 mg', 'IV', 'J1572 ', 5596);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Floxuridine', '500 mg', 'IV', 'J9200 ', 5597);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Fluconazole', '200 mg', 'IV', 'J1450 ', 5598);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Fludarabine', '1 mg', 'ORAL', 'J8562 ', 5599);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Fludarabine', '50 mg', 'IV', 'J9185 ', 5600);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Flunisolide', '1 mg', 'INH', 'J7641 ', 5601);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Fluocinolone', 'J7311 ', 5602);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Fluorouracil', '500 mg', 'IV', 'J9190 ', 5603);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Fomepizole', '15 mg', 'J1451 ', 5604);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Fomivirsen', '1.65 mg', 'Intraocular', 'J1452 ', 5605);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Fondaparinux', '0.5 mg', 'J1652 ', 5606);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Formoterol', '0.012 mg', 'INH', 'J7640 ', 5607);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Formoterol', '0.02 mg', 'J7606 ', 5608);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Fosaprepitant', '1 mg', 'J1453 ', 5609);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Foscarnet', '1000 mg', 'IV', 'J1455 ', 5610);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Fosphenytoin', '50 mg', 'Q2009 ', 5611);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Fulvestrant', '25 mg', 'J9395 ', 5612);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Furosemide', '20 mg', 'IM, IV', 'J1940 ', 5613);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Gadoxetate', '1 ml', 'A9581 ', 5614);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Gallium', '1 mg', 'J1457 ', 5615);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Galsulfase', '1 mg', 'J1458 ', 5616);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Gammagard', '500 mg', 'J1569 ', 5617);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gamma', '1 ml', 'IM', 'J1460 ', 5618);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gamma', '10 ml', 'IM', 'J1560 ', 5619);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Gammaplex', '500 mg', 'J1557 ', 5620);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Gamunex', '500 mg', 'J1561 ', 5621);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ganciclovir', '4.5 mg', 'OTH', 'J7310', 5622);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ganciclovir', '500 mg', 'IV', 'J1570', 5623);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Garamycin', '80 mg', 'IM, IV', 'J1580 ', 5624);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gatifloxacin', '10 mg', 'IV', 'J1590 ', 5625);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Gefitinib', '250 mg', 'J8565 ', 5626);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Gel-One', '1 dose', 'J7326 ', 5627);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gemcitabine', '200 mg', 'IV', 'J9201 ', 5628);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gemtuzumab', '5 mg', 'IV', 'J9300 ', 5629);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Glassia', '10 mg', 'J0257 ', 5630);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Glatiramer', '20 mg', 'J1595 ', 5631);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Glucagon', '1 mg', 'SC, IM, IV', 'J1610', 5632);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Glycopyrrolate', '1 mg', 'INH', 'J7642 ', 5633);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Glycopyrrolate', '1 mg', 'INH', 'J7643 ', 5634);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gold', '50 mg', 'IM', 'J1600 ', 5635);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gonadorelin', '0.1 mg', 'SC, IV', 'J1620 ', 5636);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Goserelin', '3.6 mg', 'SC', 'J9202 ', 5637);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Granisetron', '0.1 mg', 'IV', 'J1626 ', 5638);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Granisetron', '1 mg', 'ORAL', 'Q0166 ', 5639);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Haloperidol', '5 mg', 'IM, IV', 'J1630 ', 5640);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Haloperidol', '50 mg', 'IM', 'J1631 ', 5641);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Hemin', '1 mg', 'J1640 ', 5642);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hemophilia', '1 IU', 'IV', 'J7198 ', 5643);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hemophilia', '1 IU', 'IV', 'J7199 ', 5644);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hepagam', '0.5 ml', 'IM', 'J1571 ', 5645);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hepagam', '0.5 ml', 'IV', 'J1573 ', 5646);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Heparin', '1000 IU', 'IV, SC', 'J1644 ', 5647);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Heparin', '10 IU', 'IV', 'J1642', 5648);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Histrelin', '0.01 mg', 'J1675 ', 5649);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Histrelin', '50 mg', 'J9225 ', 5650);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Human fibrinogen', '100 mg', 'J1680 ', 5651);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Hyalgan', 'J7321 ', 5652);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hyaluronidase', '150 IU', 'SC, IV', 'J3470 ', 5653);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Hyaluronidase', '999 IU', 'J3471 ', 5654);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Hyaluronidase', '1000 IU', 'J3472 ', 5655);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Hyaluronidase', '1 usp', 'J3473 ', 5656);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hydralazine', '20 mg', 'IV, IM', 'J0360 ', 5657);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hydrocortisone', '25 mg', 'IV, IM, SC', 'J1700 ', 5658);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hydrocortisone', '50 mg', 'IV, IM, SC', 'J1710 ', 5659);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hydrocortisone', '100 mg', 'IV, IM, SC', 'J1720 ', 5660);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hydromorphone', '4 mg', 'SC, IM, IV', 'J1170 ', 5661);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Hydroxyprogesterone', '1 mg', 'J1725', 5662);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hydroxyzine', '25 mg', 'IM', 'J3410 ', 5663);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hydroxyzine', '25 mg', 'ORAL', 'Q0177 ', 5664);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hydroxyzine', '50 mg', 'ORAL', 'Q0178 ', 5665);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Hylan', 'J7322 ', 5666);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Hyoscyamine', '0.25 mg', 'SC, IM, IV', 'J1980 ', 5667);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ibandronate', '1 mg', 'J1740 ', 5668);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ibutilide', '1 mg', 'IV', 'J1742 ', 5669);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Idarubicin', '5 mg', 'IV', 'J9211', 5670);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Idursulfase', '1 mg', 'J1743 ', 5671);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ifosfamide', '1 g', 'IV', 'J9208 ', 5672);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Iloprost', '0.02 mg', 'Q4074 ', 5673);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Imiglucerase', '10 IU', 'IV', 'J1786 ', 5674);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Flebogamma', '500 mg', 'IV', 'J1572 ', 5675);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gammagard', '500 mg', 'IV', 'J1569 ', 5676);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Gammaplex', '500 mg', 'J1557 ', 5677);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Gamunex', '500 mg', 'IV', 'J1561 ', 5678);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('HepaGam', '0.5 ml', 'IM', 'J1571 ', 5679);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('HepaGam', '0.5 ml', 'IV', 'J1573 ', 5680);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Hizentra', '100 mg', 'J1559', 5681);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Octagam', '500 mg', 'IV', 'J1568 ', 5682);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Privigen', '500 mg', 'IV', 'J1459 ', 5683);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Rhophylac', '100 IU', 'IM', 'J2791 ', 5684);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Incobotulinumtoxin', '1 IU', 'J0588 ', 5685);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Infliximab', '10 mg', 'IM, IV', 'J1745 ', 5686);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Insulin', '5 IU', 'SC', 'J1815 ', 5687);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Insulin', '50 IU', 'SC', 'J1817 ', 5688);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon alphacon-1', '0.001 mg', 'SC', 'J9212 ', 5689);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon alfa-2a', '3 million', 'SC, IM', 'J9213 ', 5690);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon alfa-2b', '1 million', 'SC, IM', 'J9214 ', 5691);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon alfa-n3', '250000 IU', 'IM', 'J9215 ', 5692);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon beta-1a', '0.03 mg', 'IM', 'J1826 ', 5693);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon beta-1a', '0.011 mg', 'IM', 'Q3025 ', 5694);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon beta-1a', '0.011 mg', 'SC', 'Q3026 ', 5695);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon beta-1b', '0.25 mg', 'SC', 'J1830 ', 5696);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Interferon gamma-1b', '3 million', 'SC', 'J9216', 5697);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ipilimumab', '1 mg', 'J9228', 5698);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ipratropium', '1 mg', 'INH', 'J7644', 5699);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ipratropium', '1 mg', 'INH', 'J7645 ', 5700);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Irinotecan', '20 mg', 'IV', 'J9206 ', 5701);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Iron', '50 mg', 'J1750 ', 5702);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Iron', '1 mg', 'IV', 'J1756 ', 5703);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Irrigation', '50 ml', 'OTH', 'Q2004 ', 5704);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Isoetharine', '1 mg', 'INH', 'J7647', 5705);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Isoetharine', '1 mg', 'INH', 'J7648 ', 5706);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Isoetharine', '1 mg', 'INH', 'J7649', 5707);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Isoetharine', '1 mg', 'INH', 'J7650 ', 5708);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Isoproterenol', '1 mg', 'INH', 'J7657', 5709);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Isoproterenol', '1 mg', 'INH', 'J7658 ', 5710);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Isoproterenol', '1 mg', 'INH', 'J7659', 5711);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Isoproterenol', '1 mg', 'INH', 'J7660 ', 5712);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Itraconazole', '50 mg', 'IV', 'J1835 ', 5713);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Ixabepilone', '1 mg', 'J9207 ', 5714);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Kanamycin', '75 mg', 'IM, IV', 'J1850 ', 5715);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Kanamycin', '500 mg', 'IM, IV', 'J1840 ', 5716);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Ketorolac', '15 mg', 'IM, IV', 'J1885 ', 5717);
Insert into &1..HD_REFINED
   (DRUG, CODE, REC_NO)
 Values
   ('Laetrile', 'J3570 ', 5718);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Lanreotide', '1 mg', 'J1930 ', 5719);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Laronidase', '0.1 mg', 'J1931 ', 5720);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Lepirudin', '50 mg', 'J1945 ', 5721);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Leucovorin', '50 mg', 'IM, IV', 'J0640 ', 5722);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Leuprolide', '3.75 mg', 'IM', 'J1950 ', 5723);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Leuprolide', '7.5 mg', 'IM', 'J9217 ', 5724);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Leuprolide', '1 mg', 'IM', 'J9218 ', 5725);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, CODE, REC_NO)
 Values
   ('Leuprolide', '65 mg', 'J9219 ', 5726);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Levalbuterol', '0.5 mg', 'INH', 'J7607', 5727);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Levalbuterol', '0.5 mg', 'INH', 'J7612 ', 5728);
Insert into &1..HD_REFINED
   (DRUG, STRENGTH, ROUTE, CODE, REC_NO)
 Values
   ('Levalbuterol', '0.5 mg', 'INH', 'J7614', 5729);
COMMIT;

DROP TABLE &1..HCPCSROUTES;

CREATE TABLE &1..HCPCSROUTES
(
  CONCEPT_NAME  VARCHAR2(256 BYTE),
  CNT           VARCHAR2(256 BYTE),
  TRY           VARCHAR2(256 BYTE)
)
;

Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Tablet', '9445', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Solution', '7533', 'IV');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Solution', '7533', 'IA');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Solution', '7533', 'IM');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Solution', '7533', 'SC');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Solution', '7533', 'IT');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Capsule', '4066', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Solution', '3836', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Extended Release Tablet', '2065', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Extended Release Capsule', '1261', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Suspension', '1254', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Cream', '1165', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Syrup', '1000', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Ointment', '986', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Solution', '876', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Filled Syringe', '761', 'IV');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Filled Syringe', '761', 'IA');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Filled Syringe', '761', 'IM');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Filled Syringe', '761', 'SC');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Filled Syringe', '761', 'IT');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Chewable Tablet', '735', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Gel', '677', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Ophthalmic Solution', '623', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Lotion', '596', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Suppository', '462', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Suspension', '454', 'IV');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Suspension', '454', 'IA');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Suspension', '454', 'IM');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Suspension', '454', 'SC');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Injectable Suspension', '454', 'IT');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Lozenge', '419', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Enteric Coated Tablet', '365', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Spray', '334', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Inhalant Solution', '317', 'INH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Sublingual Tablet', '300', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('12 hour Extended Release Tablet', '278', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('12 hour Extended Release Capsule', '246', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Elixir', '224', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Transdermal Patch', '203', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Medicated Shampoo', '192', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Disintegrating Tablet', '190', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Gas for Inhalation', '170', 'INH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Enteric Coated Capsule', '161', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Nasal Spray', '155', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('24 Hour Extended Release Tablet', '144', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Medicated Liquid Soap', '143', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Extended Release Suspension', '143', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Medicated Pad', '142', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Ophthalmic Ointment', '131', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('24 Hour Extended Release Capsule', '113', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Powder', '112', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Otic Solution', '108', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Gel', '108', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Foam', '108', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Nasal Solution', '107', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Vaginal Suppository', '102', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Irrigation Solution', '100', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Mouthwash', '97', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Inhalant Powder', '84', 'INH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Ophthalmic Suspension', '83', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Metered Dose Inhaler', '82', 'INH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Vaginal Cream', '77', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Buccal Tablet', '76', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Enema', '75', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Toothpaste', '69', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Powder', '67', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Paste', '65', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Mucous Membrane Topical Solution', '63', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Granules', '63', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Medicated Bar Soap', '60', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Drug Implant', '53', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Dry Powder Inhaler', '47', 'INH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Prefilled Applicator', '46', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Nasal Inhaler', '44', 'INH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Vaginal Gel', '43', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('24 Hour Transdermal Patch', '38', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Wafer', '37', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Topical Oil', '37', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Strip', '36', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Cream', '35', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Spray', '34', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Ointment', '34', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Chewing Gum', '34', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Extended Release Enteric Coated Tablet', '32', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Vaginal Tablet', '31', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Mucosal Spray', '30', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Powder Spray', '24', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Extended Release Enteric Coated Capsule', '24', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Bar Soap', '24', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Pellet', '23', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Ophthalmic Gel', '22', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Intraperitoneal Solution', '22', 'IV');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Intraperitoneal Solution', '22', 'IA');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Intraperitoneal Solution', '22', 'IM');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Intraperitoneal Solution', '22', 'SC');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Intraperitoneal Solution', '22', 'IT');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Gel', '22', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Nasal Gel', '21', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Cream', '19', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Paste', '18', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Weekly Transdermal Patch', '16', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Ophthalmic Irrigation Solution', '16', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Douche', '14', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Otic Suspension', '14', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Nasal Inhalant', '14', 'INH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Biweekly Transdermal Patch', '12', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('72 Hour Transdermal Patch', '11', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Foam', '10', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Solution', '9', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Sustained Release Buccal Tablet', '9', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Powder', '9', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Foam', '9', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Vaginal Ring', '8', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Buccal Film', '8', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Caplet', '6', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Intrathecal Suspension', '6', 'IT');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Urethral Suppository', '6', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Suspension', '6', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Solution', '6', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Crystals', '6', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Beads', '5', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Ophthalmic Cream', '5', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('16 Hour Transdermal Patch', '5', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Chewable Bar', '5', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Oral Ointment', '4', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Nasal Ointment', '4', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Vaginal Foam', '4', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Intravenous Solution', '3', 'IV');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Vaginal Ointment', '3', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Suspension', '2', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Pudding', '2', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Liquid', '2', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Inhalant', '2', 'INH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Nasal Suspension', '2', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Cake', '2', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Urethral Gel', '2', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Augmented Topical Lotion', '2', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Capsule', '2', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Spray', '2', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Nasal Cream', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Disk', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Augmented Topical Ointment', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Suppository', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Tablet', '1', 'ORAL');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Patch', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Augmented Topical Gel', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Flakes', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Rectal Powder', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Liquid Cleanser', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Medicated Tape', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Otic Cream', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Augmented Topical Cream', '1', 'OTH');
Insert into &1..HCPCSROUTES
   (CONCEPT_NAME, CNT, TRY)
 Values
   ('Otic Ointment', '1', 'OTH');
COMMIT;


exit;

