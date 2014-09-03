options (skip=1)
load data
infile cpt4_domain.txt
into table cpt4_domain
replace
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
concept_id,
concept_code,
domain_name,
secondary_domain
)