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
*  echo "EXIT" | sqlplus <user>/<pass> @05_load_maps.sql 
*
******************************************************************************/
SPOOL 05_transform_row_maps.log
-- . 

-- DROP SEQUENCE SEQ_CONCEPT_MAP;
-- CREATE SEQUENCE SEQ_CONCEPT_MAP START WITH 50000000;




-- Create temporary table for uploading concept. 
TRUNCATE TABLE  SOURCE_TO_CONCEPT_MAP_STAGE ;

--DELETE FROM    SOURCE_TO_CONCEPT_MAP_$1.
--WHERE   VOCABULARY_ID = '07'
--; 

--/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE( --05-->05
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
, 'PROCEDURE' AS MAPPING_TYPE
, DV.concept_ID AS TARGET_CONCEPT_ID
, 05 AS TARGET_VOCABULARY_ID
, 05 AS SOURCE_VOCABULARY_ID
, 'Y' AS PRIMARY_MAP
, 0 AS ISHANDMADE
     FROM concept_STAGE Co1
     , DEV.concept dv
WHERE     
  Co1.VOCABULARY_ID = 05
  AND DV.VOCABULARY_ID = 05
  AND CO1.CONCEPT_CODE = DV.CONCEPT_CODE       
) sou
)
WHERE 1 = 1
--AND ISHANDMADE = 0
AND rn = 1
--AND TARGET_CONCEPT_ID IS NOT NULL   
;
--*/

--/*
INSERT INTO SOURCE_TO_CONCEPT_MAP_STAGE( --05-->08
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
SELECT TRIM(SOURCE_CODE), SOURCE_CODE_DESCRIPTION, MAPPING_TYPE,TARGET_CONCEPT_ID,TARGET_VOCABULARY_ID,SOURCE_VOCABULARY_ID, 'Y'
--, cd,rn,   CONCEPT_NAME, NM_
--, CASE WHEN NM_ IS NULL THEN NM__  ELSE NULL END NM__  
--, CASE WHEN NM_ IS NULL THEN NM___ ELSE NULL END NM___
FROM ( 
SELECT sour.*, ROW_NUMBER() OVER (PARTITION BY  SOURCE_CODE ORDER BY cd DESC, SOURCE_CODE_DESCRIPTION) rn
FROM (
SELECT 
code AS SOURCE_CODE        
,SUBSTR (TRIM(DRUG)||' '||strength, 1, 256) AS SOURCE_CODE_DESCRIPTION    
,'PROCEDURE DRUG' AS MAPPING_TYPE        
,NVL(CONCEPT_ID, NVL(CONCEPT_ID_,CONCEPT_ID___)) AS TARGET_CONCEPT_ID    
,08 AS TARGET_VOCABULARY_ID    
,05 AS SOURCE_VOCABULARY_ID
,NVL( CD, CD_) cd
,   CONCEPT_NAME, NM_,NM__, NM___      
 FROM 
(
--*/
SELECT hd.*
--substr(strength, INSTR (substr(strength, 1, 256 ), ' ')+1) st
-- CASE  WHEN instr(route,'[') > 0 THEN substr(route,1, instr(route,'[')-2) ELSE route END rt 
 -- , count(8) cnt
,  CASE  WHEN UPPER(sou.strength_) LIKE UPPER(TRIM(hd.strength)) THEN 'L'  ELSE   '' END  AS lk
, sou.*   
, cn.*
, br.*
--, rt.*
  FROM (
SELECT CONCEPT_ID, CONCEPT_NAME, cd
,nm
, re, substr(CONCEPT_NAME, re,  INSTR (substr(CONCEPT_NAME, re, 256 ), ' ',1,2/*2*/)-1) ||'' AS strength_ 
,substr(CONCEPT_NAME, re+  INSTR (substr(CONCEPT_NAME, re, 256 ), ' ',1,2/*2*/)-0,256) ||'' AS route_ 
--,  INSTR (substr(CONCEPT_NAME, re, 256 ), ' ')
,df, try
 FROM (
select -- + ORDERED 
d.CONCEPT_ID , d.CONCEPT_NAME, d.INVALID_REASON cd
--, substr(d.CONCEPT_NAME,1,INSTR(d.CONCEPT_NAME,' ')-1) nm
--, substr(d.CONCEPT_NAME,1,CASE WHEN REGEXP_INSTR(d.CONCEPT_NAME,'[ ,]')>0 THEN  REGEXP_INSTR(d.CONCEPT_NAME,'[ ,]')-1 ELSE 256 END) nm
, REPLACE(REPLACE(substr(substr(d.CONCEPT_NAME, 1, CASE WHEN REGEXP_INSTR(d.CONCEPT_NAME, ' [[:digit:]]') >0 THEN REGEXP_INSTR(d.CONCEPT_NAME, ' [[:digit:]]') -1 ELSE 256 END ),1,CASE WHEN REGEXP_INSTR(substr(d.CONCEPT_NAME, 1, CASE WHEN REGEXP_INSTR(d.CONCEPT_NAME, ' [[:digit:]]') >0 THEN REGEXP_INSTR(d.CONCEPT_NAME, ' [[:digit:]]') -1 ELSE 256 END ),'[ ,]',1,2/*2*/)>0 THEN  REGEXP_INSTR(substr(d.CONCEPT_NAME, 1, CASE WHEN REGEXP_INSTR(d.CONCEPT_NAME, ' [[:digit:]]') >0 THEN REGEXP_INSTR(d.CONCEPT_NAME, ' [[:digit:]]') -1 ELSE 256 END ),'[ ,]',1,2/*2*/)-1 ELSE 256 END),', ',' '),',','') nm
, f.CONCEPT_NAME df
, REGEXP_INSTR(d.CONCEPT_NAME, ' [[:digit:]]') + 1 AS re
,rt.TRY 
from  --DEV.concept c
DEV.concept f, DEV.concept d, DEV.concept_relationship r
,   HCPCSRoutes rt
--/*
, (SELECT  did, count(8) cnt FROM (
select distinct  c1.concept_id aid, c2.concept_id did 
from DEV.concept c1,DEV.concept c2,DEV.concept_ancestor a 
where  a.ancestor_concept_id=c1.concept_id
and a.descendant_concept_id=c2.concept_id
--and c1.VOCABULARY_ID IN (8)
AND c1.concept_level  = 2 
--and c1.concept_id=19032614
--and c2.VOCABULARY_ID IN (8)
AND c2.concept_level  = 1
--and (c2.concept_id=948785 OR c1.concept_id=19032614)
)
WHERE 1 = 1 
GROUP BY did
HAVING count(8) =1) ons
--*/
WHERE  1 =1
AND ons.did = d.CONCEPT_ID --!!!!NEED UNCOMMENT - ONSIE !!!!
AND TRIM(f.CONCEPT_NAME) = TRIM(rt.CONCEPT_NAME(+))
AND f.concept_class='Dose Form' and d.concept_class='Clinical Drug' and r.concept_id_1=d.concept_id and r.concept_id_2=f.concept_id
--AND  UPPER(C.CONCEPT_NAME ) LIKE '%ACETAZOLAMIDE%'
--AND VOCABULARY_ID=8 AND concept_level =1
order by 1
)
) sou
,   hd_refined hd  -- 10312011
, (SELECT  c.CONCEPT_ID CONCEPT_ID_, INVALID_REASON cd_
--, substr(c.CONCEPT_NAME,1,INSTR(c.CONCEPT_NAME,' ')-1) nm
--, substr(c.CONCEPT_NAME,1,CASE WHEN REGEXP_INSTR(c.CONCEPT_NAME,'[ ,]')>0 THEN  REGEXP_INSTR(c.CONCEPT_NAME,'[ ,]')-1 ELSE 256 END) nm_
, REPLACE(REPLACE(substr(substr(c.CONCEPT_NAME, 1, CASE WHEN REGEXP_INSTR(c.CONCEPT_NAME, ' [[:digit:]]') >0 THEN REGEXP_INSTR(c.CONCEPT_NAME, ' [[:digit:]]') -1 ELSE 256 END ),1,CASE WHEN REGEXP_INSTR(substr(c.CONCEPT_NAME, 1, CASE WHEN REGEXP_INSTR(c.CONCEPT_NAME, ' [[:digit:]]') >0 THEN REGEXP_INSTR(c.CONCEPT_NAME, ' [[:digit:]]') -1 ELSE 256 END ),'[ ,]',1,1/*2*/)>0 THEN  REGEXP_INSTR(substr(c.CONCEPT_NAME, 1, CASE WHEN REGEXP_INSTR(c.CONCEPT_NAME, ' [[:digit:]]') >0 THEN REGEXP_INSTR(c.CONCEPT_NAME, ' [[:digit:]]') -1 ELSE 256 END ),'[ ,]',1,1/*2*/)-1 ELSE 256 END),', ',' '),',','') nm_
FROM  DEV.concept c WHERE  c.VOCABULARY_ID=8 AND c.concept_level =2) cn
--/*
, (SELECT  cb.CONCEPT_ID CONCEPT_ID__ , cb.CONCEPT_NAME NM__ , cb.INVALID_REASON cd__
         , ci.CONCEPT_ID CONCEPT_ID___, ci.CONCEPT_NAME NM___, ci.INVALID_REASON cd___
FROM DEV.concept cb, DEV.concept_relationship r, DEV.concept ci
WHERE  Cb.CONCEPT_CLASS = 'Brand Name'
AND cb.concept_id=r.concept_id_1 and r.concept_id_2=ci.concept_id
AND ci.concept_level =2
) br
--*/
--WHERE UPPER(trim(hd.DRUG)) = UPPER(trim(sou.nm(+)))
WHERE   UPPER(trim(sou.nm(+))) LIKE UPPER(trim(hd.DRUG))||'%'
--AND UPPER(trim(hd.DRUG)) = 'GAMMAGARD'
AND UPPER(sou.strength_(+)) LIKE UPPER(TRIM(NVL(hd.strength,'#')))||'%'
AND UPPER(hd.route) LIKE '%'||UPPER(TRIM(NVL(sou.TRY(+),'#')))||'%'
AND UPPER(trim(hd.DRUG)) = UPPER(trim(cn.nm_(+)))
AND UPPER(trim(REPLACE(br.nm__(+),' ','#'))) LIKE '%'||UPPER(trim(hd.DRUG||'#'))||'%'
--group by hd.drug 
--CASE  WHEN instr(route,'[') > 0 THEN substr(route,1, instr(route,'[')-2) ELSE route END 
 --substr(strength, INSTR (substr(strength, 1, 256 ), ' ')+1)
--WHERE substr(strength, INSTR (substr(strength, 1, 256 ), ' ')+1) ='%'
--WHERE  CASE  WHEN instr(route,'[') > 0 THEN substr(route,1, instr(route,'[')-2) ELSE route END ='Oral Ta'
--AND NM_ IS NULL
--AND DRUG LIKE 'Calc%'
ORDER BY drug, code--2 desc
) )sour
) WHERE 1 = 1 AND rn = 1 AND TARGET_CONCEPT_ID IS NOT NULL
ORDER BY 2
;

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