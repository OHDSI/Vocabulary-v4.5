options (direct=true, errors=0)
load data
infile 'RETCGC0_ETC_GCNSEQNO.rrf' 
badfile 'RETCGC0_ETC_GCNSEQNO.bad'
discardfile 'RETCGC0_ETC_GCNSEQNO.dsc'
truncate
into table RETCGC0_ETC_GCNSEQNO
fields terminated by '|'
trailing nullcols
(
  GCN_SEQNO            CHAR(6) ,
  ETC_ID               CHAR(8) ,
  ETC_COMMON_USE_IND   CHAR(1),
  ETC_DEFAULT_USE_IND  CHAR(1)
)
