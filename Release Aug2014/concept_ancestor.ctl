options (skip=0)
load data
infile 'c:\Users\christian\Documents\OHDSI\concept_ancestor.txt'
into table concept_ancestor
replace
fields terminated by ','
trailing nullcols
(
ancestor_concept_id,
descendant_concept_id,
max_levels_of_separation,
min_levels_of_separation
)