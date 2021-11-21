CREATE TABLE FATTURE (
NumFattura char(5) not null primary key,
Importo    int not null );

CREATE TABLE VENDITE (
NumFattura char(5) not null references FATTURE,
CodProd    char(5) not null,
Quantita   int not null check (Quantita > 0),
primary key (NumFattura,CodProd) );

CREATE TABLE GIACENZE (
CodProd      char(5) not null primary key,
QtaResidua   int not null check (QtaResidua >= 0),
ScortaMinima int not null check (ScortaMinima > 0) );


CREATE TABLE CARENZE (
CodProd       char(5) not null primary key,
QtaDaOrdinare int not null check (QtaDaOrdinare > 0) );


INSERT INTO GIACENZE
VALUES ('P0001',200,100),
	   ('P0002',350,180);

-- a seguito di un ordine aggiorna la quantità residua dei prodotti venduti
--
CREATE OR REPLACE TRIGGER UpdateQtaResidua
AFTER INSERT ON Vendite
REFERENCING NEW AS NuovaVendita
FOR EACH ROW
UPDATE 	Giacenze
SET 	QtaResidua = Qtaresidua - NuovaVendita.Quantita
WHERE 	CodProd = NuovaVendita.CodProd;


INSERT INTO FATTURE
VALUES ('F0001',1000);

INSERT INTO VENDITE
VALUES ('F0001','P0001',70),
	   ('F0001','P0002',50);

SELECT * FROM Giacenze;

CREATE OR REPLACE TRIGGER QtaMinimaDaOrdinare
AFTER UPDATE ON Giacenze
REFERENCING NEW AS NG
FOR EACH ROW
WHEN (NG.QtaResidua < NG.ScortaMinima)
INSERT INTO CARENZE
VALUES (NG.CodProd,NG.SCortaMinima - NG.QtaResidua);
	
INSERT INTO FATTURE
VALUES ('F0002',1000);

INSERT INTO VENDITE
VALUES ('F0002','P0001',50),
	   ('F0002','P0002',100);

