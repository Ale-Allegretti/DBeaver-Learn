
-- es.1 ) 
CREATE TABLE R (
	valoreA		INT PRIMARY KEY NOT NULL,
	valoreC		INT
);

CREATE TABLE S (
	valoreB		VARCHAR(20) PRIMARY KEY NOT NULL,
	valoreC		INT 
);


DROP TABLE S;



-- 1.1) versione per inserimenti non multipli su R
CREATE OR REPLACE TRIGGER uniqueC
NO CASCADE BEFORE INSERT ON R
REFERENCING NEW AS temp_R
FOR EACH ROW
WHEN (EXISTS   (SELECT * FROM R 
				WHERE valoreC = temp_R.valoreC))
SIGNAL SQLSTATE '70001' ('Valore di valoreC duplicato!');


-- 1.2) vincolo di integrità referenziale su S.C
CREATE OR REPLACE TRIGGER uniqueRefC
BEFORE INSERT ON S
REFERENCING NEW AS temp_S
FOR EACH ROW
WHEN (NOT EXISTS   	   (SELECT * FROM R 
					  	WHERE temp_S.valoreC = R.valoreC)
	  OR EXISTS 	   (SELECT * FROM S 
						WHERE temp_S.valoreC = S.valoreC))
SIGNAL SQLSTATE '70002' ('Valore di riferimento valoreC non esistente in R o duplicato in S!');


-- 1.3) cancellazione in cascata su S quando vengono cancellate tuple di R
CREATE OR REPLACE TRIGGER cascadeC
AFTER DELETE ON R 
REFERENCING OLD AS casc_R
FOR EACH ROW
WHEN (EXISTS (SELECT * FROM S WHERE valoreC = casc_R.valoreC))
DELETE FROM S
WHERE S.valoreC = casc_R.valoreC;


-- 1.4) trigger per inserimenti multipli controllati su R
CREATE OR REPLACE TRIGGER multiUniqueC
AFTER INSERT ON R
REFERENCING NEW_TABLE AS tempM
FOR EACH STATEMENT
WHEN (EXISTS (SELECT valoreC FROM tempM GROUP BY valoreC HAVING COUNT(*) > 1))
-- oppure: WHEN (1 < ANY (SELECT COUNT(*) FROM tempMulti_R GROUP BY valoreC))
SIGNAL SQLSTATE '70003' ('Valore di C duplicato!');


-- prova insert 
INSERT INTO R VALUES (05,20),(09,21);
INSERT INTO S VALUES ('condizione1', 20), ('condizione2', 21);
-- errore su R
INSERT INTO R VALUES (07, 20);
-- non da errore per le condizioni di cui sopra! valido solo per inserimenti singoli
INSERT INTO R VALUES (07, 22), (10, 22);
DELETE FROM R WHERE valoreC = 22;
-- errore su S rispetto a R.C
INSERT INTO S VALUES ('condizione3', 24);
INSERT INTO S VALUES ('condizione3', 21);
-- prova di eliminazione in cascata 
INSERT INTO R VALUES (11, 24);
INSERT INTO S VALUES ('condizione3', 24);
DELETE FROM R WHERE valoreC = 24;
-- errore su R grazie al trigger 1.4
INSERT INTO R VALUES (02,25),(03,25);


SELECT * FROM R;
SELECT * FROM S;



DROP TABLE ORDINI ;
-- es.2 )
CREATE TABLE PRODOTTI (
	pcode 			INT PRIMARY KEY NOT NULL,
	descrizione		VARCHAR(50) NOT NULL,
	prezzo			DEC(12,2) NOT NULL
);

CREATE TABLE ORDINI (
	id 				VARCHAR(10) PRIMARY KEY NOT NULL,
	nomeCliente		VARCHAR(50) NOT NULL,
	speseSpedizione DEC(12,2) NOT NULL DEFAULT 7 CHECK (SPESESPEDIZIONE IN (0,7)),
	totale			NOT NULL DEFAULT 7 CHECK (TOTALE >=0) 
);

CREATE TABLE VENDITE (
	pcode 			INT NOT NULL REFERENCES PRODOTTI,
	id 				VARCHAR(10) NOT NULL REFERENCES ORDINI,
	quantita		INT NOT NULL CHECK (QUANTITA > 0),
	PRIMARY KEY (PCODE,ID)
);


-- inserimento valori
INSERT INTO prodotti VALUES 
(42, 'shampoo', 3.20),
(55, 'balsamo', 2.90),
(103, 'carta', 1.30),
(12, 'penne', 0.80),
(21, 'gomme', 1.10),
(24, 'scopaElettrica', 24.80);


-- 2.1) trigger per totale aggiornato quando si inseriscono nuovi prodotti nell’ordine
CREATE OR REPLACE TRIGGER createTot
AFTER INSERT ON VENDITE
REFERENCING NEW AS upOrdine
FOR EACH ROW
UPDATE 	ORDINI
SET 	totale = (totale +
				 	((SELECT prezzo FROM PRODOTTI WHERE pcode = upOrdine.pcode)*upOrdine.quantita))
WHERE 	id = upOrdine.id;


-- 2.2) trigger per totale aggiornato quando si modifica (in più o in meno) la quantità di un prodotto (che
-- 		deve essere comunque sempre maggiore di zero)
CREATE OR REPLACE TRIGGER UpdateQta
AFTER UPDATE OF quantita ON VENDITE
REFERENCING NEW AS nuovaVendita OLD AS vecchiaVendita
FOR EACH ROW
WHEN (nuovaVendita.quantita >= 0)
UPDATE 	ORDINI o
SET 	o.totale = o.totale + (nuovaVendita.quantita - vecchiaVendita.quantita)*(	SELECT p.prezzo FROM PRODOTTI p
																					WHERE p.pcode = nuovaVendita.pcode	)
WHERE 	o.id = nuovaVendita.id;


-- 2.3) trigger per totale aggiornato quando eliminano prodotti dall’ordine
CREATE OR REPLACE TRIGGER UpdateTot
AFTER DELETE ON VENDITE
REFERENCING OLD AS upOrdine
FOR EACH ROW
UPDATE 	ORDINI 
SET 	totale = totale - upOrdine.quantita*(	SELECT p.prezzo FROM PRODOTTI p
												WHERE p.pcode = upOrdine.pcode	)
WHERE 	id = upOrdine.id;


-- 2.4) spese spedizione gratis se totale > € 57
CREATE OR REPLACE TRIGGER UpdateSpeseSped
AFTER UPDATE OF totale ON ORDINI
REFERENCING NEW AS NewO
FOR EACH ROW
IF (NewO.TOTALE > 57 AND NewO.SPESESPEDIZIONE = 7) 
THEN
	UPDATE 	ORDINI
	SET   	TOTALE = NewO.TOTALE - 7,
			SPESESPEDIZIONE = 0
	WHERE 	ID = NewO.ID;
ELSE
	IF (NewO.TOTALE <= 50 AND NewO.SPESESPEDIZIONE = 0)
	THEN
		UPDATE 	ORDINI
		SET   	TOTALE = NewO.TOTALE + 7,
				SPESESPEDIZIONE = 7
		WHERE 	ID = NewO.ID;
	END IF	
		;
END IF	



DELETE FROM VENDITE ;
DELETE FROM ORDINI ;
-- prova per 2.1 
INSERT INTO ORDINI VALUES 	('A980A4', 'Alessandro Allegretti', 7, 7);
INSERT INTO VENDITE VALUES	(42, 'A980A4', 3), 
							(55, 'A980A4', 2);
-- prova per 2.2
UPDATE VENDITE v 
SET v.QUANTITA = 5
WHERE v.PCODE = 55
AND v.ID = 'A980A4';

-- prova per 2.3
DELETE FROM VENDITE v
WHERE v.PCODE = 42
AND v.ID = 'A980A4';

-- prova per 2.4
INSERT INTO VENDITE VALUES	(42, 'A980A4', 20);

						
SELECT * FROM PRODOTTI;
SELECT * FROM ORDINI;
SELECT * FROM VENDITE;

