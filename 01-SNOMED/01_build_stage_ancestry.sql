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
*  echo "EXIT" |   sqlplus  rxnorm_import/<password> @./ora/ETL/rxNorm_Gen_Anc01.sql 07312011 4322976 'Procedure' 'ICD-9-Procedure' 'CPT-4'
*  echo "EXIT" |  nohup sqlplus -s rxnorm_import/<password> @./ora/ETL/rxNorm_Gen_Anc01.sql 01221969 441840 'Clinical finding' 'Preferred Term' 'High Level Term' 'High Level Group Term' 'System Organ Class' 'Lowest Level Term' 'Standardized MedDRA Query' 'OMOP HOI cohort' $
*
******************************************************************************/
SPOOL 01_build_stage_ancestry_&1..log

SELECT 'START...' FROM dual;

DECLARE vCONCEPT_CLASS varchar(60);

BEGIN


--SELECT substr(C.CONCEPT_NAME,1, 60) INTO vCONCEPT_CLASS
--FROM CONCEPT c
--WHERE C.CONCEPT_ID = $2. 
--;

SELECT 
    CASE WHEN '&1.' = 'PROCEDURE'     THEN 'Procedure' 
         WHEN '&1.' = 'CLIN_FINDING'  THEN 'Clinical finding'
         WHEN '&1.' = 'SUBSTANCE'     THEN 'Substance'
         WHEN '&1.' = 'LINKAGE' THEN 'Linkage concept'
    ELSE 'N/A'
   END
INTO vCONCEPT_CLASS
FROM dual 
;

-- . 

--TRUNCATE TABLE  CONCEPT_ANCESTOR_%1. ;

--/*
INSERT /*+ APPEND */  INTO CONCEPT_ANCESTOR_STAGE(
--       concept_ancestor_map_id,
        --descendant_concept_id,
          ancestor_concept_id,
                  descendant_concept_id,
       max_levels_of_separation,
       min_levels_of_separation
)
--*/
SELECT 
--concept_ancestor_seq.nextval,
 rt, chld, MAX(lv_min), MIN(lv_min) FROM (
SELECT 
--DISTINCT
--LPAD(' ', 8 * level)|| C2.CONCEPT_CODE||'~' || C2.CONCEPT_NAME||'-->'|| C1.CONCEPT_CODE||'~'||C1.CONCEPT_NAME tree,  R.RELATIONSHIP_TYPE rl, r.CONCEPT_ID_2
--,C2.CONCEPT_TYPE_ID||'-->'||C1.CONCEPT_TYPE_ID tre
--,C2.CONCEPT_LEVEL||'-->'||C1.CONCEPT_LEVEL tr
--, level lv
-- concept_ancestor_seq.nextval
 CONNECT_BY_ROOT CONCEPT_ID_1 rt
, r.CONCEPT_ID_2 chld
--, C2.CONCEPT_LEVEL lv_max
--, C1.CONCEPT_LEVEL lv_min
, level lv_max
, level lv_min
--, connect_by_iscycle lv_min
FROM
--CONCEPT_REL_$1._$2. --4008453    
--CONCEPT_RELATIONSHIP_$1. r
CONCEPT_REL_STAGE_&1. r
, CONCEPT_STAGE c1
, CONCEPT_STAGE c2
, DEV.RELATIONSHIP rt
WHERE 1 = 1
AND rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID AND rt.DEFINES_ANCESTRY = 1
--AND  R.RELATIONSHIP_TYPE <> '269'
--AND  R.RELATIONSHIP_TYPE IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28, 269, 271, 273)
--AND  R.RELATIONSHIP_ID  = 010
AND C1.CONCEPT_ID = R.CONCEPT_ID_1
AND C2.CONCEPT_ID = R.CONCEPT_ID_2
AND C1.CONCEPT_CLASS = vCONCEPT_CLASS
AND C2.CONCEPT_CLASS = vCONCEPT_CLASS
--AND  C2.CONCEPT_CLASS  IN ('$3.', '$4.', '$5.', '$6.', '$7.', '$8.', '$9.', '$10.')
--AND  C1.CONCEPT_CLASS  IN ('$3.', '$4.', '$5.', '$6.', '$7.', '$8.', '$9.', '$10.')
-- AND connect_by_iscycle = 0
--AND R.INVALID_REASON <> 'D'
--AND C1.CONCEPT_TYPE_ID = '07'
--AND C2.CONCEPT_TYPE_ID = '07'
--AND LEVEL < 22
--AND  UPPER(c1.CONCEPT_NAME) like '%CAPTOPRIL 25%'
--and c1.concept_level > 0
--and c2.concept_level > 0
--AND  (c2.concept_level >= c1.concept_level
--OR (c2.concept_level =  c1.concept_level AND   r.RELATIONSHIP_TYPE  = '010' )
--  )
CONNECT BY  
--NOCYCLE
PRIOR r.CONCEPT_ID_2 = r.CONCEPT_ID_1 AND rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID AND rt.DEFINES_ANCESTRY = 1
AND   C1.CONCEPT_CLASS = vCONCEPT_CLASS
AND   C2.CONCEPT_CLASS = vCONCEPT_CLASS
--AND  C2.CONCEPT_CLASS  IN ('$3.', '$4.', '$5.', '$6.', '$7.', '$8.', '$9.', '$10.')
--AND  C1.CONCEPT_CLASS  IN ('$3.', '$4.', '$5.', '$6.', '$7.', '$8.', '$9.', '$10.')
  --AND r.RELATIONSHIP_ID  = 010
--AND R.INVALID_REASON <> 'D'
--AND PRIOR c2.concept_level >= c1.concept_level
 --AND (PRIOR r.RELATIONSHIP_TYPE = r.RELATIONSHIP_TYPE --OR  r.RELATIONSHIP_TYPE  = '010'
 --)
START WITH --  C2.CONCEPT_LEVEL > 0 
-- AND C2.CONCEPT_TYPE_ID = '07'
--  r.CONCEPT_ID_2 = $2. -- 4322976 441840
      C1.CONCEPT_CLASS = vCONCEPT_CLASS
AND   C2.CONCEPT_CLASS = vCONCEPT_CLASS
--     C1.CONCEPT_CLASS  IN ('$3.', '$4.', '$5.', '$6.', '$7.', '$8.', '$9.', '$10.')
--AND  C2.CONCEPT_CLASS  IN ('$3.', '$4.', '$5.', '$6.', '$7.', '$8.', '$9.', '$10.')
AND rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID AND rt.DEFINES_ANCESTRY = 1
---!AND  r.CONCEPT_ID_1 =  441840 --  4322976
--'Pharmacologic Class'
--'Therapeutic Class'
--'Pharmacokinetics'
--'VA Drug Interaction'
--'VA Product'
--'Dose Form'
--'Mechanism of Action'
--'Physiologic Effect'
--'Chemical Structure'
--'Pharmaceutical Preparations'
--'Indication or Contra-indication'
--AND R.INVALID_REASON <> 'D'
) sou
--, CONCEPT_STAGE c1
--, CONCEPT_STAGE c2
--! Don`t do this - 'ClFind'&'Proc'-1,2 level
--WHERE 1 = 1
--AND C1.CONCEPT_ID = sou.chld AND C1.CONCEPT_LEVEL > 0
--AND C2.CONCEPT_ID = sou.rt AND C2.CONCEPT_LEVEL > 0
--AND  UPPER(tree) like '%CAPTOPRIL 25%'
GROUP BY rt, chld
;

END;

/

exit;