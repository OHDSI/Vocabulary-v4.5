options (direct=true, errors=0, SKIP=1)
load data
infile 'sct1_Concepts.txt' 
badfile 'sct1_Concepts.bad'
discardfile 'sct1_Concepts.dsc'
truncate
into table sct1_Concepts
--fields terminated by WHITESPACE
fields terminated by X'09' 
trailing nullcols
(
CONCEPTID 		CHAR(256),
CONCEPTSTATUS		CHAR(256),
FULLYSPECIFIEDNAME	CHAR(256),
CTV3ID			CHAR( 9) ,
SNOMEDID		CHAR(256),
ISPRIMITIVE		CHAR(256)           
)
