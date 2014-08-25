spool 34_transform_row_maps.log;

-- Create temporary table for uploading concept. 
truncate table source_to_concept_map_stage;

-- create new stage
insert into source_to_concept_map_stage
select 
  null as source_to_concept_map_id,
  case 
    when length(m.source_code)>3 then substr(m.source_code, 1, 3)||'.'||substr(m.source_code, 4) 
    else source_code 
  end as source_code,
  m.source_code_description,
  'XXX' as mapping_type, -- mapping type gets overwritten by the domain of the target SNOMED concept
  coalesce(c.concept_id, 0) as target_concept_id, -- if not mapping map to 0
  case when c.concept_id is null then 0 when c.concept_id=0 then 0 else 1 end as target_vocabulary_id,
  34 as source_vocabulary_id
from v10_marked m
left outer join dev.concept c on trim(m.target_concept_code)=c.concept_code and c.vocabulary_id=1
;

-- Remap when target_concept_id is obsolete
drop table historical_tree;

create table historical_tree as 
select root, concept_id_2 from (
  select root, concept_id_2, dt,  row_number() over (partition by  root order by dt desc) rn
    from (
      select rownum rn, level lv, lpad(' ', 8 * level) || c1.concept_name||'-->'||c2.concept_name tree, r.concept_id_1, r.concept_id_2, r.relationship_id,
        r.valid_start_date dt,
        c1.concept_code ||'-->'||c2.concept_code  tree_code,
        c1.vocabulary_id||'-->'||c2.vocabulary_id tree_voc,
        c1.concept_level||'-->'||c2.concept_level tree_lv,
        c1.concept_class||'-->'||c2.concept_class tree_cl,
        connect_by_iscycle iscy,
        connect_by_root concept_id_1 root,
        connect_by_isleaf lf
      from  dev.concept_relationship r, dev.relationship rt, dev.concept c1, dev.concept c2
      where 1 = 1
        and rt.relationship_id = r.relationship_id  and r.relationship_id in (311, 349, 351, 353, 355) -- SNOMED update relationships
        and nvl(r.invalid_reason, 'X') <> 'D'
        and c1.concept_id = r.concept_id_1
        and c2.concept_id = r.concept_id_2
      connect by  
      nocycle  
      prior r.concept_id_2 = r.concept_id_1
        and rt.relationship_id = r.relationship_id  and r.relationship_id in (311, 349, 351, 353, 355)
        and nvl(r.invalid_reason, 'X') <> 'D'
      start with rt.relationship_id = r.relationship_id  and r.relationship_id in (311, 349, 351, 353, 355)
      and nvl(r.invalid_reason, 'X') <> 'D'
    ) sou 
) where rn = 1
;

create index x_hi_tree on historical_tree (root);

update source_to_concept_map_stage m
set target_concept_id = (select concept_id_2 from historical_tree t where m.target_concept_id = t.root )
where exists (select 1 from historical_tree tt where m.target_concept_id = tt.root )
;
----- end remap --
commit;
exit;
