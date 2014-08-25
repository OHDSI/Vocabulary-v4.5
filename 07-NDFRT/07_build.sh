#!/bin/sh

sqlplus $1 @07_transform_row_concepts.sql
sqlplus $1 @07_load_concepts.sql
sqlplus $1 @07_transform_row_relations.sql 
sqlplus $1 @07_load_relations.sql
