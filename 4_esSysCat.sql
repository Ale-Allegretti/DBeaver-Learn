
-- Q1) Determinare per ogni table (TYPE = ‘T’) , il numero di foreign key, ignorando quelle
--     autoreferenziali (ed escludendo le tabelle con 0 foreign key) e ordinare per valori
--     decrescenti (a parità, per nome di schema e di tabella)
SELECT TABSCHEMA, TABNAME, (PARENTS - SELFREFS) AS numfk 
FROM SYSCAT.TABLES
WHERE TYPE = 'T'
AND PARENTS <> 0
ORDER BY numfk DESC;


-- Q2) Mostrare gli schemi con almeno 5 table o view, ordinando in senso decrescente per
--     numero totale di oggetti 
SELECT t.TABSCHEMA, COUNT(TYPE) AS numObj
FROM SYSCAT.TABLES t
WHERE t.TYPE = 'T' OR t.TYPE = 'V'
GROUP BY t.TABSCHEMA
HAVING COUNT(TYPE) >= 5
ORDER BY numObj DESC;


-- Q3) Per ogni vista di SYSCAT, determinare da quanti oggetti di ciascun tipo dipende
SELECT t.TABNAME, t.BTYPE, COUNT(*) AS numDep
FROM SYSCAT.TABDEP t
WHERE T.TABSCHEMA = 'SYSCAT'
GROUP BY t.TABNAME, t.BTYPE
ORDER BY numDep DESC;


-- Q4) Senza usare l’attributo TABLES.COLCOUNT, né viste, determinare la table (TYPE = ‘T’)
--     con il maggior numero di colonne
WITH Colonne(tabschema, tabname, numCol) 
AS (
SELECT t.TABSCHEMA, t.TABNAME, COUNT(c.COLNAME)
FROM SYSCAT.TABLES t, SYSCAT.COLUMNS c 
WHERE t.TYPE = 'T'
AND t.TABSCHEMA = c.TABSCHEMA 
AND t.TABNAME = c.TABNAME 
GROUP BY t.TABSCHEMA, t.TABNAME
)
	SELECT *
	FROM Colonne
	WHERE numCol = (SELECT MAX(numCol)
					FROM Colonne);

				
-- Q5) Per ogni tipo di dato (COLUMNS.TYPENAME), il n. di oggetti in cui quel tipo è il più usato
WITH mostUsed (tabschema, tabname, typename, num_occorenze) 
AS (
	SELECT c.TABSCHEMA, c.TABNAME, c.TYPENAME, COUNT(c.TYPENAME)
	FROM SYSCAT.COLUMNS c 
	GROUP BY c.TABSCHEMA, c.TABNAME, c.TYPENAME
)
SELECT m1.typename, COUNT(m1.tabname) AS num_tables
FROM mostUsed m1
WHERE m1.num_occorenze >= ALL  (SELECT num_occorenze
						    	FROM mostUsed m2
						    	WHERE m2.tabname = m1.tabname
						    	AND m2.tabschema = m1.tabschema)
GROUP BY m1.typename
ORDER BY num_tables DESC;


-- ESEGUIRE QUESTE ULTIME DUE SU SIT_STUD -> NON SU SAMPLE!
-- Q6) La coppia di nomi di table che compaiono più frequentemente insieme in uno stesso schema 
WITH TABLEPAIRS(TABLE1, TABLE2, NUMSCHEMA) 
AS (	SELECT 	T1.TABNAME, T2.TABNAME, COUNT(*)
	FROM 	SYSCAT.TABLES T1, SYSCAT.TABLES T2
	WHERE 	T1.TABSCHEMA = T2.TABSCHEMA
	AND	T1.TABNAME < T2.TABNAME  -- < anzichè <> per evitare di duplicare le coppie
	AND T1.TYPE = 'T'
	AND	T2.TYPE = 'T'
	GROUP BY T1.TABNAME, T2.TABNAME
   )
SELECT	*
FROM 	TABLEPAIRS
WHERE 	NUMSCHEMA = (SELECT MAX(NUMSCHEMA)
					 FROM TABLEPAIRS);
 

-- Q7) Determinare il nome di table più “popolare” su SIT_STUD, fornendo il nome e i
--     timestamp di creazione minimo e massimo
WITH mostPop (nome, ric) 
AS (
	SELECT t.TABNAME, COUNT(t.TABNAME) AS ricorrenze
	FROM SYSCAT.TABLES t
	GROUP BY t.TABNAME )
SELECT m.nome, t1.dataMinima, t2.dataMax
FROM mostPop m, 
			TABLE (SELECT MIN(s1.CREATE_TIME) 
				   FROM SYSCAT.TABLES s1
				   WHERE s1.TABNAME = m.nome) AS t1(dataMinima),
				   TABLE (SELECT MAX(s2.CREATE_TIME) 
				   		  FROM SYSCAT.TABLES s2
				   		  WHERE s2.TABNAME = m.nome) AS t2(dataMax)			  
WHERE ric = (SELECT MAX(ric)
			 FROM mostPop);
				


	
-- Esercizio 2
-- Si assume che l'utente sia gia' connesso al database SIT_STUD
--

-- Q1)	Definire una vista che mostri, per ogni table o view nel proprio schema, 
--	il numero di (altre) table o view con lo stesso nome nel DB SIT_STUD, 
--	create prima (SAMEBEFORE) e dopo (SAMEAFTER)
			
CREATE OR REPLACE VIEW CAT_SAMENAME(TABNAME, SAMEBEFORE, SAMEAFTER) 
AS (	SELECT	COALESCE(TA.TABNAME,TB.TABNAME), TB.NUMBEFORE, TA.NUMAFTER
	FROM (SELECT M.TABNAME, COUNT(*)
		  FROM   SYSCAT.TABLES M, SYSCAT.TABLES Y
		  WHERE	 M.TABSCHEMA = CURRENT USER
		  AND	 Y.TABSCHEMA <> M.TABSCHEMA
		  AND 	 M.TABNAME = Y.TABNAME
		  AND    M.CREATE_TIME > Y.CREATE_TIME 
		  GROUP BY M.TABNAME ) AS TB(TABNAME, NUMBEFORE) 
		FULL JOIN
		( SELECT M.TABNAME, COUNT(*)
		  FROM   SYSCAT.TABLES M, SYSCAT.TABLES Y
		  WHERE	 M.TABSCHEMA = CURRENT USER
		  AND	 Y.TABSCHEMA <> M.TABSCHEMA
		  AND 	 M.TABNAME = Y.TABNAME
		  AND    M.CREATE_TIME < Y.CREATE_TIME 
		  GROUP BY M.TABNAME ) AS TA(TABNAME, NUMAFTER)
		ON (TA.TABNAME = TB.TABNAME)	) ;
	
SELECT *
FROM CAT_SAMENAME;
	
	
	
	
	
-- La funzione COALESCE restituisce il primo valore non nullo

-- Q2)	Definire una vista che mostri per ogni table o view del proprio schema e definita 
--	con lo stesso nome anche in altri schemi, le eventuali differenze esistenti 
--	sui nomi degli attributi definiti
--
CREATE OR REPLACE VIEW CAT_TABDIFF(MYTABLE, YOURSCHEMA, DIFFCOLUMN, DIFF) 
AS (SELECT	DISTINCT M.TABNAME, Y.TABSCHEMA, M.COLNAME, '-'
	FROM 	SYSCAT.COLUMNS M, SYSCAT.COLUMNS Y
	WHERE 	M.TABSCHEMA = CURRENT USER
	AND	    Y.TABSCHEMA <> M.TABSCHEMA
	AND 	M.TABNAME = Y.TABNAME
	AND	NOT EXISTS ( SELECT *
			     FROM   SYSCAT.COLUMNS Y2
			     WHERE  Y2.COLNAME = M.COLNAME
			     AND    Y2.TABNAME = Y.TABNAME
			     AND    Y2.TABSCHEMA = Y.TABSCHEMA)
    UNION ALL
	SELECT	DISTINCT M.TABNAME, Y.TABSCHEMA, Y.COLNAME, '+'
	FROM 	SYSCAT.COLUMNS M, SYSCAT.COLUMNS Y
	WHERE 	M.TABSCHEMA = CURRENT USER
	AND	Y.TABSCHEMA <> M.TABSCHEMA
	AND 	M.TABNAME = Y.TABNAME
	AND	NOT EXISTS ( SELECT *
			     FROM   SYSCAT.COLUMNS Y2
			     WHERE  Y2.COLNAME = Y.COLNAME
			     AND    Y2.TABNAME = M.TABNAME
			     AND    Y2.TABSCHEMA = M.TABSCHEMA)		) ;
			    

SELECT *
FROM CAT_TABDIFF;











