

CREATE TABLE strumenti ( 
	cod_strumento number(10) NOT NULL, 
	azienda varchar2(100) NOT NULL, 
	prezzo number(10,2) NOT NULL, 
	data_inserimento date NOT NULL, 
	data_vendita date
);

CREATE TABLE a_corda( 
	cod_a_corda number(10) NOT NULL, 
	ds_tipo varchar2(100) NOT NULL 
);

CREATE TABLE chitarre( 
	cod_a_corda number(10) NOT NULL, 
	cod_strumento number(10) NOT NULL,
	data_fabbricazione date NOT NULL,
	tipo_corde varchar2(50)
);

CREATE TABLE violini( 
	cod_a_corda number(10) NOT NULL, 
	cod_strumento number(10) NOT NULL,
	data_fabbricazione date NOT NULL,
	tipo_corde varchar2(50)
);


desc strumenti;
desc a_corda;
desc chitarre;
desc violini;


-- creazione indici 
CREATE INDEX ix_strumenti ON strumenti (azienda, prezzo, data_inserimento);
CREATE INDEX ix_chitarre ON chitarre (data_fabbricazione, tipo_corde);
CREATE INDEX ix_violini ON violini (data_fabbricazione, tipo_corde);


-- creazione PRIMARY KEYS
ALTER TABLE strumenti ADD CONSTRAINT pk_strumenti PRIMARY KEY (cod_strumento);
ALTER TABLE a_corda ADD CONSTRAINT pk_a_corda PRIMARY KEY (cod_a_corda);
ALTER TABLE chitarre ADD CONSTRAINT pk_chitarre PRIMARY KEY (cod_a_corda);
ALTER TABLE violini ADD CONSTRAINT pk_violini PRIMARY KEY (cod_a_corda);


-- creazione FOREIGN KEYS
ALTER TABLE chitarre ADD CONSTRAINT fk_chit_strum FOREIGN KEY (cod_strumento) REFERENCES strumenti (cod_strumento);
ALTER TABLE chitarre ADD CONSTRAINT fk_chit_a_corda FOREIGN KEY (cod_a_corda) REFERENCES a_corda (cod_a_corda);
ALTER TABLE violini ADD CONSTRAINT fk_viol_strum FOREIGN KEY (cod_strumento) REFERENCES strumenti (cod_strumento);
ALTER TABLE violini ADD CONSTRAINT fk_viol_a_corda FOREIGN KEY (cod_a_corda) REFERENCES a_corda (cod_a_corda);


-- aggiungo campo in tabella
ALTER TABLE strumenti ADD valutazione number(5);
ALTER TABLE chitarre ADD nome varchar2(50);
ALTER TABLE violini ADD nome varchar2(50);
desc strumenti;


-- inserimento con e senza specifica campi
INSERT INTO strumenti VALUES(7856, 'Ibanez', 350.50, to_date('01/09/2020','DD/MM/YYYY'), null, 4);
INSERT INTO strumenti VALUES(7958, 'Fender', 670.75, to_date('01/09/2020','DD/MM/YYYY'), to_date('20/09/2021','DD/MM/YYYY'), 5);
INSERT INTO strumenti (cod_strumento, azienda, prezzo, data_inserimento) 
                      VALUES (8455, 'Ibanez', 550.30, to_date('08/08/2019','DD/MM/YYYY'));
INSERT INTO strumenti (cod_strumento, azienda, prezzo, data_inserimento) 
                      VALUES (6789, 'Gibson', 824.50, to_date('19/08/2019','DD/MM/YYYY'));
    

INSERT INTO strumenti VALUES(3655, 'Pitteri', 1075.00, to_date('21/02/2019','DD/MM/YYYY'), to_date('03/02/2021','DD/MM/YYYY'), 3);
INSERT INTO strumenti VALUES(3989, 'Martino', 844.75, to_date('26/07/2020','DD/MM/YYYY'), null, null);
INSERT INTO strumenti (cod_strumento, azienda, prezzo, data_inserimento) 
                    VALUES (4522, 'Ibanez', 423.30, to_date('11/12/2019','DD/MM/YYYY'));


INSERT INTO a_corda VALUES(1001, 'chitarra acustica');
INSERT INTO a_corda VALUES(1002, 'chitarra elettrica');
INSERT INTO a_corda VALUES(1003, 'chitarra elettrica');
INSERT INTO a_corda VALUES(1004, 'chitarra elettrica');
INSERT INTO a_corda VALUES(2301, 'violino in acero');
INSERT INTO a_corda VALUES(2302, 'violino in acero');
INSERT INTO a_corda VALUES(2303, 'violino in betulla');


INSERT INTO chitarre VALUES(1001, 7856, to_date('05/07/2010','DD/MM/YYYY'), '5 corde nylon', 'Ibanez E-300');
INSERT INTO chitarre VALUES(1002, 7958, to_date('24/12/2012','DD/MM/YYYY'), '5 corde nylon', 'Stratocaster classic');
INSERT INTO chitarre VALUES(1003, 8455, to_date('10/08/2015','DD/MM/YYYY'), '5 corde nylon', 'Rock New-M');
INSERT INTO chitarre VALUES(1004, 6789, to_date('07/01/1998','DD/MM/YYYY'), '5 corde nylon', 'Les-Paul Vintage');


INSERT INTO violini VALUES(2301, 3655, to_date('15/11/2000','DD/MM/YYYY'), '4 corde nylon', 'Stradivari');
INSERT INTO violini VALUES(2302, 3989, to_date('05/07/2010','DD/MM/YYYY'), '4 corde nylon', 'Stradivari economico');
INSERT INTO violini VALUES(2303, 4522, to_date('05/07/2010','DD/MM/YYYY'), '4 corde nylon', 'Entry-level');


-- update di valore
UPDATE chitarre SET tipo_corde='5 corde metallo' WHERE cod_a_corda=1002;
UPDATE chitarre SET tipo_corde='5 corde metallo' WHERE cod_a_corda=1003;
UPDATE chitarre SET tipo_corde='5 corde metallo' WHERE cod_a_corda=1004;

UPDATE violini SET data_fabbricazione=to_date('15/02/2017','DD/MM/YYYY') WHERE cod_a_corda=2303;

SELECT * from chitarre;
SELECT * from violini;

-- delete di colonna
ALTER TABLE violini DROP COLUMN tipo_corde;

SELECT * from violini;


-- selezione di strumenti che non siano Ibanez
SELECT * from strumenti s WHERE s.azienda <> 'Ibanez';

-- tutti strumenti che sono Ibanez
SELECT * from strumenti s WHERE s.azienda = 'Ibanez';

-- tutti strumenti venduti (data vendita non nulla)
SELECT * from strumenti s WHERE s.data_vendita is not null;

-- ricerca tra gli strumenti a corda
SELECT * from a_corda ac 
WHERE ac.ds_tipo = 'chitarra acustica'
or ac.ds_tipo = 'violino in acero';

-- selezione NOT IN -> esclude le chitarre elettriche
SELECT * from a_corda c
WHERE c.ds_tipo not in ('chitarra elettrica');

-- selezione LIKE chitarre che iniziano con S
SELECT c.nome, c.tipo_corde, c.data_fabbricazione from chitarre c 
WHERE c.nome like 'S%';

-- selezione ordine alfabetico violini
 v.cod_a_corda, v.nome
from violini v
order by v.cod_a_corda desc;

-- selezione con UNIONE
SELECT c.cod_a_corda, c. nome
from chitarre c
UNION ALL
SELECT v.cod_a_corda, v.nome
from violini v;

-- selezione con UNIONE, INTERSEZIONE e LIKE di Ibanez
SELECT s.cod_strumento, ac.cod_a_corda, c.nome, v.nome, s.azienda, c.data_fabbricazione, v.data_fabbricazione, s.prezzo
from strumenti s
JOIN a_corda ac on s.cod_strumento = ac.cod_strumento
LEFT OUTER JOIN chitarre c on ac.cod_a_corda = c.cod_a_corda
LEFT OUTER JOIN violini v on ac.cod_a_corda = v.cod_a_corda;


CREATE SEQUENCE EMP_SEQ
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
