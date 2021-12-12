-- *********************************************
-- * Standard SQL generation                   
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Sun Nov 28 18:34:58 2021 
-- * LUN file: D:\Programming\Projects\DBeaver-Learn\7.3_esSchemiER2.lun 
-- * Schema: es2.6/SQL 
-- ********************************************* 


-- Database Section
-- ________________ 

create database es2.6;


-- DBSpace Section
-- _______________


-- Tables Section
-- _____________ 

create table Controlli (
     codCtrl varchar(10) not null,
     descrizione varchar(100) not null,
     constraint ID_Controlli_ID primary key (codCtrl));

create table data (
     codCtrl varchar(10) not null,
     CF char(1) not null,
     data date not null,
     constraint ID_data_ID primary key (codCtrl, CF, data));

create table Medici (
     CF char(1) not null,
     dataIncarico date not null,
     constraint FKPer_Med_ID primary key (CF));

create table Pazienti (
     CF char(1) not null,
     gruppoSan char(1) not null,
     constraint FKPer_Paz_ID primary key (CF));

create table PC (
     codCtrl varchar(10) not null,
     CF char(1) not null,
     constraint ID_PC_ID primary key (codCtrl, CF));

create table Persone (
     CF char(1) not null,
     nome varchar(25) not null,
     cognome varchar(25) not null,
     dataNascita date not null,
     luogoNascita varchar(25) not null,
     constraint ID_Persone_ID primary key (CF));


-- Constraints Section
-- ___________________ 

alter table data add constraint FKPC_dat
     foreign key (codCtrl, CF)
     references PC;

alter table Medici add constraint FKPer_Med_FK
     foreign key (CF)
     references Persone;

alter table Pazienti add constraint FKPer_Paz_FK
     foreign key (CF)
     references Persone;

alter table PC add constraint ID_PC_CHK
     check(exists(select * from data
                  where data.codCtrl = codCtrl and data.CF = CF)); 

alter table PC add constraint FKPC_Per_FK
     foreign key (CF)
     references Persone;

alter table PC add constraint FKPC_Con
     foreign key (codCtrl)
     references Controlli;


-- Index Section
-- _____________ 

create unique index ID_Controlli_IND
     on Controlli (codCtrl);

create unique index ID_data_IND
     on data (codCtrl, CF, data);

create unique index FKPer_Med_IND
     on Medici (CF);

create unique index FKPer_Paz_IND
     on Pazienti (CF);

create unique index ID_PC_IND
     on PC (codCtrl, CF);

create index FKPC_Per_IND
     on PC (CF);

create unique index ID_Persone_IND
     on Persone (CF);

