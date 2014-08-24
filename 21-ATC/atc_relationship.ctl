OPTIONS (SKIP=1)
LOAD DATA
INFILE atc_relationship.txt
INTO TABLE atc_relationship
REPLACE
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
atc_code,
rxnorm_concept_id,
combination
)
