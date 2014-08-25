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
*  echo "EXIT" | sqlplus CPT_20120131/myPass@DEV_VOCAB @04_transform_row_relations.sql 
*
******************************************************************************/
SPOOL 04_transform_row_relations.log
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
C04.CONCEPT_ID, C01.CONCEPT_ID, 94
    FROM --UMLS_20120702_ALL.
     UMLS.MRCONSO c1
     JOIN --UMLS_20120702_ALL.
     UMLS.MRCONSO c2 ON c2.cui = c1.cui
     JOIN DEV.concept c01 ON c2.code = c01.concept_code AND C01.VOCABULARY_ID = 01 AND C01.CONCEPT_CLASS = 'Procedure'  
     JOIN DEV.concept C04 ON c1.code = C04.concept_code AND C04.VOCABULARY_ID = 04
    WHERE c1.sab='CPT' 
          AND c1.tty = 'PT'
          AND c1.suppress != 'O'
      AND c2.sab='SNOMEDCT'
          AND c2.tty = 'PT'
          AND c2.suppress != 'O'
          AND c2.ts = 'P'
          AND c2.isPref = 'Y'
;



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
;                
     
--*/     



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
