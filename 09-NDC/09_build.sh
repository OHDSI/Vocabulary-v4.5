#!/bin/sh

sqlplus $1 @09_transform_row_maps.sql
sqlplus $1 @09_load_maps.sql