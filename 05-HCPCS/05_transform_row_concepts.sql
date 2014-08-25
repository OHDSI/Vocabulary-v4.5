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
*  echo "EXIT" | sqlplus CPT_20120131/myPass@DEV_VOCAB @05_transform_row_concepts.sql
*
******************************************************************************/
SPOOL 05_transform_row_concepts.log
-- . 


DELETE FROM CONCEPT_STAGE
WHERE   vocabulary_id = 05;  

INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
--*/
    SELECT TRIM(SUBSTR(MAX(descr), 1 , 256)), 5,1,cd, 'HCPCS' FROM (
  WITH stepbystep ( descr, cd, rn, ric, lin ) AS (
    SELECT descr, cd, rn, ric, lin FROM (
    SELECT  RPAD  ('"',2556,'"') as  descr
    ,  LTRIM(RTRIM(HCPC)) cd ,  ROW_NUMBER() OVER (PARTITION BY  HCPC ORDER BY SEQ_NUM  ) rn ,RIC, 0 AS lin
  FROM  txxanweb_V3   D
 -- WHERE LTRIM(RTRIM(HCPC)) IN ('A6448', 'A6449', 'TC', 'ED')
  ) WHERE rn = lin+1
    UNION ALL
    SELECT REPLACE(s.descr||' '||r.descr, '"', ''), r.cd, r.rn, r.ric, lin + 1 FROM (
  SELECT  Long_Description  descr,  LTRIM(RTRIM(HCPC)) cd ,  ROW_NUMBER() OVER (PARTITION BY  HCPC ORDER BY SEQ_NUM  ) rn ,RIC
  FROM  txxanweb_V3   D 
  --WHERE LTRIM(RTRIM(HCPC)) IN ('A6448', 'A6449', 'TC', 'ED')
  ) r  
        INNER JOIN
        stepbystep s
        ON ( s.cd = r.cd AND lin  = r.rn-1  
        )        
  --      WHERE s.distance <10000
  --WHERE cyclemark = '-'
  )
  --CYCLE cd SET cyclemark TO 'X' DEFAULT '-'
SELECT descr, cd, rn, ric--, cyclemark
, lin FROM stepbystep
WHERE --rn = lin AND
 descr <>  RPAD  ('"',2556,'"') 
ORDER BY cd, rn, ric
--WHERE cyclemark = '-'
) GROUP BY cd 
;

exit;