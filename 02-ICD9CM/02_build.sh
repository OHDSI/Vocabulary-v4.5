#!/bin/sh

sqlplus $1 @02_transform_row_maps.sql
sqlplus $1 @02_load_maps.sql
 