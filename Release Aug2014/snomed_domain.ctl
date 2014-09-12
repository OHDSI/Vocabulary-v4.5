options (skip=0)
load data
infile snomed_domain.txt
into table snomed_domain
replace
fields terminated by ','
optionally enclosed by '"'
trailing nullcols
(
concept_id,
domain_name
)
