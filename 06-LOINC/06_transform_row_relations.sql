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
*  Date:           2021/07/06
*
*  Load new concept relationships stage, identify invalid codes  information 
*  Loaded from the raw staged data SCT2_RELA_FULL_INT into the staged data CONCEPT_RELATIONSHIP_STAGE, identify invalid code information    
*     
*  Usage: 
*  echo "EXIT" | sqlplus LOINC_20120131/myPass@DEV_VOCAB @06_transform_row_relations.sql 
*
******************************************************************************/
SPOOL 06_transform_row_relations.log
-- .      

--DROP SEQUENCE SEQ_RELATIONSHIP;
--CREATE SEQUENCE SEQ_RELATIONSHIP START WITH 5000000;


-- Create temporary table for uploading concept relatioships. 
--DELETE FROM CONCEPT_RELATIONSHIP_STAGE.; 
TRUNCATE TABLE CONCEPT_RELATIONSHIP_STAGE; 


--/*
INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID)
--*/    
SELECT  DISTINCT
        CONCEPT_ID_1, 
        CONCEPT_ID_2, 
        RELATIONSHIP_ID
FROM (
SELECT  (SELECT CONCEPT_ID FROM DEV.CONCEPT WHERE vocabulary_id IN (06, 49) AND CONCEPT_CODE = IMMEDIATE_PARENT) as CONCEPT_ID_1,
        (SELECT CONCEPT_ID FROM DEV.CONCEPT WHERE vocabulary_id IN (06, 49) AND CONCEPT_CODE = CODE) as CONCEPT_ID_2,
        RELATIONSHIP_ID
FROM    (
        SELECT  IMMEDIATE_PARENT,
                CODE,
                010 as RELATIONSHIP_ID
        FROM    LOINC_49             
        WHERE   1 = 1
        )
)
WHERE   RELATIONSHIP_ID   IS NOT NULL
    AND CONCEPT_ID_1        IS NOT NULL
    AND CONCEPT_ID_2        IS NOT NULL
;

--/*
INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID)
--*/    
SELECT  DISTINCT        
        CONCEPT_ID_1, 
        CONCEPT_ID_2, 
        RELATIONSHIP_ID
FROM (
SELECT  (SELECT CONCEPT_ID FROM DEV.CONCEPT WHERE vocabulary_id IN (06, 49) AND CONCEPT_CODE = LOINC) as CONCEPT_ID_1,
        (SELECT CONCEPT_ID FROM DEV.CONCEPT WHERE vocabulary_id IN (06, 49) AND CONCEPT_CODE = MAP_TO) as CONCEPT_ID_2,
        RELATIONSHIP_ID
FROM    (
        SELECT  LOINC,
                MAP_TO,
                001 as RELATIONSHIP_ID
        FROM    LOINC_MAP_TO             
        WHERE   1 = 1
        )
)
WHERE   RELATIONSHIP_ID   IS NOT NULL
    AND CONCEPT_ID_1        IS NOT NULL
    AND CONCEPT_ID_2        IS NOT NULL
;

commit;

--/*


--  NEED uncomment !!!
--/*
SELECT 'Revers-RELATIONS' FROM dual;
INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID)
SELECT  
    R.CONCEPT_ID_2 AS CONCEPT_ID_1, R.CONCEPT_ID_1 AS CONCEPT_ID_2,
  NVL((SELECT REVERSE_RELATIONSHIP from
   --PRD.
    DEV.
   RELATIONSHIP rt WHERE rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID), 998)
  FROM  CONCEPT_RELATIONSHIP_STAGE r
  ; 
--*/
commit;




exit;
