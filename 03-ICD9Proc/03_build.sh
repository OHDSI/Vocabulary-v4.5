#!/bin/sh

sqlplus $1 @03_transform_row_concepts.sql
sqlplus $1 @03_load_concepts.sql 
sqlplus $1 @03_transform_row_relations.sql 
sqlplus $1 @03_load_relations.sql
sqlplus $1 @03_transform_row_maps.sql
sqlplus $1 @03_load_maps.sql