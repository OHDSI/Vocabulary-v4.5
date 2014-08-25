options (direct=true)
load data
characterset UTF8 length semantics char
infile 'CMS_DESC_LONG_SG.txt' 
badfile 'CMS_DESC_LONG_SG.bad'
discardfile 'CMS_DESC_LONG_SG.dsc'
truncate
into table CMS_DESC_LONG_SG
--fields terminated by x'09' --WHITESPACE
 ( CODE position(1:4), name position(5:263) )
--trailing nullcols
--(CODE	char(8),NAME CHAR(3000) "SUBSTR(:NAME, 1, 256)" )
