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
*  echo "EXIT" | sqlplus <user>/<pass> @06_load_maps.sql 
*
******************************************************************************/
SPOOL 06_transform_row_maps.log
-- . 

-- DROP SEQUENCE SEQ_CONCEPT_MAP;
-- CREATE SEQUENCE SEQ_CONCEPT_MAP START WITH 50000000;




-- Create temporary table for uploading concept. 
TRUNCATE TABLE  SOURCE_TO_CONCEPT_MAP_STAGE ;

--DELETE FROM    SOURCE_TO_CONCEPT_MAP_$1.
--WHERE   VOCABULARY_ID = '07'
--; 

--/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE( --06-->06
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
SELECT SOURCE_CODE, SOURCE_CODE_DESCRIPTION, MAPPING_TYPE,TARGET_CONCEPT_ID,TARGET_VOCABULARY_ID,SOURCE_VOCABULARY_ID, PRIMARY_MAP  
--,ISHANDMADE, RN
FROM ( 
SELECT sou.*, ROW_NUMBER() OVER (PARTITION BY  SOURCE_CODE ORDER BY ISHANDMADE DESC,  SOURCE_CODE_DESCRIPTION) rn
FROM (
SELECT 
  CO1.CONCEPT_CODE AS SOURCE_CODE 
, CO1.CONCEPT_NAME AS SOURCE_CODE_DESCRIPTION 
, 'OBSERVATION' AS MAPPING_TYPE
, DV.concept_ID AS TARGET_CONCEPT_ID
, 06 AS TARGET_VOCABULARY_ID
, 06 AS SOURCE_VOCABULARY_ID
, 'Y' AS PRIMARY_MAP
, 0 AS ISHANDMADE
     FROM concept_STAGE Co1
     , DEV.concept dv
WHERE     
  Co1.VOCABULARY_ID = 06
  AND DV.VOCABULARY_ID = 06
  AND CO1.CONCEPT_CODE = DV.CONCEPT_CODE       
) sou
)
WHERE 1 = 1
--AND ISHANDMADE = 0
AND rn = 1
--AND TARGET_CONCEPT_ID IS NOT NULL   
;
--*/


----- START Remap --
drop table historical_tree;

create table historical_tree as 
select root, CONCEPT_ID_2  from (
SELECT rownum rn, level lv, LPAD(' ', 8 * level) || C1.CONCEPT_NAME||'-->'||C2.CONCEPT_NAME tree, r.CONCEPT_ID_1, r.CONCEPT_ID_2, R.RELATIONSHIP_ID
,C1.CONCEPT_CODe ||'-->'||C2.CONCEPT_CODe  tree_code
,C1.VOCABULARY_ID||'-->'||C2.VOCABULARY_ID tree_voc
,C1.CONCEPT_LEVEL||'-->'||C2.CONCEPT_LEVEL tree_lv
,C1.CONCEPT_CLASS||'-->'||C2.CONCEPT_CLASS tree_cl
, CONNECT_BY_ISCYCLE iscy
, CONNECT_BY_ROOT CONCEPT_ID_1 root
, CONNECT_BY_ISLEAF lf
FROM    DEV.CONCEPT_RELATIONSHIP r
, DEV.RELATIONSHIP rt
, DEV.CONCEPT c1
, DEV.CONCEPT c2
WHERE 1 = 1
AND rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID  AND r.RELATIONSHIP_ID = 309
and NVL(r.INVALID_REASON, 'X') <> 'D'
AND C1.CONCEPT_ID = R.CONCEPT_ID_1
AND C2.CONCEPT_ID = R.CONCEPT_ID_2
CONNECT BY  
NOCYCLE  
PRIOR r.CONCEPT_ID_2 = r.CONCEPT_ID_1
AND rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID  AND r.RELATIONSHIP_ID = 309
and NVL(r.INVALID_REASON, 'X') <> 'D'
     START WITH 
   rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID  AND r.RELATIONSHIP_ID = 309
and NVL(r.INVALID_REASON, 'X') <> 'D'
) sou 
WHERE lf = 1
;

CREATE INDEX X_HI_TREE ON HISTORICAL_TREE (ROOT);

UPDATE SOURCE_TO_CONCEPT_MAP_STAGE m
SET TARGET_CONCEPT_ID = (SELECT CONCEPT_ID_2 FROM historical_tree t WHERE M.TARGET_CONCEPT_ID = t.root )
WHERE EXISTS (SELECT 1 FROM historical_tree tt WHERE M.TARGET_CONCEPT_ID = tt.root )
;

----- END Remap --

exit;