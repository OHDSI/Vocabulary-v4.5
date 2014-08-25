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
*  
*  Loaded from raw staged data SCT1_DESCRIPTIONS into the staged data CONCEPT_STAGE
*  In this step we will perform substitute GUID identifiers into numerical format. 
*
*  Usage: 
*  echo "EXIT" | sqlplus LOINC_20120131/myPass@DEV_VOCAB @06_transform_row_concepts.sql
*
******************************************************************************/
SPOOL 06_transform_row_concepts.log
-- . 


DELETE FROM CONCEPT_STAGE
WHERE   vocabulary_id IN (06, 49);  


--SELECT SUBSTR(CONCEPT_NAME,1,255), vocabulary_id, CONCEPT_LEVEL, CONCEPT_CODE, CONCEPT_CLASS FROM (
/* 2002 Version
SELECT  
 SUBSTR(STR,1,256) as CONCEPT_NAME, 
        04 AS vocabulary_id, 
        1 AS CONCEPT_LEVEL, 
        s.METAUI AS CONCEPT_CODE , 
        'LOINC-4' AS CONCEPT_CLASS
        ,ROW_NUMBER() OVER (PARTITION BY  d.cui ORDER BY CODE DESC--, term
        --, CASE WHEN ISPREF = 'N' then 0 else 1 END 
        , CASE WHEN STR LIKE '%(%)%' THEN 1 ELSE 0 END
        ) rn 
FROM    --snomed_$1..
MRCONSO d, MRSAT s
WHERE  1 = 1
AND D.CUI = S.CUI
  AND TS='P' 
   AND STT = 'PF'
   AND LAT ='ENG'
   AND suppress != 'O'
AND STR IS NOT NULL
--*/
/* New UMLS Version
SELECT  
 SUBSTR(STR,1,256) as CONCEPT_NAME, 
        05 AS vocabulary_id, 
        1 AS CONCEPT_LEVEL, 
        d.scui AS CONCEPT_CODE , 
        'HCPCS' AS CONCEPT_CLASS
        ,ROW_NUMBER() OVER (PARTITION BY  cui ORDER BY CODE DESC--, term
        , CASE WHEN ISPREF = 'N' then 0 else 1 END 
        , CASE WHEN STR LIKE '%(%)%' THEN 1 ELSE 0 END
        ) rn 
FROM    --snomed_$1..
MRCONSO d
WHERE  1 = 1
 AND sab = 'HCPCS' 
   AND tty IN ( 'PT', 'OP')
   AND suppress != 'O'
AND STR IS NOT NULL
--*/
--)WHERE rn  = 1  ;

--/*
INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
--*/
SELECT SUBSTR(CONCEPT_NAME,1,255), vocabulary_id, CONCEPT_LEVEL, CONCEPT_CODE, CONCEPT_CLASS FROM (
SELECT  
 SUBSTR(COMPONENT,1,256) as CONCEPT_NAME, 
        06 AS vocabulary_id, 
        1 AS CONCEPT_LEVEL, 
        d.LOINC_NUM AS CONCEPT_CODE , 
        'LOINC Code' AS CONCEPT_CLASS
        ,ROW_NUMBER() OVER (PARTITION BY  LOINC_NUM ORDER BY COMPONENT DESC--, term
        , CASE WHEN TIME_ASPCT = 'Pt' then 0 else 1 END 
        ) rn 
FROM    --snomed_$1..
LOINC d
WHERE  1 = 1
-- AND sab = 'CPT' 
--   AND tty = 'PT'
--   AND suppress != 'O'
AND COMPONENT IS NOT NULL
)
WHERE rn  = 1
AND REGEXP_LIKE(concept_CODE, '^[[:digit:]]')    
;


--/*
INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
--*/
SELECT SUBSTR(CONCEPT_NAME,1,255), vocabulary_id, CONCEPT_LEVEL, CONCEPT_CODE, CONCEPT_CLASS FROM (
SELECT  
 SUBSTR(CODE_TEXT,1,256) as CONCEPT_NAME, 
        49 AS vocabulary_id, 
        2 AS CONCEPT_LEVEL, 
        d.CODE AS CONCEPT_CODE , 
        'LOINC Multidimensional Classification' AS CONCEPT_CLASS
        ,ROW_NUMBER() OVER (PARTITION BY  CODE ORDER BY CODE_TEXT DESC--, term
        --, CASE WHEN TIME_ASPCT = 'Pt' then 0 else 1 END 
        ) rn 
FROM    --snomed_$1..
LOINC_49 d
WHERE  1 = 1
AND CODE like 'LP%'
AND CODE_TEXT IS NOT NULL
)
WHERE rn  = 1    
;


exit;