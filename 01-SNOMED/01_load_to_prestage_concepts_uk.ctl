options (direct=true, errors=0, SKIP=1)
load data
infile 'sct2_Description_Full-UK.txt' 
badfile 'sct2_Description_Full-UK.bad'
discardfile 'sct2_Description_Full-UK.dsc'
truncate
into table sct2_Desc_Full_UK
--WHEN  (50:),3,8) <> '%All rights reserved.%' 
--WHEN  (50:54) <> '2002-' 
--WHEN (01) <> '2665702012'
-- AND (01)  <> '2693208015'
-- AND (01)  <> '2794659017'
-- AND (01)  <> '2841556018'
-- AND (01)  <> '2883679019'
-- AND (01)  <> '2913224013'
--##fields terminated by '       ' --WHITESPACE
fields terminated by X'09'
trailing nullcols
(
id			    CHAR( 18)           ,		
effectiveTime	CHAR(  8)           ,		
active			CHAR(  1)           ,
moduleId		CHAR( 18)           ,		
conceptId		CHAR(256)           ,		
languageCode	CHAR(  2)           ,		
typeId			CHAR( 18)           ,		
term CHAR(256) "SUBSTR(:term, 1, 252)"      ,
caseSignificanceId	CHAR(256)           
)
