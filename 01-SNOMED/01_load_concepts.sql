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
*  echo "EXIT" |sqlplus SNOMED_20120131/myPass@DEV_VOCAB @01_load_concepts.sql  
*
******************************************************************************/
SPOOL 01_load_concepts.log

-- get existing concept_ids from DEV

UPDATE CONCEPT_STAGE d
SET     (concept_id) = (
    SELECT  c.concept_id
    FROM    DEV.CONCEPT c 
    WHERE   c.concept_code =   d.concept_code
        AND c.VOCABULARY_ID   =   01
)
WHERE d.VOCABULARY_ID   =   01
;

-- update names of existing concepts

UPDATE dev.concept c
 set C.CONCEPT_NAME = (select st.CONCEPT_NAME from CONCEPT_STAGE st  WHERE C.CONCEPT_CODE = st.CONCEPT_CODE and st.VOCABULARY_ID = 01 ) 
 , C.VALID_END_DATE = to_date('12312099','mmddyyyy'), C.INVALID_REASON = null
 WHERE C.VOCABULARY_ID = 01
  AND NVL(c.INVALID_REASON, 'X') = ('D')      
 AND  exists (select 1 from CONCEPT_STAGE st  WHERE C.CONCEPT_CODE = st.CONCEPT_CODE and st.VOCABULARY_ID = 01 )
  ;

-- DEPRECATE MISSING
UPDATE  DEV.CONCEPT c
SET     VALID_END_DATE  = TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD') 
    ,  INVALID_REASON   = 'D'
WHERE 
 NOT EXISTS (SELECT 1 FROM CONCEPT_STAGE s WHERE c.CONCEPT_ID =  s.CONCEPT_ID)
AND     c.VALID_END_DATE = to_date('12312099','mmddyyyy')
AND     c.VALID_START_DATE < TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD')
AND c.VOCABULARY_ID   =   01
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
    DEV.SEQ_CONCEPT.NEXTVAL AS CONCEPT_ID,
    TRIM(sou.CONCEPT_NAME), 
    sou.vocabulary_id, 
    sou.CONCEPT_LEVEL, 
    sou.CONCEPT_CODE,
    sou.CONCEPT_CLASS,
    TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD'),
    to_date('12312099','mmddyyyy'),
    INVALID_REASON  
FROM 
(
SELECT  
    c.CONCEPT_NAME, 
    c.vocabulary_id,
    c.CONCEPT_LEVEL, 
    c.CONCEPT_CODE,
    c.CONCEPT_CLASS,
    TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD') AS VALID_START_DATE,
    to_date('12312099','mmddyyyy') AS VALID_END_DATE,
    NULL AS INVALID_REASON
FROM    CONCEPT_STAGE c
WHERE NOT EXISTS(SELECT * FROM DEV.CONCEPT d WHERE  d.concept_code = c.concept_code AND d.VOCABULARY_ID = c.VOCABULARY_ID)
) sou
;

--/* --Class FROM descr
UPDATE  dev.concept c
SET CONCEPT_CLASS = (SELECT cs.CONCEPT_CLASS FROM CONCEPT_STAGE cs 
where  CS.VOCABULARY_ID = 01 AND C.CONCEPT_ID = CS.CONCEPT_ID
--AND c.CONCEPT_CLASS <> 'UNKNOWN' 
)
where  C.VOCABULARY_ID = 01
AND EXISTS (SELECT 1 FROM CONCEPT_STAGE css 
where  CSS.VOCABULARY_ID = 01 AND C.CONCEPT_ID = CSS.CONCEPT_ID)
AND c.CONCEPT_CLASS <> (SELECT cs.CONCEPT_CLASS FROM CONCEPT_STAGE cs 
where  CS.VOCABULARY_ID = 01 AND C.CONCEPT_ID = CS.CONCEPT_ID 
and rownum <= 1
)
;

-- update existing concept_ids from DEV

UPDATE CONCEPT_STAGE d
SET     (concept_id) = (
    SELECT  c.concept_id
    FROM    DEV.CONCEPT c 
    WHERE   c.concept_code =   d.concept_code
        AND c.VOCABULARY_ID   =   01
)
WHERE d.VOCABULARY_ID   =   01
;


exit;
