#!/bin/sh

sqlplus $1 @01_transform_row_concepts.sql
sqlplus $1 @01_load_concepts.sql 
sqlplus $1 @01_transform_row_relations.sql
sqlplus $1 @01_load_relations.sql
sqlplus $1 @01_build_hierarchy.sql PROCEDURE 4322976
sqlplus $1 @01_build_hierarchy.sql CLIN_FINDING 441840
sqlplus $1 @01_build_stage_ancestry.sql PROCEDURE
sqlplus $1 @01_build_stage_ancestry.sql CLIN_FINDING
sqlplus $1 @01_set_concept_class.sql



