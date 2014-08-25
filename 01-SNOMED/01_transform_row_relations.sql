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
*  echo "EXIT" | sqlplus SNOMED_20120131/myPass@DEV_VOCAB @01_transform_row_relations.sql 
*
******************************************************************************/
SPOOL 01_transform_row_relations.log
-- .      

--DROP SEQUENCE SEQ_RELATIONSHIP;
--CREATE SEQUENCE SEQ_RELATIONSHIP START WITH 5000000;


-- Create temporary table for uploading concept relatioships. 
--DELETE FROM CONCEPT_RELATIONSHIP_STAGE.; 
TRUNCATE TABLE CONCEPT_RELATIONSHIP_STAGE; 
DROP TABLE TMP_ROW_REL;


-- NEED uncomment !!!
--/*
SELECT '01-RELATIONS' FROM dual;

CREATE TABLE TMP_ROW_REL AS
SELECT SOURCEID, DESTINATIONID, TERM FROM (
SELECT -- + INDEX(d)
    r.SOURCEID, r.DESTINATIONID, d.TERM
, ROW_NUMBER() OVER (PARTITION BY  r.ID ORDER BY TO_DATE(r.EFFECTIVETIME,'YYYYMMDD') DESC
       ) rn    
       , r.ACTIVE 
       --, r.ID
       --, TO_DATE(r.EFFECTIVETIME,'YYYYMMDD') 
          FROM SCT2_RELA_FULL_MERGED r,
               sct2_Desc_Full_MERGED d
         WHERE 1 = 1 AND r.TYPEID = d.CONCEPTID
         AND D.MODULEID = R.MODULEID
         AND d.TERM NOT LIKE '%(attribute)%'
         --AND r.ACTIVE = 1 
         AND NOT 
         (
         --(r.SOURCEID = 64572001   AND r.DESTINATIONID = 404684003) OR
         --(r.SOURCEID = 246061005   AND r.DESTINATIONID = 106237007) OR  
         --(r.SOURCEID = 106237007   AND r.DESTINATIONID = 900000000000441003)
         (r.SOURCEID = 243796009   AND r.DESTINATIONID = 138875005) OR
         (r.SOURCEID = 246061005   AND r.DESTINATIONID = 138875005) OR
         (r.SOURCEID = 246188002   AND r.DESTINATIONID = 138875005) OR
         (r.SOURCEID = 64572001    AND r.DESTINATIONID = 138875005) OR
         (r.SOURCEID = 900000000000441003   AND r.DESTINATIONID = 138875005)
         )
         /*
         AND d.TERM NOT IN (
           'Morphology'
         , 'Intent'
         , 'Subject relationship context'
         , 'Pathological process (qualifier value)'
         , 'Using'
         )
         --*/
--ORDER BY r.id,  TO_DATE(r.EFFECTIVETIME,'YYYYMMDD') DESC  
)
WHERE  rn = 1 AND active = 1      
; 
INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID
   -- ,TERM 
    )
SELECT 
  CASE WHEN RELATIONSHIP_ID = 010 THEN CONCEPT_ID_2 ELSE CONCEPT_ID_1 END AS CONCEPT_ID_1
, CASE WHEN RELATIONSHIP_ID = 010 THEN CONCEPT_ID_1 ELSE CONCEPT_ID_2 END AS CONCEPT_ID_2
, RELATIONSHIP_ID AS RELATIONSHIP_ID
--, null AS TERM  
FROM (    
SELECT 
DISTINCT 
         (SELECT (CONCEPT_ID) FROM CONCEPT_STAGE WHERE --VOCABULARY_ID = 01 AND 
         CONCEPT_CODE = SOURCEID) as CONCEPT_ID_1
,        (SELECT (CONCEPT_ID) FROM CONCEPT_STAGE WHERE --VOCABULARY_ID = 01 AND 
CONCEPT_CODE = DESTINATIONID) as CONCEPT_ID_2
,        RELATIONSHIP_ID
--,TERM 
FROM (
SELECT SOURCEID,
       DESTINATIONID,
       CASE
          WHEN TERM = 'Is a' THEN 010
          WHEN TERM = 'Recipient category' THEN 029
          WHEN TERM = 'Procedure site' THEN 030
          WHEN TERM = 'Priority' THEN 031
          WHEN TERM = 'Pathological process' THEN 032
          WHEN TERM = 'Part of' THEN 033
          WHEN TERM = 'Severity' THEN 034
          WHEN TERM = 'Revision status' THEN 035
          WHEN TERM = 'Access' THEN 036
          WHEN TERM = 'Occurrence' THEN 037
          WHEN TERM = 'Method' THEN 038
          WHEN TERM = 'Laterality' THEN 039
          WHEN TERM = 'Interprets' THEN 040
          WHEN TERM = 'Indirect morphology' THEN 041
          WHEN TERM = 'Indirect device' THEN 042
          WHEN TERM = 'Has specimen' THEN 043
          WHEN TERM = 'Has interpretation' THEN 044
          WHEN TERM = 'Has intent' THEN 045
          WHEN TERM = 'Has focus' THEN 046
          WHEN TERM = 'Has definitional manifestation' THEN 047
          WHEN TERM = 'Has active ingredient' THEN 048
          WHEN TERM = 'Finding site' THEN 049
          WHEN TERM = 'Episodicity' THEN 050
          WHEN TERM = 'Direct substance' THEN 051
          WHEN TERM = 'Direct morphology' THEN 052
          WHEN TERM = 'Direct device' THEN 053
          WHEN TERM = 'Component' THEN 054
          WHEN TERM = 'Causative agent' THEN 055
          WHEN TERM = 'Associated morphology' THEN 056
          WHEN TERM = 'Associated finding' THEN 057
          WHEN TERM = 'Measurement Method' THEN 058
          WHEN TERM = 'Property' THEN 059
          WHEN TERM = 'Scale type' THEN 060
          WHEN TERM = 'Time aspect' THEN 061
          WHEN TERM = 'Specimen procedure' THEN 062
          WHEN TERM = 'Specimen source identity' THEN 063
          WHEN TERM = 'Specimen source morphology' THEN 064
          WHEN TERM = 'Specimen source topography' THEN 065
          WHEN TERM = 'Specimen substance' THEN 066
          WHEN TERM = 'Due to' THEN 067
          WHEN TERM = 'Subject TERMtionship context' THEN 068
          WHEN TERM = 'Has dose form' THEN 069
          WHEN TERM = 'After' THEN 070
          WHEN TERM = 'Associated procedure' THEN 071
          WHEN TERM = 'Procedure site - Direct' THEN 072
          WHEN TERM = 'Procedure site - Indirect' THEN 073
          WHEN TERM = 'Procedure device' THEN 074
          WHEN TERM = 'Procedure morphology' THEN 075
          WHEN TERM = 'Finding context' THEN 076
          WHEN TERM = 'Procedure context' THEN 077
          WHEN TERM = 'Temporal context' THEN 078
          WHEN TERM = 'Associated with' THEN 079
          WHEN TERM = 'Surgical approach' THEN 080
          WHEN TERM = 'Using device' THEN 081
          WHEN TERM = 'Using energy' THEN 082
          WHEN TERM = 'Using substance' THEN 083
          WHEN TERM = 'Using access device' THEN 084
          WHEN TERM = 'Clinical course' THEN 085
          WHEN TERM = 'Route of administration' THEN 086
          WHEN TERM = 'Finding method' THEN 087
          WHEN TERM = 'Finding informer' THEN 088
          ELSE 999
       END
          AS RELATIONSHIP_ID
    --   ,TERM   
  FROM (
         SELECT     SOURCEID, DESTINATIONID, TERM FROM TMP_ROW_REL 
         )
)     
)  WHERE CONCEPT_ID_1 IS NOT NULL 
        AND CONCEPT_ID_2 IS NOT NULL         
;

INSERT INTO CONCEPT_RELATIONSHIP_STAGE(CONCEPT_ID_1, CONCEPT_ID_2, RELATIONSHIP_ID)
SELECT CONCEPT_ID_1,    CONCEPT_ID_2,    RELATIONSHIP_ID FROM (
SELECT 
C1.CONCEPT_ID CONCEPT_ID_1, C2.CONCEPT_ID CONCEPT_ID_2, CASE 
    WHEN sc.REFSETID = 900000000000526001 THEN 311 
    WHEN sc.REFSETID = 900000000000523009 THEN 353
    WHEN sc.REFSETID = 900000000000528000 THEN 355
    WHEN sc.REFSETID = 900000000000527005 THEN 349
    WHEN sc.REFSETID = 900000000000530003 THEN 351
END RELATIONSHIP_ID, sc.EFFECTIVETIME
,ROW_NUMBER() OVER (PARTITION BY  C1.CONCEPT_ID ORDER BY TO_DATE(sc.EFFECTIVETIME, 'YYYYMMDD') DESC) rn
,  sc.ACTIVE  
FROM 
  der2_cRefset_AssRefFull_merged sc
, dev.concept c1
, dev.concept c2
WHERE 1= 1
AND C1.VOCABULARY_ID = 01 AND C1.CONCEPT_CODE = SC.REFERENCEDCOMPONENTID
AND C2.VOCABULARY_ID = 01 AND C2.CONCEPT_CODE = SC.TARGETCOMPONENT
AND sc.REFSETID IN (900000000000526001, 900000000000526001, 900000000000523009, 900000000000528000, 900000000000527005, 900000000000530003)
) WHERE rn = 1 AND ACTIVE = 1
;

commit;

DELETE                                                    
      FROM  CONCEPT_RELATIONSHIP_STAGE r
      WHERE 1 = 1 AND r.RELATIONSHIP_ID = 010
            AND ROWID <>
                   (SELECT MIN (t.ROWID)
                      FROM CONCEPT_RELATIONSHIP_STAGE t
                     WHERE t.RELATIONSHIP_ID = 010
                           AND (t.CONCEPT_ID_1 = r.CONCEPT_ID_1
                                AND t.CONCEPT_ID_2 = r.CONCEPT_ID_2
                                OR t.CONCEPT_ID_2 = r.CONCEPT_ID_1
                                   AND t.CONCEPT_ID_1 = r.CONCEPT_ID_2))

commit;

SELECT 'Revers-RELATIONS' FROM dual;
INSERT INTO CONCEPT_RELATIONSHIP_STAGE(
    CONCEPT_ID_1, 
    CONCEPT_ID_2, 
    RELATIONSHIP_ID)
SELECT  
    R.CONCEPT_ID_2 AS CONCEPT_ID_1, R.CONCEPT_ID_1 AS CONCEPT_ID_2,
  NVL((SELECT REVERSE_RELATIONSHIP from
    DEV.RELATIONSHIP rt WHERE rt.RELATIONSHIP_ID = r.RELATIONSHIP_ID), 998)
  FROM  CONCEPT_RELATIONSHIP_STAGE r
  ; 
commit;

DROP TABLE TMP_ROW_REL;

exit;
