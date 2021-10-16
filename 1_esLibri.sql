CREATE TABLE "UTENTI" (
	tessera	DEC(10,0) NOT NULL,
	nome VARCHAR(100) NOT NULL,
	cognome VARCHAR(100) NOT NULL,
	telefono DEC(16,0) NOT NULL
);

CREATE TABLE "LIBRI" (
	codice DEC(10,0) NOT NULL,
	titolo VARCHAR(100) NOT NULL,
	autori VARCHAR(100) DEFAULT 'Anonimo',
	note VARCHAR(300)
);

CREATE TABLE "PRESTITI" (
	codicelibro DEC(10,0) NOT NULL,
	tessera DEC(10,0) NOT NULL,
	data_out DATE NOT NULL,
	data_in DATE
);

SELECT * FROM UTENTI ;
SELECT * FROM LIBRI ;
SELECT * FROM PRESTITI ;

-- creazione chiavi primarie
ALTER TABLE UTENTI ADD CONSTRAINT pk_tessera PRIMARY KEY (tessera);
ALTER TABLE LIBRI ADD CONSTRAINT pk_codice PRIMARY KEY (codice);
ALTER TABLE PRESTITI ADD CONSTRAINT pk_codicelibro PRIMARY KEY (codicelibro, tessera, data_out);

-- creazione condizioni e chiavi esterne
ALTER TABLE PRESTITI ADD CONSTRAINT data_valida CHECK ((data_in > data_out) OR (data_in = data_out));
ALTER TABLE PRESTITI ADD CONSTRAINT fk_codicelibro FOREIGN KEY (codicelibro) REFERENCES LIBRI ON DELETE CASCADE;
ALTER TABLE PRESTITI ADD CONSTRAINT fk_tessera FOREIGN KEY (tessera) REFERENCES UTENTI ON DELETE CASCADE;


-- inserimento valori UTENTI
INSERT INTO UTENTI VALUES (1220, 'Alessandro', 'Allegretti', 320424444);
INSERT INTO UTENTI VALUES (1760, 'Marco', 'Rossi', 329422344);
INSERT INTO UTENTI VALUES (5134, 'Marcello', 'Bianchi', 347422544);
INSERT INTO UTENTI VALUES (7739, 'Pino', 'Verdi', 334275434);

-- inserimento valori LIBRI
INSERT INTO LIBRI VALUES (122839, 'Cappuccetto Rosso', 'Gino Rossi', null);
INSERT INTO LIBRI VALUES (172123, 'Pinocchio', 'Walt Disney', 'revisione in formato cartone animato');
INSERT INTO LIBRI VALUES (283993, 'Fight Club', 'Palanhiuk', null);
INSERT INTO LIBRI VALUES (342953, 'Shades of Earth', 'Beth Revis', 'bellissimo libro, profondo e vero');
INSERT INTO LIBRI VALUES (218779, 'Fall from India Place', 'Samantha Young', 'bellissima descrizione di tutta il paese indiano');
INSERT INTO LIBRI VALUES (413993, 'Morsi di Ghiaccio', 'Richelle Mead', null);

-- inserimento valori PRESTITI
INSERT INTO PRESTITI VALUES (122839, 1220, '10/09/2021', null);
INSERT INTO PRESTITI VALUES (342953, 1760, '02/18/2019', '07/02/2020');
INSERT INTO PRESTITI VALUES (413993, 1220, '05/07/2020', '06/12/2021');
INSERT INTO PRESTITI VALUES (218779, 1220, '08/16/2021', null);
-- fallisce per data_out < data_in
INSERT INTO PRESTITI VALUES (283993, 5134, '10/09/2021', '09/09/2021');
-- ok
INSERT INTO PRESTITI VALUES (283993, 5134, '10/09/2021', '12/09/2021');

-- delete di un utente e relativi prestiti
DELETE FROM utenti WHERE tessera = 5134;
-- delete di un libro e relativi prestiti
DELETE FROM libri WHERE codice = 283993;


-- update di alcuni valori
UPDATE utenti SET telefono = 3342754343 WHERE tessera = 7739;
UPDATE libri SET note = 'libro da cui si è ispirato il famoso film' WHERE codice = 283993;
UPDATE utenti SET cognome = 'Allegretti' WHERE tessera = 5134;


-- selezioni varie ed interrogazioni
SELECT * FROM libri l 
WHERE l.autori LIKE '%l%'
AND l.titolo LIKE 'P%';

SELECT * FROM utenti u
WHERE u.cognome = 'Allegretti';

SELECT * FROM prestiti p
WHERE YEAR(p.data_out) = 2020; -- va bene anche LIKE 2020

SELECT * FROM prestiti p
WHERE YEAR(p.data_out) NOT LIKE YEAR(p.DATA_IN);


SELECT p.codicelibro, u.nome, u.cognome, u.telefono 
FROM utenti u JOIN PRESTITI p ON (u.tessera = p.tessera);

SELECT p.codicelibro, u.nome, u.cognome, u.telefono 
FROM utenti u JOIN PRESTITI p ON (u.tessera = p.tessera)
WHERE p.data_out > '04/01/2020';

SELECT p.codicelibro, l.titolo, l.autori, u.nome, u.cognome, u.telefono 
FROM utenti u 
JOIN prestiti p ON (u.tessera = p.tessera)
JOIN libri l ON (p.codicelibro = l.codice)
WHERE p.data_out > '04/01/2020';


-- selezione di chi ha preso più di un libro nel 2021
SELECT u.nome, u.cognome, u.telefono
FROM utenti u
JOIN prestiti p ON (u.tessera = p.tessera)
WHERE YEAR(p.data_out) = 2021
EXCEPT ALL
SELECT u2.nome, u2.cognome, u2.telefono
FROM utenti u2;

-- selezione di chi non ha preso nessun libro nel 2021
SELECT u2.nome, u2.cognome, u2.telefono
FROM utenti u2
EXCEPT
SELECT u.nome, u.cognome, u.telefono
FROM utenti u
JOIN prestiti p ON (u.tessera = p.tessera)
WHERE YEAR(p.data_out) = 2021;

--selezione di chi non hanno mai preso in prestito un libro senza autori e che nei commenti include la parolla bell*
SELECT l.titolo, l.note, u.nome, u.cognome, u.telefono
FROM utenti u
JOIN prestiti p ON (u.tessera = p.tessera)
JOIN libri l ON (l.codice = p.codicelibro)
WHERE l.autori NOT LIKE 'Anonimo' 
AND l.note LIKE 'bell%';