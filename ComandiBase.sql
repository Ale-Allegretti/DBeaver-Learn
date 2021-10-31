-- creo la tabella libri
CREATE TABLE libri ( 
	codice_libro number(10) NOT NULL, 
	autore varchar2(100) NOT NULL, 
	casa_editrice varchar2(100) NOT NULL, 
	id_casa number(10) NOT NULL, 
	num_pagine number(10) NOT NULL 
);


-- creo la tabella caseEditrici
CREATE TABLE caseEditrici ( 
	id_casa number(10) NOT NULL, 
	codice_libro number(10) NOT NULL,
	nome_casa varchar2(100) NOT NULL, 
	indirizzo varchar2(100) NOT NULL, 
	cap number(10) NOT NULL, 
	iva number(10) 
);

-- comando per vedere la struttura delle tabelle e i tipi di dati
describe libri;
describe caseEditrici;



-- indice non univoco
CREATE INDEX ix_caseEditrici ON caseEditrici (nome_casa, indirizzo);

-- indice univoco
CREATE UNIQUE INDEX uk_caseEditrici  ON caseEditrici (iva);



-- definisco id_casa come primary key della tabella libri
ALTER TABLE libri ADD CONSTRAINT pk_cod_libro PRIMARY KEY (codice_libro);
ALTER TABLE caseEditrici ADD CONSTRAINT pk_id_casa PRIMARY KEY (id_casa);


-- definisco id_casa come foreign key della tabella caseEditrici
ALTER TABLE caseEditrici ADD CONSTRAINT fk_cod_libro FOREIGN KEY (codice_libro) REFERENCES libri (codice_libro);

-- aggiungo campo in tabella
ALTER TABLE libri ADD data_ins date;



--Tipologia di inserimento senza specifica dei campi da inserire
INSERT INTO libri VALUES(0001,'Poe','Mondadori', 1122, 350, to_date('01/01/2010','DD/MM/YYYY'));

--Tipologia di inserimento con specifica dei campi da inserire
INSERT INTO libri (codice_libro, autore, casa_editrice, id_casa, num_pagine, data_ins)
            VALUES(0002,'Calvino','Bompiani',1134, 129, null);


-- update di valore
UPDATE libri SET autore='Italo Calvino' WHERE codice_libro=0002;


-- selezione e selezione distinta
SELECT * FROM libri;
SELECT t.autore, t.casa_editrice FROM libri t

-- delete di tupla
DELETE FROM libri WHERE codice_libro=0002;


-- delete di colonna
ALTER TABLE libri DROP COLUMN data_ins;
















CREATE TABLE libri ( 
	codice_libro number(10) NOT NULL, 
	autore varchar2(100) NOT NULL, 
	casa_editrice varchar2(100) NOT NULL, 
	id_casa number(10) NOT NULL, 
	num_pagine number(10) 
);

CREATE TABLE poesie ( 
	codice_poesia number(10) NOT NULL, 
	autore varchar2(100) NOT NULL, 
	casa_editrice varchar2(100) NOT NULL, 
	id_casa number(10) NOT NULL, 
	num_pagine number(10) 
);

DESC libri;
DESC poesie;

INSERT INTO libri VALUES(0001,'Poe','Mondadori', 1122, 350);
INSERT INTO libri VALUES(0002,'Cortazar','Mondadori', 1122, null);
INSERT INTO libri VALUES(0003,'Leopardi','Bompiani', 2514, 125);
INSERT INTO libri VALUES(0004,'Palahniuk','Zanichelli', 0456, 275);
INSERT INTO libri VALUES(0005,'Poe','Zanichelli', 0456, 263);

INSERT INTO poesie VALUES(0024,'Leopardi','Bompiani', 2514, 60);
INSERT INTO poesie VALUES(0034,'Bukowski','Bompiani', 2514, 105);
INSERT INTO poesie VALUES(0034,'Bukowski','Zanichelli', 0456, 54);



select * from libri;
select * from poesie;

-- tutte i libri che non siano Mondadori
select * from libri l where l.casa_editrice <> 'Mondadori';

-- tutti i libri Mondadori
select * from libri l where l.casa_editrice = 'Mondadori';

-- selezione codice > 3
select * from libri l where l.codice_libro > 3;

-- selezione in OR
select * from libri l 
where l.autore = 'Poe'
or casa_editrice = 'Mondadori';

-- selezione in OR NOT
select * from libri l 
where l.autore = 'Alighieri'
or not casa_editrice = 'Mondadori';

-- selezione NOT IN
select * from libri l 
where l.casa_editrice not in ('Mondadori');

-- selezione pagine NULL
select * from libri l 
where l.num_pagine is null;

-- selezione LIKE autori che iniziano con P
select * from libri l 
where l.autore like 'P%';

-- selezione ordine alfabetico autore
select l.autore, l. casa_editrice, l.num_pagine 
from libri l
order by l.autore asc;


-- selezione con UNIONE
select l.autore, l. casa_editrice, l.num_pagine 
from libri l
union
select p.autore, p. casa_editrice, p.num_pagine 
from poesie p;


-- selezione con INTERSEZIONE
select l.autore
from libri l
intersect
select p.autore
from poesie p;


-- selezione con INNER JOIN
select *
from libri l


-- selezione con OUTER
select *
from libri l
left outer join poesie p
on l.autore = p.autore;

-- selezione CONTEGGIO LIBRI + POESIE divisi per AUTORE
select t.autore, count(*) from (
select l.autore
from libri l
union all
select p.autore
from poesie p) t
group by t.autore;