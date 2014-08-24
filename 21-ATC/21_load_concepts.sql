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

spool 21_load_concepts.log; 

-- Get existing ATC concept_id into stage
update concept_stage d
set concept_id = (
  select  c.concept_id
  from dev.concept c 
  where c.concept_code = d.concept_code and c.vocabulary_id = 21
)
;

-- Update all concept_names and make fresh if still existing in stage
update dev.concept c set 
  c.concept_name = (select st.concept_name from concept_stage st where c.concept_code=st.concept_code), 
  c.concept_class = (select s.concept_class from concept_stage s where c.concept_code=s.concept_code),
  c.valid_end_date = to_date('12312099', 'mmddyyyy'), 
  c.invalid_reason = null
where exists (
  select 1 from concept_stage st where c.concept_code=st.concept_code and c.vocabulary_id=21
)
;

select * from dev.concept where vocabulary_id=21 and invalid_reason is not null;

-- Deprecate ones that are now missing
update dev.concept c set
  valid_end_date = to_date(substr(user, regexp_instr(user, '_[[:digit:]]')+1, 256),'yyyymmdd')-1, 
  invalid_reason = 'D'
where not exists (
  select 1 from concept_stage s where c.concept_id = s.concept_id
)
  and c.valid_end_date = to_date('12312099','mmddyyyy')
  and c.valid_start_date < to_date(substr(user, regexp_instr(user, '_[[:digit:]]')+1, 256),'yyyymmdd')
  and c.vocabulary_id = 21
  and c.invalid_reason is not null
;

-- Insert new concepts
insert into dev.concept (
  concept_id, 
  concept_name, 
  vocabulary_id, 
  concept_level, 
  concept_code,
  concept_class,
  valid_start_date,
  valid_end_date,
  invalid_reason
)
select  
  dev.seq_concept.nextval as concept_id,
  concept_name, 
  vocabulary_id, 
  concept_level, 
  concept_code,
  concept_class,
  to_date(substr(user, regexp_instr(user, '_[[:digit:]]')+1, 256),'yyyymmdd') as valid_start_date,
  to_date('12312099','mmddyyyy') as valid_end_date,
  null as invalid_reason
from concept_stage
where concept_id is null
;

commit;
exit;
