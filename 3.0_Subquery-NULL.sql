-- Subquery e NULL

CREATE TABLE R(KR int PRIMARY KEY NOT NULL);

CREATE TABLE S(KS int PRIMARY KEY NOT NULL,
			   KR int 						);
	
INSERT INTO R VALUES (1),(2),(3);

INSERT INTO S VALUES (10,1),(11,1),(20,2),(40,4);

SELECT *
FROM R
WHERE R.KR IN ( SELECT 	S.KR
				FROM 	S 		);
								
SELECT *
FROM R
WHERE R.KR NOT IN ( SELECT 	S.KR
					FROM 	S 		);
				
INSERT INTO S VALUES (50,NULL);

-- riprovare le 2 query: la seconda non restituisce nulla!
-- Va modificata in:
SELECT *
FROM R
WHERE R.KR NOT IN ( SELECT 	S.KR
					FROM 	S
					WHERE	S.KR IS NOT NULL );
					
-- oppure, usando outer join:
SELECT R.*
FROM   R LEFT JOIN S ON (R.KR = S.KR)
WHERE  S.KR IS NULL;


-- MAX vs >= ALL (e MIN vs <= ALL)

INSERT INTO R VALUES (4);

-- a causa del NULL non va bene
SELECT *
FROM R
WHERE R.KR >= ALL ( SELECT 	S.KR
					FROM 	S 		);

-- o si escludono i NULL dal risultato della subquery oppure:
SELECT *
FROM R
WHERE R.KR >= ( SELECT 	MAX(S.KR)
				FROM 	S 		);
				
-- per contro, >= ALL permette di usare funzioni aggregate nella subquery
SELECT *
FROM R
WHERE R.KR >= ALL ( SELECT 	SUM(S.KR)
					FROM 	S
					GROUP BY S.KS
					HAVING  SUM(S.KR) IS NOT NULL);

