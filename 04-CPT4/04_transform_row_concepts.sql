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
*  echo "EXIT" | sqlplus CPT_20120131/myPass@DEV_VOCAB @04_transform_row_concepts.sql
*
******************************************************************************/
SPOOL 04_transform_row_concepts.log
-- . 


DELETE FROM CONCEPT_STAGE
WHERE   vocabulary_id = 04;  

INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
SELECT SUBSTR(CONCEPT_NAME,1,255), vocabulary_id, CONCEPT_LEVEL, CONCEPT_CODE, CONCEPT_CLASS FROM (
SELECT  
 SUBSTR(STR,1,256) as CONCEPT_NAME, 
        04 AS vocabulary_id, 
        1 AS CONCEPT_LEVEL, 
        d.scui AS CONCEPT_CODE , 
        'CPT-4' AS CONCEPT_CLASS
        ,ROW_NUMBER() OVER (PARTITION BY  cui ORDER BY CODE DESC--, term
        , CASE WHEN ISPREF = 'N' then 0 else 1 END 
        , CASE WHEN STR LIKE '%(%)%' THEN 1 ELSE 0 END
        ) rn 
FROM
UMLS.MRCONSO d
WHERE  1 = 1
 AND sab = 'CPT' 
   AND tty = 'PT'
   AND suppress != 'O'
AND STR IS NOT NULL
)
WHERE rn  = 1    
;

exit;