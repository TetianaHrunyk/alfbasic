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
	udim3 VARCHAR(30) REFERENCES udim3(dname) ON DELETE CASCADE ON UPDATE CASCADE
);
--Run fill_alfbasic.py to fill the table with random values
--To ensure reproducibility of the rest of the script, do not modify tenants.csv and acts.csv

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

--Varianta 4: RLS na RLS na tenant, acta, CaseType, stage, udim1, udim2, udim3
CREATE USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP fog_tenant_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP coast_acta_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP budget_ctype_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP draft_stage_group ADD USER tfog_acoast_cbudget_sdraft_u;
ALTER GROUP udim1_public_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP udim2_table_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;
ALTER GROUP udim3_neutral_group ADD USER tfog_acoast_cbudget_sdraft_u1public_u2table_u3neutral;


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

--Table for storing files and some further metadata on them

CREATE TABLE files (
	CaseNumber INTEGER PRIMARY KEY REFERENCES alfbasic(CaseNumber),
	file_oid oid,
	mod_date TIMESTAMP default now(),
	cur_path VARCHAR(200) default '/home/tania/Downloads',
	meta1 VARCHAR(30) default 'xls',
	meta2 VARCHAR(30) default 'file_creator',
	meta3 VARCHAR(30) default 'last_modified_by'
);

GRANT SELECT ON TABLE files TO fog_tenant_group, bells_acta_group, coast_acta_group, budget_ctype_group, statistics_ctype_group, draft_stage_group, task_stage_group, udim1_public_group, udim2_table_group, udim3_neutral_group;

CREATE OR REPLACE FUNCTION get_lo_size(oid) RETURNS bigint
LANGUAGE 'plpgsql'
AS $$
DECLARE
    fd integer;
    sz bigint;
BEGIN
    fd := lo_open($1, x'40000'::int);
    PERFORM lo_lseek(fd, 0, 2);
    sz := lo_tell(fd);
    PERFORM lo_close(fd);
    RETURN sz;
END;
$$;


--PostgreSQL documentation on working with large files: https://www.postgresql.org/docs/10/lo-interfaces.html

CREATE OR REPLACE FUNCTION insert_files_into_alfbasic(path text, mod_val integer) RETURNS boolean
AS $$ 
DECLARE r INTEGER;
BEGIN
	FOR r IN
        SELECT CaseNumber FROM alfbasic WHERE mod(CaseNumber, mod_val) = 0
    LOOP
		IF r NOT IN (SELECT CaseNumber FROM files) THEN
	        INSERT INTO files(CaseNumber, path, file_oid) VALUES(r, path, lo_import(path));
		END IF;    
	END LOOP;
RETURN true;
END;
$$ LANGUAGE plpgsql;

INSERT INTO files(CaseNumber, file_oid) VALUES(50090, lo_import('/home/tania/Downloads/piskoviste_addfunction.xlsx'));
--select * from insert_files_into_alfbasic('/home/tania/Code/alf/data/report1.docx', 100);

--For retriving a file a function int lo_export(PGconn *conn, Oid lobjId, const char *filename) has to be used.
--This functions exports the data from the file stored in the database to a file that already eists in the operating system.
--Therefore, one has to make sure that the file exixts and it has appropriate level access.
--Further issue is that we have to decide if we allow to overwrite the file or not, and manage the query accordingly.


--TABLE FOR STORING PREPROCESSED TEXT FOR TEXT SEARCH
CREATE TABLE fiels_seach (
	search_id SERIAL PRIMARY KEY,
	CaseNumber INTEGER REFERENCES alfbasic(CaseNumber),
	text TEXT
);

--Python function for reading excel
--Before using Python in PostgreSQL:
--  In Ubuntu shell: sudo apt-get install postgresql-plpython3-10
--  From PostgreSQl client: create extension plpython3u;

CREATE  OR REPLACE FUNCTION read_excel_file(path text)
  RETURNS varchar[]
AS $$
    import math
    import pandas as pd
    import re

    limit = 1e+9
    
    def chunkstring(string, length):
        return [string[0+i:length+i] for i in range(0, len(string), length)]

    xls = pd.ExcelFile(path)
    
    excel_csv_tot = ""
    for sheet in xls.sheet_names:
        excel = pd.read_excel(path, separator = " ", sheet_name=sheet)
        excel.dropna(how="all", axis = 1, inplace=True)
        excel.dropna(how="all", axis = 0, inplace=True)
        excel_csv = excel.to_csv(index=False, line_terminator=" ")
        excel_csv=excel_csv.lower()
        excel_csv=excel_csv.replace('"', " ")
        excel_csv = re.sub(r",+", " ", excel_csv)
        excel_csv = re.sub(r"\ +", " ", excel_csv)
        excel_csv=excel_csv.strip()
        excel_csv_tot += excel_csv
    
    size = len(excel_csv_tot.encode("utf8"))
    
    if size <= limit:
        return [excel_csv]
    else:
    #NOTE: the flaw of this function is that it will break every 10e+9th word 
    #unless a blank space will occasionally occur at the breaking point
        chunks = size//limit + 1
        chunk_size = math.ceil(len(excel_csv_tot)/chunks)
        return chunkstring(excel_csv_tot, chunk_size)
        
$$ LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION load_search_vectors() 
RETURNS trigger 
AS $$
DECLARE vector VARCHAR;
BEGIN
    FOR vector IN
        SELECT * FROM read_excel_file()
    LOOP
		IF r NOT IN (SELECT CaseNumber FROM files) THEN
	        INSERT INTO files(CaseNumber, file_oid) VALUES(r, lo_import(path));
		END IF;    
	END LOOP;
END;
$$ LANGUAGE pgplpsql;



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

