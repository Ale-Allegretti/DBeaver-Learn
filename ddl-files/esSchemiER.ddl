-- *********************************************
-- * Standard SQL generation                   
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Sat Nov 27 12:31:19 2021 
-- * LUN file: D:\Programming\Projects\DBeaver-Learn\7.2_esSchemiER1.lun 
-- * Schema: Ale-Allegretti/SQL 
-- ********************************************* 


-- Database Section
-- ________________ 

create database Ale-Allegretti;


-- DBSpace Section
-- _______________


-- Tables Section
-- _____________ 

create table Dipartimenti (
     codice varchar(15) not null,
     nome varchar(35) not null,
     constraint ID_Dipartimenti_ID primary key (codice));

create table Dipendenti (
     codice varchar(15) not null,
     matricola varchar(15) not null,
     constraint ID_Dipendenti_ID primary key (codice, matricola));


-- Constraints Section
-- ___________________ 

alter table Dipendenti add constraint FKlavora
     foreign key (codice)
     references Dipartimenti;


-- Index Section
-- _____________ 

create unique index ID_Dipartimenti_IND
     on Dipartimenti (codice);

create unique index ID_Dipendenti_IND
     on Dipendenti (codice, matricola);

