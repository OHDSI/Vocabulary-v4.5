options (direct=true, errors=0, SKIP=1)
load data
infile 'sct1_Relationships_Core_INT.txt' 
badfile 'sct1_Relationships_Core_INT.bad'
discardfile 'sct1_Relationships_Core_INT.dsc'
truncate
into table sct1_Relationships_Core_INT
fields terminated by WHITESPACE
trailing nullcols
(
RELATIONSHIPID				char(256)           ,	
CONCEPTID1				char(256)           ,	
RELATIONSHIPTYPE			char(256)           ,	
CONCEPTID2				char(256)           ,	
CHARACTERISTICTYPE			char(256)           ,	
REFINABILITY				char(256)           ,	
RELATIONSHIPGROUP			char(256)           
)
