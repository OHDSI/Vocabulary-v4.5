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
*  Date:           2012/10/10
*
*  The following 3 steps will create table in staging schema, populating concept relationship tree.
*  Create staging table CONCEPT_REL_STAGE_ROOT, Populate hierarchy based on top "root" concept
*  Create staging table CONCEPT_REL_STAGE_PROCEDURE, Populate hierarchy based on top "Procedure" concept
*  Create staging table CONCEPT_REL_STAGE_CLIN_FINDING, Populate hierarchy based on top "Clinical Finding" concept
*
*  Usage: 
*  echo "EXIT" | sqlplus SNOMED_20120131/myPass@DEV_VOCAB @01_build_hierarchy.sql ROOT 4008453
*  echo "EXIT" | sqlplus SNOMED_20120131/myPass@DEV_VOCAB @01_build_hierarchy.sql PROCEDURE 4322976
*  echo "EXIT" | sqlplus SNOMED_20120131/myPass@DEV_VOCAB @01_build_hierarchy.sql CLIN_FINDING 441840
*  nohup sqlplus -s SNOMED_20130131/myPass@DEV_VOCAB @01_build_hierarchy.sql ROOT 4008453 &
*
******************************************************************************/


SPOOL 01_build_hierarchy_&1..log;
DROP table tmp_Anc_&1.c;
DROP table CONCEPT_REL_STAGE_&1. ;          

--DECLARE vCONCEPT_CLASS varchar(60);

--BEGIN


  
create table tmp_Anc_&1.c AS
WITH stepbystep ( par, chl
---,way
,lv,ri 
 ) AS (
  SELECT CONCEPT_ID_1, CONCEPT_ID_2,
   ---CONCEPT_ID_1 || '-' || CONCEPT_ID_2
   1 as lv
  , rr.rowid
  --,rr.RELATIONSHIP_ID
  FROM   CONCEPT_RELATIONSHIP_STAGE rr--
  , concept_STAGE c 
  WHERE  1 = 1 
  AND CONCEPT_ID_1 = &2. -- 4008453--441840--35100000--441840 --4156363--4048384 --4008453 --AND RELATIONSHIP_ID = 010 441840  4286733
   AND C.CONCEPT_ID =  rr.CONCEPT_ID_1  --AND C.CONCEPT_TYPE_ID = 15 
  AND RELATIONSHIP_ID = 010
     UNION ALL
  SELECT r.CONCEPT_ID_1, r.CONCEPT_ID_2
      ---  , s.way || '-' || r.CONCEPT_ID_2
        , lv+1
       , r.rowid
   --,r.RELATIONSHIP_ID
  FROM CONCEPT_RELATIONSHIP_STAGE r
        INNER JOIN
        stepbystep s
        ON ( s.chl = r.CONCEPT_ID_1  AND R.RELATIONSHIP_ID = 010
        )
        WHERE lv < 16 -- iterations for $2. --
  )
CYCLE par SET cyclemark TO 1 DEFAULT 0
  --CYCLE root SET cyclemark TO 'X' DEFAULT '-'
SELECT 
par, chl
--!!!-, way
--, cyclemark
,lv
, cyclemark
, ri
 FROM stepbystep
 WHERE 1 = 1
AND cyclemark = 1
;


 CREATE table CONCEPT_REL_STAGE_&1.
   AS select * FROM CONCEPT_RELATIONSHIP_STAGE r
   WHERE R.RELATIONSHIP_ID = 010
   AND rowid not IN (select ri from tmp_Anc_&1.c);

CREATE INDEX XF_CR_&1.c_3CD2 ON CONCEPT_REL_STAGE_&1.
(CONCEPT_ID_2, RELATIONSHIP_ID, CONCEPT_ID_1)
;

  
   --END;

--/

exit;