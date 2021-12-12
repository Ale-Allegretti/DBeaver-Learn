-- *********************************************
-- * Standard SQL generation                   
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Sun Nov 28 16:04:34 2021 
-- * LUN file: D:\Programming\Projects\DBeaver-Learn\7.3_esSchemiER2.lun 
-- * Schema: es2.4/SQL 
-- ********************************************* 


-- Database Section
-- ________________ 

create database es2.4;


-- DBSpace Section
-- _______________


-- Tables Section
-- _____________ 

create table Tecnici (
     matr varchar(10) not null,
     nome char(1) not null,
     constraint ID_Tecnici_ID primary key (matr));

create table Esperimenti (
     matr varchar(10) not null,
     codEsp varchar(10) not null,
     constraint ID_Esperimenti_ID primary key (matr, codEsp));

create table Analisi (
     codAn varchar(10) not null,
     codEsp varchar(10) not null,
     tipo varchar(20) not null,
     data date not null,
     EA_matr varchar(10) not null,
     EA_codEsp varchar(10) not null,
     constraint ID_Analisi_ID primary key (codAn));


-- Constraints Section
-- ___________________ 

alter table Esperimenti add constraint FKTE
     foreign key (matr)
     references Tecnici;

alter table Analisi add constraint FKEA_FK
     foreign key (EA_matr, EA_codEsp)
     references Esperimenti;


-- Index Section
-- _____________ 

create unique index ID_Tecnici_IND
     on Tecnici (matr);

create unique index ID_Esperimenti_IND
     on Esperimenti (matr, codEsp);

create unique index ID_Analisi_IND
     on Analisi (codAn);

create index FKEA_IND
     on Analisi (EA_matr, EA_codEsp);

