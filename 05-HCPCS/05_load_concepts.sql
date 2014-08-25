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
*  Load new concepts into DEV schema concept table,mark deprecated concepts as deleted
*  Transfer records from CONCEPT_STAGE to DEV.CONCEPT table
*      
*  Usage: 
*  echo "EXIT" |sqlplus HCPCS_20120131/myPass@DEV_VOCAB @05_load_concepts.sql  
*
******************************************************************************/
SPOOL 05_load_concepts.log
-- . 

-- DROP SEQUENCE SEQ_CONCEPT;
-- CREATE SEQUENCE SEQ_CONCEPT START WITH 39000000;


--UPDATE CONCEPT_STAGE d  SET     (concept_id) = NULL;

UPDATE CONCEPT_STAGE d
SET     (concept_id) = (
    SELECT  c.concept_id
    FROM    DEV.CONCEPT c 
    WHERE   c.concept_code =   d.concept_code
        AND c.VOCABULARY_ID   =   05       
)
WHERE d.VOCABULARY_ID   =   05       
;

-- "Восставшие из пепла"
UPDATE dev.concept c
 set C.CONCEPT_NAME = (select st.CONCEPT_NAME from CONCEPT_STAGE st  WHERE C.CONCEPT_CODE = st.CONCEPT_CODE and st.VOCABULARY_ID = 05 ) 
 , C.VALID_END_DATE = to_date('12312099','mmddyyyy'), C.INVALID_REASON = null
 WHERE C.VOCABULARY_ID = 05
  AND NVL(c.INVALID_REASON, 'X') = ('D')      
 AND  exists (select 1 from CONCEPT_STAGE st  WHERE C.CONCEPT_CODE = st.CONCEPT_CODE and st.VOCABULARY_ID = 05 )
  ;

-- DEPRECATE MISSING
UPDATE  DEV.CONCEPT c
SET     VALID_END_DATE  = TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD') 
    ,  INVALID_REASON   = 'D'
WHERE 
 NOT EXISTS (SELECT 1 FROM CONCEPT_STAGE s WHERE c.CONCEPT_ID =  s.CONCEPT_ID)
AND     c.VALID_END_DATE = to_date('12312099','mmddyyyy')
AND     c.VALID_START_DATE < TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD')
AND c.VOCABULARY_ID   =   05
;

-- INSERT NEW
INSERT INTO DEV.CONCEPT(
    CONCEPT_ID, 
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS,
    VALID_START_DATE,
    VALID_END_DATE,
    INVALID_REASON)
SELECT 
    NVL(sou.CONCEPT_ID, DEV.SEQ_CONCEPT.NEXTVAL) AS CONCEPT_ID,
    TRIM(sou.CONCEPT_NAME), 
    sou.vocabulary_id, 
    sou.CONCEPT_LEVEL, 
    sou.CONCEPT_CODE,
    sou.CONCEPT_CLASS,
    TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD'),
    to_date('12312099','mmddyyyy'),
    --NVL2(sou.CONCEPT_ID,'V','N')
    INVALID_REASON  
FROM 
(
SELECT  
    (SELECT MIN(CONCEPT_ID) FROM 
    DEV.
    CONCEPT v
    WHERE  v.concept_code = c.concept_code AND v.VOCABULARY_ID = c.VOCABULARY_ID
    ) AS CONCEPT_ID,
    c.CONCEPT_NAME, 
    c.vocabulary_id, 
    c.CONCEPT_LEVEL, 
    c.CONCEPT_CODE,
    c.CONCEPT_CLASS,
    TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD') AS VALID_START_DATE,
    to_date('12312099','mmddyyyy') AS VALID_END_DATE,
    NULL AS INVALID_REASON
FROM    CONCEPT_STAGE c
WHERE   CONCEPT_ID  IS NULL
) sou
;
--commit;
exit;
