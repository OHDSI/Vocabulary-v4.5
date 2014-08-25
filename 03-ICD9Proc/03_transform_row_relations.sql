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
*  echo "EXIT" | sqlplus RXNORM_20120131/myPass@DEV_VOCAB @03_transform_row_relations.sql 
*
******************************************************************************/
SPOOL 03_transform_row_relations.log
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
SELECT DISTINCT 
C03.CONCEPT_ID, C01.CONCEPT_ID, 92  
    FROM --UMLS_20120702_ALL.
     UMLS.MRCONSO c1
     JOIN --UMLS_20120702_ALL.
     UMLS.MRCONSO c2 ON c2.cui = c1.cui
     JOIN DEV.concept c01 ON c2.code = c01.concept_code AND C01.VOCABULARY_ID = 01   
     JOIN DEV.concept c03 ON c1.code = c03.concept_code AND C03.VOCABULARY_ID = 03
    WHERE c1.sab='ICD9CM' 
          AND c1.tty = 'PT'
          AND c1.suppress != 'O'
      AND c2.sab='SNOMEDCT'
          AND c2.tty = 'PT'
          AND c2.suppress != 'O'
          AND c2.ts = 'P'
          AND c2.isPref = 'Y'
;
commit;

/*
INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    --RELATIONSHIP_ID, 
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID
    )
SELECT
    sou.CONCEPT_ID_1 AS CONCEPT_ID_1, 
    sou.CONCEPT_ID_2 AS CONCEPT_ID_2, 
    sou.RELATIONSHIP_ID AS RELATIONSHIP_ID 
FROM 
DEV.CONCEPT_RELATIONSHIP sou
--SNOMED_20120131.CONCEPT_REL_STAGE_CLIN_FINDING sou
WHERE sou.RELATIONSHIP_ID = 010
AND EXISTS
              (SELECT 1
                 FROM DEV.CONCEPT c
                WHERE c.VOCABULARY_ID IN (01) AND c.CONCEPT_ID = CONCEPT_ID_1
                AND C.CONCEPT_CLASS = 'Procedure')
       AND EXISTS
              (SELECT 1
                 FROM DEV.CONCEPT c
                WHERE c.VOCABULARY_ID IN (01) AND c.CONCEPT_ID = CONCEPT_ID_2
                AND C.CONCEPT_CLASS = 'Procedure')
--*/       
;


INSERT INTO CONCEPT_RELATIONSHIP_STAGE (CONCEPT_ID_1, CONCEPT_ID_2,RELATIONSHIP_ID)
SELECT * FROM (
--/*                
WITH SOU as (
--*/
SELECT
L1, L2, L3
, F1 AS c3, L1||'.'||L2 AS c2, L1 AS c1
, CONCEPT_CODE, CONCEPT_NAME 
FROM (
SELECT 
    F1, DOT1
    , TRIM(SUBSTR(F1,1,DOT1 - 1)) L1
    , TRIM(SUBSTR(F1,DOT1 + 1, 1)) L2
    , TRIM(SUBSTR(F1,DOT1 + 2, 1)) L3    
    , CONCEPT_CODE, CONCEPT_NAME 
 FROM (
 SELECT REPLACE(CONCEPT_CODE,'''','') F1
 , INSTR(CONCEPT_CODE, '.', 1, 1) DOT1   
 , CONCEPT_CODE, CONCEPT_NAME
FROM CONCEPT_STAGE
)
WHERE 1 = 1
AND  DOT1 > 0 --AND  length(TRIM(CONCEPT_CODE))>4
ORDER BY 1, 2
)
--/*
)
--/*
SELECT DISTINCT (select concept_id from dev.concept c where c.VOCABULARY_ID = 03 and c.CONCEPT_CODE = sou.c2 ) ID2
,(select concept_id from dev.concept c where c.VOCABULARY_ID = 03 and c.CONCEPT_CODE = sou.c3 ) ID3, 010
--, c2, c3 
 FROM sou
union
--*/
SELECT DISTINCT  
 (select concept_id from dev.concept c where c.VOCABULARY_ID = 03 and c.CONCEPT_CODE = sou.c1||'.' ) ID2 --ID1
,(select concept_id from dev.concept c where c.VOCABULARY_ID = 03 and c.CONCEPT_CODE = sou.c2 ) ID3--ID2
, 010
--,  c1, c2
FROM sou
ORDER BY 1, 2
--*/
) WHERE ID2 IS NOT NULL AND ID3 IS NOT NULL AND ID2 <> ID3
--WHERE ID3 IS  NULL -- 17.5 17.6 17.7 17.8
--WHERE c2  = '01' -- 01.6
;

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
