options (skip=1)
load data
infile cpt4_to_procedure_relationship.txt
into table cpt4_to_proc_relationship
append
fields terminated by '\t'
optionally enclosed by '"'
trailing nullcols
(
cpt4_code,
snomed_code
)
