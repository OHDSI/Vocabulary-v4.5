options (direct=true, errors=0, SKIP=1)
load data
characterset UTF8 length semantics char
infile 'LOINC_MAP_TO.TXT' --"str X'7c0d0a'"
badfile 'LOINC_MAP_TO.bad'
discardfile 'LOINC_MAP_TO.dsc'
truncate
into table LOINC_MAP_TO
--fields terminated by ','
--fields terminated by WHITESPACE
fields terminated by X'09'
trailing nullcols
(
LOINC CHAR(8256) "REPLACE(:LOINC, '\"', '')"     , 
MAP_TO CHAR(8256) "REPLACE(:MAP_TO , '\"', '')"    , 
COMMENTS CHAR(8256) "REPLACE(:COMMENTS , '\"', '')"    
)