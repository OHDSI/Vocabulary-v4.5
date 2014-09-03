OPTIONS (SKIP=1)
LOAD DATA
INFILE hcpcs_to_measurement_relationship.txt
INTO TABLE hcpcs_to_meas_relationship
APPEND
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
concept_id_1,
concept_id_2
)
