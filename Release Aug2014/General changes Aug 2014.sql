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
values (26, 'Note', 6, 'Domain', 59, 'OMOP generated', '1-Jan-1970', '31-Dec-2099', null);
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


exit;