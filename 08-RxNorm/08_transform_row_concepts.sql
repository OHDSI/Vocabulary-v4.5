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
*  echo "EXIT" | sqlplus RXNORM_20120131/myPass@DEV_VOCAB @08_transform_row_concepts.sql
*
******************************************************************************/
SPOOL 08_transform_row_concepts.log
-- . 


DELETE FROM CONCEPT_STAGE
WHERE   vocabulary_id = 08;  


INSERT INTO CONCEPT_STAGE(
    CONCEPT_NAME, 
    vocabulary_id, 
    CONCEPT_LEVEL, 
    CONCEPT_CODE,
    CONCEPT_CLASS)
SELECT  SUBSTR(str,1,256), 
        '08', 
        2, 
        rxcui, 
        'Ingredient' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
   and tty='IN'
   AND  rxaui <> 2295010
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        0, 
        rxcui, 
        'Dose Form' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    and tty='DF'
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        0, 
        rxcui, 
        'Clinical Drug Component' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    and tty='SCDC'
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        0, 
        rxcui, 
        'Clinical Drug Form' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    and tty='SCDF'
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        1, 
        rxcui, 
        'Clinical Drug' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    and tty='SCD'
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        0, 
        rxcui, 
        'Brand Name' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    and tty='BN'
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        0, 
        rxcui, 
        'Branded Drug Component' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    and tty='SBDC'
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        0, 
        rxcui, 
        'Branded Drug Form' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    and tty='SBDF'
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        1, 
        rxcui, 
        'Branded Drug' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    and tty='SBD'
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        1, 
        code, 
        'Branded Pack' 
FROM    rxnConso 
WHERE   sab='RXNORM' 
    AND tty='BPCK'    /* Branded Pack */
UNION
SELECT  SUBSTR(str,1,256), 
        '08', 
        1, 
        code, 
        'Clinical Pack' 
FROM    rxnConso 
WHERE   sab='RXNORM'   AND tty='GPCK'    /* Clinical Pack */
;

exit;