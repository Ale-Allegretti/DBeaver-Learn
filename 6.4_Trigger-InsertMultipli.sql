-- TRIGGER per evitare duplicazioni
-- in caso di INSERT multipli

CREATE TABLE PROVA (K INT);
-- si vogliono evitare valori duplicati di K, 
-- che in DB2 non si può dichiarare come chiave
-- perché ammette valori nulli

INSERT INTO PROVA VALUES (10),(20);

-- prima versione
CREATE OR REPLACE TRIGGER CheckInsert
BEFORE INSERT ON PROVA
REFERENCING NEW AS N
FOR EACH ROW
WHEN (EXISTS (SELECT * FROM PROVA WHERE K = N.K))
SIGNAL SQLSTATE '70001' ('Valore di K duplicato!');

-- funziona per INSERT singoli...
INSERT INTO PROVA VALUES (10);

-- ... ma non con INSERT multipli!
INSERT INTO PROVA VALUES (30),(30);

DELETE FROM PROVA;

INSERT INTO PROVA VALUES (10),(20);

-- seconda versione
-- Si deve referenziare la NEW_TABLE, e quindi usare un AFTER TRIGGER.
-- Il test di prima però non funziona più, perché PROVA include già
-- le nuove tuple: EXISTS (SELECT * FROM PROVA WHERE K = N.K) è sempre vero!
CREATE OR REPLACE TRIGGER CheckInsert
AFTER INSERT ON PROVA
REFERENCING NEW_TABLE AS NT
FOR EACH STATEMENT
WHEN (EXISTS (SELECT * FROM NT GROUP BY K HAVING COUNT(*) > 1))
-- oppure: WHEN (1 < ANY (SELECT COUNT(*) FROM NT GROUP BY K))
SIGNAL SQLSTATE '70002' ('Valore di K duplicato!');

-- dà errore
INSERT INTO PROVA VALUES (30),(30); 

-- non dà errore
INSERT INTO PROVA VALUES (10);

-- soluzione generale:
-- usare entrambe le versioni (con nomi diversi)

CREATE OR REPLACE TRIGGER CheckInsertBefore
BEFORE INSERT ON PROVA
REFERENCING NEW AS N
FOR EACH ROW
WHEN (EXISTS (SELECT * FROM PROVA WHERE K = N.K))
SIGNAL SQLSTATE '70002' ('Valore di K già presente!');

CREATE OR REPLACE TRIGGER CheckInsertAfter
AFTER INSERT ON PROVA
REFERENCING NEW_TABLE AS NT
FOR EACH STATEMENT
WHEN (1 < ANY (SELECT COUNT(*) FROM NT GROUP BY K))
SIGNAL SQLSTATE '70003' ('Valore di K duplicato nelle tuple inserite!');

-- errore dal primo trigger
INSERT INTO PROVA VALUES (20); 

-- errore dal secondo trigger
INSERT INTO PROVA VALUES (30),(30); 

-- errore dal primo trigger (che viene attivato comunque prima)
INSERT INTO PROVA VALUES (30),(30),(20); 

-- in alternativa, si può usare un singolo trigger che però lavora su tutta la table:
CREATE OR REPLACE TRIGGER CheckInsertAfter
AFTER INSERT ON PROVA
-- REFERENCING NEW_TABLE AS NT
FOR EACH STATEMENT
WHEN (1 < ANY (SELECT COUNT(*) FROM PROVA GROUP BY K))
SIGNAL SQLSTATE '70004' ('Valore di K duplicato nelle tuple inserite!');

