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
*  Load NDF-RT concepts in the staging data
*  Usage: 
*  echo "EXIT" | sqlplus Dev/<password> @xx_set_concept_class.sql 01312012
*
******************************************************************************/

SPOOL 01_set_concept_class.log

--SELECT 'START' FROM dual;

--DECLARE vCONCEPT_CLASS varchar(60);

--BEGIN


--SELECT substr(C.CONCEPT_NAME,1, 60) INTO vCONCEPT_CLASS
--FROM CONCEPT c
--WHERE C.CONCEPT_ID = &2.
--;
-- .

--TRUNCATE TABLE  CONCEPT_TRE_&1.
--;

--------------AFTER 01_build_tree.sql_01312012_4008453_441840 & 4322976

/* -- Class from tree
UPDATE DEV.concept c
   SET c.concept_class =
          (SELECT MIN (t.ANCESTOR_CONCEPT_ID)
             FROM CONCEPT_TREE_STAGE t
            WHERE t.DESCENDANT_CONCEPT_ID = c.concept_id)
 WHERE c.VOCABULARY_ID = 01
       AND EXISTS
              (SELECT 1
                 FROM CONCEPT_TREE_STAGE tt
                WHERE tt.DESCENDANT_CONCEPT_ID = c.concept_id);


UPDATE DEV.concept c
   SET c.concept_class =
          (SELECT SUBSTR (cc.concept_name, 1, 60)
             FROM DEV.concept cc
            WHERE c.concept_class = cc.concept_id)
 WHERE c.VOCABULARY_ID = 01
       AND EXISTS
              (SELECT 1
                 FROM CONCEPT_TREE_STAGE tt
                WHERE tt.DESCENDANT_CONCEPT_ID = c.concept_id);
--*/



--/*

UPDATE CONCEPT_STAGE c
   SET c.concept_LEVEL = 0
 WHERE c.VOCABULARY_ID = 01 AND c.concept_id NOT IN (441840, 4322976);


UPDATE CONCEPT_STAGE c
   SET c.concept_LEVEL = 3
 WHERE c.VOCABULARY_ID = 01 AND c.concept_id IN (441840, 4322976);

UPDATE CONCEPT_STAGE c
   SET c.concept_LEVEL = 2
 WHERE c.VOCABULARY_ID = 01 AND c.concept_id NOT IN (441840, 4322976)
       AND C.CONCEPT_CLASS IN ('Procedure', 'Clinical finding')
;

UPDATE CONCEPT_STAGE c
   SET c.concept_LEVEL = 1
 WHERE c.VOCABULARY_ID = 01 AND c.concept_id NOT IN (441840, 4322976)
       AND C.CONCEPT_CLASS IN ('Procedure', 'Clinical finding')
       AND NOT EXISTS
              (SELECT 1
                 FROM CONCEPT_ANCESTOR_STAGE tt
                WHERE tt.ANCESTOR_CONCEPT_ID = c.concept_id
                AND TT.MAX_LEVELS_OF_SEPARATION <> 0 AND TT.MIN_LEVELS_OF_SEPARATION <> 0 );


--UPDATE CONCEPT_STAGE c
--   SET c.concept_LEVEL = 2
-- WHERE c.VOCABULARY_ID = 01 AND c.concept_id NOT IN (441840, 4322976)
--       AND EXISTS
--              (SELECT 1
--                 FROM CONCEPT_TREE_STAGE tt
--                WHERE tt.DESCENDANT_CONCEPT_ID = c.concept_id
--                      AND tt.MIN_LEVELS_OF_SEPARATION = 0);
--
--UPDATE CONCEPT_STAGE c
--   SET c.concept_LEVEL = 1
-- WHERE c.VOCABULARY_ID = 01 AND c.concept_id NOT IN (441840, 4322976)
--       AND EXISTS
--              (SELECT 1
--                 FROM CONCEPT_TREE_STAGE tt
--                WHERE tt.DESCENDANT_CONCEPT_ID = c.concept_id
--                      AND tt.MIN_LEVELS_OF_SEPARATION = 1);

--*/

UPDATE  dev.concept c
SET concept_LEVEL = (SELECT cs.concept_LEVEL FROM CONCEPT_STAGE cs 
where  CS.VOCABULARY_ID = 01 AND C.CONCEPT_ID = CS.CONCEPT_ID
--AND c.CONCEPT_CLASS <> 'UNKNOWN' 
)
where  C.VOCABULARY_ID = 01
AND EXISTS (SELECT 1 FROM CONCEPT_STAGE css 
where  CSS.VOCABULARY_ID = 01 AND C.CONCEPT_ID = CSS.CONCEPT_ID);

EXIT;