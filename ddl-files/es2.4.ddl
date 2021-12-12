-- *********************************************
-- * Standard SQL generation                   
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Sun Nov 28 16:12:41 2021 
-- * LUN file: D:\Programming\Projects\DBeaver-Learn\7.3_esSchemiER2.lun 
-- * Schema: es2.4/SQL1 
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
     codEsp varchar(10) not null,
     codAn varchar(10) not null,
     matr varchar(10) not null,
     constraint ID_Esperimenti_ID primary key (codEsp));

create table Analisi (
     codAn varchar(10) not null,
     tipo varchar(20) not null,
     data date not null,
     constraint ID_Analisi_ID primary key (codAn));


-- Constraints Section
-- ___________________ 

alter table Tecnici add constraint ID_Tecnici_CHK
     check(exists(select * from Esperimenti
                  where Esperimenti.matr = matr)); 

alter table Esperimenti add constraint FKEA_FK
     foreign key (codAn)
     references Analisi;

alter table Esperimenti add constraint FKTE_FK
     foreign key (matr)
     references Tecnici;

alter table Analisi add constraint ID_Analisi_CHK
     check(exists(select * from Esperimenti
                  where Esperimenti.codAn = codAn)); 


-- Index Section
-- _____________ 

create unique index ID_Tecnici_IND
     on Tecnici (matr);

create unique index ID_Esperimenti_IND
     on Esperimenti (codEsp);

create index FKEA_IND
     on Esperimenti (codAn);

create index FKTE_IND
     on Esperimenti (matr);

create unique index ID_Analisi_IND
     on Analisi (codAn);

