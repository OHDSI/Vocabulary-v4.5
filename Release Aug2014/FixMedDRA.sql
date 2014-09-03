-- Deprecate all relationships from MedDRA LLT to SNOMED. Only MedDRA PT relationships should survive
-- One direction
update concept_relationship r set
  r.valid_end_date = to_date('20140631', 'yyyymmdd'),
  r.invalid_reason = 'D'
where exists (
  select 1 from concept c1, concept c2
  where c1.concept_id=r.concept_id_1 and c1.vocabulary_id=15 and c1.concept_class='Low Level Term'
  and c2.concept_id=r.concept_id_2 and c2.vocabulary_id=1
)
;

-- Other direction
update concept_relationship r set
  r.valid_end_date = to_date('20140631', 'yyyymmdd'),
  r.invalid_reason = 'D'
where exists (
  select 1 from concept c1, concept c2
  where c1.concept_id=r.concept_id_1 and c1.vocabulary_id=1
  and c2.concept_id=r.concept_id_2 and c2.vocabulary_id=15 and c2.concept_class='Low Level Term'
)
;

