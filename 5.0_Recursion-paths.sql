-- Interrogazioni ricorsive

CREATE TABLE RIC(PRIMA CHAR, DOPO CHAR);

--
-- DB aciclico
--
INSERT INTO RIC
VALUES ('A','C'),('A','D'),('B','D'),('B','E'),('C','H'),('H','I'),
	   ('C','I'),('D','F'),('D','G'),('E','G'),('F','E');
	
	
SELECT * FROM ric;

-- solo percorsi, che crescono "in testa" (a sx)
WITH PATHS(BEFORE,AFTER)
AS 	((	SELECT 	PRIMA,DOPO
		FROM 	RIC )
	UNION ALL
	 (	SELECT 	R.PRIMA, P.AFTER 
		FROM 	RIC R, PATHS P
		WHERE 	P.BEFORE = R.DOPO ))
SELECT 	* 
FROM 	PATHS
ORDER BY BEFORE,AFTER;

-- idem, ma ora crescono "in coda" (a dx)
WITH PATHS(BEFORE,AFTER)
AS 	((	SELECT 	PRIMA,DOPO
		FROM 	RIC )
	UNION ALL
	 (	SELECT 	P.BEFORE, R.DOPO 
		FROM 	RIC R, PATHS P
		WHERE 	P.AFTER = R.PRIMA ))
SELECT 	* 
FROM 	PATHS
ORDER BY BEFORE,AFTER;


-- percorsi con lunghezza
WITH PATHS(BEFORE,AFTER,LEN)
AS 	((	SELECT 	PRIMA,DOPO,1 
		FROM 	RIC )
		UNION ALL
	 (	SELECT 	P.BEFORE, R.DOPO,P.LEN+1
		FROM   	RIC R, PATHS P
		WHERE  	P.AFTER = R.PRIMA
		AND 	P.LEN + 1 <= 10    )) --serve in caso di DB ciclico
-- tutti i percorsi
SELECT 	 BEFORE, AFTER, LEN
FROM 	 PATHS
ORDER BY BEFORE, AFTER, Len DESC;
	
-- sostituire se si vogliono solo i percorsi di lunghezza minima
SELECT 	 BEFORE, AFTER, MIN(LEN) AS LenMinima
FROM 	 PATHS
GROUP BY BEFORE, AFTER
ORDER BY LenMinima, BEFORE, AFTER;

--
-- DB ciclico
--
INSERT INTO RIC VALUES ('G','A');

-- percorsi espliciti e limitazione sulla loro lunghezza
WITH PATHS(BEFORE,AFTER,LEN,PATH)
AS 	((
	-- si inizializzano i PATH con le coppie preseni in RIC
	SELECT 	PRIMA,DOPO,1, varchar(PRIMA || '-' || DOPO,200)
	FROM 	RIC
	)
		UNION ALL
	(
	-- a ogni passo si aggiunge un elemento (R.DOPO) al PATH
	SELECT 	P.BEFORE, R.DOPO,LEN+1, PATH || '-' || R.DOPO
	FROM 	RIC R, PATHS P
	WHERE 	P.AFTER = R.PRIMA
	AND 	P.LEN + 1 <= 10
	))
SELECT * FROM PATHS
ORDER BY LEN DESC,BEFORE,AFTER;


-- percorsi espliciti con controllo dei cicli
WITH PATHS(BEFORE,AFTER,LEN,PATH)
AS 	((
	SELECT 	PRIMA,DOPO,1,varchar(PRIMA || '-' || DOPO,200)
	FROM 	RIC
	)
		UNION ALL
	(
	SELECT P.BEFORE, R.DOPO,LEN+1, PATH || '-' || R.DOPO
	FROM RIC R, PATHS P
	WHERE P.AFTER = R.PRIMA
	AND PATH NOT LIKE '%' || R.DOPO || '%'
	-- verifica che il PATH già formato non includa R.DOPO, 
	-- che genererebbe un ciclo
	-- AND 	P.LEN + 1 <= 10 è ora inutile
	))
SELECT * FROM PATHS
ORDER BY LEN DESC,BEFORE,AFTER;
