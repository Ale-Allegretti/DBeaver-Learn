-- *********************************************
-- * Standard SQL generation                   
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Sat Nov 27 18:10:56 2021 
-- * LUN file: D:\Programming\Projects\DBeaver-Learn\7.3_esSchemiER2.lun 
-- * Schema: es2.1/SQL 
-- ********************************************* 


-- Database Section
-- ________________ 

create database es2.1;


-- DBSpace Section
-- _______________


-- Tables Section
-- _____________ 

create table Atleti (
     Nome char(1) not null,
     pettorale numeric(5) not null,
     nazione varchar(15) not null,
     dataNascita date not null,
     constraint ID_Atleti_ID primary key (nazione));

create table Esibizioni (
     Vot_nazione varchar(25) not null,
     nazione varchar(15) not null,
     voto char(1) not null,
     constraint ID_Esibizioni_ID primary key (Vot_nazione, nazione, voto));

create table Giudici (
     Nome varchar(25) not null,
     nazione varchar(25) not null,
     constraint ID_Giudici_ID primary key (nazione));


-- Constraints Section
-- ___________________ 

alter table Esibizioni add constraint FKGareggia_FK
     foreign key (nazione)
     references Atleti;

alter table Esibizioni add constraint FKVota
     foreign key (Vot_nazione)
     references Giudici;


-- Index Section
-- _____________ 

create unique index ID_Atleti_IND
     on Atleti (nazione);

create unique index ID_Esibizioni_IND
     on Esibizioni (Vot_nazione, nazione, voto);

create index FKGareggia_IND
     on Esibizioni (nazione);

create unique index ID_Giudici_IND
     on Giudici (nazione);

