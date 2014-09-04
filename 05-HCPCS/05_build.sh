#!/bin/sh

sqlplus $1 @05_transform_row_concepts.sql
sqlplus $1 @05_load_concepts.sql
sqlplus $1 @05_transform_row_maps.sql
sqlplus $1 @05_load_maps.sql