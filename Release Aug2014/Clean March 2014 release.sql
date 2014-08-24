-- 1. deprecate source_to_concept_map records where target_concept_id=0 and there is another record of the same source_code 
update source_to_concept_map isnull set
  isnull.valid_end_date='31-Jul-2014',
  isnull.invalid_reason='D'
where isnull.target_concept_id=0 -- delete the null of the pair
and exists (
  select 1 from source_to_concept_map notnull 
  join concept cnotnull on cnotnull.concept_id=notnull.target_concept_id
  where isnull.source_code=notnull.source_code and isnull.source_vocabulary_id=notnull.source_vocabulary_id and isnull.target_concept_id!=notnull.target_concept_id
)
;

-- 2. fix Angström and Ampere ambiguity (same concept_code in vocabulary 11)
update concept set
  concept_code='Ang'
where concept_id=9452;

