/**************************************************************************
* Copyright 2014 Observational Health Data Sciences and Informatics (OHDSI)
* OMOP Standard Vocabulary V4.4
* 
* This is free and unencumbered software released into the public domain.
* 
* Anyone is free to copy, modify, publish, use, compile, sell, or
* distribute this software, either in source code form or as a compiled
* binary, for any purpose, commercial or non-commercial, and by any
* means.
* 
* In jurisdictions that recognize copyright laws, the author or authors
* of this software dedicate any and all copyright interest in the
* software to the public domain. We make this dedication for the benefit
* of the public at large and to the detriment of our heirs and
* successors. We intend this dedication to be an overt act of
* relinquishment in perpetuity of all present and future rights to this
* software under copyright law.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
* 
* For more information, please refer to <http://unlicense.org/>
**************************************************************************/

truncate table concept_relationship_stage; 

-- Create ISA relationships based on concept_code match. load_concepts.sql has to be run at this point.
insert into concept_relationship_stage (
  concept_id_1, 
  concept_id_2, 
  relationship_id
)
select
  c1.concept_id,
  c2.concept_id,
  10
from (
  select
    r.atc_code as concept_code_1, 
    rp.atc_code as concept_code_2 
  from atc_code r, atc_code rp
  where rp.atc_code=substr(r.atc_code, 1, length(r.atc_code)-1)
  union all
  select
    r.atc_code as concept_code_1, 
    rp.atc_code as concept_code_2 
  from atc_code r, atc_code rp
  where length(r.atc_code) in (3, 7)
  and rp.atc_code=substr(r.atc_code, 1, length(r.atc_code)-2)
) t
join dev.concept c1 on t.concept_code_1=c1.concept_code and c1.vocabulary_id=21
join dev.concept c2 on t.concept_code_2=c2.concept_code and c2.vocabulary_id=21
;

-- Add OMOP ATC to RxNorm relationships
insert into concept_relationship_stage (
  concept_id_1, 
  concept_id_2, 
  relationship_id
)
select 
  c1.concept_id,
  t.concept_id_2,
  289 -- ATC to RxNorm (OMOP)
from (
  select atc_code as concept_code_1, rxnorm_concept_id as concept_id_2 from atc_relationship where rxnorm_concept_id is not null
) t
join dev.concept c1 on t.concept_code_1=c1.concept_code and c1.vocabulary_id=21
;

-- Invert relationships
insert into concept_relationship_stage (
  concept_id_1, 
  concept_id_2, 
  relationship_id
)
select
  r.concept_id_2 as concept_id_1, 
  r.concept_id_1 as concept_id_2,
  (select reverse_relationship from dev.relationship v where v.relationship_id = r.relationship_id)
  from  concept_relationship_stage r
; 

commit;
exit;
