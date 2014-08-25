options (direct=true, errors=0)
load data
infile 'RATCGC0_ATC_GCNSEQNO_LINK.rrf' 
badfile 'RATCGC0_ATC_GCNSEQNO_LINK.bad'
discardfile 'RATCGC0_ATC_GCNSEQNO_LINK.dsc'
truncate
into table RATCGC0_ATC_GCNSEQNO_LINK
fields terminated by '|'
trailing nullcols
(
  GCN_SEQNO  CHAR(6),
  ATC        CHAR(7)  ,
  ATC_VER    CHAR(6)
)
