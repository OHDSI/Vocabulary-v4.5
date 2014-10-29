-- Copy all relevant tables from DevV4

create table CONCEPT as select * from DEV.CONCEPT;
create table VOCABULARY as select * from DEV.VOCABULARY;
create table CONCEPT_RELATIONSHIP as select * from DEV.CONCEPT_RELATIONSHIP;
create table RELATIONSHIP as select * from DEV.RELATIONSHIP;
create table CONCEPT_SYNONYM as select * from DEV.CONCEPT_SYNONYM;
create table CONCEPT_ANCESTOR as select * from DEV.CONCEPT_ANCESTOR;
create table SOURCE_TO_CONCEPT_MAP as select * from DEV.SOURCE_TO_CONCEPT_MAP;
create table DRUG_STRENGTH as select * from DEV.DRUG_STRENGTH;

alter table CONCEPT add constraint XPK_CONCEPT primary key (CONCEPT_ID);
create index CONCEPT_vocab on CONCEPT (vocabulary_id);

create index CONCEPT_RELATIONSHIP_C_1 on CONCEPT_RELATIONSHIP (concept_id_1);
create index CONCEPT_RELATIONSHIP_C_2 on CONCEPT_RELATIONSHIP (concept_id_2);

create index CONCEPT_SYNONYM_concept on CONCEPT_SYNONYM (concept_id);

--------------------------------------------------------------------------------------------------------------------

