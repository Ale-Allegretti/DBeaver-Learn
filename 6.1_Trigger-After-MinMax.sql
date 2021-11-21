create table RISTORANTI (
     Nome char(15) NOT NULL PRIMARY KEY,
     VotoMin INT DEFAULT NULL,
     VotoMax INT DEFAULT NULL );

INSERT INTO RISTORANTI VALUES
('gnamgnam',DEFAULT,DEFAULT);

create table RECENSIONI (
     Username char(10) NOT NULL,
     Nome char(15) NOT NULL REFERENCES RISTORANTI,
     Data DATE NOT NULL,
     Testo varchar(100) NOT NULL,
     Voto INT NOT NULL CHECK (Voto BETWEEN 0 AND 10),
     CONSTRAINT PK_RECE PRIMARY KEY (Username, Nome, Data));

CREATE OR REPLACE TRIGGER UpdateVotiMinMax
AFTER INSERT ON RECENSIONI
REFERENCING NEW AS N
FOR EACH ROW
UPDATE 	RISTORANTI
SET 	VotoMin = MIN(COALESCE(VotoMin,N.Voto),N.Voto),
		VotoMax = MAX(COALESCE(VotoMax,N.Voto),N.Voto)
WHERE   Nome = N.Nome;

INSERT INTO RECENSIONI VALUES
('Pippo','gnamgnam','15.01.2021','buonino',7);

INSERT INTO RECENSIONI VALUES
(:Username,:Rist,:Data,:Testo,:Voto);


-------------------------------------------------

---- Ciclo ricorsivo: dà errore
CREATE TABLE R(A int);

CREATE OR REPLACE TRIGGER IncreaseA
AFTER UPDATE ON R
REFERENCING NEW AS N
FOR EACH ROW
WHEN (N.A > 1)
UPDATE 	R
SET 	A = N.A +1;

INSERT INTO R VALUES(0);

UPDATE R SET A = 2;