OPTIONS (SKIP=1)
LOAD DATA
INFILE v10_marked.txt
INTO TABLE v10_marked
REPLACE
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  source_code,
  checked,
  source_code_description,
  target_concept_code,
  target_concept_name
)
