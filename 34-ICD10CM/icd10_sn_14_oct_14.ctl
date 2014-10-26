OPTIONS (SKIP=1)
LOAD DATA
INFILE icd10_sn_14_oct_14.csv
INTO TABLE icd10_sn_14_oct_14
REPLACE
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  source_code,
  source_code_description,
  target_concept_code
)
