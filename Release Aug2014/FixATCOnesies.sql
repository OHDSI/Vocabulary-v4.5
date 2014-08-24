-- Deprecate all onesie-based relationship that were created to higher-level ATC classes
-- One direction
update concept_relationship r set
  r.valid_end_date = to_date('20140630', 'yyyymmdd'),
  r.invalid_reason = 'D'
where exists (
  select 1 from concept c1, concept c2
  where c1.concept_id=r.concept_id_1 and c1.vocabulary_id in (8, 22) and c1.concept_class='Ingredient'
  and c2.concept_id=r.concept_id_2 and c2.vocabulary_id=21 and length(c2.concept_code)<7 -- remove from all ATC codes that are not leaf nodes
)
and r.relationship_id=282
;

-- Other direction
update concept_relationship r set
  r.valid_end_date = to_date('20140630', 'yyyymmdd'),
  r.invalid_reason = 'D'
where exists (
  select 1 from concept c1, concept c2
  where c1.concept_id=r.concept_id_1 and c1.vocabulary_id = 21 and length(c1.concept_code)<7 -- remove from all ATC codes that are not leaf nodes
  and c2.concept_id=r.concept_id_2 and c2.vocabulary_id in (8, 22) and c2.concept_class='Ingredient'
)
and r.relationship_id=281
;

