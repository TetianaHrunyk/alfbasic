CREATE TYPE tbl AS (
    meta VARCHAR[],
    col_names VARCHAR[],
    rws VARCHAR[]
);  


create table test (
    id serial primary key,
    tbls tbl
);

insert into test (tbls) values (ROW( 
                                    ARRAY['RQ1', 'DEP1', 'A', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Cena_Nákupní', 'Dodavatel', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[    
                                          'P1',	'5',	'100',	'D1',	'DEP1',	'A',	'RQ1', 
                                          'P2',	'4',	'200',	'D1',	'DEP1',	'A',	'RQ1',
                                          'P3',	'4',	'750',	'D1',	'DEP1',	'A',	'RQ1',
                                          'P8',	'1',	'300',	'D3',	'DEP1',	'A',	'RQ1'
                                         ]
                                )),
                                (ROW( 
                                    ARRAY['RQ2', 'DEP2', 'A', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Cena_Nákupní', 'Dodavatel', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[
                                          'P1',	'5',	'100',	'D1',	'DEP2',	'A',	'RQ2', 
                                          'P5',	'7',	'300',	'D2',	'DEP2',	'A',	'RQ2',
                                          'P8',	'4',	'300',	'D3',	'DEP2',	'A',	'RQ2',
                                          'P10',	'1',    '300',	'D3',	'DEP2',	'A',	'RQ2'
                                         ]
                                )), 
                                (ROW( 
                                    ARRAY['RQ3', 'DEP2', 'B', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Cena_Nákupní', 'Dodavatel', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[ 
                                          'P4',	'5',	'100',	'D1',	'DEP2',	'B',	'RQ3', 
                                          'P9',	'4',	'200',	'D3',	'DEP2',	'B',	'RQ3',
                                          'P7',	'4',	'800',	'D3',	'DEP2',	'B',	'RQ3'

                                         ]
                                ));
                                
select (tbls).meta, (tbls).col_names, (tbls).rws from test;
select array_position((tbls).col_names, 'Dodavatel') from test limit 1;



-------------------------Match tables by meta data+
CREATE OR REPLACE FUNCTION match_by_meta(t tbl, filter varchar) 
RETURNS tbl
AS $$
BEGIN
    IF (select * from unnest((t).meta) as elem where elem like filter) is not null THEN
        return t;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR # (
    LEFTARG = tbl,
    RIGHTARG = varchar,
    PROCEDURE = match_by_meta
);


----------------------------Getting rows by index+
CREATE OR REPLACE FUNCTION match_ind(t tbl, i int) 
RETURNS tbl
AS $$
DECLARE alen int;
DECLARE clen int;
BEGIN 
    select array_length((t).rws, 1) into alen;
    select array_length((t).col_names, 1) into clen;
        
    IF i > (alen/clen) THEN
        RAISE NOTICE 'Index out of range';
        RETURN NULL;
    else
        RETURN ((t).meta, (t).col_names, (t).rws[((i-1)*clen)+1:(i)*clen])::tbl;
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR @@ (
    LEFTARG = tbl,
    RIGHTARG = int,
    PROCEDURE = match_ind
);

-------------------------------Getting the columns+
CREATE OR REPLACE FUNCTION arithmetic_prog(a int, d int, n int) 
RETURNS INT[]
AS $$
DECLARE res INT[];
BEGIN
    n = n+1;
    WHILE n > 0 LOOP
        res = array_cat(res, ARRAY[a+(n-1)*d]);
        n = n-1;
    END LOOP;
    RETURN res;
END;
$$ LANGUAGE plpgsql;


--Returns self-defined type tbl
CREATE OR REPLACE FUNCTION match_col(t tbl, c varchar) 
RETURNS tbl
AS $$
DECLARE sep_ind int;
DECLARE col_num int;
DECLARE prog INT[];
DECLARE rws varchar[];
BEGIN 
    select array_position((t).col_names, c) into sep_ind; 
    IF sep_ind is not NULL THEN
        select array_length((t).col_names, 1) into col_num; 
        select arithmetic_prog(sep_ind, col_num, array_length((t).rws, 1)/col_num::int) into prog;
        
        select array_agg(col::varchar) from 
           (select ArrayOrder, col from unnest((t).rws) WITH ORDINALITY As T (col, ArrayOrder)) as f1 
            where (select * from unnest(prog) as u where u = ArrayOrder) is not null into rws;
        RETURN ((t).meta, ARRAY[c], rws)::tbl;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR @ (
    LEFTARG = tbl,
    RIGHTARG = varchar,
    PROCEDURE = match_col
);





--Return psql table
CREATE OR REPLACE FUNCTION match_col_meta(t tbl, c varchar) 
RETURNS table (col_name varchar,
               meta varchar[])
AS $$
DECLARE sep_ind int;
DECLARE col_num int;
DECLARE prog INT[];
BEGIN 
    select array_position((t).col_names, c) into sep_ind; 
    select array_length((t).col_names, 1) into col_num; 
    select arithmetic_prog(sep_ind, col_num, array_length((t).rws, 1)/col_num::int) into prog;
    IF sep_ind is not NULL THEN
        RETURN QUERY select * from (select col from 
                        (select ArrayOrder, col from unnest((t).rws) WITH ORDINALITY As T (col, ArrayOrder)) as f1 
                         where (select * from unnest(prog) as u where u = ArrayOrder) is not null) as f2  cross join (select (t).meta as meta) as f3;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR @+ (
    LEFTARG = tbl,
    RIGHTARG = varchar,
    PROCEDURE = match_col_meta
);


select tbls@'Dodavatel' from test;
select tbls@+'Dodavatel' from test;

-----------------------------Add a row to the table

CREATE OR REPLACE FUNCTION insert_row(t tbl, r varchar[]) 
RETURNS tbl
AS $$
BEGIN 
    IF t is NULL THEN
        RAISE NOTICE 'Table is empty';
        RETURN NULL;
    ELSIF array_length((t).col_names, 1) != array_length(r, 1) THEN
        RAISE NOTICE 'The row does not match the number of columns in the table';
        RETURN t;
    ELSE
        t.rws := t.rws || r;
        RETURN t;
        
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR | (
    LEFTARG = tbl,
    RIGHTARG = varchar[],
    PROCEDURE = insert_row
);


CREATE OR REPLACE FUNCTION add_row(tname varchar, r varchar[]) 
RETURNS boolean
AS $$
BEGIN
    
END;
$$ LANGUAGE plpgsql;


----------------------Separate by colums operator

CREATE OR REPLACE FUNCTION separate_by(t tbl, column varchar) 
RETURNS tbl[]
AS $$
DECLARE 
    tbls tbl[];
    t_help tbl;
    cols varchar[];
    col_len int;
    col_ind int;
    i int;
BEGIN 
    select array_position((t).col_names, column) into col_ind;
    IF col_ind is NULL THEN
        RETURN NULL;
    END IF;
    select t@column into t_help;    
    select array_length(t.col_names) into col_len;
    select array_agg(distinct(u) from (select unnest(t_help.rws) as u) as f1) into cols;
    i := 0;
    t_ind = t@@i;
        
    while t_ind is not null LOOP
        
    END LOOP;
            
END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR ^ (
    LEFTARG = tbl,
    RIGHTARG = varchar,
    PROCEDURE = separate_by
);













-------------------createFromRequest
CREATE OR REPLACE FUNCTION createFromRequest(tname varchar, SeparationColumn VARCHAR, MetaColumn VARCHAR) 
RETURNS tbl[]
AS $$
DECLARE sep_cols varchar[];
 tbls tbl[];
 i int;
 t tbl;
 t_ind tbl;
 t_sep_col tbl;
BEGIN 
    FOR t IN 
        select tbls from test
    LOOP
        i := 0;
        t_ind = t@@i;
        
        while t_ind is not null 
        LOOP
            t_sep_col = t_ind@SeparationColumn;
            
            IF t_sep_col.rws <@ sep_cols is false THEN
                sep_cols := sep_cols || array[ t_sep_col.rws];
                tbls := tbls || (ARRAY[SeparationColumn], ARRAY[t_ind.col_names], ARRAY[])::tbl;
            END IF;
            
            
            tbls[array_position(sep_cols, t_sep_col.rws[1])].rws = tbls[array_position(sep_cols, t_sep_col.rws[1])].rws || t_ind.rws;
            
            IF tbls[array_position(sep_cols, t_sep_col[1])].meta @> t_ind@MetaColumn is false THEN
                tbls[array_position(sep_cols, t_sep_col[1])].meta = tbls[array_position(sep_cols, t_sep_col[1])].meta || t_ind@MetaColumn;
            END IF;
            
            i := i+1
        END LOOP;
    
    END LOOP;
    RETURN tbls;
END;
$$ LANGUAGE plpgsql;









