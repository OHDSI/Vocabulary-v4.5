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
*  Loaded from raw staged data SCT2_DESC_FULL_EN_INT into the staged data CONCEPT_STAGE
*  In this step we will perform substitute GUID identifiers into numerical format. 
*
*  Usage: 
*  echo "EXIT" | sqlplus ICD9PR_20120131/myPass@DEV_VOCAB @07_transform_row_concepts.sql
*
******************************************************************************/
SPOOL 03_transform_row_concepts.log
-- . 


DELETE FROM CONCEPT_STAGE
WHERE   vocabulary_id IN (03);  


--/*
INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
--*/    
SELECT CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS 
    --, ISHANDMADE
    FROM (
SELECT sou.*, ROW_NUMBER() OVER (PARTITION BY  CONCEPT_CODE ORDER BY ISHANDMADE DESC) rn
FROM (
SELECT  
   NAME AS CONCEPT_NAME   
 , 03 AS VOCABULARY_ID
 , 03 AS CONCEPT_LEVEL
 --, CODE AS ORIG_CODE
 , regexp_replace( code, '^([0-9][0-9])([0-9]+)', '\1.\2' )  AS CONCEPT_CODE
 , 'ICD-9-Procedure' AS CONCEPT_CLASS
 , 0 AS ISHANDMADE
    FROM CMS_DESC_LONG_SG              
 WHERE 1 = 1
--/* 
 UNION ALL
 SELECT  
  CONCEPT_NAME   
 , TO_NUMBER(VOCABULARY_ID)
 ,  CONCEPT_LEVEL
 --, CODE AS ORIG_CODE
 ,  CONCEPT_CODE
 --||CASE WHEN length(TRIM(CONCEPT_CODE))<3 then'.' else '' END 
 ,  CONCEPT_CLASS
 , 1 AS ISHANDMADE
    FROM DEV.concept c where c.VOCABULARY_ID = 03
--*/     
 ) sou
 ) WHERE 1 = 1
 AND rn = 1
--AND  length(TRIM(CONCEPT_CODE))<4
 ORDER BY 4
;

exit;
