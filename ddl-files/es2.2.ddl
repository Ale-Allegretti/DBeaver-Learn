-- *********************************************
-- * Standard SQL generation                   
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Sun Nov 28 15:17:15 2021 
-- * LUN file: D:\Programming\Projects\DBeaver-Learn\7.3_esSchemiER2.lun 
-- * Schema: es2.2/SQL 
-- ********************************************* 


-- Database Section
-- ________________ 

create database es2.2;


-- DBSpace Section
-- _______________


-- Tables Section
-- _____________ 

create table Mobili (
     codMob varchar(10) not null,
     descrizione varchar(100) not null,
     constraint ID_Mobili_ID primary key (codMob));

create table Restaurati (
     codRestauro varchar(10) not null,
     dataInizio date not null,
     dataFine date not null,
     prezzo numeric(6,2) not null,
     constraint ID_Restaurati_ID primary key (codRestauro));

create table Restauro (
     codMob varchar(10) not null,
     codRestauro varchar(10) not null,
     data char(1) not null,
     constraint ID_Restauro_ID primary key (codMob, codRestauro, data));


-- Constraints Section
-- ___________________ 

alter table Restaurati add constraint ID_Restaurati_CHK
     check(exists(select * from Restauro
                  where Restauro.codRestauro = codRestauro)); 

alter table Restauro add constraint FKRR_FK
     foreign key (codRestauro)
     references Restaurati;

alter table Restauro add constraint FKMR
     foreign key (codMob)
     references Mobili;


-- Index Section
-- _____________ 

create unique index ID_Mobili_IND
     on Mobili (codMob);

create unique index ID_Restaurati_IND
     on Restaurati (codRestauro);

create unique index ID_Restauro_IND
     on Restauro (codMob, codRestauro, data);

create index FKRR_IND
     on Restauro (codRestauro);

