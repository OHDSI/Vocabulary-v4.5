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
*  echo "EXIT" | sqlplus <user>/<pass> @02_load_maps.sql 
*
******************************************************************************/
SPOOL 02_transform_row_maps.log
-- . 

-- DROP SEQUENCE SEQ_CONCEPT_MAP;
-- CREATE SEQUENCE SEQ_CONCEPT_MAP START WITH 50000000;




-- Create temporary table for uploading concept. 
TRUNCATE TABLE  SOURCE_TO_CONCEPT_MAP_STAGE ;

--DELETE FROM    SOURCE_TO_CONCEPT_MAP_$1.
--WHERE   VOCABULARY_ID = '07'
--; 

--/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE( --02-->01
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
 icd9_code AS SOURCE_CODE 
,icd9_name AS SOURCE_CODE_DESCRIPTION 
, 'CONDITION' AS MAPPING_TYPE
, concept_ID AS TARGET_CONCEPT_ID
, 01 AS TARGET_CONCEPT_TYPE_ID
, 02 AS SOURCE_CONCEPT_TYPE_ID
, 'Y' AS PRIMARY_MAP
, 0 AS ISHANDMADE
FROM 
     ( select --'V'||
     c1.code AS icd9_code, c1.str AS icd9_name
        , c2.code AS snomed_code, c2.str AS snomed_name
        , nvl(c2.cvf, 0) as counts 
        , c2.ts, c2.tty, c2.suppress, c2.isPref
        , co1.concept_ID
        , rank() OVER( PARTITION BY c1.code 
              ORDER BY nvl( c2.cvf, 0 ) DESC
                     --, bestMatch( c1.str, c2.str ) DESC
                     , dbms_random.random ) AS ranking
     FROM --UMLS_20120702_ALL.
     UMLS.MRCONSO c1
     JOIN --UMLS_20120702_ALL.
     UMLS.MRCONSO c2 ON c2.cui = c1.cui
     JOIN DEV.concept co1 ON c2.code = co1.concept_code AND Co1.VOCABULARY_ID = 01   
    WHERE c1.sab='ICD9CM' 
          AND c1.tty = 'PT'
          AND c1.suppress != 'O'
      AND c2.sab='SNOMEDCT'
          AND c2.tty = 'PT'
          AND c2.suppress != 'O'
          AND c2.ts = 'P'
          AND c2.isPref = 'Y'
          --AND c1.code LIKE 'V56%'
          --AND c1.cui = 'C1135441'
AND EXISTS (SELECT 1 FROM
CMS_DESC_LONG_DX d WHERE c1.code  =  
 CASE WHEN SUBSTR(d.code,1,1) = 'V' THEN regexp_replace( d.code, '(V)([0-9][0-9])', '\1\2' )
       WHEN SUBSTR(d.code,1,1) = 'E' THEN regexp_replace( d.code, '(E)([0-9][0-9][0-9])([0-9]+)', '\1\2.\3' )
       ELSE regexp_replace( d.code, '^([0-9][0-9][0-9])([0-9]+)', '\1.\2' ) 
       END
)          
     )
 WHERE ranking = 1
/* 
 UNION ALL
 SELECT          
  SOURCE_CODE              ,
  SOURCE_CODE_DESCRIPTION  ,
  MAPPING_TYPE             ,
  TARGET_CONCEPT_ID        ,
  01   AS TARGET_VOCABULARY_ID   ,
  02 AS SOURCE_VOCABULARY_ID   ,
  'Y' AS PRIMARY_MAP,
  1 AS ISHANDMADE  
FROM 
--voc_v3.
--DEV.
dev.SOURCE_TO_CONCEPT_MAP_a D
WHERE 1 = 1 
 AND D.SOURCE_VOCABULARY_ID IN (02)
   AND D.TARGET_VOCABULARY_ID IN (01)
--AND D.SOURCE_VOCABULARY_CODE = 02
--AND D.TARGET_VOCABULARY_CODE = 01   
--   AND D.VALID_START_DATE =  TO_DATE('19800101', 'YYYYMMDD')
--*/
) sou
)
WHERE 1 = 1
--AND ISHANDMADE = 0
AND rn = 1   
;
--*/


--/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE( --02-->19
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
SELECT SOURCE_CODE, SOURCE_CODE_DESCRIPTION, MAPPING_TYPE,TARGET_CONCEPT_ID,TARGET_CONCEPT_TYPE_ID,SOURCE_CONCEPT_TYPE_ID, PRIMARY_MAP  
--,ISHANDMADE, RN
FROM ( 
SELECT sou.*, ROW_NUMBER() OVER (PARTITION BY  SOURCE_CODE ORDER BY ISHANDMADE DESC,  SOURCE_CODE_DESCRIPTION) rn
FROM (
SELECT
--/* 
  --DI.SEARCH_ICD9CM  AS SOURCE_CODE
  DI.SEARCH_ICD_CD   AS SOURCE_CODE
, d.NAME AS SOURCE_CODE_DESCRIPTION 
, 'INDICATION' AS MAPPING_TYPE
, c.concept_ID AS TARGET_CONCEPT_ID
, 19 AS TARGET_CONCEPT_TYPE_ID
, 02 AS SOURCE_CONCEPT_TYPE_ID
, 'Y' AS PRIMARY_MAP
, 0 AS ISHANDMADE
--*/
FROM       
    DEV.concept                    C
  --, RFMLISR0_ICD9CM_SEARCH         DI --!!!z
  , RFMLISR1_ICD_SEARCH         DI --!!!z
  ,  CMS_DESC_LONG_DX d
    WHERE 1 = 1
   AND C.VOCABULARY_ID = 19
   AND    TRIM(C.CONCEPT_CODE) = TRIM(DI.RELATED_DXID)
    --AND    TRIM(C.CONCEPT_CODE) = TRIM(DI.FML_CLIN_CODE)
    --AND    REPLACE( DI.SEARCH_ICD9CM, '.', '') = D.CODE    
   -- AND DI.SEARCH_ICD9CM =
--/*
    AND DI.SEARCH_ICD_CD =
       CASE WHEN SUBSTR(code,1,1) = 'V' THEN regexp_replace( code, '(V)([0-9][0-9])', '\1\2' )
       WHEN SUBSTR(code,1,1) = 'E' THEN regexp_replace( code, '(E)([0-9][0-9][0-9])([0-9]+)', '\1\2.\3' )
       ELSE regexp_replace( code, '^([0-9][0-9][0-9])([0-9]+)', '\1.\2' ) 
       END
--*/       
--AND  DI.SEARCH_ICD9CM IN ('200.88', '851.06')
AND  ICD_CD_TYPE in ('01','02', '03', '04')
AND SUBSTR(FML_NAV_CODE, 1,2)  = '02'      
/* 
 UNION ALL
 SELECT          
  SOURCE_CODE              ,
  SOURCE_CODE_DESCRIPTION  ,
  MAPPING_TYPE             ,
  TARGET_CONCEPT_ID        ,
  TARGET_VOCABULARY_ID   ,
  SOURCE_VOCABULARY_ID   ,
  PRIMARY_MAP,
  1 AS ISHANDMADE
FROM DEV.SOURCE_TO_CONCEPT_MAP D
WHERE  D.SOURCE_VOCABULARY_ID IN (02)
   AND D.TARGET_VOCABULARY_ID IN (19)
   AND D.VALID_START_DATE =  TO_DATE('19800101', 'YYYYMMDD')
--*/   
) sou
)
WHERE 1 = 1
--AAAAND ISHANDMADE = 0
AND rn = 1   
;

--/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE( --02-->00
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
 icd9_code AS SOURCE_CODE 
,icd9_name AS SOURCE_CODE_DESCRIPTION 
, 'CONDITION' AS MAPPING_TYPE
, concept_ID AS TARGET_CONCEPT_ID
, 00 AS TARGET_CONCEPT_TYPE_ID
, 02 AS SOURCE_CONCEPT_TYPE_ID
, 'Y' AS PRIMARY_MAP
, 0 AS ISHANDMADE
FROM 
     (
      select CASE WHEN SUBSTR(code,1,1) = 'V' THEN regexp_replace( code, '(V)([0-9][0-9])', '\1\2' )
       WHEN SUBSTR(code,1,1) = 'E' THEN regexp_replace( code, '(E)([0-9][0-9][0-9])([0-9]+)', '\1\2.\3' )
       ELSE regexp_replace( code, '^([0-9][0-9][0-9])([0-9]+)', '\1.\2' ) 
  END AS icd9_code, substr(name,1,256) AS icd9_name
        --, c1.code AS snomed_code, c1.str AS snomed_name
        --, nvl(c2.cvf, 0) as counts 
        --, c2.ts, c2.tty, c2.suppress, c2.isPref
        , 0 as concept_ID
        , rank() OVER( PARTITION BY c1.code 
              ORDER BY nvl( c1.code, 0 ) DESC
                     --, bestMatch( c1.str, c2.str ) DESC
                     , dbms_random.random ) AS ranking
     FROM 
     CMS_DESC_LONG_DX c1
    WHERE 1= 1     
/*     
      select c1.code AS icd9_code, c1.str AS icd9_name
        --, c1.code AS snomed_code, c1.str AS snomed_name
        --, nvl(c2.cvf, 0) as counts 
        --, c2.ts, c2.tty, c2.suppress, c2.isPref
        , 0 as concept_ID
        , rank() OVER( PARTITION BY c1.code 
              ORDER BY nvl( c1.code, 0 ) DESC
                     --, bestMatch( c1.str, c2.str ) DESC
                     , dbms_random.random ) AS ranking
     FROM --UMLS_20120702_ALL.
     UMLS.MRCONSO c1
    WHERE c1.sab='ICD9CM' 
          AND c1.tty = 'PT'
          AND c1.suppress != 'O'    
--*/           
AND NOT EXISTS (select 1 FROM SOURCE_TO_CONCEPT_MAP_STAGE m where M.SOURCE_CODE = --c1.code
CASE WHEN SUBSTR(code,1,1) = 'V' THEN regexp_replace( code, '(V)([0-9][0-9])', '\1\2' )
       WHEN SUBSTR(code,1,1) = 'E' THEN regexp_replace( code, '(E)([0-9][0-9][0-9])([0-9]+)', '\1\2.\3' )
       ELSE regexp_replace( code, '^([0-9][0-9][0-9])([0-9]+)', '\1.\2' ) 
  END
 )
--AND c1.code LIKE 'V56%'          
          )
 WHERE ranking = 1
) sou
)
WHERE 1 = 1
--AND ISHANDMADE = 0
AND rn = 1   
;
--*/


UPDATE--,vm.SOURCE_VOCABULARY_ID
SOURCE_TO_CONCEPT_MAP_STAGE vm
set MAPPING_TYPE = 
 (select 
case when c.concept_class = 'Body structure' THEN 'CONDITION'
 when c.concept_class = 'Context-dependent category' THEN 'CONDITION-OBS'
 when c.concept_class = 'Event' THEN 'CONDITION-OBS'
 when c.concept_class = 'Morphologic abnormality' THEN 'CONDITION'
 when c.concept_class = 'Observable entity' THEN 'CONDITION'
 when c.concept_class = 'Procedure' THEN 'CONDITION-PROCEDURE'
 when c.concept_class = 'Qualifier value' THEN 'CONDITION-OBS'
 when c.concept_class = 'Specimen' THEN 'CONDITION-OBS'
 when c.concept_class = 'Clinical finding' THEN 'CONDITION'
ELSE 'N|A' 
end 
from DEV.CONCEPT c where
VOCABULARY_ID = 01 and vm.TARGET_CONCEPT_ID = c.concept_id 
) 
where 1 = 1 AND vm.SOURCE_VOCABULARY_ID = 02
and TARGET_VOCABULARY_ID = 01
;

--UPDATE
----DEV.SOURCE_TO_CONCEPT_MAP vm
--SOURCE_TO_CONCEPT_MAP_STAGE vm
--set MAPPING_TYPE ='CONDITION-OBS'
--where 1 = 1 AND vm.SOURCE_VOCABULARY_ID = 02
--and TARGET_VOCABULARY_ID = 01
--AND vm.SOURCE_CODE = 'V17.41'
--;

--UPDATE
----DEV.SOURCE_TO_CONCEPT_MAP m
--SOURCE_TO_CONCEPT_MAP_STAGE m
--set MAPPING_TYPE ='CONDITION-OBS'
--where 1 = 1
--AND lower(M.SOURCE_CODE_DESCRIPTION) LIKE '%history%'
--AND M.SOURCE_CODE LIKE  'V%'
--AND M.TARGET_VOCABULARY_ID = 1
--AND M.SOURCE_VOCABULARY_ID = 2
--;


UPDATE SOURCE_TO_CONCEPT_MAP_STAGE d
SET     ( MAPPING_TYPE) = (    SELECT MAX(MAPPING_TYPE)--  MIN(c.SOURCE_TO_CONCEPT_MAP_ID)
    FROM    DEV.SOURCE_TO_CONCEPT_MAP c 
    WHERE   d.SOURCE_CODE = c.SOURCE_CODE 
        AND d.SOURCE_VOCABULARY_ID = c.SOURCE_VOCABULARY_ID
        --AND d.MAPPING_TYPE = c.MAPPING_TYPE
        AND d.TARGET_CONCEPT_ID = c.TARGET_CONCEPT_ID
        AND d.TARGET_VOCABULARY_ID = c.TARGET_VOCABULARY_ID
        AND NVL(d.PRIMARY_MAP,'X') = NVL(c.PRIMARY_MAP, 'X')
 --!       AND d.SOURCE_CODE_DESCRIPTION = c.SOURCE_CODE_DESCRIPTION
--        AND c.TARGET_VOCABULARY_CODE   =   '08'
)
WHERE EXISTS (select 1 from DEV.SOURCE_TO_CONCEPT_MAP c 
    WHERE   d.SOURCE_CODE = c.SOURCE_CODE 
        AND d.SOURCE_VOCABULARY_ID = c.SOURCE_VOCABULARY_ID
        --AND d.MAPPING_TYPE = c.MAPPING_TYPE
        AND d.TARGET_CONCEPT_ID = c.TARGET_CONCEPT_ID
        AND d.TARGET_VOCABULARY_ID = c.TARGET_VOCABULARY_ID
        AND NVL(d.PRIMARY_MAP,'X') = NVL(c.PRIMARY_MAP, 'X'))
;


----- START Remap --
drop table historical_tree;

create table historical_tree as 
SELECT root, CONCEPT_ID_2 FROM (
select root, CONCEPT_ID_2, dt,  ROW_NUMBER() OVER (PARTITION BY  root ORDER BY dt desc) rn
  from (
SELECT rownum rn, level lv, LPAD(' ', 8 * level) || C1.CONCEPT_NAME||'-->'||C2.CONCEPT_NAME tree, r.CONCEPT_ID_1, r.CONCEPT_ID_2, R.RELATIONSHIP_ID
,R.VALID_START_DATE dt
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
AND rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID  AND r.RELATIONSHIP_ID IN (1, 309, 311, 313)
and NVL(r.INVALID_REASON, 'X') <> 'D'
AND C1.CONCEPT_ID = R.CONCEPT_ID_1
AND C2.CONCEPT_ID = R.CONCEPT_ID_2
CONNECT BY  
NOCYCLE  
PRIOR r.CONCEPT_ID_2 = r.CONCEPT_ID_1
AND rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID  AND r.RELATIONSHIP_ID IN (1, 309, 311, 313)
and NVL(r.INVALID_REASON, 'X') <> 'D'
     START WITH 
   rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID  AND r.RELATIONSHIP_ID IN (1, 309, 311, 313)
and NVL(r.INVALID_REASON, 'X') <> 'D'
) sou 
WHERE lf = 1
--AND root = 1143407
) WHERE rn = 1
;

CREATE INDEX X_HI_TREE ON HISTORICAL_TREE (ROOT);

UPDATE SOURCE_TO_CONCEPT_MAP_STAGE m
SET TARGET_CONCEPT_ID = (SELECT CONCEPT_ID_2 FROM historical_tree t WHERE M.TARGET_CONCEPT_ID = t.root )
WHERE EXISTS (SELECT 1 FROM historical_tree tt WHERE M.TARGET_CONCEPT_ID = tt.root )
;

----- END Remap --





-- load existing concept/vocabulary ids from DEV

UPDATE SOURCE_TO_CONCEPT_MAP_STAGE s
SET 
    (TARGET_CONCEPT_ID, TARGET_VOCABULARY_ID) = (
	SELECT TARGET_CONCEPT_ID, TARGET_VOCABULARY_ID
	FROM DEV.SOURCE_TO_CONCEPT_MAP d
	WHERE 
	    ROWNUM = 1
	    AND d.SOURCE_CODE = s.SOURCE_CODE
	    AND d.SOURCE_VOCABULARY_ID = s.SOURCE_VOCABULARY_ID
	    AND d.MAPPING_TYPE = s.MAPPING_TYPE
            AND NVL(d.PRIMARY_MAP,'X') = NVL(s.PRIMARY_MAP, 'X')
            AND NVL(d.INVALID_REASON,'X') <> 'D'
    )
WHERE
    TARGET_CONCEPT_ID = 0 AND TARGET_VOCABULARY_ID = 0
    AND EXISTS (
	SELECT 1 FROM DEV.SOURCE_TO_CONCEPT_MAP d
	WHERE 
	    d.SOURCE_CODE = s.SOURCE_CODE
	    AND d.SOURCE_VOCABULARY_ID = s.SOURCE_VOCABULARY_ID
	    AND d.MAPPING_TYPE = s.MAPPING_TYPE
            AND NVL(d.PRIMARY_MAP,'X') = NVL(s.PRIMARY_MAP, 'X')
            AND NVL(d.INVALID_REASON,'X') <> 'D'
    )
;
    
exit;