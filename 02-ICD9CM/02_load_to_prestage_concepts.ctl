options (direct=true)
load data
characterset UTF8 length semantics char
infile 'CMS_DESC_LONG_DX.txt' 
badfile 'CMS_DESC_LONG_DX.bad'
discardfile 'CMS_DESC_LONG_DX.dsc'
truncate
into table CMS_DESC_LONG_DX
--fields terminated by x'09' --WHITESPACE
 ( CODE position(1:6), name position(7:263) )
--trailing nullcols
--(CODE	char(8),NAME CHAR(3000) "SUBSTR(:NAME, 1, 256)" )
