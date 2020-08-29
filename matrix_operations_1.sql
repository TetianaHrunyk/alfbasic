CREATE TYPE tbl AS (
    meta VARCHAR[],
    col_names VARCHAR[],
    rws VARCHAR[][]
);  


create table test (
    id serial primary key,
    tbls tbl
);

insert into test (tbls) values (ROW( 
                                    ARRAY['RQ1', 'DEP1', 'A', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Cena_Nákupní', 'Dodavatel', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[    
                                          ARRAY['P1',	'5',	'100',	'D1',	'DEP1',	'A',	'RQ1'], 
                                          ARRAY['P2',	'4',	'200',	'D1',	'DEP1',	'A',	'RQ1'],
                                          ARRAY['P3',	'4',	'750',	'D1',	'DEP1',	'A',	'RQ1'],
                                          ARRAY['P8',	'1',	'300',	'D3',	'DEP1',	'A',	'RQ1']
                                         ]
                                )),
                                (ROW( 
                                    ARRAY['RQ2', 'DEP2', 'A', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Cena_Nákupní', 'Dodavatel', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[
                                          ARRAY['P1',	'5',	'100',	'D1',	'DEP2',	'A',	'RQ2'], 
                                          ARRAY['P5',	'7',	'300',	'D2',	'DEP2',	'A',	'RQ2'],
                                          ARRAY['P8',	'4',	'300',	'D3',	'DEP2',	'A',	'RQ2'],
                                          ARRAY['P10',	'1',    '300',	'D3',	'DEP2',	'A',	'RQ2']
                                         ]
                                )), 
                                (ROW( 
                                    ARRAY['RQ3', 'DEP2', 'B', 'Ready'],
                                    ARRAY['ProduktID', 'Množství', 'Cena_Nákupní', 'Dodavatel', 'Oddělení', 'Rozpočtová_kategorie', 'RQID'],
                                    ARRAY[ 
                                          ARRAY['P4',	'5',	'100',	'D1',	'DEP2',	'B',	'RQ3'], 
                                          ARRAY['P9',	'4',	'200',	'D3',	'DEP2',	'B',	'RQ3'],
                                          ARRAY['P7',	'4',	'800',	'D3',	'DEP2',	'B',	'RQ3']

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
CREATE OR REPLACE FUNCTION match_by_meta(t tbl, filters varchar[]) 
RETURNS SETOF varchar
AS $$
DECLARE filter VARCHAR;
DECLARE meta_item VARCHAR;
BEGIN
        IF (t).meta @> filters THEN
            RETURN NEXT (t).rws;
        ELSE
            FOREACH filter IN ARRAY filters LOOP
                FOREACH meta_item IN ARRAY (t).meta LOOP
                    IF meta_item LIKE filter THEN
                        
                        RETURN NEXT (t).rws;
                        
                    END IF;  
                END LOOP;
            END LOOP;    
        END IF;        


END;
$$ LANGUAGE plpgsql;

CREATE OPERATOR # (
    LEFTARG = tbl,
    RIGHTARG = varchar[],
    PROCEDURE = match_by_meta
);


----------------------------Getting rows by index
CREATE OR REPLACE FUNCTION match_row(t tbl, i integer) 
RETURNS SETOF varchar
AS $$
DECLARE alen int;
BEGIN 
    select array_length((t).rws, 1) into alen;
    IF i > alen THEN
        RAISE NOTICE 'Index out of range';
        RETURN NEXT array[Null];
    else
        RETURN NEXT flatten((t).rws[i:i]);
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
DECLARE sep_ind int;
BEGIN 
    select array_position((t).col_names, c) into sep_ind; 
    IF sep_ind is not NULL THEN
        RETURN NEXT flatten((t).rws[:][sep_ind:sep_ind]);
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
CREATE OR REPLACE FUNCTION createFromRequest(SeparationColumn VARCHAR, MetaColumn VARCHAR) 
RETURNS tbl[]
AS $$
DECLARE res_tbls tbl[];
DECLARE metas VARCHAR[];
DECLARE t tbl;
DECLARE r VARCHAR[];
DECLARE i int := 1;
DECLARE sep_ind int;
DECLARE elem_ind int;
DECLARE meta_ind int;
BEGIN  
    FOR t IN 
        SELECT tbls from test
    LOOP
        select array_position((t).col_names, SeparationColumn) into sep_ind; 
        select array_position((t).col_names, MetaColumn) into meta_ind;
        
        FOREACH r IN ARRAY (t).rws LOOP
            select array_position(metas, r[sep_ind]) into elem_ind; 
            
            IF elem_ind is NULL THEN
                metas = array_cat(metas, r[sep_ind:sep_ind]);
                res_tbls = array_cat(res_tbls, (ROW( 
                                    ARRAY['PO'||i::varchar, r[sep_ind]],
                                    (t).col_names,
                                    ARRAY[    ]  ))::tbl);
            END IF;
            
            
            IF not (res_tbls[elem_ind]).meta @> r[meta_ind:meta_ind] THEN
                SELECT array_cat((res_tbls[elem_ind]).meta, r[meta_ind:meta_ind]);
            END IF;
            
            SELECT array_cat((res_tbls[elem_ind]).rws, r);
            
        END LOOP;       
        
    END LOOP;
    RETURN res_tbls;
END;
$$ LANGUAGE plpgsql;









