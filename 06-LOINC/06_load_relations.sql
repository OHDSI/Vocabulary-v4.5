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
*  Load new concept relationships into DEV schema,mark deprecated concept relatuionships as deleted
*  Transfer records from CONCEPT_RELATIONSHIP_STAGE to DEV.CONCEPT_RELATIONSHIP table
* 
*  Usage: 
*  echo "EXIT" |sqlplus RXNORM_20120131/myPass@DEV_VOCAB @06_load_relations.sql 
*
******************************************************************************/
SPOOL 06_load_relations.log
-- .  	


SELECT 'REL_ID  =   curr' FROM dual;

UPDATE CONCEPT_RELATIONSHIP_STAGE d
SET     (REL_ID) = (
    SELECT  MAX(1) --r.RELATIONSHIP_ID
    FROM    
    --PRD.
    DEV.
    CONCEPT_RELATIONSHIP r 
    WHERE   r.CONCEPT_ID_1 =   d.CONCEPT_ID_1
        AND r.CONCEPT_ID_2 =   d.CONCEPT_ID_2
	    AND r.RELATIONSHIP_ID = d.RELATIONSHIP_ID
);

commit;


-- "Восставшие из пепла"
 UPDATE DEV.CONCEPT_RELATIONSHIP d
 set  d.VALID_END_DATE = to_date('12312099','mmddyyyy'), d.INVALID_REASON = null
WHERE  EXISTS (SELECT   
    1 FROM CONCEPT_RELATIONSHIP_STAGE r 
        WHERE r.CONCEPT_ID_1 =   d.CONCEPT_ID_1
            AND r.CONCEPT_ID_2 =   d.CONCEPT_ID_2
            AND r.RELATIONSHIP_ID = d.RELATIONSHIP_ID)
AND NVL(d.INVALID_REASON, 'X') = ('D')                    
;  

-- DEPRECATE MISSING RELATIONSHIPS
SELECT 'DEPRECATE MISSING RELATIONSHIPS' FROM dual;

UPDATE  DEV.CONCEPT_RELATIONSHIP d
SET     VALID_END_DATE      = TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD'),
        INVALID_REASON   = 'D'
WHERE NOT EXISTS (SELECT --+ INDEX(r)  
    1 FROM CONCEPT_RELATIONSHIP_STAGE r 
        WHERE r.CONCEPT_ID_1 =   d.CONCEPT_ID_1
            AND r.CONCEPT_ID_2 =   d.CONCEPT_ID_2
            AND r.RELATIONSHIP_ID = d.RELATIONSHIP_ID)
AND     d.VALID_END_DATE = to_date('12312099','mmddyyyy')
AND     d.VALID_START_DATE < TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD')
AND D.RELATIONSHIP_ID NOT IN ( 1, 309, 311, 313, 135, 310 ,312, 314)
AND EXISTS (SELECT 1 FROM DEV.CONCEPT c1 
        WHERE c1.VOCABULARY_ID   IN (06,49) AND d.CONCEPT_ID_1 =   c1.CONCEPT_ID)
AND EXISTS (SELECT 1 FROM DEV.CONCEPT c2 
        WHERE c2.VOCABULARY_ID   IN (06,49) AND d.CONCEPT_ID_2 =   c2.CONCEPT_ID)
--AND D.RELATIONSHIP_ID NOT IN (2, 3, 4, 5, 6, 7, 8, 9, 136, 137, 138, 139, 140, 141, 142, 143)        
;

commit;

-- INSERT NEW RELATIONSHIPS
SELECT 'NEW RELATIONSHIPS' FROM dual;

INSERT INTO DEV.CONCEPT_RELATIONSHIP(
    --RELATIONSHIP_ID, 
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID,
    VALID_START_DATE,
    VALID_END_DATE,
    INVALID_REASON)
SELECT
    --NVL(sou.RELATIONSHIP_ID, SEQ_RELATIONSHIP.NEXTVAL) AS RELATIONSHIP_ID,
    sou.CONCEPT_ID_1, 
    sou.CONCEPT_ID_2, 
    sou.RELATIONSHIP_ID, 
    TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD'),
    to_date('12312099','mmddyyyy'),
    --NVL2(sou.RELATIONSHIP_ID,'V','N')
    INVALID_REASON 
FROM 
(
SELECT  
-- (SELECT RELATIONSHIP_ID FROM VOCABULARY.CONCEPT_RELATIONSHIP v
--	WHERE v.CONCEPT_ID_1 = c.CONCEPT_ID_1
--	AND v.CONCEPT_ID_2 = c.CONCEPT_ID_2
--	AND v.RELATIONSHIP_ID = c.RELATIONSHIP_ID
--    ) AS RELATIONSHIP_ID,
    c.CONCEPT_ID_1, 
    c.CONCEPT_ID_2, 
    c.RELATIONSHIP_ID, 
    TO_DATE(SUBSTR(USER, REGEXP_INSTR(user, '_[[:digit:]]')+1, 256),'YYYYMMDD') AS VALID_START_DATE,
    to_date('12312099','mmddyyyy') AS VALID_START_DATE,
    NULL AS INVALID_REASON
FROM    CONCEPT_RELATIONSHIP_STAGE c
WHERE   REL_ID  IS NULL
 AND RELATIONSHIP_ID NOT IN (998, 999)
) sou
;
commit;
--*/

UPDATE dev.concept c1
SET C1.INVALID_REASON = 'U'
,  VALID_END_DATE = (select max(VALID_START_DATE) from dev.concept cc WHERE C1.VOCABULARY_ID = CC.VOCABULARY_ID  )
WHERE exists (select 1 from DEV.CONCEPT_RELATIONSHIP r WHERE r.CONCEPT_ID_1 = C1.CONCEPT_ID
AND R.RELATIONSHIP_ID  IN ( 1, 309, 311, 313) )
AND NVL(C1.INVALID_REASON, 'X') <> 'U'
;

exit;
