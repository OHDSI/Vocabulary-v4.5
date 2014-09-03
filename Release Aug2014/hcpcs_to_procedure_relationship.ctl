OPTIONS (SKIP=1)
LOAD DATA
INFILE hcpcs_to_procedure_relationship.txt
INTO TABLE hcpcs_to_proc_relationship
APPEND
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
concept_id_1,
concept_id_2
)
