-- 1. deprecate source_to_concept_map records where target_concept_id=0 and there is another record of the same source_code 
update source_to_concept_map isnull set
  isnull.valid_end_date='31-Jul-2014',
  isnull.invalid_reason='D'
where isnull.target_concept_id=0 -- delete the null of the pair
and exists (
  select 1 from source_to_concept_map notnull 
  join concept cnotnull on cnotnull.concept_id=notnull.target_concept_id -- to make sure the target_concept_id exists
  where isnull.source_code=notnull.source_code and isnull.source_vocabulary_id=notnull.source_vocabulary_id 
  and isnull.target_concept_id!=notnull.target_concept_id and notnull.invalid_reason is null
)
and isnull.invalid_reason is null
;

-- 2. fix Angström and Ampere ambiguity (same concept_code in vocabulary 11)
update concept set
  concept_code='Ang'
where concept_id=9452;

-- Rename vocabulary names
update vocabulary set vocabulary_name='OMOP Vocabulary v4.5 10-Sep-2014' where vocabulary_id=0;
update vocabulary set vocabulary_name='OMOP Visit' where vocabulary_id=24;
update vocabulary set vocabulary_name='OMOP Drug Exposure Type' where vocabulary_id=36;
update vocabulary set vocabulary_name='OMOP Condition Occurrence Type' where vocabulary_id=37;
update vocabulary set vocabulary_name='OMOP Procedure Occurrence Type' where vocabulary_id=38;
update vocabulary set vocabulary_name='OMOP Observation Type' where vocabulary_id=39;
update vocabulary set vocabulary_name='OMOP Death Type' where vocabulary_id=45;

-- undo ICD-9-Proc to SNOMED mapping deprecation
update concept_relationship r set
  r.valid_end_date='31-Dec-2099',
  r.invalid_reason=null 
where r.relationship_id in (92, 226)
and exists (
  select 1 from concept c where c.concept_id=r.concept_id_1 and c.concept_class='Procedure' and vocabulary_id=1
  union
  select 1 from concept c where c.concept_id=r.concept_id_2 and c.concept_class='Procedure' and vocabulary_id=1
);
exit;