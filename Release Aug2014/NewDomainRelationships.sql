--The only allowable concepts for the GENDER_CONCEPT_ID field are defined as any descendants of the domain 'GENDER' (CONCEPT_ID = 1)
--There is no enforcement of allowable concepts in the GENDER_SOURCE_CONCEPT_ID field, but it must be a valid value in the CONCEPT table.

-- Define new relationships
insert into relationship (relationship_id, relationship_name, reverse_relationship, is_hierarchical, defines_ancestry)
values (357, 'Domain subsumes (OMOP)', 358, 1, 1);
insert into relationship (relationship_id, relationship_name, reverse_relationship, is_hierarchical, defines_ancestry)
values (358, 'Is a domain (OMOP)', null, 0, 0);

-- deprecate null flavors for sex and race;
update concept set 
  valid_end_date='31-Jul-2014',
  invalid_reason='D'
where concept_id in (8521, 8522, 8551, 8552, 8570, 9178);

-- make all snomed active (concept_level=1)
update concept c set 
  c.concept_level=1
where c.vocabulary_id=1 and c.concept_level=0
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_1=c.concept_id and s.defines_ancestry=1
);

-- make all snomed active (concept_level=2)
update concept c set 
  c.concept_level=2
where c.vocabulary_id=1 and c.concept_level=0
and exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_1=c.concept_id and s.defines_ancestry=1
);

-- Define gender
insert into concept_relationship 
select 
  2 as concept_id_1, concept_id as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept where vocabulary_id=12;

-- Define race
insert into concept_relationship
select 
  3 as concept_id_1, c.concept_id as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=13
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null
);

-- Define ethnicity
insert into concept_relationship
select 
  4 as concept_id_1, c.concept_id as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=44
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null
);

-- Define observation_period_type
insert into concept_relationship
select 
  5 as concept_id_1, c.concept_id as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=61
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null
);

-- Define Death Type
insert into concept_relationship
select 
  6 as concept_id_1, c.concept_id as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=45
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null
);

-- Define Visit
insert into concept_relationship
select 
  8 as concept_id_1, c.concept_id as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=24
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null
);

-- Define Visit Type
insert into concept_relationship
select 
  9 as concept_id_1, c.concept_id as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=62
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null
);

----------------------
select * from vocabulary order by vocabulary_id;
select * from concept where vocabulary_id=24;
select * from concept_relationship r, relationship s where s.relationship_id=r.relationship_id and r.concept_id_2 in (9203);
-- Define Procedure
insert into concept_relationship
select 
  10 as concept_id_1, c.concept_id as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from (
  select c.concept_id from concept c join snomed_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=1 and d.domain='Procedure'
  union
  select c.concept_id from concept c where c.vocabulary_id=3 -- icd-9-proc are all procedures
  union
  select c.concept_id from concept c join cpt4_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=4 and d.domain='Procedure'
  union
  select c.concept_id from concept c join hcpcs_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=5 and d.domain='Procedure'
  -- add ospc-4 here
) c
where not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Procedure Type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 11 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Modifiers
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 12 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Drug
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 13 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from (
  select c.concept_id from concept c join snomed_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=1 and d.domain='Drug'
  union
  select c.concept_id from concept c where c.vocabulary_id in (7, 8, 19, 20, 21, 32) -- NDF-RT, RxNorm, ATC, ETC, FDB indications, VA Class
) c
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Drug Type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 14 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Route, needs special concept_ancestor treatment
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 15 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c 
where vocabulary_id=1 and concept_class='Qualifier value'
and concept_name in ('Intravenous', 'Oral',' Rectal', 'Intramuscular use', 'Topical', 'Intravaginal', 'Inhalation', 'Intrathecal route', 'Nasal','Intraocular use', 'Subcutaneous', 'Urethral use')
 and invalid_reason is null;

-- Define Unit
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 16 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Device
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 17 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from (
  select c.concept_id from concept c join snomed_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=1 and d.domain='Device'
  union
  select c.concept_id from concept c join cpt4_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=4 and d.domain='Device'
  union
  select c.concept_id from concept c join hcpcs_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=5 and d.domain='Device'
  -- add ospc-4 here
) c
where not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Device Type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 18 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Condition
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 19 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from (
  select c.concept_id from concept c join snomed_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=1 and d.domain='Condition'
  union
  select c.concept_id from concept c join cpt4_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=4 and d.domain='Condition'
  union
  select c.concept_id from concept c join hcpcs_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=5 and d.domain='Condition'
  -- add ospc-4 here
) c
where not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Condition Type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 20 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Measurement
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 21 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from (
  select c.concept_id from concept c join snomed_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=1 and d.domain='Measurement'
  union
  select c.concept_id from concept c join cpt4_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=4 and d.domain='Measurement'
  union
  select c.concept_id from concept c join hcpcs_concept_domain d on c.concept_id=d.concept_id where c.vocabulary_id=5 and d.domain='Measurement'
  union
  select concept_id from concept where vocabulary_id in (6, 46) -- Loinc and Loinc multidimensional hierarchy
  -- add ospc-4 here
) c
where not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

22, 'Measurement type',
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

23, 'Measurement value operator',
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

24, 'Measurement value',
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

-- Define Note Type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 26 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=58
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

27, 'Observation'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

28, 'Observation type'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

31, 'Relationship'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

32, 'Place of service'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

33, 'Provider specialty'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

34, 'Currency'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

35, 'Revenue code'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

36, 'Specimen'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

37, 'Specimen type'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

38, 'Specimen anatomic site'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

39, 'Specimen disease status'
-- Define observation_period_type
insert into concept_relationship
select 
  c.concept_id as concept_id_1, 5 as concept_id_2, 357 as relationship_id, '1-Jan-1970' as valid_start_date, '31-Dec-2099' as valid_end_date, null as invalid_reason
from concept c where c.vocabulary_id=NNN
and not exists (
  select 1 from concept_relationship r join relationship s on s.relationship_id=r.relationship_id
  where r.concept_id_2=c.concept_id and s.defines_ancestry=1
and invalid_reason is null);

40, 'Generic'







--official set of SNOMED concepts belonging to the ROUTE domain
select *
from concept
where vocabulary_id = 1
and concept_class = 'Qualifier value'
and concept_name in ('Intravenous','Oral','Rectal','Intramuscular use', 'Topical','Intravaginal', 'Inhalation', 'Intrathecal route','Nasal','Intraocular use', 'Subcutaneous', 'Urethral use')


--official operator concepts
select *
from concept
where vocabulary_id = 1
and concept_class = 'Qualifier value'
and concept_name in ('Equal symbol =','Greater-than-or-equal symbol >=','Less-than-or-equal symbol <=','Less-than symbol <','Greater-than symbol >')
 and invalid_reason is null;



--official concepts for specimen
select *
from concept
where vocabulary_id = 1
and concept_class = 'specimen' and invalid_reason is null;


--official concepts for specimen anatomic site
select *
from concept
where vocabulary_id = 1
and concept_class = 'body structure' and invalid_reason is null;


--official concepts for specimen disease status
select *
from concept
where vocabulary_id = 1
and concept_class = 'Qualifier value'
and concept_name in ('malignant', 'normal','abnormal')
and invalid_reason is null and invalid_reason is null;

