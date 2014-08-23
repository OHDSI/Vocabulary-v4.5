OPTIONS (SKIP=1)
LOAD DATA
INFILE keyv2.all
INTO TABLE keyv2
REPLACE
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  termclass,
  classnumber,
  description_short,
  description,
  description_long,
  termcode,
  lang,
  readcode,
  digit
)
