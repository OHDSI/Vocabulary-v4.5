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

-- Usage: 
-- echo "EXIT" | sqlplus ATC_YYYYMMDD/myPass@DEV_VOCAB @21_transform_row_concepts.sql

spool 21_transform_row_concepts.log
-- . 

truncate table concept_stage;

-- create new ATC concepts
insert into concept_stage (
  concept_name, 
  vocabulary_id, 
  concept_level, 
  concept_code,
  concept_class
)
select    
    atc_description,
    '21',
    3,
    atc_code,
    -- the class depends on the code length
    case 
      when length(atc_code)=1 then '1st level, Anatomical Main Group'
      when length(atc_code)=3 then '2nd level, Therapeutic Subgroup'
      when length(atc_code)=4 then '3rd level, Pharmacological Subgroup'
      when length(atc_code)=5 then '4th level, Chemical Subgroup'
      when length(atc_code)=7 then '5th level, Chemical Substance'
      end as concept_class
from atc_code
;

commit;
exit;
