CREATE TYPE tbl AS (
    meta VARCHAR[],
    col_names VARCHAR[],
    cols VARCHAR[][]
);  


create table test (
    id serial primary key,
    tbls tbl
);

insert into test (tbls) values (ROW( 
                                    ARRAY['RQ1', 'DEP1', 'A', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Dodavatel', 'Cena _Nákupní', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[    
                                          ARRAY['P2', 'P3', 'P8', 'P5'], 
                                          ARRAY['5', '4', '4', '1'],
                                          ARRAY['D1', 'D1', 'D1', 'D3'],
                                          ARRAY['100', '200', '750', '300'],
                                          ARRAY['DEP1', 'DEP1', 'DEP1', 'DEP1'],
                                          ARRAY['A', 'A', 'A', 'A'],
                                          ARRAY['RQ1', 'RQ1', 'RQ1', 'RQ1']
                                         ]
                                )),
                                (ROW( 
                                    ARRAY['RQ2', 'DEP2', 'A', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Dodavatel', 'Cena _Nákupní', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[
                                          ARRAY['P1', 'P5', 'P8', 'P10'], 
                                          ARRAY['5', '7', '4', '1'],
                                          ARRAY['D1', 'D2', 'D3', 'D3'],
                                          ARRAY['100', '300', '300', '300'],
                                          ARRAY['DEP2', 'DEP2', 'DEP2', 'DEP2'],
                                          ARRAY['A', 'A', 'A', 'A'],
                                          ARRAY['RQ2', 'RQ2', 'RQ2', 'RQ2']
                                         ]
                                )), 
                                (ROW( 
                                    ARRAY['RQ3', 'DEP2', 'B', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Dodavatel', 'Cena _Nákupní', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[ 
                                          ARRAY['P4', 'P9', 'P7'], 
                                          ARRAY['5', '4', '4'],
                                          ARRAY['D1', 'D1', 'D3'],
                                          ARRAY['100', '200', '800'],
                                          ARRAY['DEP1', 'DEP3', 'DEP3'],
                                          ARRAY['B', 'B', 'B'],
                                          ARRAY['RQ3', 'RQ3', 'RQ3']
                                         ]
                                ));
                                
select (tbls).meta, (tbls).col_names, (tbls).rws from test;
select array_position((tbls).col_names, 'Dodavatel') from test limit 1;


----------------flatten 2D array to 1D array
CREATE OR REPLACE FUNCTION flatten(arr varchar[][]) 
RETURNS varchar[]
AS $$
DECLARE res VARCHAR[];
DECLARE elem VARCHAR[];
BEGIN 
   FOREACH elem SLICE 1 IN ARRAY arr
   LOOP
      select array_cat(res, elem) into res;
   END LOOP;
   RETURN res;
END;
$$ LANGUAGE plpgsql;





-------------------------Match tables by meta data
CREATE OR REPLACE FUNCTION match_by_meta(filters varchar[]) 
RETURNS SETOF varchar
AS $$
DECLARE cols VARCHAR[][];
DECLARE meta VARCHAR[];
DECLARE filter VARCHAR;
DECLARE meta_item VARCHAR;
BEGIN
    FOR meta, cols IN
        SELECT (tbls).meta, (tbls).cols from test
    LOOP
        IF meta @> filters THEN
            RETURN NEXT cols;
        ELSE
            FOREACH filter IN ARRAY filters LOOP
                FOREACH meta_item IN ARRAY meta LOOP
                    IF meta_item LIKE filter THEN
                        
                        RETURN NEXT cols;
                        
                    END IF;  
                END LOOP;
            END LOOP;    
        END IF;        
    END LOOP;

END;
$$ LANGUAGE plpgsql;



----------------------------Getting rows by index
CREATE OR REPLACE FUNCTION match_row(t tbl, i integer) 
RETURNS SETOF varchar
AS $$
DECLARE cols VARCHAR[];
DECLARE alen int;
BEGIN 
    select array_length((t).cols, 2) into alen;
    IF i > alen THEN
        RAISE NOTICE 'Index out of range';
        RETURN NEXT array[Null];
    else
        SELECT (t).cols from test  into cols;
        RETURN NEXT flatten(cols[:][i:i]);
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR @@ (
    LEFTARG = tbl,
    RIGHTARG = int,
    PROCEDURE = match_row
);

-------------------------------Getting the columns
CREATE OR REPLACE FUNCTION match_col(t tbl, c varchar) 
RETURNS SETOF varchar
AS $$
DECLARE cols VARCHAR[];
DECLARE sep_ind int;
BEGIN 
    select array_position((t).col_names, c) into sep_ind; 
    IF sep_ind THEN
        SELECT (t).cols from test  into cols;
        RETURN NEXT flatten(cols[sep_ind:sep_ind]);
    ELSE
        RETURN NEXT ARRAY[NULL];
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR @ (
    LEFTARG = tbl,
    RIGHTARG = varchar,
    PROCEDURE = match_col
);



-------------------createFromRequest
CREATE OR REPLACE FUNCTION createFromRequest(SeparationColumn VARCHAR) 
RETURNS tbl[]
AS $$
DECLARE tbls tbl[];
BEGIN  
    
END;
$$ LANGUAGE plpgsql;















