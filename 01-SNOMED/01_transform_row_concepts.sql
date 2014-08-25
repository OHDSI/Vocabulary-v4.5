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
*  
*  Loaded from raw staged data SCT2_DESC_FULL_EN_INT into the staged data CONCEPT_STAGE
*  In this step we will perform substitute GUID identifiers into numerical format. 
*
*  Usage: 
*  echo "EXIT" | sqlplus SNOMED_20120131/myPass@DEV_VOCAB @01_transform_row_concepts.sql
*
******************************************************************************/
SPOOL 01_transform_row_concepts.log
-- . 


DELETE FROM CONCEPT_STAGE
WHERE   vocabulary_id = 01;  

INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
SELECT CONCEPT_NAME, vocabulary_id, CONCEPT_LEVEL, CONCEPT_CODE, CONCEPT_CLASS FROM (
SELECT  
 SUBSTR(d.term,1,256) as CONCEPT_NAME, 
        01 AS vocabulary_id, 
        0 AS CONCEPT_LEVEL, 
        d.CONCEPTID AS CONCEPT_CODE , 
        NULL AS CONCEPT_CLASS
, C.ACTIVE
, ROW_NUMBER() OVER (PARTITION BY  D.CONCEPTID ORDER BY TO_DATE(c.EFFECTIVETIME,'YYYYMMDD') DESC,  TO_DATE(d.EFFECTIVETIME,'YYYYMMDD') DESC
        , CASE WHEN typeid = '900000000000013009' then 0 else 1 END --900000000000003001
        , CASE WHEN term LIKE '%(%)%' THEN 1 ELSE 0 END
       ) rn
FROM    --snomed_$1..
SCT2_CONCEPT_FULL_MERGED c
 , SCT2_DESC_FULL_MERGED d
WHERE  c.ID = D.CONCEPTID 
--AND lower( D.TERM ) = 'new' -- 'coeliac disease'--'new'
AND term IS NOT NULL
--AND term not LIKE '%(%)%'
)
WHERE  rn = 1 AND active = 1
;


DROP TABLE tmp_CONC_CL;
CREATE TABLE tmp_CONC_CL AS 
SELECT * FROM (
SELECT 
   CONCEPT_CODE
 , F7 
--, d.ACTIVE
 , ROW_NUMBER() OVER (PARTITION BY  CONCEPT_CODE 
    ORDER BY active DESC
    ,DECODE (f7,                                
                                'disorder', 1,
                                'finding', 2,
                                'procedure', 3,
                                'regime/therapy', 4,
                                'qualifier value', 5,
                                'contextual qualifier', 6,
                                'body structure', 7,
                                'cell', 8,
                                'cell structure', 9,
                                'external anatomical feature', 10,
                                'organ component', 11,
                                'organism', 12,
                                'living organism', 13,
                                'physical object', 14,
                                'physical device', 15,
                                'physical force', 16,
                                'occupation', 17,
                                'person', 18,
                                'ethnic group', 19, 
                                'religion/philosophy', 20, 
                                'life style', 21, 
                                'social concept', 22,
                                'racial group', 23,
                                'event', 24,
                                'life event - finding', 25,
                                'product', 26,
                                'substance', 27,
                                'assessment scale', 28,
                                'tumor staging', 29,
                                'staging scale', 30,
                                'specimen', 31,
                                'special concept', 32,
                                'observable entity', 33,
                                'namespace concept', 34,     
                                'morphologic abnormality', 35, 
                                'foundation metadata concept', 36,
                                'core metadata concept', 37,
                                'metadata', 38, 
                                'environment', 39, 
                                'geographic location', 40,  
                                'situation', 41,
                                'situation', 42,
                                'context-dependent category', 43,  
                                'biological function', 44,
                                'attribute', 45, 
                                'administrative concept', 46,       
                                'record artifact', 47,                   
                                99) 
        , rnB
        ) rnC
FROM (
select 
  CONCEPT_CODE
  ,aCTIVE
  ,PC1, PC2
, CASE WHEN PC1 = 0 OR PC2= 0 THEN TERM ELSE 
SUBSTR(TERM,REGEXP_INSTR(TERM, '\(', 1, REGEXP_COUNT( TERM, '\(' )) + 1,REGEXP_INSTR(TERM, '\)', 1, REGEXP_COUNT( TERM, '\)' )) -REGEXP_INSTR(TERM, '\(', 1, REGEXP_COUNT( TERM, '\(' )) - 1) 
END f7 
, rnA AS rnB
 FROM
( 
SELECT 
   c.CONCEPT_CODE
 , d.TERM 
 , d.ACTIVE
 , REGEXP_COUNT( d.TERM, '\(' ) pc1
 , REGEXP_COUNT( d.TERM, '\)' ) pc2
 , ROW_NUMBER() OVER (PARTITION BY  c.CONCEPT_CODE ORDER BY d.active DESC
        , REGEXP_COUNT( d.TERM, '\(' ) DESC
        ) rnA  
FROM CONCEPT_STAGE c, sct2_Desc_Full_merged d
WHERE 01 = vocabulary_id
AND d.CONCEPTID = c.CONCEPT_CODE
) 
)
)
WHERE rnC = 1
;

CREATE INDEX X_CC_2CD ON tmp_CONC_CL
(CONCEPT_CODE);

/*
UPDATE CONCEPT_STAGE cs
SET CONCEPT_CLASS = (SELECT c.CONCEPT_CLASS FROM dev.concept c 
where  C.VOCABULARY_ID = 01 AND C.CONCEPT_ID = CS.CONCEPT_ID
AND c.CONCEPT_CLASS <> 'UNKNOWN' 
);
--*/

UPDATE CONCEPT_STAGE cs
SET CONCEPT_CLASS = (SELECT  
CASE 
WHEN F7 = 'disorder' THEN 'Clinical finding'
WHEN F7 = 'procedure' THEN 'Procedure'
WHEN F7 = 'finding' THEN 'Clinical finding'
WHEN F7 = 'organism' THEN 'Organism'
WHEN F7 = 'body structure' THEN 'Body structure'
WHEN F7 = 'substance' THEN 'Substance'
WHEN F7 = 'product' THEN 'Pharmaceutical / biologic product'
WHEN F7 = 'event' THEN 'Event'
WHEN F7 = 'qualifier value' THEN 'Qualifier value'
WHEN F7 = 'observable entity' THEN 'Observable entity'
WHEN F7 = 'situation' THEN 'Context-dependent category'
WHEN F7 = 'occupation' THEN 'Social context'
WHEN F7 = 'regime/therapy' THEN 'Procedure'
WHEN F7 = 'morphologic abnormality' THEN 'Morphologic abnormality'
WHEN F7 = 'physical object' THEN 'Physical object'
WHEN F7 = 'specimen' THEN 'Specimen'
WHEN F7 = 'environment' THEN 'Environment or geographical location'
WHEN F7 = 'context-dependent category' THEN 'Context-dependent category'
WHEN F7 = 'attribute' THEN 'Attribute'
WHEN F7 = 'assessment scale' THEN 'Staging and scales'
WHEN F7 = 'person' THEN 'Social context'
WHEN F7 = 'cell' THEN 'Body structure'
WHEN F7 = 'geographic location' THEN 'Environment or geographical location'
--WHEN F7 = 'navigational concept' THEN ''
WHEN F7 = 'cell structure' THEN 'Body structure'
WHEN F7 = 'ethnic group' THEN 'Social context'
WHEN F7 = 'tumor staging' THEN 'Staging and scales'
--NA WHEN F7 = 'ISBT symbol' THEN ''
WHEN F7 = 'religion/philosophy' THEN 'Social context'
WHEN F7 = 'record artifact' THEN 'Record artifact'
WHEN F7 = 'physical force' THEN 'Physical force'
WHEN F7 = 'foundation metadata concept' THEN 'Model component'
WHEN F7 = 'namespace concept' THEN 'Namespace concept'
WHEN F7 = 'administrative concept' THEN 'Administrative concept'
WHEN F7 = 'biological function' THEN 'Biological function'
--
WHEN F7 = 'foundation metadata concept'         THEN 'Model component'
WHEN F7 = 'living organism'         THEN 'Organism'
WHEN F7 = 'life style'         THEN 'Social context'
WHEN F7 = 'administrative concept'         THEN 'Administrative concept'
WHEN F7 = 'contextual qualifier'         THEN 'Qualifier value'
WHEN F7 = 'staging scale'         THEN 'Staging and scales'
WHEN F7 = 'life event - finding'         THEN 'Event'
WHEN F7 = 'social concept'         THEN 'Social context'
WHEN F7 = 'core metadata concept'         THEN 'Model component'
WHEN F7 = 'special concept'         THEN 'Special concept'
WHEN F7 = 'racial group'         THEN 'Social context'
WHEN F7 = 'therapy'         THEN 'Procedure'
WHEN F7 = 'external anatomical feature'         THEN 'Body structure'
WHEN F7 = 'organ component'         THEN 'Body structure'
WHEN F7 = 'physical device'         THEN 'Physical object'
WHEN F7 = 'linkage concept'         THEN 'Linkage concept'
WHEN F7 = 'metadata'         THEN 'Model component'
ELSE 'UNKNOWN'--substr(F7,1,60) 
END
FROM tmp_CONC_CL cc WHERE cc.CONCEPT_CODE = cs.CONCEPT_CODE)
WHERE 1 = 1
--AND CS.CONCEPT_CLASS IS NULL
;

/*

INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
SELECT CONCEPT_NAME, vocabulary_id, CONCEPT_LEVEL, CONCEPT_CODE, CONCEPT_CLASS FROM (
SELECT  
 SUBSTR(FULLYSPECIFIEDNAME,1,256) as CONCEPT_NAME, 
        01 AS vocabulary_id, 
        0 AS CONCEPT_LEVEL, 
        d.CONCEPTID AS CONCEPT_CODE , 
        'SNOMED UK' AS CONCEPT_CLASS
        ,ROW_NUMBER() OVER (PARTITION BY  CONCEPTID ORDER BY CONCEPTSTATUS--, term
        ) rn 
FROM    --snomed_$1..
SCT1_CONCEPTS d
WHERE  1 = 1
AND FULLYSPECIFIEDNAME IS NOT NULL
--AND term not LIKE '%(%)%'
)
WHERE rn  = 1
;

*/
exit;