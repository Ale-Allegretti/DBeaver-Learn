
CREATE TABLE "MODELLI" (
	modello varchar(100) NOT NULL,
	marca VARCHAR(100) NOT NULL,
	cilindrata INT NOT NULL CHECK (cilindrata > 0),
	alimentazione VARCHAR(100) NOT NULL,
	velMax INT NOT NULL CHECK (velMax > 0),
	prezzoListino DEC(8,2) NOT NULL CHECK (prezzoListino > 0)
);

CREATE TABLE "RIVENDITORI" (
	codR VARCHAR(50) NOT NULL,
	citta VARCHAR(100) NOT NULL
);

CREATE TABLE "AUTO" (
	targa VARCHAR(50) NOT NULL,
	modello VARCHAR(100) NOT NULL,
	codR VARCHAR(50) NOT NULL,
	prezzoVendita DEC(8,2) NOT NULL CHECK (prezzoVendita > 0),
	km INT NOT NULL CHECK (km >= 0),
	anno INT NOT NULL CHECK (anno >= 1900),
	venduta CHAR(2) CHECK (venduta = 'SI')
);



-- creazione chiavi primarie
ALTER TABLE MODELLI ADD CONSTRAINT pk_modello PRIMARY KEY (modello);
ALTER TABLE RIVENDITORI ADD CONSTRAINT pk_codR PRIMARY KEY (codR);
ALTER TABLE AUTO ADD CONSTRAINT pk_targa PRIMARY KEY (targa);

-- creazione chiavi esterne
ALTER TABLE AUTO ADD CONSTRAINT fk_codR FOREIGN KEY (codR) REFERENCES RIVENDITORI;
ALTER TABLE AUTO ADD CONSTRAINT fk_modello FOREIGN KEY (modello) REFERENCES MODELLI;


-- inserimento valori
INSERT INTO RIVENDITORI VALUES 
('RIV01', 'Venezia'),
('RIV02','Bologna'),
('RIV03','Bologna'),
('RIV04','Rimini');

INSERT INTO MODELLI VALUES 
('Agila', 'Opel', 998, 'Benzina', 180, 12000.00),
('Aventador', 'Lamborghini', 6498, 'Benzina', 350, 432729.00),
('Ghibli', 'Maserati', 3799, 'Benzina', 326, 150000.00),
('Stratos', 'Lancia', 2419, 'Benzina', 230, 130000.00);

INSERT INTO AUTO VALUES 
('AG123AG', 'Agila', 'RIV03', 10500.00, 50000, 2003, NULL),
('AG234AG', 'Agila', 'RIV03', 9000.00, 70000, 2003, NULL),
('AV456AV', 'Aventador', 'RIV02',430000.00, 0, 2017, NULL),
('AV567AV', 'Aventador', 'RIV02', 400000.00, 0, 2015, 'SI'),
('GH789GH', 'Ghibli', 'RIV01', 90000.00, 0, 2015, 'SI'),
('GH890GH', 'Ghibli', 'RIV02', 100000.00, 30000, 2013, NULL),
('GH901GH', 'Ghibli','RIV03', 70000.00, 50000, 2015, 'SI'),
('ST123ST', 'Stratos', 'RIV04', 80000.00, 15000, 1997, 'SI'),
('ST234ST', 'Stratos','RIV04', 95000.00, 70000, 2012, 'SI');


-- Q1) Maserati ancora in vendita a Bologna a un prezzo inferiore al 70% del listino
SELECT r.citta, a.targa, a.modello, m.cilindrata, m.velMax, a.prezzoVendita
FROM AUTO a
JOIN MODELLI m ON (a.modello = m.modello)
JOIN RIVENDITORI r ON (a.codR = r.codR)
WHERE r.citta = 'Bologna'
AND a.prezzoVendita < (m.prezzoListino*0.7)
AND a.venduta IS NULL;


-- Q2) prezzo medio di un auto a benzina con cilindrata (cc) < 1000, almeno 5 anni di vita e meno di 80000 Km
SELECT AVG(a.prezzoVendita) AS PrezzoMedio, m.modello, m.marca, m.cilindrata, a.kM, a.anno
FROM AUTO a
JOIN MODELLI m ON (a.modello = m.modello)
JOIN RIVENDITORI r ON (a.codR = r.codR)
WHERE m.cilindrata < 1000
AND a.anno <= 2016
AND a.kM < 80000
GROUP BY m.modello, m.marca, m.cilindrata, a.kM, a.anno;


-- Q3) il prezzo più basso a Bologna per ogni modello con velocità massima > 180 Km/h
SELECT MIN(a.prezzoVendita) AS PrezzoMin, m.modello, m.marca, m.velMax, r.citta
FROM AUTO a
JOIN MODELLI m ON (a.modello = m.modello)
JOIN RIVENDITORI r ON (a.codR = r.codR)
WHERE m.velMax > 180
AND r.citta = 'Bologna'
GROUP BY m.modello, m.marca, m.velMax, r.citta;


-- Q4) numero di auto complessivamente trattate e vendute in ogni città
SELECT r.citta, COUNT(*) AS numAuto_tot
FROM AUTO a
JOIN MODELLI m ON (a.modello = m.modello)
JOIN RIVENDITORI r ON (a.codR = r.codR)
GROUP BY r.citta;


-- Q5) rivenditori che hanno ancora in vendita almeno il 20% delle auto complessivamente trattate, 
--	   ordinando il risultato per città e quindi per codice rivenditore
SELECT r.codR, r.citta
FROM AUTO a
JOIN RIVENDITORI r ON (a.codR = r.codR)
GROUP BY r.codR, r.citta
HAVING (COUNT(a.targa) - COUNT(a.venduta)) > (COUNT(a.targa) * 0.2);


-- Q6) rivenditori che hanno disponibili auto di modelli mai venduti prima da loro
SELECT DISTINCT a1.codr, a1.modello, a1.venduta 
FROM auto a1
LEFT JOIN (
SELECT a2.codr, a2.modello
FROM auto a2
WHERE a2.venduta IS NULL) a3
ON (a1.modello = a3.modello);


-- Q7) il numero di auto vendute, solo se il prezzo medio di tali auto risulta < 120000 Euro per ogni rivenditore
SELECT DISTINCT COUNT(a.venduta) AS vendute_lowcost, AVG(a.prezzovendita) AS prezzo_medio,
				a.modello, a.codr
FROM auto a 
WHERE a.venduta IS NOT NULL
GROUP BY a.modello, a.codr
HAVING AVG(a.prezzovendita) < 120000;


-- Q8) per ogni auto A, il numero di auto vendute a un prezzo minore di quello di A
SELECT COUNT(a1.venduta) AS vendute_min, a1.modello, a1.prezzovendita
FROM auto a1
JOIN auto a2 ON (a1.modello = a2.modello)
WHERE a1.venduta IS NOT NULL
AND a2.venduta IS NOT NULL
AND a1.prezzovendita < a2.prezzovendita
GROUP BY a1.modello, a1.prezzovendita;


-- Q9) per ogni anno e ogni modello, il rapporto medio tra prezzo di vendita e prezzo di listino, 
--     considerando un minimo di 2 auto vendute
SELECT DISTINCT DEC(AVG(a.prezzovendita/m.prezzolistino), 2, 2) AS rap_medio, COUNT(a.venduta) AS num_vendute,
				a.anno, a.modello
FROM auto a
JOIN modelli m ON (a.modello = m.modello)
WHERE a.venduta IS NOT NULL
GROUP BY a.anno, a.modello
HAVING COUNT(a.venduta) >= 2;



SELECT * FROM MODELLI m ;
SELECT * FROM RIVENDITORI r ;
SELECT * FROM AUTO a ;


