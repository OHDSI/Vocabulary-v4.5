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
*  Date:           2021/07/06
*
*  Load new concept relationships stage, identify invalid codes  information 
*  Loaded from the raw staged data SCT2_RELA_FULL_INT into the staged data CONCEPT_RELATIONSHIP_STAGE, identify invalid code information    
*     
*  Usage: 
*  echo "EXIT" | sqlplus RXNORM_20120131/myPass@DEV_VOCAB @07_transform_row_relations.sql 
*
******************************************************************************/
SPOOL 07_transform_row_relations.log
-- .      

--DROP SEQUENCE SEQ_RELATIONSHIP;
--CREATE SEQUENCE SEQ_RELATIONSHIP START WITH 5000000;


-- Create temporary table for uploading concept relatioships. 
--DELETE FROM CONCEPT_RELATIONSHIP_STAGE; 
TRUNCATE TABLE CONCEPT_RELATIONSHIP_STAGE; 
commit;


INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_2, 
    CONCEPT_ID_1, 
    RELATIONSHIP_ID)
SELECT  CONCEPT_ID_1, 
        CONCEPT_ID_2, 
        RELATIONSHIP_ID
FROM (
SELECT  (SELECT CONCEPT_ID FROM DEV.CONCEPT WHERE vocabulary_id = 08 AND CONCEPT_CODE = RXCUI1) as CONCEPT_ID_1,
        (SELECT CONCEPT_ID FROM DEV.CONCEPT WHERE vocabulary_id = 08 AND CONCEPT_CODE = RXCUI2) as CONCEPT_ID_2,
        RELATIONSHIP_ID
FROM    (
        SELECT  RXCUI1,
                RXCUI2,
                CASE 
                    WHEN    RELA = 'has_precise_ingredient' THEN    '002'
                    WHEN    RELA = 'has_tradename'          THEN    '003'
                    WHEN    RELA = 'has_dose_form'          THEN    '004'
                    WHEN    RELA = 'has_form'               THEN    '005'
                    WHEN    RELA = 'has_ingredient'         THEN    '006' 
                    WHEN    RELA = 'constitutes'            THEN    '007' 
                    WHEN    RELA = 'contains'               THEN    '008' 
                    WHEN    RELA = 'reformulation_of'       THEN    '009' 
                END as RELATIONSHIP_ID
        FROM    rxnrel             
        WHERE   SAB     = 'RXNORM'
        )
)
WHERE   RELATIONSHIP_ID   IS NOT NULL
    AND CONCEPT_ID_1        IS NOT NULL
    AND CONCEPT_ID_2        IS NOT NULL
;

-- 07 - 08 --028
-- NEED uncomment !!!
--/*
SELECT '07 - 08-RELATIONS 028' FROM dual; -- 028 162

INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID)
SELECT * FROM (
SELECT DISTINCT
   (SELECT cc1.CONCEPT_ID FROM DEV.CONCEPT cc1 WHERE cc1.VOCABULARY_ID = 07 AND cc1.CONCEPT_CODE = c1.code) AS CONCEPT_ID_1    
 , (SELECT cc2.CONCEPT_ID FROM DEV.CONCEPT cc2 WHERE cc2.VOCABULARY_ID = 08 AND cc2.CONCEPT_CODE = c2.code) AS CONCEPT_ID_2    
 , 028 as RELATIONSHIP_ID
FROM    
  RXNCONSO c1
, RXNCONSO c2
WHERE 1 = 1
AND c1.SAB = 'NDFRT' AND c1.TTY IN ( 'FN', 'HT', 'MTH_RXN_RHT')
AND c2.SAB = 'RXNORM' -- AND c2.TTY IN...
AND c1.RXCUI =  c2.RXCUI  
)
--, CONCEPT cd1
--, CONCEPT cd2
WHERE 1= 1
AND CONCEPT_ID_1 IS not NULL
AND CONCEPT_ID_2 IS not NULL
--AND CONCEPT_ID_1 = cd1.concept_id
--AND CONCEPT_ID_2 = cd2.concept_id
--AND cd1.concept_class= 'VA Product'
--AND cd2.concept_class= 'Ingredient'
;
--*/


-- 07 - 07 --
-- NEED uncomment !!!
--/*

SELECT '07 - 07-RELATIONS' FROM dual;

INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_2, 
    CONCEPT_ID_1, 
    RELATIONSHIP_ID)
SELECT -- RELATIONSHIP_ID, REL, 
* --count(8) cnt 
 FROM ( 
SELECT --count(8) cnt 
  (SELECT cc1.CONCEPT_ID FROM DEV.CONCEPT cc1 WHERE cc1.VOCABULARY_ID = 07 AND cc1.CONCEPT_CODE = c1.code) AS CONCEPT_ID_1
 ,(SELECT cc2.CONCEPT_ID FROM DEV.CONCEPT cc2 WHERE cc2.VOCABULARY_ID = 07 AND cc2.CONCEPT_CODE = c2.code) AS CONCEPT_ID_2
        -- (SELECT CONCEPT_ID FROM CONCEPT WHERE VOCABULARY_ID = '07' AND CONCEPT_CODE = RXCUI1),
       -- (SELECT CONCEPT_ID FROM CONCEPT WHERE VOCABULARY_ID = '07' AND CONCEPT_CODE = RXCUI2),              
               ,CASE 
                    WHEN    r.RELA = 'has_dose_form'                            THEN    '011' -- NDFRT Has DoseForm --
                    WHEN    r.RELA = 'induces'                                  THEN    '012' -- NDFRT Induces --
                    WHEN    r.RELA = 'may_diagnose'                             THEN    '013' -- NDFRT May Diagnose --
                    WHEN    r.RELA = 'has_physiologic_effect'                   THEN    '014' -- NDFRT Has PE --
                    WHEN    r.RELA = 'has_contraindicating_physiologic_effect'  THEN    '015' -- NDFRT CI PE --
                    WHEN    r.RELA = 'has_ingredient'                           THEN    '016' -- NDFRT Has Ingredient --
                    WHEN    r.RELA = 'has_contraindicating_class'               THEN    '017' -- NDFRT CI ChemClass --
                    WHEN    r.RELA = 'has_mechanism_of_action'                  THEN    '018' -- NDFRT Has MoA --                    
                    WHEN    r.RELA = 'has_contraindicating_mechanism_of_action' THEN    '019' -- NDFRT CI MoA --
                    WHEN    r.RELA = 'has_pharmacokinetics'                     THEN    '020' -- NDFRT Has PK --
                    WHEN    r.RELA = 'may_treat'                                THEN    '021' -- NDFRT May Treat --
                    WHEN    r.RELA = 'contraindicated_drug'                     THEN    '022' -- NDFRT CI With --
                    WHEN    r.RELA = 'may_prevent'                              THEN    '023' -- NDFRT May Prevent --
                    WHEN    r.RELA = 'has_active_metabolites'                   THEN    '024' -- NDFRT Has Active Metabolites --
                    WHEN    r.RELA = 'site_of_metabolism'                       THEN    '025' -- NDFRT Site of Metabolism --
                    WHEN    r.RELA = 'may_inhibit_effect_of'                    THEN    '026' -- NDFRT Effect May Be Inhibited By --
                    WHEN    r.RELA = 'has_chemical_structure'                   THEN    '027' -- NDFRT Has Chemical Structure --
                    WHEN    r.RELA = 'has_therapeutic_class'                       THEN    '275' -- NDFRT Has Chemical Structure --
                    WHEN    r.RELA = 'has_participant'                      THEN    '277' -- NDFRT Has Chemical Structure --
                    WHEN    r.RELA = 'has_product_component'                      THEN    '279' -- NDFRT Has Chemical Structure --
                    ELSE   
                             CASE WHEN r.REL IN('PAR', 'CHD') THEN '010'                       
                                     WHEN r.REL = 'SY' THEN '271'
                  -- WHEN r.REL = 'RO' THEN '273'
                                   ELSE r.REL 
                               END
                END as RELATIONSHIP_ID
                --,r.RELA
                --,r.*
FROM    rxnrel r
    ,  RXNCONSO c1            
    ,  RXNCONSO c2
WHERE  r.SAB     = 'NDFRT'
--r.RELA    = 'has_dose_form'
AND (r.REL = 'PAR' OR r.RELA IN (
  'has_dose_form'                            
, 'induces'                                  
, 'may_diagnose'                             
, 'has_physiologic_effect'                   
, 'has_contraindicating_physiologic_effect'  
, 'has_ingredient'                           
, 'has_contraindicating_class'               
, 'has_mechanism_of_action'                  
, 'has_contraindicating_mechanism_of_action' 
, 'has_pharmacokinetics'                     
, 'may_treat'                                
, 'contraindicated_drug'                     
, 'may_prevent'                              
, 'has_active_metabolites'                   
, 'site_of_metabolism'                       
, 'may_inhibit_effect_of'                    
, 'has_chemical_structure'                   
, 'has_therapeutic_class'                       
, 'has_participant'                      
, 'has_product_component'
))
AND c1.sab(+)='NDFRT'  AND c1.TTY IN ( 'FN', 'HT', 'MTH_RXN_RHT') AND c1.RXAUI(+) =  r.RXAUI1
AND c2.sab(+)='NDFRT'  AND c2.TTY IN ( 'FN', 'HT', 'MTH_RXN_RHT') AND c2.RXAUI(+) =  r.RXAUI2
)WHERE CONCEPT_ID_1 IS NOT NULL
AND CONCEPT_ID_2 IS not NULL
GROUP BY CONCEPT_ID_1, CONCEPT_ID_2, RELATIONSHIP_ID
ORDER BY RELATIONSHIP_ID
;
--*/

-- NEED uncomment !!!
--/*
DELETE from CONCEPT_RELATIONSHIP_STAGE r
WHERE R.RELATIONSHIP_ID = 022
AND EXISTS (SELECT 1 FROM CONCEPT_STAGE c1  WHERE c1.CONCEPT_ID =  r.CONCEPT_ID_1  AND c1.CONCEPT_CLASS = 'Indication or Contra-indication' )
AND EXISTS (SELECT 1 FROM CONCEPT_STAGE c2  WHERE c2.CONCEPT_ID =  r.CONCEPT_ID_2  AND c2.CONCEPT_CLASS = 'Pharmaceutical Preparations')
;

DELETE from CONCEPT_RELATIONSHIP_STAGE r
WHERE R.RELATIONSHIP_ID = 022
AND EXISTS (SELECT 1 FROM CONCEPT_STAGE c1  WHERE c1.CONCEPT_ID =  r.CONCEPT_ID_1  AND c1.CONCEPT_CLASS = 'Indication or Contra-indication' )
AND EXISTS (SELECT 1 FROM CONCEPT_STAGE c2  WHERE c2.CONCEPT_ID =  r.CONCEPT_ID_2  AND c2.CONCEPT_CLASS = 'VA Product' )
;
--*/
commit;



-- NEED uncomment !!!
--/*
SELECT '07-08 string match ' FROM dual;

UPDATE CONCEPT_STAGE d
SET     (concept_id) = (
    SELECT  c.concept_id
    FROM    DEV.CONCEPT c 
    WHERE   c.concept_code =   d.concept_code
        AND c.VOCABULARY_ID   =   d.VOCABULARY_ID
)
----WHERE d.VOCABULARY_ID   IN ('07', '08')
;

INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID)
SELECT 
-- + NO_INDEX(C1) NO_INDEX(C3)
c1.CONCEPT_ID, c3.CONCEPT_ID
--, case WHEN C1.CONCEPT_CLASS = 'Chemical Structure' THEN '016' else '273' end
, CASE 
    WHEN    C1.VOCABULARY_ID = 07 THEN  285
    WHEN    C1.VOCABULARY_ID = 20 THEN  287
    WHEN    C1.VOCABULARY_ID = 21 THEN  289
    END as t028 
FROM    
  CONCEPT_STAGE c1
, CONCEPT_STAGE c3
WHERE 1 = 1 
 AND C1.VOCABULARY_ID IN (07, 20, 21)
 and c1.concept_level<>0   
 --AND c1.CONCEPT_CLASS in ('Pharmaceutical Preparations', 'Chemical Structure')
AND UPPER(RTRIM(lTRIM(c1.concept_name))) = UPPER(RTRIM(lTRIM(c3.concept_name)))
AND C3.VOCABULARY_ID = 08
and c3.concept_level<>0   
AND 
NOT 
EXISTS 
(
SELECT 1
FROM    
  CONCEPT_RELATIONSHIP_STAGE r            
WHERE   1 = 1
AND c1.CONCEPT_ID =  r.CONCEPT_ID_1  
AND c3.CONCEPT_ID =  r.CONCEPT_ID_2
--AND case WHEN C1.CONCEPT_CLASS = 'Chemical Structure' THEN '016' else '273' end = R.RELATIONSHIP_ID
AND 028  = R.RELATIONSHIP_ID 
)
;
--*/
commit;



--  NEED uncomment !!!
--/*
SELECT 'Revers-RELATIONS' FROM dual;
INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID)
SELECT  
    R.CONCEPT_ID_2 AS CONCEPT_ID_1, R.CONCEPT_ID_1 AS CONCEPT_ID_2,
  NVL((SELECT REVERSE_RELATIONSHIP from
   --PRD.
    DEV.
   RELATIONSHIP rt WHERE rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID), 998)
  FROM  CONCEPT_RELATIONSHIP_STAGE r
  ; 
--*/
commit;




exit;
