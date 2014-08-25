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
*  echo "EXIT" | sqlplus RXNORM_20120131/myPass@DEV_VOCAB @07_transform_row_concepts.sql
*
******************************************************************************/
SPOOL 07_transform_row_concepts.log
-- . 


DELETE FROM CONCEPT_STAGE
WHERE   vocabulary_id IN (07, 28, 32);  


--/*
INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
--*/    
SELECT  
 TRIM(CONCEPT_NAME) 
 ,CASE 
       WHEN CONCEPT_CLASS = 'VA Product' THEN 28
       WHEN CONCEPT_CLASS = 'VA Class'   THEN 32
       ELSE 07 
  END AS CONCEPT_TYPE_ID
 , CASE WHEN TTY = 'HT' THEN 0
        WHEN CONCEPT_CLASS IN (
          'Chemical Structure', 'Indication or Contra-indication'
        , 'Mechanism of Action', 'Physiologic Effect'
     --!!   , 'Pharmaceutical Preparations'
        , 'VA Class'
        )
        THEN 3
        ELSE 0
 END
 AS CONCEPT_LEVEL
 ,CASE
            WHEN CONCEPT_CLASS =  'VA Class'  THEN SUBSTR (real_name, 2,INSTR (real_name, ']') - 2)
            WHEN CONCEPT_CLASS =  'VA Product'  THEN  
            --LTRIM(SUBSTR (CONCEPT_CODE, 1, 256),'N0')
            --(SELECT MAX(cns2.code) from rxnorm_$1..rxnConso cns2 WHERE cns2.sab = 'VANDF'and cns2.tty='CD' AND sou.rxcui = cns2.rxcui )
            CONCEPT_CODE
          ELSE CONCEPT_CODE
       END
          AS CONCEPT_CODE
 , CONCEPT_CLASS
-- ,real_name
 --, SUBSTR (real_name, 2,INSTR (real_name, ']') - 2) stri
 FROm (
 SELECT 
  TTY
 ,rxcui  
 ,CONCEPT_NAME 
 ,CONCEPT_TYPE_ID
 ,CONCEPT_LEVEL1
 ,CONCEPT_CODE
 ,     CASE
            WHEN CONCEPT_CLASS =  '[PK]'  THEN 'Pharmacokinetics'
            WHEN CONCEPT_CLASS =  '[Dose Form]'  THEN 'Dose Form'
            WHEN CONCEPT_CLASS =  '[TC]'  THEN 'Therapeutic Class'
            WHEN CONCEPT_CLASS =  '[MoA]'  THEN 'Mechanism of Action'
            WHEN CONCEPT_CLASS =  '[PE]'  THEN 'Physiologic Effect'
            WHEN CONCEPT_CLASS =  '[VA Drug Interaction]'  THEN 'VA Drug Interaction'
            WHEN CONCEPT_CLASS =  '[Preparations]'  THEN 'Pharmaceutical Preparations'
            WHEN CONCEPT_CLASS =  '[VA Product]'  THEN 'VA Product'
            WHEN CONCEPT_CLASS =  '[EPC]'  THEN 'Pharmacologic Class'
            WHEN CONCEPT_CLASS =  '[Chemical/Ingredient]'  THEN 'Chemical Structure'
            WHEN CONCEPT_CLASS =  '[Disease/Finding]'  THEN 'Indication or Contra-indication'     
          ELSE CONCEPT_CLASS
       END
          AS CONCEPT_CLASS
          ,real_name
FROM (
SELECT 
TTY,
rxcui,
CASE
          WHEN INSTR (str, '[') > 1
          THEN
             SUBSTR (c1.str, 1, INSTR (str, '[') - 1)
      WHEN INSTR (str, '[') = 1
          THEN
             SUBSTR (c1.str, INSTR (str, ']') + 1, 256)
          ELSE
             SUBSTR (c1.str, 1, 256)
       END
          AS CONCEPT_NAME,
       '07' AS CONCEPT_TYPE_ID,
       CASE
          WHEN INSTR (str, '[') > 1          THEN             3
          ELSE             4
       END
    AS CONCEPT_LEVEL1,
       c1.code AS CONCEPT_CODE,
       CASE
          WHEN INSTR (str, '[') > 1
          THEN
             SUBSTR (c1.str, INSTR (str, '['), 256)
      WHEN INSTR (str, '[') = 1
          THEN
             'VA Class'
          ELSE
             'Pharmaceutical Preparations' --'N/A'
       END
          AS CONCEPT_CLASS
          ,str as real_name
    FROM RXNCONSO c1              
 WHERE SAB = 'NDFRT' AND TTY IN ( 'FN', 'HT', 'MTH_RXN_RHT')
--and INSTR(str, '[')>1
)
--WHERE CONCEPT_CLASS <> 'N/A'
)sou
--WHERE CONCEPT_CLASS NOT IN ( 'N/A', 'VA Product')
;

exit;