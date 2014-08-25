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
*  Date:           2011/10/19
*
*  Uploading concept relatioships.
*  Usage: 
*  echo "EXIT" | sqlplus <user>/<pass> @04_load_maps.sql 
*
******************************************************************************/
SPOOL 04_transform_row_maps.log
-- . 

-- DROP SEQUENCE SEQ_CONCEPT_MAP;
-- CREATE SEQUENCE SEQ_CONCEPT_MAP START WITH 50000000;




-- Create temporary table for uploading concept. 
TRUNCATE TABLE  SOURCE_TO_CONCEPT_MAP_STAGE ;

--DELETE FROM    SOURCE_TO_CONCEPT_MAP_$1.
--WHERE   VOCABULARY_ID = '07'
--; 

--/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE( --04-->04
--  SOURCE_TO_CONCEPT_MAP_ID ,
  SOURCE_CODE              ,
  SOURCE_CODE_DESCRIPTION  ,
  MAPPING_TYPE             ,
  TARGET_CONCEPT_ID        ,
  TARGET_VOCABULARY_ID   ,
  SOURCE_VOCABULARY_ID   ,
  PRIMARY_MAP             
  )
--*/
--/*  
SELECT SOURCE_CODE, SOURCE_CODE_DESCRIPTION, MAPPING_TYPE,TARGET_CONCEPT_ID,TARGET_CONCEPT_TYPE_ID,SOURCE_CONCEPT_TYPE_ID, PRIMARY_MAP  
--,ISHANDMADE, RN
FROM ( 
SELECT sou.*, ROW_NUMBER() OVER (PARTITION BY  SOURCE_CODE ORDER BY ISHANDMADE DESC,  SOURCE_CODE_DESCRIPTION) rn
FROM (
SELECT 
  CO1.CONCEPT_CODE AS SOURCE_CODE 
, CO1.CONCEPT_NAME AS SOURCE_CODE_DESCRIPTION 
, 'PROCEDURE' AS MAPPING_TYPE
, DV.concept_ID AS TARGET_CONCEPT_ID
, 04 AS TARGET_CONCEPT_TYPE_ID
, 04 AS SOURCE_CONCEPT_TYPE_ID
, 'Y' AS PRIMARY_MAP
, 0 AS ISHANDMADE
     FROM concept_STAGE Co1
     , DEV.concept dv
WHERE     
  Co1.VOCABULARY_ID = 04
  AND DV.VOCABULARY_ID = 04
  AND CO1.CONCEPT_CODE = DV.CONCEPT_CODE       
) sou
)
WHERE 1 = 1
--AND ISHANDMADE = 0
AND rn = 1
--AND TARGET_CONCEPT_ID IS NOT NULL   
;
--*/


exit;