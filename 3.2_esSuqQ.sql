
-- Q1) il numero dei dipartimenti con almeno 7 dipendenti 
SELECT COUNT(d1.deptno)
FROM (
		SELECT d.deptno
		FROM EMPLOYEE e, DEPARTMENT d 
		WHERE d.deptno = e.WORKDEPT 
		GROUP BY d.deptno
		HAVING COUNT(e.empno) >= 7) d1;
	

-- Q2) I dati dei dipendenti che lavorano in un dipartimento con almeno 7 dipendenti 
SELECT e.*
FROM EMPLOYEE e
WHERE e.WORKDEPT IN (
		SELECT d.deptno
		FROM EMPLOYEE e, DEPARTMENT d 
		WHERE d.deptno = e.WORKDEPT 
		GROUP BY d.deptno
		HAVING COUNT(e.empno) >= 7);
	
	
-- Q3) I dati del dipartimento con il maggior numero di dipendenti 
SELECT d.*
FROM DEPARTMENT d 
JOIN EMPLOYEE e ON (d.deptno = e.WORKDEPT)
GROUP BY d.DEPTNO, d.DEPTNAME, d.MGRNO, d.ADMRDEPT, d.LOCATION  -- davvero non si può fare un GROUP BY d.* ??
HAVING COUNT(e.empno) >= ALL (  SELECT COUNT(e.EMPNO)
								FROM EMPLOYEE e, DEPARTMENT d 
								WHERE d.deptno = e.WORKDEPT 
								GROUP BY d.deptno);

							
-- Q4) Il nome delle regioni e il totale delle vendite per ogni regione con un totale di vendite
--     maggiore di 30, ordinando per totale vendite decrescente 
SELECT s.region, SUM(s.sales) AS tot_vendite
FROM SALES s 
GROUP BY s.region
HAVING SUM(s.sales) > 30
ORDER BY tot_vendite DESC;


-- Q5) lo stipendio medio degli impiegati che non sono manager di nessun dipartimento 
SELECT DEC(AVG(e.SALARY), 7, 2) AS stip_med
FROM EMPLOYEE e
WHERE e.EMPNO NOT IN (SELECT e1.EMPNO
					  FROM EMPLOYEE e1, DEPARTMENT d1
					  WHERE d1.MGRNO = e1.EMPNO);
					 

-- Q6) i dipartimenti che non hanno impiegati il cui cognome inizia per ‘L’ 
SELECT d.*
FROM DEPARTMENT d
WHERE d.deptno NOT IN   (SELECT e1.WORKDEPT
					  	 FROM EMPLOYEE e1
					  	 WHERE e1.LASTNAME LIKE 'L%');

-- alternativa con NOT EXISTS
SELECT	D.*
FROM 	DEPARTMENT D
WHERE 	NOT EXISTS 
	     (	SELECT 	*
			FROM 	EMPLOYEE E
			WHERE 	E.WORKDEPT = D.DEPTNO
			AND 	E.LASTNAME LIKE 'L%'  )	;
					  	
			
-- Q7) I dipartimenti e il rispettivo massimo stipendio per tutti i dipartimenti aventi un salario
--     medio minore del salario medio calcolato considerando i dipendenti di tutti gli altri dipartimenti  					 
SELECT d.DEPTNO, d.DEPTNAME, MAX(e.SALARY) salario_max
FROM DEPARTMENT d, EMPLOYEE e 
WHERE d.deptno = e.WORKDEPT
GROUP BY d.DEPTNO, d.DEPTNAME
HAVING AVG(e.SALARY) <     (SELECT AVG(e1.salary) 
							FROM EMPLOYEE e1	
							e1.WORKDEPT <> e.WORKDEPT)  ;
						
						
-- Q8) Per ogni dipartimento determinare lo stipendio medio per ogni lavoro per il quale il
--     livello di educazione medio è maggiore di quello degli impiegati dello stesso dipartimento che fanno un lavoro differente
SELECT e.WORKDEPT, e.job, AVG(e.salary) AS stip_med
FROM EMPLOYEE e 
GROUP BY e.job, e.WORKDEPT
HAVING AVG(e.edlevel/1.0) > (	SELECT AVG(e2.edlevel/1.0)   -- importante qui il /1.0 per avere un intero
								FROM EMPLOYEE e2
								WHERE e2.WORKDEPT = e.WORKDEPT
								AND e2.JOB <> e.JOB);
							
							
-- Q9) Lo stipendio medio degli impiegati che non sono addetti alle vendite 
SELECT DEC(AVG(e.salary), 7, 2)
FROM EMPLOYEE e
WHERE e.lastname NOT IN (SELECT s.sales_person 
						 FROM SALES s);
						

-- Q10) Per ogni regione, i dati dell’impiegato che ha il maggior numero di vendite
--      (SUM(SALES)) in quella regione 
SELECT s.region, s.sales_person, SUM(s.sales)
FROM EMPLOYEE e, SALES s 
WHERE s.sales_person = e.lastname
GROUP BY s.region, s.sales_person
HAVING SUM(s.sales) >= ALL (SELECT SUM(SALES)
							FROM SALES s1
							WHERE s.region = s1.REGION 
							GROUP BY s1.SALES_PERSON);
						

-- alternativa più completa
SELECT 	DISTINCT S.REGION, E.*
FROM	EMPLOYEE E, SALES S
WHERE	E.LASTNAME = S.SALES_PERSON
AND	(S.SALES_PERSON, S.REGION) IN (	SELECT 	S1.SALES_PERSON, S1.REGION
									FROM	SALES S1
									GROUP BY S1.SALES_PERSON, S1.REGION
									HAVING	 SUM(S1.SALES) >= ALL  (	SELECT 	SUM(S2.SALES)
																		FROM	SALES S2
																		WHERE	S2.REGION = S1.REGION
																		GROUP BY S2.SALES_PERSON) );						
						
						
-- Q11) I codici dei dipendenti che svolgono un’attività per la quale ogni tupla di EMPPROJACT
--      riguarda un periodo minore di 200 giorni				
SELECT 	DISTINCT E.EMPNO
FROM	EMPPROJACT E
WHERE	NOT EXISTS
	(	SELECT	*
		FROM	EMPPROJACT E1
		WHERE	E1.ACTNO = E.ACTNO
		AND	DAYS(E1.EMENDATE) - DAYS(E1.EMSTDATE) >= 200);
					 
	
							
SELECT * FROM DEPARTMENT ;
SELECT * FROM EMPLOYEE ;
SELECT * FROM EMPPROJACT ;
SELECT * FROM SALES ;
SELECT * FROM PROJECT ;
