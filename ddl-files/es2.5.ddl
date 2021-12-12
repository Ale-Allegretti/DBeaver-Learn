-- *********************************************
-- * Standard SQL generation                   
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Sun Nov 28 17:32:54 2021 
-- * LUN file: D:\Programming\Projects\DBeaver-Learn\7.3_esSchemiER2.lun 
-- * Schema: es2.5/SQL7 
-- ********************************************* 


-- Database Section
-- ________________ 

create database es2.5;


-- DBSpace Section
-- _______________


-- Tables Section
-- _____________ 

create table Spazzaneve (
     codMezzo varchar(10) not null,
     codStrada varchar(10) not null,
     constraint ID_Spazzaneve_ID primary key (codMezzo));

create table Strada (
     codStrada varchar(10) not null,
     constraint ID_Strada_ID primary key (codStrada));

create table Nevicate (
     inizio date not null,
     fine date not null,
     codMezzo varchar(10) not null,
     cm numeric(6,2) not null,
     constraint ID_Nevicate_ID primary key (inizio, fine),
     constraint FKSN_ID unique (codMezzo));


-- Constraints Section
-- ___________________ 

alter table Spazzaneve add constraint ID_Spazzaneve_CHK
     check(exists(select * from Nevicate
                  where Nevicate.codMezzo = codMezzo)); 

alter table Spazzaneve add constraint FKSS_FK
     foreign key (codStrada)
     references Strada;

alter table Strada add constraint ID_Strada_CHK
     check(exists(select * from Spazzaneve
                  where Spazzaneve.codStrada = codStrada)); 

alter table Nevicate add constraint FKSN_FK
     foreign key (codMezzo)
     references Spazzaneve;


-- Index Section
-- _____________ 

create unique index ID_Spazzaneve_IND
     on Spazzaneve (codMezzo);

create index FKSS_IND
     on Spazzaneve (codStrada);

create unique index ID_Strada_IND
     on Strada (codStrada);

create unique index ID_Nevicate_IND
     on Nevicate (inizio, fine);

create unique index FKSN_IND
     on Nevicate (codMezzo);

