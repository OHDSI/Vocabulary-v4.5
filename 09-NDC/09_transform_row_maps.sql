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
*  echo "EXIT" | sqlplus <user>/<pass> @09_load_maps.sql 
*
******************************************************************************/
SPOOL 09_transform_row_maps.log
-- . 

-- DROP SEQUENCE SEQ_CONCEPT_MAP;
-- CREATE SEQUENCE SEQ_CONCEPT_MAP START WITH 50000000;




-- Create temporary table for uploading concept. 
TRUNCATE TABLE  SOURCE_TO_CONCEPT_MAP_STAGE ;

--DELETE FROM    SOURCE_TO_CONCEPT_MAP_$1.
--WHERE   VOCABULARY_ID = '07'
--; 

--/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE( --09-->08
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
SELECT
 SUBSTR(SOURCE_CODE, 1, 20) AS SOURCE_CODE, SOURCE_CODE_DESCRIPTION, MAPPING_TYPE,TARGET_CONCEPT_ID,TARGET_VOCABULARY_ID,SOURCE_VOCABULARY_ID, PRIMARY_MAP  FROM ( 
SELECT sou.*, ROW_NUMBER() OVER (PARTITION BY  SOURCE_CODE, PRIMARY_MAP 
ORDER BY PRIMARY_MAP desc, priory
, TARGET_CONCEPT_ID DESC
) rn 
FROM (
--/*
SELECT DISTINCT --09-->08 RxNorm
SUBSTR(s.ATV, 1, 20) AS SOURCE_CODE        
,SUBSTR (c.str--||' rxnsat'
, 1, 256) AS SOURCE_CODE_DESCRIPTION    
,'DRUG' AS MAPPING_TYPE        
,C1.CONCEPT_ID AS TARGET_CONCEPT_ID    
,C1.VOCABULARY_ID AS TARGET_VOCABULARY_ID    
,09 --C2.VOCABULARY_ID
 AS SOURCE_VOCABULARY_ID
 --, C1.CONCEPT_CLASS
 --, C1.CONCEPT_LEVEL
 , CASE WHEN C1.CONCEPT_LEVEL = 1 THEN
            CASE WHEN C1.CONCEPT_CLASS = 'Branded Drug' THEN 0    ELSE 9   END
        WHEN C1.CONCEPT_LEVEL = 2 THEN
            CASE WHEN C1.CONCEPT_CLASS = 'Ingredient' THEN 0    ELSE 9   END
   ELSE 9 
   END AS priory 
   , 'Y' AS PRIMARY_MAP
 --, c.*
 FROM 
     DEV.CONCEPT c1 
  ,  rxnsat s 
  ,  rxnConso c
 WHERE 1 = 1 
AND s.sab='RXNORM' and s.atn='NDC'
AND c.sab='RXNORM'
AND c.RxAUI = s.RxAUI--2967275
AND c.RxCUI = s.RxCUI 
--AND ATV IN ('58160081541','60491050120','60760041914','60760041960')
  AND C1.VOCABULARY_ID  = 08
  AND c.rxcui = C1.CONCEPT_CODE  
UNION ALL
--*/
SELECT 
 SUBSTR(M.NDC, 1, 20) AS SOURCE_CODE --09-->08 FDB ATC
,substr(M.LN--||' RATCGC0_ATC'
, 1, 256) AS SOURCE_CODE_DESCRIPTION 
, 'DRUG' AS MAPPING_TYPE
, NVL(C.CONCEPT_ID_2, 0) AS TARGET_CONCEPT_ID
, 08 AS  TARGET_VOCABULARY_ID
, 09 AS  SOURCE_VOCABULARY_ID
, 10 AS priory 
, 'Y' AS PRIMARY_MAP
FROM 
      (      SELECT DISTINCT
             r.code,
             C.CONCEPT_CODE,
             r.str,
             C.CONCEPT_ID        concept_id_2,
             C.concept_name,
             c.concept_class,
             NULL AS PRIMARY_MAP
      FROM   rxnconso               R,
             DEV.concept            C
      WHERE  R.sab = 'NDDF'
      AND    R.tty NOT IN ('DF', 'IN')
      AND    R.rxcui = C.CONCEPT_CODE
      AND    C.VOCABULARY_ID = 08
      ORDER BY r.code
)C,
      --   RATCGC0_ATC_GCNSEQNO_LINK   L
      -- , DEV.concept                 RC
        RNDC14_NDC_MSTR             m
WHERE  1 = 1
--AND (C.code) = (L.GCN_SEQNO)
--AND    (l.atc) = (rc.concept_code)
--AND    rc.VOCABULARY_ID = 21   
AND c.code(+)  = m.GCN_SEQNO
UNION ALL
SELECT
 SUBSTR(M.NDC, 1, 20) AS SOURCE_CODE --09-->08 ETC
,substr(M.LN--||'RETCGC0_ETC'
,1,256) AS SOURCE_CODE_DESCRIPTION 
, 'DRUG' AS MAPPING_TYPE
, NVL(C.CONCEPT_ID_2, 0) AS TARGET_CONCEPT_ID
, 08 AS TARGET_CONCEPT_TYPE_ID
, 09 AS SOURCE_CONCEPT_TYPE_ID
, 11 AS priory
, 'Y' AS PRIMARY_MAP
FROM 
      (
      SELECT DISTINCT
             r.code,
             r.str,
             C.CONCEPT_ID        concept_id_2,
             C.concept_name,
             c.concept_class,
             NULL AS PRIMARY_MAP
      FROM   rxnconso               R,
             --vocabulary.
             DEV.concept            C
      WHERE  R.sab = 'NDDF'
      AND    R.tty NOT IN ('DF', 'IN')
      AND    R.rxcui = C.CONCEPT_CODE
      AND    C.VOCABULARY_ID = '08'
      ORDER BY r.code
      )  C,
  --       RETCGC0_ETC_GCNSEQNO      L
  --     , DEV.concept               RC
        RNDC14_NDC_MSTR           m
WHERE 1 = 1
--AND (C.code) = (L.GCN_SEQNO)
--AND    (l.etc_id) = (rc.concept_code)
--AND    rc.VOCABULARY_ID = 20
AND c.code(+) = m.GCN_SEQNO
--/* --  MKhayter: Sergey, remove FDA mapping of NDC codes. FDA mappings are not correct.
UNION ALL
SELECT 
      CASE when length(PRODUCTNDC) = 9 then '0'||replace(p.PRODUCTNDC, '-', '') 
else replace(p.PRODUCTNDC, '-', '')  
END  AS source_code
    , SUBSTR(nonproprietaryname||' '||ACTIVE_NUMERATOR_STRENGTH||' '||ACTIVE_INGRED_UNIT
    ||' '||DOSAGEFORMNAME||' '||'['||PROPRIETARYNAME||']'--||' FDA'
    , 1, 256) AS source_code_description
    , 'DRUG' AS mapping_type
, 0 AS Target_concept_id
, 0 AS target_vocabulary_id
, 09 AS source_vocabulary_id
--, TO_DATE(STARTMARKETINGDATE,'YYYYMMDD')  AS VALID_START_DATE
--, TO_DATE(NVL(ENDMARKETINGDATE, '20991231'),'YYYYMMDD')  AS VALID_END_DATE
, 12 AS priory
, 'Y' AS PRIMARY_MAP
FROM FDA_NDC_PRODUCTS p
--*/
------
/* -- one time
UNION ALL
SELECT 
      source_code AS source_code
    ,  source_code_description AS source_code_description
    , 'DRUG' AS mapping_type
, Target_concept_id AS Target_concept_id
, 08 AS target_vocabulary_id
, 09 AS source_vocabulary_id
, 13 AS priory
, 'Y' AS PRIMARY_MAP
FROM DEV.SOURCE_TO_CONCEPT_MAP d
WHERE d.SOURCE_VOCABULARY_ID      = 9
        AND d.TARGET_VOCABULARY_ID      = 8
AND d.PRIMARY_MAP IS NULL
--*/
)sou
WHERE 1 = 1
--AND SOURCE_CODE = '00002411201'
) WHERE  rn = 1
--lower(SOURCE_CODE_DESCRIPTION) like '%orlistat%120%'
--AND SOURCE_CODE LIKE '%256%'
--AND Target_concept_id = 0
;

commit;

update SOURCE_TO_CONCEPT_MAP_STAGE n
set TARGET_CONCEPT_ID = 
NVL((
SELECT MAX(M.TARGET_CONCEPT_ID ) FROM SOURCE_TO_CONCEPT_MAP_STAGE m
WHERE M.SOURCE_VOCABULARY_ID = 9
AND M.TARGET_VOCABULARY_ID = 8
AND M.SOURCE_CODE = n.SOURCE_CODE
),0), TARGET_VOCABULARY_ID = 8
WHERE TARGET_CONCEPT_ID =0 ;
commit;

update SOURCE_TO_CONCEPT_MAP_STAGE n
set TARGET_CONCEPT_ID = 
NVL((
SELECT MAX(M.TARGET_CONCEPT_ID ) FROM SOURCE_TO_CONCEPT_MAP_STAGE m
WHERE M.SOURCE_VOCABULARY_ID = 9
AND M.TARGET_VOCABULARY_ID = 8
AND SUBSTR(M.SOURCE_CODE,1,9) = SUBSTR(n.SOURCE_CODE,1,9)
), 0), TARGET_VOCABULARY_ID = 8
WHERE TARGET_CONCEPT_ID = 0 ;
commit;
update SOURCE_TO_CONCEPT_MAP_STAGE n
set TARGET_CONCEPT_ID = 
NVL((
SELECT MAX(M.TARGET_CONCEPT_ID ) FROM DEV.SOURCE_TO_CONCEPT_MAP m
WHERE M.SOURCE_VOCABULARY_ID = 9
AND M.TARGET_VOCABULARY_ID = 8
AND M.SOURCE_CODE = n.SOURCE_CODE
),0), TARGET_VOCABULARY_ID = 8
WHERE TARGET_CONCEPT_ID =0 ;
commit;
update SOURCE_TO_CONCEPT_MAP_STAGE n
set TARGET_CONCEPT_ID = 
NVL((
SELECT MAX(M.TARGET_CONCEPT_ID ) FROM DEV.SOURCE_TO_CONCEPT_MAP m
WHERE M.SOURCE_VOCABULARY_ID = 9
AND M.TARGET_VOCABULARY_ID = 8
AND SUBSTR(M.SOURCE_CODE,1,9) = SUBSTR(n.SOURCE_CODE,1,9)
),0), TARGET_VOCABULARY_ID = 8
WHERE TARGET_CONCEPT_ID = 0 ;
commit;
update SOURCE_TO_CONCEPT_MAP_STAGE n
set TARGET_CONCEPT_ID = 0, TARGET_VOCABULARY_ID = 0
WHERE TARGET_CONCEPT_ID = 0 ;
commit;
/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE(
--  SOURCE_TO_CONCEPT_MAP_ID ,
  SOURCE_CODE              ,
  SOURCE_CODE_DESCRIPTION  ,
  MAPPING_TYPE             ,
  TARGET_CONCEPT_ID        ,
  TARGET_VOCABULARY_ID   ,
  SOURCE_VOCABULARY_ID   ,
  PRIMARY_MAP
  )
SELECT SOURCE_CODE, SOURCE_CODE_DESCRIPTION, MAPPING_TYPE,TARGET_CONCEPT_ID,TARGET_CONCEPT_TYPE_ID,SOURCE_CONCEPT_TYPE_ID, PRIMARY_MAP  FROM ( 
SELECT sou.*, ROW_NUMBER() OVER (PARTITION BY  SOURCE_CODE ORDER BY SOURCE_CODE_DESCRIPTION) rn
FROM (
SELECT 
 M.NDC AS SOURCE_CODE 
,M.LN AS SOURCE_CODE_DESCRIPTION 
, 'DRUG' AS MAPPING_TYPE
, C.CONCEPT_ID_2 AS TARGET_CONCEPT_ID
, 08 AS TARGET_CONCEPT_TYPE_ID
, 09 AS SOURCE_CONCEPT_TYPE_ID
, PRIMARY_MAP AS PRIMARY_MAP
FROM 
      (
      SELECT DISTINCT
             r.code,
             r.str,
             C.CONCEPT_ID        concept_id_2,
             C.concept_name,
             c.concept_class,
             NULL AS PRIMARY_MAP
      FROM   rxnconso               R,
             --vocabulary.
             DEV.concept            C
      WHERE  R.sab = 'NDDF'
      AND    R.tty NOT IN ('DF', 'IN')
      AND    R.rxcui = C.CONCEPT_CODE
      AND    C.VOCABULARY_ID = '08'
      ORDER BY r.code
      )  C,
         RETCGC0_ETC_GCNSEQNO      L
       , DEV.concept               RC
       , RNDC14_NDC_MSTR           m
WHERE  (C.code) = (L.GCN_SEQNO)
AND    (l.etc_id) = (rc.concept_code)
AND    rc.VOCABULARY_ID = 20
AND c.code = m.GCN_SEQNO
)sou
)
WHERE rn = 1
;

INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE(
--  SOURCE_TO_CONCEPT_MAP_ID ,
  SOURCE_CODE              ,
  SOURCE_CODE_DESCRIPTION  ,
  MAPPING_TYPE             ,
  TARGET_CONCEPT_ID        ,
  TARGET_VOCABULARY_ID   ,
  SOURCE_VOCABULARY_ID   ,
  PRIMARY_MAP              
  )
SELECT SOURCE_CODE, SOURCE_CODE_DESCRIPTION, MAPPING_TYPE,TARGET_CONCEPT_ID,TARGET_CONCEPT_TYPE_ID,SOURCE_CONCEPT_TYPE_ID, PRIMARY_MAP  FROM ( 
SELECT sou.*, ROW_NUMBER() OVER (PARTITION BY  SOURCE_CODE ORDER BY SOURCE_CODE_DESCRIPTION) rn
FROM (
SELECT 
 M.NDC AS SOURCE_CODE 
,M.LN AS SOURCE_CODE_DESCRIPTION 
, 'DRUG' AS MAPPING_TYPE
, C.CONCEPT_ID_2 AS TARGET_CONCEPT_ID
, 08 AS TARGET_CONCEPT_TYPE_ID
, 09 AS SOURCE_CONCEPT_TYPE_ID
, PRIMARY_MAP AS PRIMARY_MAP
FROM 
      (      SELECT DISTINCT
             r.code,
             C.CONCEPT_CODE,
             r.str,
             C.CONCEPT_ID        concept_id_2,
             C.concept_name,
             c.concept_class,
             NULL AS PRIMARY_MAP
      FROM   rxnconso               R,
             DEV.concept            C
      WHERE  R.sab = 'NDDF'
      AND    R.tty NOT IN ('DF', 'IN')
      AND    R.rxcui = C.CONCEPT_CODE
      AND    C.VOCABULARY_ID = 08
      ORDER BY r.code
)C,
         RATCGC0_ATC_GCNSEQNO_LINK   L
       , DEV.concept                 RC
       , RNDC14_NDC_MSTR             m
WHERE  (C.code) = (L.GCN_SEQNO)
AND    (l.atc) = (rc.concept_code)
AND    rc.VOCABULARY_ID = 21   
AND c.code = m.GCN_SEQNO 
)sou
)
WHERE rn = 1
;     
--*/

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

exit;