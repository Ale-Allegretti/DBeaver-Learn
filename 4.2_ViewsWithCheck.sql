--
-- VIEWS con CHECK OPTION
--

-- non aggiornabile
CREATE OR REPLACE VIEW VenditeBO(NID,CODP,MESE,NUMVENDUTI)
AS   (	SELECT  V.*
		FROM	VENDITE V JOIN NEGOZI N ON (V.NID = N.NID)
		WHERE	COMUNE = 'Bologna') ;

INSERT INTO VENDITEBO
VALUES ('N0003','P1103',3,250);  -- dà errore

-- aggiornabile, ma senza CHECK OPTION
CREATE OR REPLACE VIEW VenditeBO(NID,CODP,MESE,NUMVENDUTI)
AS   (	SELECT  *
		FROM	VENDITE
		WHERE	NID	IN ( SELECT NID
						 FROM	NEGOZI
						 WHERE  COMUNE = 'Bologna') );

INSERT INTO VENDITEBO
VALUES ('N0003','P1103',3,250); -- funziona, ma N0003 è a Cesena!

SELECT * FROM VENDITEBO; -- non compare...

SELECT * FROM VENDITE;  -- ma è nel DB

DELETE FROM VENDITE
WHERE  (NID,CODP,MESE) = ('N0003','P1103',3);

-- aggiornabile, con CHECK OPTION
CREATE OR REPLACE VIEW VenditeBO(NID,CODP,MESE,NUMVENDUTI)
AS   (	SELECT  *
		FROM	VENDITE
		WHERE	NID	IN ( SELECT NID
						 FROM	NEGOZI
						 WHERE  COMUNE = 'Bologna') )
WITH CHECK OPTION ;

INSERT INTO VENDITEBO
VALUES ('N0003','P1103',3,250); -- ora dà errore

DROP VIEW VENDITEBO;


-- Check Option locale vs globale
CREATE TABLE R ( A int not null );

-- in inserimento accetta solo valori > 10
CREATE VIEW V1
AS ( SELECT * FROM R WHERE A > 10 )
WITH CHECK OPTION;

-- in inserimento accetta anche valori >= 100 !
CREATE VIEW V2
AS ( SELECT * FROM R WHERE A < 100 );

-- in inserimento accetta valori che soddisfano la WHERE di V1 e V3,
-- quindi valori >10
CREATE VIEW V3
AS ( SELECT * FROM V2 WHERE A IN ( SELECT * FROM V1))
WITH LOCAL CHECK OPTION;

-- in inserimento accetta valori che soddisfano la WHERE di V1,V4 E V2,
-- quindi valori >10 e <100
CREATE VIEW V4
AS ( SELECT * FROM V2 WHERE A IN ( SELECT * FROM V1))
WITH CHECK OPTION;

INSERT INTO V1 VALUES (5); 

SELECT * FROM V3

DELETE FROM R

-- non va
INSERT INTO V3 VALUES(5); 

-- va bene
INSERT INTO V3 VALUES(15); 

-- va bene!?
INSERT INTO V3 VALUES(105); 

SELECT * FROM R

-- non va
INSERT INTO V4 VALUES(6); 

-- va bene
INSERT INTO V4 VALUES(16); 

-- non va
INSERT INTO V4 VALUES(106); 

DROP VIEW V4;
DROP VIEW V3;
DROP VIEW V2;
DROP VIEW V1;
DROP TABLE R;

--------------------------------------

CREATE TABLE EMPLOYEES
( Company 	CHAR(8) NOT NULL,
  Employee 	CHAR(10) NOT NULL PRIMARY KEY,
  Job 		VARCHAR(20) NOT NULL );

CREATE VIEW PRESIDENTS AS
 SELECT *
 FROM 	EMPLOYEES
 WHERE 	Job = 'president'
 AND 	1 >= ALL ( SELECT COUNT(*)
               FROM EMPLOYEES E
               WHERE E.job = 'president'
               GROUP BY E.Company )
WITH CHECK OPTION
;


INSERT INTO presidents VALUES ( 'Acme', '1', 'president' );

INSERT INTO presidents VALUES ( 'Acme', '2', 'president' );

SELECT * FROM PRESIDENTS;

DELETE FROM EMPLOYEES;

INSERT INTO PRESIDENTS VALUES ( 'Acme', '1', 'president' );
INSERT INTO PRESIDENTS VALUES ( 'Acme', '2', 'president' );

SELECT * FROM PRESIDENTS;

DROP VIEW PRESIDENTS;



