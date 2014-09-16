/* Apply various fixes */

-- Replace bad concept_names in SNOMED. Use UMLS information for that.
update concept c set  
  c.concept_name = ( -- take the best str, and remove things like "(procedure)"
    select distinct first_value(regexp_replace(n.str, ' \(.*?\)$', '')) over (
      partition by n.code order by 
        decode(n.tty,
          'PT', 1,
          'PTGB', 2,
          'SY', 3,
          'SYGB', 4,
          'MTH_PT', 5,
          'FN', 6,
          'MTH_SY', 7,
          'SB', 8,
          10 -- default for the obsolete ones
      ) 
    )
  from umls.mrconso n where n.code=c.concept_code and n.sab='SNOMEDCT_US'
  )
where exists ( -- the concept_name is identical to the str of a record 
  select 1 from umls.mrconso m where m.code=c.concept_code and m.sab='SNOMEDCT_US' and c.vocabulary_id=1 and trim(c.concept_name)=trim(m.str)
  and m.tty != 'PT' -- anything that is not the preferred term
)
and c.invalid_reason is null -- only active ones. The inactive ones often only have obsolete tty anyway
and c.vocabulary_id=1
;


-- add new vocabularies
insert into vocabulary (vocabulary_id, vocabulary_name) values (58, 'OMOP Note Type');
insert into vocabulary (vocabulary_id, vocabulary_name) values (59, 'OMOP Domain');
insert into vocabulary (vocabulary_id, vocabulary_name) values (60, 'PCORNet');
insert into vocabulary (vocabulary_id, vocabulary_name) values (61, 'OMOP Observation Period Type');
insert into vocabulary (vocabulary_id, vocabulary_name) values (62, 'OMOP Visit Type');
insert into vocabulary (vocabulary_id, vocabulary_name) values (63, 'OMOP Device Type');
insert into vocabulary (vocabulary_id, vocabulary_name) values (64, 'OMOP Measurement Type');
insert into vocabulary (vocabulary_id, vocabulary_name) values (65, 'Currency');
insert into vocabulary (vocabulary_id, vocabulary_name) values (66, 'OMOP Relationship');
insert into vocabulary (vocabulary_id, vocabulary_name) values (67, 'OMOP Vocabulary');
insert into vocabulary (vocabulary_id, vocabulary_name) values (68, 'OMOP Concept Class');

-- add Note types
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Discharge summary', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Admission note', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inpatient note', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Outpatient note', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Radiology report', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pathology report', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ancillary report', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Nursing report', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Note', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Emergency department note', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Operative/procedure report', 1, 'Note Type', 58, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- add new domain concepts. The concept_ids are fixed and low
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (1, 'Domain', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (2, 'Gender', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (3, 'Race', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (4, 'Ethnicity', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (5, 'Observation period type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (6, 'Death type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (7, 'Metadata', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (8, 'Visit', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (7, 'Metadata', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (9, 'Visit type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (10, 'Procedure', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (11, 'Procedure type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (12, 'Modifier', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (13, 'Drug', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (14, 'Drug type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (15, 'Route', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (16, 'Unit', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (17, 'Device', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (18, 'Device type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (19, 'Condition', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (20, 'Condition type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (21, 'Measurement', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (22, 'Measurement type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (23, 'Measurement value operator', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (24, 'Measurement value', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (26, 'Note Type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (27, 'Observation', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (28, 'Observation type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (31, 'Relationship', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (32, 'Place of service', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (33, 'Provider specialty', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (34, 'Currency', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (35, 'Revenue code', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (36, 'Specimen', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (37, 'Specimen type', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (38, 'Specimen anatomic site', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (39, 'Specimen disease status', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (40, 'Generic', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- Add PCORNet concepts for Rimma
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Avaible in biobank', 1, 'Biobank Flag', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unavailable in biobank', 1, 'Biobank Flag', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Hispanic - other', 1, 'Hispanic', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Hispanic - no information', 1, 'Hispanic', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Hispanic', 1, 'Hispanic', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Not Hispanic', 1, 'Hispanic', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Hispanic - unknown', 1, 'Hispanic', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'American Indian or Alaska Native', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Asian', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Black or African American', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Native Hawaiian or Other Pacific Islander', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'White', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Multiple race', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Refuse to answer', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'No information', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unknown', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other', 1, 'Race', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ambiguous', 1, 'Sex', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Female', 1, 'Sex', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Male', 1, 'Sex', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'No information', 1, 'Sex', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unknown', 1, 'Sex', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other', 1, 'Sex', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Adult foster home', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Assisted living facility', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ambulatory visit', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Emergency department', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Home health', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Home / self care', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Hospice', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other acute inpatient hospital', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Nursing home (includes ICF)', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Rehabilitation facility', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Residential facility', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Skilled nursing facility', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'No information', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unknown', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other', 1, 'Admitting Source', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Discharged alive', 1, 'Discharge Disposition', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Expired', 1, 'Discharge Disposition', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'No information', 1, 'Discharge Disposition', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unknown', 1, 'Discharge Disposition', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other', 1, 'Discharge Disposition', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Adult foster home', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Assisted living facility', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Against medical advice', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Absent without leave', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Expired', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Home health', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Home / self care', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Hospice', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other acute inpatient hospital', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Nursing home (includes ICF)', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Rehabilitation facility', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Residential facility', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Still in hospital', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Skilled nursing facility', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'No information', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unknown', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other', 1, 'Discharge Status', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inpatient hospital stay', 1, 'Encounter Type', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ambulatory visit', 1, 'Encounter Type', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Emergency department', 1, 'Encounter Type', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Non-acute institutional stay', 1, 'Encounter Type', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other ambulatory visit', 1, 'Encounter Type', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'No information', 1, 'Encounter Type', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unknown', 1, 'Encounter Type', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Other', 1, 'Encounter Type', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Chart available', 1, 'Chart Availability', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Chart unavailable', 1, 'Chart Availability', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Enrollment by insurance', 1, 'Enrollment Basis', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Enrollment by geography', 1, 'Enrollment Basis', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Enrollment inferred by algorithm', 1, 'Enrollment Basis', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Enrollment encounter-based', 1, 'Enrollment Basis', 60, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- add observation type (also for Rimma's patient reported vital signs
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Patient reported', 1, 'Observation Type', 39, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- add observation period types
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Period while enrolled in insurance', 1, 'Observation Period Type', 61, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Period while enrolled in study', 1, 'Observation Period Type', 61, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Period covering healthcare encounters', 1, 'Observation Period Type', 61, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Period inferred by algorithm', 1, 'Observation Period Type', 61, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- add death types
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'EHR discharge status "Expired"', 1, 'Death Type', 45, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- add visit types
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Visit derived from encounter on claim', 1, 'Visit Type', 62, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Visit derived from EHR record', 1, 'Visit Type', 62, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Clinical Study visit', 1, 'Visit Type', 62, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);


-- Rename new relationships introduced for SNOMED updating obsolete concepts
update relationship set relationship_name='Inactive same_as active (SNOMED)', reverse_relationship=350 where relationship_id=349;
update relationship set relationship_name='Active same_as inactive (SNOMED)', reverse_relationship=null where relationship_id=350;
update relationship set relationship_name='Inactive alternative_to active (SNOMED)', reverse_relationship=352 where relationship_id=351;
update relationship set relationship_name='Active alternative_to inactive (SNOMED)', reverse_relationship=null where relationship_id=352;
update relationship set relationship_name='Inactive possibly_equivalent_to active (SNOMED)', reverse_relationship=354 where relationship_id=353;
update relationship set relationship_name='Active possibly_equivalent_to inactive (SNOMED)', reverse_relationship=null where relationship_id=354;
update relationship set relationship_name='Inactive was_a active (SNOMED)', reverse_relationship=356 where relationship_id=355;
update relationship set relationship_name='Active was_a inactive (SNOMED)', reverse_relationship=null where relationship_id=356;

-- Rename manual ATC to RxNorm relationships, now all (not just equivalent by name)
update relationship set relationship_name='ATC to RxNorm (OMOP)' where relationship_id=289;
update relationship set relationship_name='RxNorm to ATC (OMOP)' where relationship_id=290;


-- Add currency concepts
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'United Arab Emirates dirham', 1, 'Currency', 65, 'AED', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Afghan afghani', 1, 'Currency', 65, 'AFN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Albanian lek', 1, 'Currency', 65, 'ALL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Armenian dram', 1, 'Currency', 65, 'AMD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Netherlands Antillean guilder', 1, 'Currency', 65, 'ANG', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Angolan kwanza', 1, 'Currency', 65, 'AOA', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Argentine peso', 1, 'Currency', 65, 'ARS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Australian dollar', 1, 'Currency', 65, 'AUD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Aruban florin', 1, 'Currency', 65, 'AWG', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Azerbaijani manat', 1, 'Currency', 65, 'AZN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Bosnia and Herzegovina convertible mark', 1, 'Currency', 65, 'BAM', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Barbados dollar', 1, 'Currency', 65, 'BBD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Bangladeshi taka', 1, 'Currency', 65, 'BDT', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Bulgarian lev', 1, 'Currency', 65, 'BGN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Bahraini dinar', 1, 'Currency', 65, 'BHD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Burundian franc', 1, 'Currency', 65, 'BIF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Bermudian dollar', 1, 'Currency', 65, 'BMD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Brunei dollar', 1, 'Currency', 65, 'BND', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Boliviano', 1, 'Currency', 65, 'BOB', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Bolivian Mvdol (funds code)', 1, 'Currency', 65, 'BOV', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Brazilian real', 1, 'Currency', 65, 'BRL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Bahamian dollar', 1, 'Currency', 65, 'BSD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Bhutanese ngultrum', 1, 'Currency', 65, 'BTN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Botswana pula', 1, 'Currency', 65, 'BWP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Belarusian ruble', 1, 'Currency', 65, 'BYR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Belize dollar', 1, 'Currency', 65, 'BZD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Canadian dollar', 1, 'Currency', 65, 'CAD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Congolese franc', 1, 'Currency', 65, 'CDF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'WIR Euro (complementary currency)', 1, 'Currency', 65, 'CHE', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Swiss franc', 1, 'Currency', 65, 'CHF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'WIR Franc (complementary currency)', 1, 'Currency', 65, 'CHW', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Unidad de Fomento (funds code)', 1, 'Currency', 65, 'CLF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Chilean peso', 1, 'Currency', 65, 'CLP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Chinese yuan', 1, 'Currency', 65, 'CNY', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Colombian peso', 1, 'Currency', 65, 'COP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Unidad de Valor Real (UVR) (funds code)[7]', 1, 'Currency', 65, 'COU', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Costa Rican colon', 1, 'Currency', 65, 'CRC', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Cuban convertible peso', 1, 'Currency', 65, 'CUC', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Cuban peso', 1, 'Currency', 65, 'CUP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Cape Verde escudo', 1, 'Currency', 65, 'CVE', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Czech koruna', 1, 'Currency', 65, 'CZK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Djiboutian franc', 1, 'Currency', 65, 'DJF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Danish krone', 1, 'Currency', 65, 'DKK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Dominican peso', 1, 'Currency', 65, 'DOP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Algerian dinar', 1, 'Currency', 65, 'DZD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Egyptian pound', 1, 'Currency', 65, 'EGP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Eritrean nakfa', 1, 'Currency', 65, 'ERN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Ethiopian birr', 1, 'Currency', 65, 'ETB', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Euro', 1, 'Currency', 65, 'EUR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Fiji dollar', 1, 'Currency', 65, 'FJD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Falkland Islands pound', 1, 'Currency', 65, 'FKP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Pound sterling', 1, 'Currency', 65, 'GBP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Georgian lari', 1, 'Currency', 65, 'GEL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Ghanaian cedi', 1, 'Currency', 65, 'GHS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Gibraltar pound', 1, 'Currency', 65, 'GIP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Gambian dalasi', 1, 'Currency', 65, 'GMD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Guinean franc', 1, 'Currency', 65, 'GNF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Guatemalan quetzal', 1, 'Currency', 65, 'GTQ', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Guyanese dollar', 1, 'Currency', 65, 'GYD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Hong Kong dollar', 1, 'Currency', 65, 'HKD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Honduran lempira', 1, 'Currency', 65, 'HNL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Croatian kuna', 1, 'Currency', 65, 'HRK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Haitian gourde', 1, 'Currency', 65, 'HTG', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Hungarian forint', 1, 'Currency', 65, 'HUF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Indonesian rupiah', 1, 'Currency', 65, 'IDR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Israeli new shekel', 1, 'Currency', 65, 'ILS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Indian rupee', 1, 'Currency', 65, 'INR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Iraqi dinar', 1, 'Currency', 65, 'IQD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Iranian rial', 1, 'Currency', 65, 'IRR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Icelandic króna', 1, 'Currency', 65, 'ISK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Jamaican dollar', 1, 'Currency', 65, 'JMD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Jordanian dinar', 1, 'Currency', 65, 'JOD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Japanese yen', 1, 'Currency', 65, 'JPY', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Kenyan shilling', 1, 'Currency', 65, 'KES', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Kyrgyzstani som', 1, 'Currency', 65, 'KGS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Cambodian riel', 1, 'Currency', 65, 'KHR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Comoro franc', 1, 'Currency', 65, 'KMF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'North Korean won', 1, 'Currency', 65, 'KPW', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'South Korean won', 1, 'Currency', 65, 'KRW', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Kuwaiti dinar', 1, 'Currency', 65, 'KWD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Cayman Islands dollar', 1, 'Currency', 65, 'KYD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Kazakhstani tenge', 1, 'Currency', 65, 'KZT', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Lao kip', 1, 'Currency', 65, 'LAK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Lebanese pound', 1, 'Currency', 65, 'LBP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Sri Lankan rupee', 1, 'Currency', 65, 'LKR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Liberian dollar', 1, 'Currency', 65, 'LRD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Lesotho loti', 1, 'Currency', 65, 'LSL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Lithuanian litas', 1, 'Currency', 65, 'LTL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Libyan dinar', 1, 'Currency', 65, 'LYD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Moroccan dirham', 1, 'Currency', 65, 'MAD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Moldovan leu', 1, 'Currency', 65, 'MDL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Malagasy ariary', 1, 'Currency', 65, 'MGA', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Macedonian denar', 1, 'Currency', 65, 'MKD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Myanmar kyat', 1, 'Currency', 65, 'MMK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Mongolian tugrik', 1, 'Currency', 65, 'MNT', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Macanese pataca', 1, 'Currency', 65, 'MOP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Mauritanian ouguiya', 1, 'Currency', 65, 'MRO', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Mauritian rupee', 1, 'Currency', 65, 'MUR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Maldivian rufiyaa', 1, 'Currency', 65, 'MVR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Malawian kwacha', 1, 'Currency', 65, 'MWK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Mexican peso', 1, 'Currency', 65, 'MXN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Mexican Unidad de Inversion (UDI) (funds code)', 1, 'Currency', 65, 'MXV', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Malaysian ringgit', 1, 'Currency', 65, 'MYR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Mozambican metical', 1, 'Currency', 65, 'MZN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Namibian dollar', 1, 'Currency', 65, 'NAD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Nigerian naira', 1, 'Currency', 65, 'NGN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Nicaraguan córdoba', 1, 'Currency', 65, 'NIO', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Norwegian krone', 1, 'Currency', 65, 'NOK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Nepalese rupee', 1, 'Currency', 65, 'NPR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'New Zealand dollar', 1, 'Currency', 65, 'NZD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Omani rial', 1, 'Currency', 65, 'OMR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Panamanian balboa', 1, 'Currency', 65, 'PAB', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Peruvian nuevo sol', 1, 'Currency', 65, 'PEN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Papua New Guinean kina', 1, 'Currency', 65, 'PGK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Philippine peso', 1, 'Currency', 65, 'PHP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Pakistani rupee', 1, 'Currency', 65, 'PKR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Polish z?oty', 1, 'Currency', 65, 'PLN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Paraguayan guaraní', 1, 'Currency', 65, 'PYG', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Qatari riyal', 1, 'Currency', 65, 'QAR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Romanian new leu', 1, 'Currency', 65, 'RON', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Serbian dinar', 1, 'Currency', 65, 'RSD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Russian ruble', 1, 'Currency', 65, 'RUB', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Rwandan franc', 1, 'Currency', 65, 'RWF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Saudi riyal', 1, 'Currency', 65, 'SAR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Solomon Islands dollar', 1, 'Currency', 65, 'SBD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Seychelles rupee', 1, 'Currency', 65, 'SCR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Sudanese pound', 1, 'Currency', 65, 'SDG', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Swedish krona/kronor', 1, 'Currency', 65, 'SEK', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Singapore dollar', 1, 'Currency', 65, 'SGD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Saint Helena pound', 1, 'Currency', 65, 'SHP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Sierra Leonean leone', 1, 'Currency', 65, 'SLL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Somali shilling', 1, 'Currency', 65, 'SOS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Surinamese dollar', 1, 'Currency', 65, 'SRD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'South Sudanese pound', 1, 'Currency', 65, 'SSP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'São Tomé and Príncipe dobra', 1, 'Currency', 65, 'STD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Syrian pound', 1, 'Currency', 65, 'SYP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Swazi lilangeni', 1, 'Currency', 65, 'SZL', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Thai baht', 1, 'Currency', 65, 'THB', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Tajikistani somoni', 1, 'Currency', 65, 'TJS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Turkmenistani manat', 1, 'Currency', 65, 'TMT', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Tunisian dinar', 1, 'Currency', 65, 'TND', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Tongan pa?anga', 1, 'Currency', 65, 'TOP', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Turkish lira', 1, 'Currency', 65, 'TRY', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Trinidad and Tobago dollar', 1, 'Currency', 65, 'TTD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'New Taiwan dollar', 1, 'Currency', 65, 'TWD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Tanzanian shilling', 1, 'Currency', 65, 'TZS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Ukrainian hryvnia', 1, 'Currency', 65, 'UAH', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Ugandan shilling', 1, 'Currency', 65, 'UGX', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'United States dollar', 1, 'Currency', 65, 'USD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'United States dollar (next day) (funds code)', 1, 'Currency', 65, 'USN', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'United States dollar (same day) (funds code)[10]', 1, 'Currency', 65, 'USS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Uruguay Peso en Unidades Indexadas (URUIURUI) (funds code)', 1, 'Currency', 65, 'UYI', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Uruguayan peso', 1, 'Currency', 65, 'UYU', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Uzbekistan som', 1, 'Currency', 65, 'UZS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Venezuelan bolívar', 1, 'Currency', 65, 'VEF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Vietnamese dong', 1, 'Currency', 65, 'VND', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Vanuatu vatu', 1, 'Currency', 65, 'VUV', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Samoan tala', 1, 'Currency', 65, 'WST', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'CFA franc BEAC', 1, 'Currency', 65, 'XAF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Silver (one troy ounce)', 1, 'Currency', 65, 'XAG', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Gold (one troy ounce)', 1, 'Currency', 65, 'XAU', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'European Composite Unit (EURCO) (bond market unit)', 1, 'Currency', 65, 'XBA', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'European Monetary Unit (E.M.U.-6) (bond market unit)', 1, 'Currency', 65, 'XBB', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'European Unit of Account 9 (E.U.A.-9) (bond market unit)', 1, 'Currency', 65, 'XBC', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'European Unit of Account 17 (E.U.A.-17) (bond market unit)', 1, 'Currency', 65, 'XBD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'bitcoin International internet currency', 1, 'Currency', 65, 'XBT', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'East Caribbean dollar', 1, 'Currency', 65, 'XCD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Special drawing rights', 1, 'Currency', 65, 'XDR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'UIC franc (special settlement currency)', 1, 'Currency', 65, 'XFU', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'CFA franc BCEAO', 1, 'Currency', 65, 'XOF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Palladium (one troy ounce)', 1, 'Currency', 65, 'XPD', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'CFP franc (franc Pacifique)', 1, 'Currency', 65, 'XPF', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Platinum (one troy ounce)', 1, 'Currency', 65, 'XPT', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'SUCRE', 1, 'Currency', 65, 'XSU', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Code reserved for testing purposes', 1, 'Currency', 65, 'XTS', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'ADB Unit of Account', 1, 'Currency', 65, 'XUA', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'No currency', 1, 'Currency', 65, 'XXX', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Yemeni rial', 1, 'Currency', 65, 'YER', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'South African rand', 1, 'Currency', 65, 'ZAR', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Zambian kwacha', 1, 'Currency', 65, 'ZMW', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values(seq_concept.nextval, 'Zimbabwe dollar', 1, 'Currency', 65, 'ZWD', '1-Jan-1970', '31-Dec-2099', null);

-- add Measurment types
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Vital sign', 1, 'Measurement Type', 64, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Lab result', 1, 'Measurement Type', 64, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pathology finding', 1, 'Measurement Type', 64, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Patient reported value', 1, 'Measurement Type', 64, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- add Device types
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inferred from procedure claim', 1, 'Device Type', 63, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Patient reported device', 1, 'Device Type', 63, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id,  concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'EHR Detail', 1, 'Device Type', 63, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- add Condition Occurrence types (from Amy)
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inpatient detail – 16th position', 1, 'Condition Occurrence Type', 37, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inpatient detail – 17th position', 1, 'Condition Occurrence Type', 37, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inpatient detail – 18th position', 1, 'Condition Occurrence Type', 37, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inpatient detail – 19th position', 1, 'Condition Occurrence Type', 37, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inpatient detail – 20th position', 1, 'Condition Occurrence Type', 37, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- Add Concept Relationships
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaced by (LOINC)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has precise ingredient (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has tradename (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has dose form (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has form (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has ingredient (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Constitutes (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Contains (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Reformulation of (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Subsumes', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has dose form (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Induces (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'May diagnose (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has physiological effect (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has contraindicating physiological effect (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has ingredient (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has contraindicating chemical class (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has mechanism of action (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has contraindicating mechanism of action (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has pharmacokinetics (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'May treat (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Contraindication to (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'May prevent (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has active metabolites (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has site of metabolism (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Effect may be inhibited by (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has chemical structure (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'NDF-RT to RxNorm equivalent (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has recipient category (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has procedure site (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has priority (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has pathological process (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has part of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has severity (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has revision status (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has access (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has occurrence (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has method (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has laterality (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has interprets (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has indirect morphology (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has indirect device (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has specimen (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has interpretation (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has intent (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has focus (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has definitional manifestation (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has active ingredient (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has finding site (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has episodicity (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has direct substance (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has direct morphology (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has direct device (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has component (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has causative agent (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has associated morphology (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has associated finding (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has measurement method (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has property (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has scale type (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has time aspect (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has specimen procedure (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has specimen source identity (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has specimen source morphology (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has specimen source topography (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has specimen substance (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has due to (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has subject relationship context (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has dose form (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Occurs after (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has associated procedure (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has direct procedure site (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has indirect procedure site (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has procedure device (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has procedure morphology (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has finding context (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has procedure context (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has temporal context (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Associated with (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has surgical approach (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Using device (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Using energy (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Using substance (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Using access device (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has clinical course (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has route of administration (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Using finding method (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Using finding informer (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'ICD9 procedure to SNOMED equivalent (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'CPT-4 to SNOMED category (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'CPT-4 to SNOMED equivalent (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'MedDRA to SNOMED equivalent (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has FDA-approved drug indication (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has off-label drug indication (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has drug contra-indication (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'ETC to RxNorm (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'ATC to RxNorm (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SMQ consists of MedDRA (MedDRA)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaces (LOINC)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Precise ingredient of (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Tradename of (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Dose form of (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Form of (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ingredient of (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Consists of (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Is contained in (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Reformulated in (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Is a', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Dose form of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Induced by (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Diagnosed through (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Physiological effect induced by (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Contraindicating physiological effect induced by (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ingredient of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Contraindicating chemical class of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Mechanism of action of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Contraindicating mechanism of action of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pharmacokinetics of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'May be treated by (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Contraindicated by (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'May be prevented by (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Active metabolite of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Site of metabolism of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inhibits effect (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Chemical structure of (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm to NDF-RT equivalent (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Recipient category of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Procedure site of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Priority of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pathological process of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Part of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Severity of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Revision status of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Access of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Occurrence of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Method of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Laterality of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Interprets of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Indirect morphology of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Indirect device of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Specimen of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Interpretation of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Intent of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Focus of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Definitional manifestation of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Active ingredient of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Finding site of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Episodicity of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Direct substance of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Direct morphology of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Direct device of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Component of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Causative agent of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Associated morphology of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Associated finding of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Measurement method of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Property of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Scale type of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Time aspect of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Specimen procedure of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Specimen source identity of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Specimen source morphology of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Specimen source topography of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Specimen substance of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Due to of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Subject relationship context of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Dose form of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Occurs before (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Associated procedure of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Direct procedure site of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Indirect procedure site of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Procedure device of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Procedure morphology of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Finding context of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Procedure context of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Temporal context of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Associated with (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Surgical approach of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Device used by (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Energy used by (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Substance used by (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Access device used by (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has clinical course of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Route of administration of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Finding method of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Finding informer of (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SNOMED to ICD9 procedure equivalent (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SNOMED category to CPT-4 (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SNOMED to CPT-4 equivalent (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SNOMED to MedDRA equivalent (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Is FDA-approved indication of (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Is off-label indication of (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Is contra-indication of (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm to ETC (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm to ATC (FDB)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'MedDRA contained in SMQ (MedDRA)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Indication/Contra-indication to SNOMED', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SNOMED to Indication/Contra-indication', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has therapeutic class (NDF)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Therapeutic class of (NDF)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Drug-drug interaction for (NDF)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Is involved in drug-drug interaction (NDF)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has pharmaceutical preparation (NDF)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pharmaceutical preparation contained in (NDF)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inferred drug class of (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has inferred drug class (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SNOMED procedure subsumes HCPCS (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'HCPCS is a SNOMED procedure (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm to NDF-RT equivalent by concept_name (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'NDF-RT to RxNorm equivalent by concept_name (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'ETC to RxNorm equivalent by concept_name (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm to ETC equivalent by concept_name (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'ATC to RxNorm equivalent by concept_name (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm to ATC equivalent by concept_name (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'HOI contains SNOMED (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SNOMED contained in HOI (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'DOI contains RxNorm (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm contained in DOI (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'HOI contains MedDRA (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'MedDRA contained in HOI (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'NUCC to CMS Specialty (CMS)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'CMS Specialty to NUCC (CMS)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'DRG to MS-DRG equivalent (CMS)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'MS-DRG to DRG equivalent (CMS)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'DRG to MDC category (CMS)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'MDC category to DRG (CMS)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Visit category to Place of Service (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Place of Service to Visit category (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'VA Product to NDF-RT (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'NDF-RT to VA Product (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'VA Product to RxNorm equivalent (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm to VA Product equivalent (NDF-RT)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaced by (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaces (RxNorm)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaced by (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaces (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Has ingredient (Multilex)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ingredient of (Multilex)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm to Multilex equivalent (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Multilex to RxNorm equivalent (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Multilex ingredient to drug class (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Drug class to Multilex ingredient (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaced by', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaces', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inactive same_as active (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Active same_as inactive (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inactive alternative_to active (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Active alternative_to inactive (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inactive possibly_equivalent_to active (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Active possibly_equivalent_to inactive (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Inactive was_a active (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Active was_a inactive (SNOMED)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'SNOMED measurement subsumes HCPCS (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'HCPCS is a SNOMED measurement (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Domain subsumes (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Is a domain (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Standard to Non-standard exclude child (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaced by (ICD-9-Procedure)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaces (ICD-9-Procedure)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Standard to Non-standard include child (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Non-standard to Standard exclude child (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Non-standard to Standard include child (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Standard to Non-standard map (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Non-standard to Standard map (OMOP)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaced by (UCUM)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept replaces (UCUM)', 1, 'Concept Relationship', 66, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- Class concepts
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ingredient', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Branded Pack', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pharmaceutical Preparations', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pharmacokinetics', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Place of Service', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Administrative Concept', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'High Level Group Term', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Chart Availability', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Clinical Pack', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Drug Class', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Therapeutic Class', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Body structure', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Clinical finding', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Record artifact', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Death Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Measurement Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Admitting Source', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Discharge Disposition', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Branded Drug Component', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Mechanism of Action', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pharmacologic Class', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Pharmaceutical / Biologic Product', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Morphologic Abnormality', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Physical Object', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Staging and Scales', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Environment or Geographical Location', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Condition Occurrence Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Health Care Provider Specialty', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Specialty', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Preferred Term', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'High Level Term', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Biobank Flag', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Clinical Drug Form', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Qualifier Value', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Social Context', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Visit', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Drug Cohort', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Domain', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Concept Relationship', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Device Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Clinical Drug', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Observable Entity', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Race', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Condition Cohort', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ethnicity', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'System Organ Class', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Enrollment Basis', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Visit Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Drug Product', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Branded Drug Form', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Indication or Contra-Indication', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Organism', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Undefined', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Special Concept', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Biological Function', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Condition', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Currency', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Substance', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Context-dependent Category', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Physical Force', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Canonical Unit', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Anatomical Therapeutic Chemical Classification', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Specimen', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Event', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Namespace Concept', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Model Component', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Measurement Class', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Standardized MedDRA Query', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Note Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Observation Period Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Branded Drug', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Clinical Drug Component', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Brand Name', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Dose Form', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Physiologic Effect', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Chemical Structure', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Drug Interaction', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Attribute', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Measurement', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unit', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Standard Unit', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Custom Unit', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Revenue Code', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Observation Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Diagnostic Category', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Drug Exposure Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Patient Status', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Procedure', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Lowest Level Term', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Enhanced Therapeutic Classification', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Discharge Status', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Encounter Type', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Hispanic', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Gender', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, '1st level - Anatomical Main Group', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, '2nd level - Therapeutic Subgroup', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, '3rd level - Pharmacological Subgroup', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, '4th level - Chemical Subgroup', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, '5th level - Chemical Substance', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Quality Metric', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Observation', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Device', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Procedure Drug', 1, 'Concept Class', 68, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);

-- Add Vocabulary concepts 
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Vocabulary v5.0 2014-10-01', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Systematic Nomenclature of Medicine - Clinical Terms (IHDSTO)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'International Classification of Diseases, Ninth Revision, Clinical Modification, Volume 1 and 2 (NCHS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'International Classification of Diseases, Ninth Revision, Clinical Modification, Volume 3 (NCHS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Current Procedural Terminology version 4 (AMA)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Healthcare Common Procedure Coding System (CMS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Logical Observation Identifiers Names and Codes (Regenstrief Institute)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'National Drug File – Reference Terminology (VA)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'RxNorm (NLM)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'National Drug Code (FDA and manufacturers)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Medi-Span Generic Product Identifier (Wolters Kluwer Health)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Unified Code for Units of Measure (Regenstrief Institute)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Gender', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Race and Ethnicity Code Set (USBC)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Place of Service Codes for Professional Claims (CMS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Medical Dictionary for Regulatory Activities (MSSO)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Cerner Multum (Cerner)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'NHS UK Read Codes Version 2 (HSCIC)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Oxford Medical Information System (OCHP)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Indications and Contraindications (FDB)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Enhanced Therapeutic Classification (FDB)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'WHO Anatomic Therapeutic Chemical Classification', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Multilex (FDB)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Visit', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'VA National Drug File Product (VA)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Standardised MedDRA Queries (MSSO)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'VA National Drug File Class (VA)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Cohort', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'International Classification of Diseases, 10th Revision, Clinical Modification (NCHS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'ICD-10 Procedure Coding System (CMS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Drug Exposure Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Condition Occurrence Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Procedure Occurrence Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Observation Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Diagnosis-related group (CMS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Major Diagnostic Categories (CMS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Ambulatory Payment Classification (CMS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'UB04/CMS1450 Revenue Codes (CMS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Ethnicity', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Death Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Medical Subject Headings (NLM)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'National Uniform Claim Committee Health Care Provider Taxonomy Code Set (NUCC)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Medicare provider/supplier specialty codes (CMS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'LOINC Multidimensional Classification (Regenstrief Institute)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, ' Structured Product Labeling (FDA)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Generic sequence number (FDB)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Clinical Classifications Software for ICD-9-CM (HCUP)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OPCS Classification of Interventions and Procedures version 4 (NHS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Gemscript NHS dictionary of medicine and devices (NHS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'Hospital Episode Statistics Specialty (NHS)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Note Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Domain', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'PCORNet', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Observation Period Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Visit Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Device Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'OMOP Measurement Type', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
insert into concept (concept_id, concept_name, concept_level, concept_class, vocabulary_id, concept_code, valid_start_date, valid_end_date, invalid_reason)
values (seq_concept.nextval, 'International Currency Symbol (ISO 4217)', 1, 'OMOP Vocabulary', 67, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);


commit;
exit;