CREATE TABLE PRESTAZIONI (
Giocatore 	 varchar(10) not null,
Campo 		 varchar(10) not null,
PunteggioMax int not null,
primary key (Giocatore,Campo) );

INSERT INTO PRESTAZIONI
VALUES ('Pippo','Green18',25);

CREATE OR REPLACE TRIGGER UpdatePunteggioMax
BEFORE UPDATE OF PunteggioMax ON PRESTAZIONI
REFERENCING NEW AS NewP OLD AS OldP
FOR EACH ROW
WHEN (NewP.PunteggioMax < OldP.PunteggioMax)
SIGNAL SQLSTATE '70000' ('Punteggio inferiore all''esistente!');

-- OK
UPDATE PRESTAZIONI
SET PunteggioMax = 26
WHERE Giocatore = 'Pippo'
AND   Campo = 'Green18';

-- NO
UPDATE PRESTAZIONI
SET PunteggioMax = 25
WHERE Giocatore = 'Pippo'
AND   Campo = 'Green18';

----------------------------------------------

CREATE TABLE AUTO2 (	
	TARGA CHAR(7) NOT NULL PRIMARY KEY,
	ANNO  INT NOT NULL			);

CREATE OR REPLACE TRIGGER AnnoValido
BEFORE INSERT ON AUTO2
REFERENCING NEW AS NewA
FOR EACH ROW
WHEN (NewA.Anno > YEAR(CURRENT DATE))
SIGNAL SQLSTATE '70000' ('Anno non valido!');

-- OK
INSERT INTO AUTO2
VALUES ('GG123HH',2015);

-- NO (se eseguita prima del 2022)
INSERT INTO AUTO2
VALUES ('FF123HH',2022);

----------------------

CREATE TABLE R(K char(2) NOT NULL PRIMARY KEY, Num INT NOT NULL);

CREATE OR REPLACE TRIGGER AutoNum
BEFORE INSERT ON R
REFERENCING NEW AS N
FOR EACH ROW
SET N.Num = COALESCE((SELECT SUM(Num) FROM R),1);

INSERT INTO R(K) VALUES(:K);
