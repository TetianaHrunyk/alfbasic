--------------------------------------------------TABLES DEFINITION----------------------------------------------------------------

--For ensuring referential integrity we would like to store all the tenants.
CREATE OR REPLACE DATABASE alfbasic0;

CREATE TABLE case_types(
	type_id SERIAL PRIMARY KEY,
	CaseType VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO case_types(CaseType) VALUES ('budget'),
	('statistics'),
	('logistics'),
	('employees'),
	('salary');

CREATE TABLE stages (
	stage_id SERIAL PRIMARY KEY,
	stage VARCHAR(30) UNIQUE NOT NULL,
	stage_translation VARCHAR(30)
);

INSERT INTO stages(stage, stage_translation) VALUES ('draft', 'vytvářeno'),
	('task', 'úkol'),
	('ready', 'platné'),
	('delete', 'zrušeno'),	
	('close', 'ukončeno');

CREATE TABLE udim1 (
	udim_id SERIAL PRIMARY KEY,
	dname VARCHAR(30) UNIQUE NOT NULL
);

INSERT INTO udim1(dname) VALUES ('public'), ('protected'), ('private');

CREATE TABLE udim2 (
	udim_id SERIAL PRIMARY KEY,
	dname VARCHAR(30) UNIQUE NOT NULL
);

INSERT INTO udim2(dname) VALUES ('text_doc'), ('presenation'), ('table'), ('diagram'), ('sketech');

CREATE TABLE udim3 (
	udim_id SERIAL PRIMARY KEY,
	dname VARCHAR(30) UNIQUE NOT NULL
);

INSERT INTO udim3(dname) VALUES ('very important'), ('importnat'), ('neutral'), ('not important');

CREATE TABLE acty (
	acta_id SERIAL PRIMARY KEY,
	acta VARCHAR(60) UNIQUE NOT NULL
);

COPY acty(acta) FROM '/home/tania/Code/alf/acty.csv' WITH (format csv);

CREATE TABLE tenants (
	tenant_id SERIAL PRIMARY KEY,
	tenant VARCHAR(100) NOT NULL UNIQUE
);

COPY tenants(tenant) FROM '/home/tania/Code/alf/tenants.csv' WITH (format csv);

CREATE TABLE alfbasic (
	CaseNumber SERIAL PRIMARY KEY,	
	tenant VARCHAR(100) REFERENCES tenants(tenant) ON DELETE CASCADE ON UPDATE CASCADE,
	CaseType VARCHAR(30) REFERENCES case_types(CaseType) ON DELETE CASCADE ON UPDATE CASCADE,
	acta VARCHAR(60) REFERENCES acty(acta) ON DELETE CASCADE ON UPDATE CASCADE,
	stage VARCHAR(30) REFERENCES stages(stage) ON DELETE CASCADE ON UPDATE CASCADE,
	udim1 VARCHAR(30) REFERENCES udim1(dname) ON DELETE CASCADE ON UPDATE CASCADE,
	udim2 VARCHAR(30) REFERENCES udim2(dname) ON DELETE CASCADE ON UPDATE CASCADE,
	udim3 VARCHAR(30) REFERENCES udim3(dname) ON DELETE CASCADE ON UPDATE CASCADE,
	bstream BYTE ARRAY,
	file_type VARCHAR(10),
	svector tsvector,
	attachment BOOLEAN default false,
	asize int default 0
);
--Run fill_alfbasic.py to fill the table with random values
--To ensure reproducibility of the rest of the script, do not modify tenants.csv and acts.csv






---------------------------------------------GROUPS DEFINITION-------------------------------------------------------------
--Each tenant, act, CaseType, stage, etc. should have its own group
--In total, there will be #tenants+#acts+#CaseType+#stages groups
--Users will be assigned to either group in each cathegory
CREATE GROUP fog_tenant_group;

CREATE GROUP bells_acta_group;
CREATE GROUP coast_acta_group;

CREATE GROUP budget_ctype_group;
CREATE GROUP statistics_ctype_group;

CREATE GROUP draft_stage_group;
CREATE GROUP task_stage_group;

CREATE GROUP udim1_public_group;
CREATE GROUP udim2_table_group;
CREATE GROUP udim3_neutral_group;

--Varianta 0: No RLS=>run the commands as user postgres

--Varianta 1: RLS na acta a stages => set the role to one of these users and run the comands

CREATE USER abells_sdraft_u;
ALTER GROUP bells_acta_group ADD USER abells_sdraft_u;
ALTER GROUP draft_stage_group ADD USER abells_sdraft_u;

CREATE USER acoast_stask_u;
ALTER GROUP coast_acta_group ADD USER acoast_stask_u;
ALTER GROUP task_stage_group ADD USER acoast_stask_u;

CREATE USER abells_sdraft_u;
ALTER GROUP bells_acta_group ADD USER abells_sdraft_u;
ALTER GROUP draft_stage_group ADD USER abells_sdraft_u;

--Varianta 2: RLS na tenant a acta => set the role to one of these users and run the comands
CREATE USER tfog_abells_u;
ALTER GROUP fog_tenant_group ADD USER tfog_abells_u;
ALTER GROUP bells_acta_group ADD USER tfog_abells_u;

CREATE USER tfog_acoast_u;
ALTER GROUP fog_tenant_group ADD USER tfog_acoast_u;
ALTER GROUP coast_acta_group ADD USER tfog_acoast_u;

--Varianta 3: RLS na tenant, acta, CaseType, stage => set the role to one of these users and run the comands
CREATE USER tfog_abells_cbudget_sdraft_u;
ALTER GROUP fog_tenant_group ADD USER tfog_abells_cbudget_sdraft_u;
ALTER GROUP bells_acta_group ADD USER tfog_abells_cbudget_sdraft_u;
ALTER GROUP budget_ctype_group ADD USER tfog_abells_cbudget_sdraft_u;
ALTER GROUP draft_stage_group ADD USER tfog_abells_cbudget_sdraft_u;

CREATE USER tfog_acoast_cbudget_sdraft_u;
ALTER GROUP fog_tenant_group ADD USER tfog_acoast_cbudget_sdraft_u;
ALTER GROUP coast_acta_group ADD USER tfog_acoast_cbudget_sdraft_u;
ALTER GROUP budget_ctype_group ADD USER tfog_acoast_cbudget_sdraft_u;
ALTER GROUP draft_stage_group ADD USER tfog_acoast_cbudget_sdraft_u;

CREATE USER tfog_acoast_cstatistics_stask_u;
ALTER GROUP fog_tenant_group ADD USER tfog_acoast_cstatistics_stask_u;
ALTER GROUP coast_acta_group ADD USER tfog_acoast_cstatistics_stask_u;
ALTER GROUP statistics_ctype_group ADD USER tfog_acoast_cstatistics_stask_u;
ALTER GROUP task_stage_group ADD USER tfog_acoast_cstatistics_stask_u;

CREATE USER tfog_admin;
ALTER GROUP fog_tenant_group ADD USER tfog_admin;


GRANT SELECT ON TABLE alfbasic TO fog_tenant_group, bells_acta_group, coast_acta_group, budget_ctype_group, statistics_ctype_group, draft_stage_group, task_stage_group, udim1_public_group, udim2_table_group, udim3_neutral_group;
GRANT INSERT, UPDATE ON TABLE alfbasic TO fog_tenant_group, bells_acta_group, coast_acta_group, budget_ctype_group, statistics_ctype_group, draft_stage_group, task_stage_group, udim1_public_group, udim2_table_group, udim3_neutral_group;

--Varianta 4: RLS na RLS na tenant, acta, CaseType, stage, udim1, udim2, udim3
CREATE USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP fog_tenant_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP coast_acta_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP budget_ctype_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP draft_stage_group ADD USER tfog_acoast_cbudget_sdraft_u;
ALTER GROUP udim1_public_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP udim2_table_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP udim3_neutral_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;




---------------------------------------POLICIES DEFINITION------------------------------------------------------------
ALTER TABLE alfbasic ENABLE ROW LEVEL SECURITY;
--NOTE: at least one policy in each query has to be PERMISSIVE. Depending on the application needs,
--the policy that is permissive has to be modified. The permissive policy has to be the one that
--occurrs in all the queries. In this case, policies on acta are permissive. Others are restrictive.

CREATE POLICY fog_tenant_policy ON alfbasic AS  RESTRICTIVE TO fog_tenant_group
    USING ('fog_tenant_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.tenant = 'fog');

CREATE POLICY bells_acta_policy ON alfbasic TO bells_acta_group
    USING ('bells_acta_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.acta = 'bells');

CREATE POLICY coast_acta_policy ON alfbasic  TO coast_acta_group
    USING ('coast_acta_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.acta = 'coast');

CREATE POLICY budget_ctype_policy ON alfbasic AS  RESTRICTIVE TO budget_ctype_group
    USING ('budget_ctype_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.casetype = 'budget');

CREATE POLICY statistics_ctype_policy ON alfbasic AS  RESTRICTIVE TO statistics_ctype_group
    USING ('statistics_ctype_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.casetype = 'statistics');

CREATE POLICY draft_stage_policy ON alfbasic  AS  RESTRICTIVE TO draft_stage_group
    USING ('draft_stage_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.stage = 'draft');

CREATE POLICY task_stage_policy ON alfbasic AS  RESTRICTIVE TO task_stage_group
    USING ('task_stage_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.stage = 'task');

CREATE POLICY udim1_public_policy ON alfbasic AS  RESTRICTIVE TO udim1_public_group
    USING ('udim1_public_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.udim1 = 'public');

CREATE POLICY udim2_table_policy ON alfbasic AS  RESTRICTIVE TO udim2_table_group
    USING ('udim2_table_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.udim2 = 'table');

CREATE POLICY udim3_neutral_policy ON alfbasic AS  RESTRICTIVE TO udim3_neutral_group
    USING ('udim3_neutral_group' IN (
		SELECT rolname 
		FROM pg_user JOIN pg_auth_members ON (pg_user.usesysid=pg_auth_members.member) 
					 JOIN pg_roles ON (pg_roles.oid=pg_auth_members.roleid)
	    WHERE pg_user.usename=current_user
	) AND alfbasic.udim3 = 'neutral');

CREATE INDEX tenant_index ON alfbasic(tenant);
CREATE INDEX acty_index ON alfbasic(acta);
CREATE INDEX stage_index ON alfbasic(stage);
CREATE INDEX casetype_index ON alfbasic(casetype);





-----------------------------------------------------------ATTACHMENTS---------------------------------------------------------------------
--Table for storing large files that do not require extremely high level of security
CREATE TABLE attachments (
	CaseNumber INTEGER PRIMARY KEY REFERENCES alfbasic(CaseNumber),
	file_oid oid,
	mod_date TIMESTAMP default now(),
	path VARCHAR(150),
	meta1 VARCHAR(30) default 'xls',
	meta2 VARCHAR(30) default 'file_creator',
	meta3 VARCHAR(30) default 'last_modified_by'
);
GRANT SELECT ON TABLE attachments TO fog_tenant_group, bells_acta_group, coast_acta_group, budget_ctype_group, statistics_ctype_group, draft_stage_group, task_stage_group, udim1_public_group, udim2_table_group, udim3_neutral_group;
--PostgreSQL documentation on working with large files: https://www.postgresql.org/docs/10/lo-interfaces.html


CREATE OR REPLACE FUNCTION insert_attachment(path text, cn integer) RETURNS boolean
AS $$ 
BEGIN
    IF cn NOT IN (SELECT CaseNumber FROM attachments) THEN
	    INSERT INTO attachments(CaseNumber, path, file_oid) VALUES(cn, path, lo_import(path));
	END IF; 
	UPDATE alfbasic SET attachment = true WHERE CaseNumber = cn;
	UPDATE alfbasic SET file_type = get_file_type(path) WHERE CaseNumber = cn;   
RETURN true;
END;
$$ LANGUAGE plpgsql;
--select * from insert_files_into_alfbasic('/home/tania/Code/alf/data/report1.docx', 100);
--For retriving a file a function int lo_export() has to be used. 
--In order to use lo_export() server-side, user has to be a  superuser, so in our case we can only use client-side lo_export().




------------------------------------------FUNCTION PREPARING DATA FOR SEARCH VECTORS----------------------------------
CREATE  OR REPLACE FUNCTION read_excel_file(path text)
  RETURNS varchar
AS $$
    
    import re
    import sys
    sys.path.insert(0, '/home/tania/.local/lib/python3.6/site-packages')
    import os
    current_dir = os.getcwd()
    try:
        import pandas as pd
        imported = True
    except:
        imported = False
    while len(os.getcwd()) > 1:
        os.chdir("..")
    if not imported:
        try:
            import pandas as pd
        except:
            os.chdir(current_dir)  
            exit()      
    xls = pd.ExcelFile(path)
    
    excel_csv_tot = ""
    for sheet in xls.sheet_names:
        excel = pd.read_excel(path, separator = " ", sheet_name=sheet)
        excel.dropna(how="all", axis = 1, inplace=True)
        excel.dropna(how="all", axis = 0, inplace=True)
        excel_csv = excel.to_csv(index=False, line_terminator=" ")
        excel_csv=excel_csv.lower()
#        excel_csv=excel_csv.replace('"', " ")
        excel_csv = re.sub(r",+", " ", excel_csv)
        excel_csv = re.sub(r"\ +", " ", excel_csv)
        excel_csv=excel_csv.strip()
        excel_csv_tot += excel_csv
    os.chdir(current_dir)
   
    return excel_csv_tot

$$ LANGUAGE plpython3u;

CREATE  OR REPLACE FUNCTION read_excel_file_from_bin(f BYTEA)
  RETURNS varchar
AS $$
    
    import re
    import sys
    sys.path.insert(0, '/home/tania/.local/lib/python3.6/site-packages')
    import os
    current_dir = os.getcwd()
    try:
        import pandas as pd
        imported = True
    except:
        imported = False
    while len(os.getcwd()) > 1:
        os.chdir("..")
    if not imported:
        try:
            import pandas as pd
        except:
            os.chdir(current_dir)  
            exit()      
    xls = pd.ExcelFile(f)
    
    excel_csv_tot = ""
    for sheet in xls.sheet_names:
        excel = pd.read_excel(f, separator = " ", sheet_name=sheet)
        excel.dropna(how="all", axis = 1, inplace=True)
        excel.dropna(how="all", axis = 0, inplace=True)
        excel_csv = excel.to_csv(index=False, line_terminator=" ")
        excel_csv=excel_csv.lower()
#        excel_csv=excel_csv.replace('"', " ")
        excel_csv = re.sub(r",+", " ", excel_csv)
        excel_csv = re.sub(r"\ +", " ", excel_csv)
        excel_csv=excel_csv.strip()
        excel_csv_tot += excel_csv
    os.chdir(current_dir)
   
    return excel_csv_tot

$$ LANGUAGE plpython3u;




-----------------------------------LOADING FILES DIRECTLY INTO ALFBASIC-----------------------------------
--Python function for reading excel
--Before using Python in PostgreSQL:
--  In Ubuntu shell: sudo apt-get install postgresql-plpython3-10
--  From PostgreSQL client: CREATE EXTENSION plpython3u;

CREATE  OR REPLACE FUNCTION get_bin_array(path text)
  RETURNS bytea
AS $$
    import os, sys
    current_dir = os.getcwd()
    sys.path.insert(0, '/')
    try:
        try: 
            f = open(path, mode = "rb")
        except:    
            while len(os.getcwd()) > 1:
                os.chdir("..")
            f = open(path, mode = "rb")
        stream = f.read()
        os.chdir(current_dir)
        f.close()
    except:
        os.chdir(current_dir)
    os.chdir(current_dir)
    return stream
$$ LANGUAGE plpython3u;




CREATE  OR REPLACE FUNCTION get_file_type(path text)
  RETURNS varchar
AS $$
    i = -1
    while path[i] != ".":
        i-=1
    return path[i+1:]
$$ LANGUAGE plpython3u;




--The following function supposes that the metadata on the file already is in the alfbasic table.
--There two possible scenarios for the future:
--      1.First load the metadata and then call a trigger to load the file
--      2.(probably better) Create a function that would load the metadata and call the load_file() function inside of it
CREATE OR REPLACE FUNCTION load_file(path TEXT, CN INTEGER) 
RETURNS boolean
AS $$
DECLARE read_file BYTEA;
BEGIN 
    SELECT get_bin_array(path) INTO read_file;   
    UPDATE alfbasic SET bstream = read_file  WHERE CaseNumber=CN;
    UPDATE alfbasic SET file_type = get_file_type(path) WHERE CaseNumber=CN;
    UPDATE alfbasic SET svector = to_tsvector(read_excel_file(path)) WHERE CaseNumber=CN;
    UPDATE alfbasic SET asize = octet_length(read_file) WHERE CaseNumber=CN;
    RETURN true;
END;
$$ LANGUAGE plpgsql;


------------------BIN ONLY
CREATE OR REPLACE FUNCTION load_file_from_bin(arr BYTEA, CN INTEGER) 
RETURNS boolean
AS $$
BEGIN 
    UPDATE alfbasic SET bstream = arr  WHERE CaseNumber=CN;
    UPDATE alfbasic SET file_type = 'xls' WHERE CaseNumber=CN;
    UPDATE alfbasic SET asize = octet_length(arr) WHERE CaseNumber=CN;
    RETURN true;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION load_file_from_bin_with_ts(arr BYTEA, CN INTEGER) 
RETURNS boolean
AS $$
BEGIN 
    UPDATE alfbasic SET bstream = arr  WHERE CaseNumber=CN;
    UPDATE alfbasic SET file_type = 'xls' WHERE CaseNumber=CN;
    UPDATE alfbasic SET asize = octet_length(arr) WHERE CaseNumber=CN;
    UPDATE alfbasic SET svector = to_tsvector(read_excel_file_from_bin(arr)) WHERE CaseNumber=CN;
    RETURN true;
END;
$$ LANGUAGE plpgsql;




-----------------------------------EXPORTING FILES STORED DIRECTLY IN ALFBASIC-----------------------------------
    

CREATE  OR REPLACE FUNCTION export_file_helper(p varchar, file_type varchar, casenumber int, stream bytea)
RETURNS BOOLEAN
AS $$
    global p
    global file_type
    global casenumber
    global stream
    import os, sys, stat
    current_dir = os.getcwd()
    try:
        try:
            path_to_new_file = p+'/'+str(casenumber)+"."+file_type
            if not os.path.isfile(path_to_new_file):
                os.mknod(path_to_new_file)
            os.system('chmod 777 '+path_to_new_file)
            f = open(path_to_new_file, "wb+")
        except:
            while len(os.getcwd()) > 1:
                os.chdir("..") 
            path_to_new_file = p+'/'+str(casenumber)+"."+file_type
            if not os.path.isfile(path_to_new_file):
                os.mknod(path_to_new_file)
            os.system('chmod 777 '+path_to_new_file)
            f = open(path_to_new_file, "wb+")
        f.write(stream)
        f.close()
    except:
        sys.exit("Exit from export_file_helper")
    finally:
        os.chdir(current_dir)
    
    return True

$$ LANGUAGE plpython3u;    




CREATE OR REPLACE FUNCTION export_file(CN INTEGER, p VARCHAR) 
RETURNS boolean
AS $$
DECLARE ft VARCHAR;
        stream bytea;
        res BOOLEAN;
BEGIN    
    SELECT file_type FROM alfbasic WHERE casenumber = CN INTO ft;
    SELECT bstream FROM alfbasic WHERE casenumber = CN INTO stream;
    SELECT * FROM export_file_helper(p, ft, CN, stream) INTO res;
    RETURN res;
END;
$$ LANGUAGE plpgsql;


-----------------------------INSERT TEST DATA INTO ALFBASIC--------------------------------
CREATE OR REPLACE FUNCTION insert_file_into_alfbasic(path text, mod_val integer) RETURNS boolean
AS $$ 
DECLARE r INTEGER;
BEGIN
	FOR r IN
        SELECT CaseNumber FROM alfbasic WHERE mod(CaseNumber, mod_val) = 0
    LOOP
		IF r NOT IN (SELECT CaseNumber FROM alfbasic WHERE svector IS NOT NULL) THEN
	        PERFORM load_file(path, r);
		END IF;    
	END LOOP;
RETURN true;
END;
$$ LANGUAGE plpgsql;

----------------BIN ONLY
CREATE OR REPLACE FUNCTION insert_bin_into_alfbasic(arr BYTEA, mod_val integer) RETURNS boolean
AS $$ 
DECLARE r INTEGER;
BEGIN
	FOR r IN
        SELECT CaseNumber FROM alfbasic WHERE mod(CaseNumber, mod_val) = 0
    LOOP
		IF r NOT IN (SELECT CaseNumber FROM alfbasic WHERE svector IS NOT NULL) THEN
	        PERFORM load_file_from_bin(arr, r);
		END IF;    
	END LOOP;
RETURN true;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_bin_ts_into_alfbasic(arr BYTEA, mod_val integer) RETURNS boolean
AS $$ 
DECLARE r INTEGER;
BEGIN
	FOR r IN
        SELECT CaseNumber FROM alfbasic WHERE mod(CaseNumber, mod_val) = 0
    LOOP
		IF r NOT IN (SELECT CaseNumber FROM alfbasic WHERE svector IS NOT NULL) THEN
	        PERFORM load_file_from_bin_with_ts(arr, r) ;
		END IF;    
	END LOOP;
RETURN true;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION add_ts_vectors() 
RETURNS boolean
AS $$
DECLARE CN INTEGER;
arr BYTEA;
BEGIN 
    FOR CN IN
        SELECT CaseNumber FROM alfbasic WHERE bstream is not null and svector is null
    LOOP
        SELECT bstream FROM alfbasic WHERE CaseNumber=CN INTO arr;
        UPDATE alfbasic SET file_type = 'xls' WHERE CaseNumber=CN;
        UPDATE alfbasic SET asize = octet_length(arr) WHERE CaseNumber=CN;   
	END LOOP;
RETURN true;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_ts_vectors_by_cn(mod_val int) 
RETURNS boolean
AS $$
DECLARE CN INTEGER;
arr BYTEA;
BEGIN 
    FOR CN IN
        SELECT CaseNumber FROM alfbasic WHERE CaseNumber%mod_val = 0
    LOOP
        SELECT bstream FROM alfbasic WHERE CaseNumber=CN INTO arr;
        UPDATE alfbasic SET file_type = 'xls' WHERE CaseNumber=CN;
        UPDATE alfbasic SET asize = octet_length(arr) WHERE CaseNumber=CN;   
	END LOOP;
RETURN true;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION add_ts_vector(CN int) 
RETURNS boolean
AS $$
DECLARE CN INTEGER;
arr BYTEA;
BEGIN 
    SELECT bstream FROM alfbasic WHERE CaseNumber=CN INTO arr;
    UPDATE alfbasic SET file_type = 'xls' WHERE CaseNumber=CN;
    UPDATE alfbasic SET asize = octet_length(arr) WHERE CaseNumber=CN;
    UPDATE alfbasic SET svector = to_tsvector(read_excel_file_from_bin(arr)) WHERE CaseNumber=CN;    
RETURN true;
END;
$$ LANGUAGE plpgsql;


----------------------------------SEARCHING DATA IN FILES-----------------------------------
CREATE  OR REPLACE FUNCTION qparser(query TEXT)
  RETURNS varchar
AS $$
    global query
    query = query.split()
    return ' & '.join(query)
$$ LANGUAGE plpython3u; 

CREATE OR REPLACE FUNCTION find_text(t VARCHAR) 
RETURNS SETOF INTEGER
AS $$
DECLARE r INTEGER;
BEGIN  
    FOR r IN
        SELECT CaseNumber FROM alfbasic WHERE svector @@ to_tsquery(qparser(t))
    LOOP
        RETURN NEXT r;
    END LOOP;
    RETURN;  
END;
$$ LANGUAGE plpgsql;










/*
DROP INDEX tenant_index;
DROP INDEX acty_index;
DROP INDEX stage_index;
DROP INDEX casetype_index;

DROP ROLE fog_tenant_group;

DROP ROLE bells_acta_group;
DROP ROLE coast_acta_group;

DROP ROLE budget_ctype_group;
DROP ROLE statistics_ctype_group;

DROP ROLE draft_stage_group;
DROP ROLE task_stage_group;

DROP ROLE udim1_public_group;
DROP ROLE udim2_table_group;
DROP ROLE udim3_neutral_group;

DROP ROLE tfog_abells_u;
DROP ROLE tfog_abells_cbudget_sdraft_u;
DROP ROLE tfog_acoast_cbudget_sdraft_u;
DROP ROLE tfog_acoast_cstatistics_stask_u;
DROP ROLE tfog_admin;

DROP ROLE tfog_acoast_u;

DROP ROLE abells_sdraft_u;
DROP ROLE acoast_stask_u;
DROP ROLE abells_sdraft_u;

DROP ROLE tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;

DROP POLICY fog_tenant_policy ON alfbasic;
DROP POLICY bells_acta_policy ON alfbasic;
DROP POLICY coast_acta_policy ON alfbasic;
DROP POLICY budget_ctype_policy ON alfbasic;
DROP POLICY statistics_ctype_policy ON alfbasic;
DROP POLICY draft_stage_policy ON alfbasic;
DROP POLICY task_stage_policy ON alfbasic;
DROP POLICY udim1_public_policy ON alfbasic;
DROP POLICY udim2_table_policy ON alfbasic;
DROP POLICY udim3_neutral_policy ON alfbasic;
*/

