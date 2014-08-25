-- This is the Control file for loading the tXXanweb_V3 table

LOAD        DATA
INFILE      'tXXanweb_V3.txt'
BADFILE     'tXXanweb_V3.bad'
DISCARDFILE 'tXXanweb_V3.dsc'
--APPEND
truncate
INTO TABLE tXXanweb_V3
FIELDS TERMINATED BY  ";"
TRAILING NULLCOLS
(HCPC CHAR(9),RIC CHAR(9),Long_Description CHAR(256))
-- (HCPC CHAR(9),Seq_Num CHAR(9),RIC CHAR(9),Long_Description CHAR(256))
--  (HCPC position(1:5) "TRIM(:HCPC)", Seq_Num position(6:8), RIC position(9:11), Long_Description position(12:91) )