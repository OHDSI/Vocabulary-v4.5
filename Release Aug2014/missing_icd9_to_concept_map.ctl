options (skip=1)
load data
infile missing_icd9_to_concept_map.txt
into table missing_icd9_to_concept_map
append
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
source_code,
target_code
)
