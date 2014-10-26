options (skip=1)
load data
infile relationship.txt
into table relationship
append
fields terminated by ','
trailing nullcols
(
relationship_id,relationship_name,is_hierarchical,defines_ancestry,reverse_relationship
)