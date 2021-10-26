-- Subquery correlate e non

CREATE TABLE NEGOZI (
	NID CHAR(5) NOT NULL PRIMARY KEY,
	INDIRIZZO VARCHAR(30) NOT NULL,
	COMUNE VARCHAR(30) NOT NULL	);

CREATE TABLE PRODOTTI (
	CODP CHAR(5) NOT NULL PRIMARY KEY,
	DESCRIZIONE VARCHAR(30) NOT NULL,
	PREZZO DEC(6,2) NOT NULL CHECK (PREZZO > 0)	);

CREATE TABLE VENDITE(
	NID CHAR(5) NOT NULL REFERENCES NEGOZI,
	CODP CHAR(5) NOT NULL REFERENCES PRODOTTI,
	MESE SMALLINT NOT NULL CHECK (MESE BETWEEN 1 AND 12),
	NUMVENDUTI INT NOT NULL CHECK (NUMVENDUTI > 0),
	PRIMARY KEY (NID,CODP,MESE)				);


INSERT INTO NEGOZI VALUES
('N0001','Via Roma, 25','Bologna'),
('N0002','Piazza Galilei, 3','Bologna'),
('N0003','Via Verdi, 17','Cesena');

INSERT INTO PRODOTTI VALUES
('P0998','TV LCD 40',150.00),
('P0999','TV LCD 42',230.00),
('P1000','SMART TV LCD 50',500.00),
('P1001','SMART TV LCD 65',900.00),
('P1102','SISTEMA HOME THEATRE',250.00),
('P1103','SISTEMA HOME THEATRE TOP',750.00),
('P2004','LETTORE 3D BLU-RAY XYZ',150.00),
('P3005','OCCHIALI 3D WZH (1 PAIO)',20.00)
;

INSERT INTO VENDITE VALUES
('N0001','P0998',1,300),
('N0001','P0999',1,450),
('N0001','P1000',1,300),
('N0001','P1000',2,700),
('N0001','P1001',2,1200),
('N0002','P0999',1,600),
('N0002','P1000',1,150),
('N0002','P1001',1,1400),
('N0002','P1102',2,650),
('N0002','P1103',2,1300),
('N0002','P1001',3,800),
('N0003','P0999',1,300),
('N0003','P1001',2,600),
('N0003','P1103',2,150);

--


-- subqueries

-- i dati della maggior vendita
SELECT 	* 
FROM 	VENDITE V
WHERE 	V.NUMVENDUTI = ( SELECT MAX(V1.NUMVENDUTI)
				 		 FROM 	VENDITE V1			);

-- per ogni negozio i dati della maggior vendita				 		 
SELECT 	* 
FROM 	VENDITE V
WHERE 	(V.NID,V.NUMVENDUTI) IN ( SELECT V1.NID, MAX(V1.NUMVENDUTI)
				 		      	  FROM 	 VENDITE V1
				 		      	  GROUP BY V1.NID)		;
 				 
-- per ogni negozio, il numero di pezzi venduti, solo se la media non è superiore
-- alla media calcolata su tutti i negozi 				 		      	  
SELECT	V.NID, COUNT(V.NUMVENDUTI) 
FROM 	VENDITE V		
GROUP BY V.NID
HAVING 	AVG(V.NUMVENDUTI) <= ( SELECT AVG(V1.NUMVENDUTI)
							   FROM   VENDITE V1);

-- il negozio con il massimo numero di pezzi venduti							   
SELECT V.NID, SUM(V.NUMVENDUTI) AS TOTVENDUTI
FROM VENDITE V
GROUP BY V.NID 
HAVING SUM(V.NUMVENDUTI) >= ALL (SELECT SUM(NUMVENDUTI)
				 				 FROM	VENDITE V1
				 				 GROUP BY V1.NID) ;

-- correlate

-- per ogni prodotto il negozio che ne ha venduti più pezzi	
SELECT V.CODP, V.NID, SUM(V.NUMVENDUTI) AS TOTVENDUTI
FROM VENDITE V
GROUP BY V.CODP, V.NID 
HAVING SUM(V.NUMVENDUTI) >= ALL (SELECT SUM(V1.NUMVENDUTI)
				 				 FROM	VENDITE V1
				 				 WHERE  V1.CODP = V.CODP -- correlazione
				 				 GROUP BY V1.NID ) ;
				 				 
-- per ogni negozio i dati della maggior vendita
SELECT V.NID, V.NUMVENDUTI 
FROM  VENDITE V
WHERE V.NUMVENDUTI >= ALL (SELECT V1.NUMVENDUTI
				 		   FROM	  VENDITE V1
				 		   WHERE  V1.NID = V.NID ); -- correlazione
				 		   
-- i (codici dei) prodotti con vendite solo in una città
SELECT  DISTINCT V.CODP, N.COMUNE
FROM	VENDITE V JOIN NEGOZI N ON (V.NID = N.NID)
WHERE   NOT EXISTS ( SELECT  *
							FROM	VENDITE V1 JOIN NEGOZI N1 ON (V1.NID = N1.NID)	
							WHERE   N1.COMUNE <> N.COMUNE
							AND		V1.CODP = V.CODP); 

-- oppure:
SELECT 	DISTINCT V.CODP, N.COMUNE
FROM 	VENDITE V JOIN NEGOZI N ON (V.NID = N.NID)
WHERE 	V.CODP NOT IN ( SELECT 	V1.CODP
				 		FROM 	VENDITE V1 JOIN NEGOZI N1 ON (V1.NID = N1.NID)
				 		WHERE 	N1.COMUNE <> N.COMUNE  )	;

-- con outer join
SELECT  DISTINCT V.CODP, N.COMUNE
FROM	(VENDITE V JOIN NEGOZI N ON (V.NID = N.NID)) LEFT JOIN
        (VENDITE V1 JOIN NEGOZI N1 ON (V1.NID = N1.NID)) ON (V.CODP = V1.CODP) AND (N.COMUNE <> N1.COMUNE)
WHERE   N1.COMUNE IS NULL;	 		 

-- per ogni negozio, l'incasso complessivo per i prodotti venduti solo da quel negozio
SELECT	V.NID, SUM(V.NUMVENDUTI*P.PREZZO) AS TotIncassi
FROM	VENDITE V, PRODOTTI P
WHERE	V.CODP = P.CODP
AND		P.CODP NOT IN (	SELECT	V1.CODP
						FROM	VENDITE V1
						WHERE	V1.NID <> V.NID )
GROUP BY V.NID;
			
-- oppure:
SELECT	V.NID, SUM(V.NUMVENDUTI*P.PREZZO) AS TotIncassi
FROM	VENDITE V, PRODOTTI P
WHERE	V.CODP = P.CODP
AND		NOT EXISTS ( SELECT	*
					 FROM	VENDITE V1
					 WHERE	V1.NID <> V.NID
					 AND	V1.CODP = P.CODP )
GROUP BY V.NID;

-- per ogni prodotto il numero di mesi in cui è stato venduto da un solo negozio
SELECT	V.CODP, COUNT(V.MESE) AS NumMesi
FROM	VENDITE V
WHERE	NOT EXISTS ( SELECT	*  -- se esiste stesso prodotto, stesso mese, ma negozio diverso allora la vendita va scartata
					 FROM	VENDITE V1
					 WHERE	V1.CODP = V.CODP  
					 AND    V1.MESE = V.MESE
					 AND	V1.NID <> V.NID  )
GROUP BY V.CODP;


-- altre query

-- l'incasso relativo a ogni vendita
SELECT 	V.NID, V.CODP, V.NUMVENDUTI*P.PREZZO AS Incasso
FROM 	PRODOTTI P JOIN VENDITE V ON (V.CODP=P.CODP);

-- l'incasso relativo a ogni prodotto, solo se superiore a 400000 Euro
SELECT 	V.CODP, SUM(V.NUMVENDUTI*P.PREZZO) AS TotIncassi
FROM 	PRODOTTI P JOIN VENDITE V ON (V.CODP=P.CODP)
GROUP BY V.CODP
HAVING SUM(V.NUMVENDUTI*P.PREZZO) > 400000
ORDER BY TotIncassi DESC;

-- per ogni prodotto, l'incasso medio comune per comune
SELECT 	P.CODP, N.COMUNE,
		SUM(V.NUMVENDUTI*P.PREZZO)/COUNT(*) AS IncassoMedio
FROM 	VENDITE V, PRODOTTI P, NEGOZI N
WHERE 	V.CODP = P.CODP
AND	  	V.NID = N.NID
GROUP BY P.CODP, N.COMUNE ;


DROP TABLE NEGOZI;
DROP TABLE PRODOTTI;
DROP TABLE VENDITE;
		
GRANT SELECT ON TABLE NEGOZI TO PUBLIC;
GRANT SELECT ON TABLE PRODOTTI TO PUBLIC;
GRANT SELECT ON TABLE VENDITE TO PUBLIC;
			 		      
