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
*  echo "EXIT" | sqlplus RXNORM_20120131/myPass@DEV_VOCAB @01_transform_row_relations.sql 
*
******************************************************************************/
SPOOL 08_transform_row_relations.log
-- .      

--DROP SEQUENCE SEQ_RELATIONSHIP;
--CREATE SEQUENCE SEQ_RELATIONSHIP START WITH 5000000;


-- Create temporary table for uploading concept relatioships. 
--DELETE FROM CONCEPT_RELATIONSHIP_STAGE.; 
TRUNCATE TABLE CONCEPT_RELATIONSHIP_STAGE; 



INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_2, 
    CONCEPT_ID_1, 
    RELATIONSHIP_ID)
SELECT  CONCEPT_ID_1, 
        CONCEPT_ID_2, 
        RELATIONSHIP_ID
FROM (
SELECT  (SELECT CONCEPT_ID FROM DEV.CONCEPT WHERE vocabulary_id = 08 AND CONCEPT_CODE = RXCUI1) as CONCEPT_ID_1,
        (SELECT CONCEPT_ID FROM DEV.CONCEPT WHERE vocabulary_id = 08 AND CONCEPT_CODE = RXCUI2) as CONCEPT_ID_2,
        RELATIONSHIP_ID
FROM    (
        SELECT  RXCUI1,
                RXCUI2,
                CASE 
                    WHEN    RELA = 'has_precise_ingredient' THEN    '002'
                    WHEN    RELA = 'has_tradename'          THEN    '003'
                    WHEN    RELA = 'has_dose_form'          THEN    '004'
                    WHEN    RELA = 'has_form'               THEN    '005'
                    WHEN    RELA = 'has_ingredient'         THEN    '006' 
                    WHEN    RELA = 'constitutes'            THEN    '007' 
                    WHEN    RELA = 'contains'               THEN    '008' 
                    WHEN    RELA = 'reformulation_of'       THEN    '009' 
                END as RELATIONSHIP_ID
        FROM    rxnrel             
        WHERE   SAB     = 'RXNORM'
        )
)
WHERE   RELATIONSHIP_ID   IS NOT NULL
    AND CONCEPT_ID_1        IS NOT NULL
    AND CONCEPT_ID_2        IS NOT NULL
;
commit;

--/*


--NO NEED ??? uncomment !!!
/*
SELECT '006-007-RELATIONS' FROM dual; --106 234

INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_2, --ITs TRUE
    CONCEPT_ID_1, 
    RELATIONSHIP_ID)
select  
DISTINCT C1.CONCEPT_ID,  C2.CONCEPT_ID, 106  --R2.CONCEPT_ID_1
from  DEV.CONCEPT c1
    , CONCEPT_RELATIONSHIP_STAGE r1
    , CONCEPT_RELATIONSHIP_STAGE r2
    , DEV.CONCEPT c2
WHERE 1 = 1
AND C1.VOCABULARY_ID = 08 
AND C1.CONCEPT_CLASS IN ( 'Clinical Drug', 'Branded Drug', 'Clinical Pack', 'Branded Pack')
AND C1.CONCEPT_ID = R1.CONCEPT_ID_2 AND R1.RELATIONSHIP_ID = 007
AND R1.CONCEPT_ID_1 = R2.CONCEPT_ID_1  AND R2.RELATIONSHIP_ID = 006
AND C2.CONCEPT_ID = R2.CONCEPT_ID_2  AND C2.CONCEPT_CLASS = 'Ingredient'
--WHERE 1 = 1
--AND C1.vocabulary_id = '08' 
--AND C1.CONCEPT_CLASS IN ( 'Clinical Drug', 'Branded Drug', 'Clinical Pack', 'Branded Pack')
--AND C1.CONCEPT_ID = R1.CONCEPT_ID_2 AND R1.RELATIONSHIP_ID = 007
--AND R1.CONCEPT_ID_1 = R2.CONCEPT_ID_1  AND R2.RELATIONSHIP_ID = 006
--AND C2.CONCEPT_ID = R2.CONCEPT_ID_2  AND C2.CONCEPT_CLASS = 'Ingredient'
;
--*/

--/*
INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID)
--*/    
SELECT CONCEPT_ID_1, CONCEPT_ID_2,  RELATIONSHIP_ID FROM (
select 
CDEPR.CONCEPT_ID CONCEPT_ID_1, CMERG.CONCEPT_ID CONCEPT_ID_2, 309 RELATIONSHIP_ID
, TO_DATE(    a.UPDATED_TIMESTAMP,    'MM/dd/YYYY HH:MI:SS AM',     'NLS_DATE_LANGUAGE = American') dt
, ROW_NUMBER() OVER (PARTITION BY  CDEPR.CONCEPT_ID 
ORDER BY TO_DATE(    a.UPDATED_TIMESTAMP,    'MM/dd/YYYY HH:MI:SS AM',     'NLS_DATE_LANGUAGE = American') DESC) rn
from 
  dev.concept cdepr
, RXNATOMARCHIVE a
, dev.concept cmerg
where 1 = 1
and NVL(cdepr.INVALID_REASON, 'X') = 'D'
and cdepr.VOCABULARY_ID = 8
and cdepr.CONCEPT_CODE = A.RXCUI--(+)
AND a.SAB = 'RXNORM' 
AND a.MERGED_TO_RXCUI  <> A.RXCUI
AND (
CASE cdepr.CONCEPT_CLASS 
         WHEN 'Ingredient'    THEN 'IN'
         WHEN 'Dose Form'      THEN 'DF'
         WHEN 'Clinical Drug Component'     THEN 'SCDC'
         WHEN 'Clinical Drug Form'     THEN 'SCDF'
         WHEN 'Clinical Drug'      THEN 'SCD'
         WHEN 'Brand Name'      THEN 'BN'
         WHEN 'Branded Drug Component'     THEN 'SBDC'
         WHEN 'Branded Drug Form'      THEN 'SBDF'
         WHEN 'Branded Drug'      THEN 'SBD'
         WHEN 'Branded Pack'      THEN 'BPCK'
         WHEN 'Clinical Pack' THEN 'GPCK'
END  = a.TTY
)
and cmerg.VOCABULARY_ID = 8
and cmerg.CONCEPT_CODE = A.MERGED_TO_RXCUI--(+)
order by cdepr.CONCEPT_CODE
) WHERE rn = 1
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
