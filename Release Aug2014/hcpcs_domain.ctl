options (skip=1)
load data
infile hcpcs_domain.txt
into table hcpcs_domain
replace
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
concept_id,
concept_code,
concept_class
)