-- *********************************************
-- * Standard SQL generation                   
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Sun Nov 28 15:41:15 2021 
-- * LUN file: D:\Programming\Projects\DBeaver-Learn\7.3_esSchemiER2.lun 
-- * Schema: es2.3/SQL3 
-- ********************************************* 


-- Database Section
-- ________________ 

create database es2.3;


-- DBSpace Section
-- _______________


-- Tables Section
-- _____________ 

create table Auto (
     targa char(8) not null,
     modello char(15) not null,
     codR varchar(10) not null,
     prezzoRichiesto numeric(6,2) not null,
     km numeric(8) not null,
     anno numeric(6) not null,
     MA_modello char(15) not null,
     constraint ID_Auto_ID primary key (targa),
     constraint SID_Auto_ID unique (modello));

create table Vendute (
     codV varchar(10) not null,
     prezzoVendita char(1) not null,
     targa char(8) not null,
     constraint ID_Vendute_ID primary key (codV, prezzoVendita));

create table Modelli (
     modello char(15) not null,
     marca varchar(25) not null,
     cilindrata numeric(6) not null,
     alimentazione varchar(15) not null,
     velMax numeric(6) not null,
     constraint ID_Modelli_ID primary key (modello));

create table Venditori (
     codV varchar(10) not null,
     constraint ID_Venditori_ID primary key (codV));


-- Constraints Section
-- ___________________ 

alter table Auto add constraint FKMA_FK
     foreign key (MA_modello)
     references Modelli;

alter table Vendute add constraint FKVV
     foreign key (codV)
     references Venditori;

alter table Vendute add constraint FKAV_FK
     foreign key (targa)
     references Auto;


-- Index Section
-- _____________ 

create unique index ID_Auto_IND
     on Auto (targa);

create unique index SID_Auto_IND
     on Auto (modello);

create index FKMA_IND
     on Auto (MA_modello);

create unique index ID_Vendute_IND
     on Vendute (codV, prezzoVendita);

create index FKAV_IND
     on Vendute (targa);

create unique index ID_Modelli_IND
     on Modelli (modello);

create unique index ID_Venditori_IND
     on Venditori (codV);

