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
*  echo "EXIT" | sqlplus <user>/<pass> @03_load_maps.sql 
*
******************************************************************************/
SPOOL 03_load_maps.log
-- . 



--/*

UPDATE SOURCE_TO_CONCEPT_MAP_STAGE d
SET     (SOURCE_TO_CONCEPT_MAP_ID) = (    SELECT MAX(1)--  MIN(c.SOURCE_TO_CONCEPT_MAP_ID)
    FROM    DEV.SOURCE_TO_CONCEPT_MAP c 
    WHERE   d.SOURCE_CODE = c.SOURCE_CODE 
        AND d.SOURCE_VOCABULARY_ID = c.SOURCE_VOCABULARY_ID
        AND d.MAPPING_TYPE = c.MAPPING_TYPE
        AND d.TARGET_CONCEPT_ID = c.TARGET_CONCEPT_ID
        AND d.TARGET_VOCABULARY_ID = c.TARGET_VOCABULARY_ID
        AND NVL(d.PRIMARY_MAP,'X') = NVL(c.PRIMARY_MAP, 'X')
 --!       AND d.SOURCE_CODE_DESCRIPTION = c.SOURCE_CODE_DESCRIPTION
--        AND c.TARGET_VOCABULARY_CODE   =   '08'
AND NVL(c.INVALID_REASON,'X') <> 'D'
)
--WHERE d.TARGET_VOCABULARY_CODE   =   '08'
;




-- DEPRECATE MISSING
UPDATE  DEV.SOURCE_TO_CONCEPT_MAP c
SET     VALID_END_DATE      = TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD')-1,
        INVALID_REASON   = 'D'
WHERE 
  NOT EXISTS (SELECT 1 FROM SOURCE_TO_CONCEPT_MAP_STAGE d WHERE 
            d.SOURCE_CODE               = c.SOURCE_CODE 
        AND d.SOURCE_VOCABULARY_ID      = c.SOURCE_VOCABULARY_ID
        AND d.MAPPING_TYPE              = c.MAPPING_TYPE
        AND d.TARGET_CONCEPT_ID         = c.TARGET_CONCEPT_ID
        AND d.TARGET_VOCABULARY_ID      = c.TARGET_VOCABULARY_ID
        AND NVL(d.PRIMARY_MAP,'')       =  NVL(c.PRIMARY_MAP,'')
)
AND     c.VALID_END_DATE    = to_date('12312099','mmddyyyy')
AND     c.VALID_START_DATE  < TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD')
AND     c.SOURCE_VOCABULARY_ID IN (03)
AND     c.TARGET_VOCABULARY_ID IN (03)
 AND EXISTS (SELECT 1 FROM SOURCE_TO_CONCEPT_MAP_STAGE d WHERE 
            d.SOURCE_CODE               = c.SOURCE_CODE 
        AND d.SOURCE_VOCABULARY_ID    = c.SOURCE_VOCABULARY_ID
        AND d.MAPPING_TYPE              = c.MAPPING_TYPE
--        AND d.TARGET_CONCEPT_ID         = c.TARGET_CONCEPT_ID -- rule of depr
        AND d.TARGET_VOCABULARY_ID    = c.TARGET_VOCABULARY_ID
)
--AND NVL(c.PRIMARY_MAP,'') = 'Y' -- both cases
;

-- INSERT NEW
INSERT INTO DEV.SOURCE_TO_CONCEPT_MAP(
--  SOURCE_TO_CONCEPT_MAP_ID ,
  SOURCE_CODE              ,
  SOURCE_CODE_DESCRIPTION  ,
  MAPPING_TYPE             ,
  TARGET_CONCEPT_ID        ,
  TARGET_VOCABULARY_ID   ,
  SOURCE_VOCABULARY_ID   ,
  VALID_START_DATE,
  VALID_END_DATE,
  INVALID_REASON,
  PRIMARY_MAP       
  )
SELECT 
    --NVL(sou.SOURCE_TO_CONCEPT_MAP_ID, SEQ_CONCEPT_MAP.NEXTVAL    ) AS SOURCE_TO_CONCEPT_MAP_ID,
    sou.SOURCE_CODE, 
    sou.SOURCE_CODE_DESCRIPTION, 
    sou.MAPPING_TYPE, 
    sou.TARGET_CONCEPT_ID,
    sou.TARGET_VOCABULARY_ID,
    sou.SOURCE_VOCABULARY_ID,
    TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD') AS VALID_START_DATE,
    to_date('12312099','mmddyyyy'),
    --NVL2(sou.SOURCE_TO_CONCEPT_MAP_ID,'V','N')
    INVALID_REASON,
    PRIMARY_MAP AS PRIMARY_MAP 
FROM 
(
SELECT  DISTINCT 
    (SELECT MIN(SOURCE_TO_CONCEPT_MAP_ID) FROM DEV.SOURCE_TO_CONCEPT_MAP v
    WHERE  v.SOURCE_CODE = c.SOURCE_CODE 
        AND v.SOURCE_VOCABULARY_ID = c.SOURCE_VOCABULARY_ID
        AND v.MAPPING_TYPE = c.MAPPING_TYPE
        AND v.TARGET_CONCEPT_ID = c.TARGET_CONCEPT_ID
        AND v.TARGET_VOCABULARY_ID = c.TARGET_VOCABULARY_ID
    --!    AND v.SOURCE_CODE_DESCRIPTION = c.SOURCE_CODE_DESCRIPTION
    )  AS SOURCE_TO_CONCEPT_MAP_ID,
    --c.SOURCE_TO_CONCEPT_MAP_ID AS SOURCE_TO_CONCEPT_MAP_ID_ORIG,
    c.SOURCE_CODE, 
    c.SOURCE_CODE_DESCRIPTION, 
    c.MAPPING_TYPE, 
    c.TARGET_CONCEPT_ID,
    c.TARGET_VOCABULARY_ID,
    c.SOURCE_VOCABULARY_ID,
    --TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD') AS VALID_START_DATE,
    --to_date('12312099','mmddyyyy') AS VALID_END_DATE,
    NULL AS INVALID_REASON,
    PRIMARY_MAP AS PRIMARY_MAP
FROM    SOURCE_TO_CONCEPT_MAP_STAGE c
WHERE   SOURCE_TO_CONCEPT_MAP_ID  IS NULL
) sou
;

--*/

/* -- Need histor.load
UPDATE DEV.SOURCE_TO_CONCEPT_MAP d
SET     VALID_START_DATE      = (select  MIN(TO_DATE(STARTMARKETINGDATE,'YYYYMMDD'))  from FDA_NDC_PRODUCTS c    WHERE       d.SOURCE_CODE = c.PRODUCTNDC )
--        INVALID_REASON   = 'D'
WHERE d.SOURCE_VOCABULARY_ID IN (09) AND D.TARGET_VOCABULARY_ID IN (08)
AND EXISTS (select 1 from FDA_NDC_PRODUCTS c WHERE            d.SOURCE_CODE = c.PRODUCTNDC )
AND d.VALID_START_DATE <> (select  MIN(TO_DATE(STARTMARKETINGDATE,'YYYYMMDD'))  from FDA_NDC_PRODUCTS c    WHERE       d.SOURCE_CODE = c.PRODUCTNDC )
;

UPDATE DEV.SOURCE_TO_CONCEPT_MAP d
SET     VALID_END_DATE      = (select  MIN(TO_DATE(ENDMARKETINGDATE,'YYYYMMDD'))  from FDA_NDC_PRODUCTS c    WHERE       d.SOURCE_CODE = c.PRODUCTNDC )
--        INVALID_REASON   = 'D'
WHERE d.SOURCE_VOCABULARY_ID IN (09) AND D.TARGET_VOCABULARY_ID IN (08)
AND EXISTS (select 1 from FDA_NDC_PRODUCTS c WHERE            d.SOURCE_CODE = c.PRODUCTNDC  AND c.ENDMARKETINGDATE IS NOT NULL )
AND VALID_END_DATE      <> (select  MIN(TO_DATE(ENDMARKETINGDATE,'YYYYMMDD'))  from FDA_NDC_PRODUCTS c    WHERE       d.SOURCE_CODE = c.PRODUCTNDC )
--AND  TO_DATE(NVL(VALID_END_DATE, '20991231'),'YYYYMMDD')  <> VALID_END_DATE
;
--*/

--commit;
exit;