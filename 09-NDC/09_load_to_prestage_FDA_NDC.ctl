options (direct=true, errors=0, SKIP=1)
load data
infile 'package.tx' 
badfile 'package.bad'
discardfile 'package.dsc'
truncate
into table FDA_NDC_PACKAGES
--fields terminated by '|'
--fields terminated by WHITESPACE
fields terminated by X'09'
trailing nullcols
(
PRODUCTNDC		CHAR(10) ,
NDCPACKAGECODE		CHAR(12) ,
--PACKAGEDESCRIPTION	CHAR(256) 
PACKAGEDESCRIPTION CHAR(8256) "SUBSTR(:PACKAGEDESCRIPTION, 1, 256)"      
)
