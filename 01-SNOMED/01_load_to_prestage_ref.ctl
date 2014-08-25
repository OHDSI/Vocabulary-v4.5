options (direct=true, errors=0, SKIP=1)
load data
characterset UTF8 length semantics char
infile 'der2_cRefset_AssociationReferenceFull_INT.txt' --"str X'7c0d0a'"
badfile 'der2_cRefset_AssociationReferenceFull_INT.bad'
discardfile 'der2_cRefset_AssociationReferenceFull_INT.dsc'
truncate
into table der2_cRefset_AssRefFull_INT
--fields terminated by ';'
fields terminated by WHITESPACE
--fields terminated by X'09'
trailing nullcols
(
id		 CHAR(256),	
effectiveTime    CHAR(256),	
active		 CHAR(256),	
moduleId	 CHAR(256),	
refsetId	 CHAR(256),	
referencedComponentId   	 CHAR(256),	
targetComponent	 CHAR(256)
)