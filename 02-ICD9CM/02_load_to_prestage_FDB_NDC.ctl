options (direct=true, errors=0)
load data
infile 'RFMLISR0_ICD9CM_SEARCH.rrf' 
badfile 'RFMLISR0_ICD9CM_SEARCH.bad'
discardfile 'RFMLISR0_ICD9CM_SEARCH.dsc'
truncate
into table RFMLISR0_ICD9CM_SEARCH
fields terminated by '|'
trailing nullcols
(
  SEARCH_ICD9CM  CHAR(10)              ,
  RELATED_DXID   CHAR(8)                      ,
  FML_CLIN_CODE  CHAR(2)               ,
  FML_NAV_CODE   CHAR(2)               
)
