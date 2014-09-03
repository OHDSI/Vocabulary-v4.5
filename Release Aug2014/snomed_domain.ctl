options (skip=0)
load data
infile snomed_domain.txt
into table concept_domain
replace
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
concept_id,
domain_name
)
