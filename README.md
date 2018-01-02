`terraform apply` against main.tf to create database

roger-sqlserver.database.windows.net

https://roger-sqlserver.database.windows.net/?langid=en-us#database=master

Added firewall rul in Azure portal to allow ingress from 0.0.0.0 to 255.255.255.255

Found mssql tool for Mac:
https://blogs.msdn.microsoft.com/joseph_idzioreks_blog/2015/10/26/azure-sql-database-cli-on-mac-os-x/

Install homebrew on Mac
brew install node
npm install -g sql-cli

Connect to master db with:

mssql -s roger-sqlserver.database.windows.net -u roger -p pAssw0rd -d master –e

-e means encrypt
-d indicates database


use `.quit` to exit mssql tool



vault mount database
Successfully mounted 'database' at 'database'!

vault write database/config/mssql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=test-vault;app name=vault;' allowed_roles="readonly"

The following warnings were returned from the Vault server:
* Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.

vault write database/roles/readonly \
db_name=test-vault \
creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
    CREATE USER [{{name}}] FOR LOGIN [{{name}}]; \
    GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" \
 default_ttl="1h" max_ttl="24h"
Success! Data written to: database/roles/readonly

vault read database/creds/readonly

Error reading database/creds/readonly: Error making API request.
URL: GET http://127.0.0.1:8200/v1/database/creds/readonly
Code: 500. Errors:
* 1 error occurred:
* failed to find entry for connection with name: test-vault

vault write database/roles/readonly db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}]; \
   GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" default_ttl="1h" max_ttl="24h"

Success! Data written to: database/roles/readonly

vault read database/creds/readonly
Error reading database/creds/readonly: Error making API request.

URL: GET http://127.0.0.1:8200/v1/database/creds/readonly
Code: 500. Errors:
* 1 error occurred:
* mssql: User must be in the master database.

vault write database/roles/readonly db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}]; \
   GRANT SELECT ON SCHEMA::dbo TO [{{name}}]; use master" default_ttl="1h" max_ttl="24h"
Success! Data written to: database/roles/readonly

vault write database/roles/readonly db_name=mssql  creation_statements="use master; CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}]; \
   GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" default_ttl="1h" max_ttl="24h"
Success! Data written to: database/roles/readonly

vault read database/creds/readonly
Error reading database/creds/readonly: Error making API request.
URL: GET http://127.0.0.1:8200/v1/database/creds/readonly
Code: 500. Errors:
* 1 error occurred:
* mssql: USE statement is not supported to switch between databases. Use a new connection to connect to a different database.


vault write database/config/mssql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="readonly"


The following warnings were returned from the Vault server:
* Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.


vault write database/roles/readonly db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
    CREATE USER [{{name}}] FOR LOGIN [{{name}}]; \
    GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" default_ttl="1h" max_ttl="24h"

Success! Data written to: database/roles/readonly

vault read database/creds/readonly
Error reading database/creds/readonly: Error making API request.

URL: GET http://127.0.0.1:8200/v1/database/creds/readonly
Code: 500. Errors:
* 1 error occurred:
* mssql: Cannot find the schema 'dbo', because it does not exist or you do not have permission.

vault write database/roles/readonly db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}];" default_ttl="1h" max_ttl="24h"
Success! Data written to: database/roles/readonly

vault read database/creds/readonly
Key            	Value
---            	-----
lease_id       	database/creds/readonly/e7bfa552-94d9-a1b8-ecbf-29813a4b5e0e
lease_duration 	1h0m0s
lease_renewable	true
password       	A1a-064w736345r479zt
username       	v-token-readonly-0wrsyzv5u98zzvszu90x-1513171047

But user could not login in Azure portal

# Get new credentials since I stepped away for an hour
vault read database/creds/readonly
Key            	Value
---            	-----
lease_id       	database/creds/readonly/5637e7c4-fe92-209d-8c07-58786ab85485
lease_duration 	1h0m0s
lease_renewable	true
password       	A1a-qss196v1912s22zx
username       	v-token-readonly-xz5v8zq2zv89tr8zzq83-1513177103





vault write database/config/mssql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=test-vault;app name=vault;' allowed_roles="readonly"

The following warnings were returned from the Vault server:
* Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.

vault write database/roles/readonly db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
    USE test-vault; CREATE USER [{{name}}] FOR LOGIN [{{name}}];  \
    GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" default_ttl="1h" max_ttl="24h"

Success! Data written to: database/roles/readonly

vault read database/creds/readonly

Error reading database/creds/readonly: Error making API request.
URL: GET http://127.0.0.1:8200/v1/database/creds/readonly
Code: 500. Errors:
* 1 error occurred:
* mssql: User must be in the master database.

vault write database/config/mssql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="readonly"

vault write database/roles/readonly db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
    USE test-vault; CREATE USER [{{name}}] FOR LOGIN [{{name}}];  \
    GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" default_ttl="1h" max_ttl="24h"

Decided to start over with vault config after figuring out how to connect to master database with mssql CLI on my Mac.

vault unmount database

Unmount error: Error making API request.
URL: DELETE http://127.0.0.1:8200/v1/sys/mounts/database
Code: 400. Errors:
* failed to revoke 'database/creds/readonly/5637e7c4-fe92-209d-8c07-58786ab85485' (1 / 2): failed to revoke entry: resp:(*logical.Response)(nil) err:mssql: Could not find stored procedure 'master.dbo.sp_msloginmappings'.*

curl --header "X-Vault-Token: decfb81f-42c1-1a37-5489-faf81d461f79" --request PUT http://localhost:8200/v1/sys/leases/revoke-force/database/creds

vault unmount database
Successfully unmounted 'database' if it was mounted

Start with new mount:

vault mount database
Successfully mounted 'database' at 'database'!

vault write database/config/mssql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="readonly"

The following warnings were returned from the Vault server:
Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.

vault write database/roles/readonly db_name=mssql \
    creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
    CREATE USER [{{name}}] FOR LOGIN [{{name}}];  \
    GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" default_ttl="1h" max_ttl="24h"

Success! Data written to: database/roles/readonly

vault read database/creds/readonly

Error reading database/creds/readonly: Error making API request.
URL: GET http://127.0.0.1:8200/v1/database/creds/readonly
Code: 500. Errors:
1 error occurred:
mssql: Cannot find the schema 'dbo', because it does not exist or you do not have permission.

This actually makes sense based on https://docs.microsoft.com/en-us/azure/sql-database/sql-database-manage-logins which says that admin user do not enter the master database as the dbo user.

vault write database/roles/readonly db_name=mssql \
    creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
    CREATE USER [{{name}}] FOR LOGIN [{{name}}];  \
    GRANT SELECT TO [{{name}}];" default_ttl="1h" max_ttl="24h"

Success! Data written to: database/roles/readonly

vault read database/creds/readonly

Error reading database/creds/readonly: Error making API request.
URL: GET http://127.0.0.1:8200/v1/database/creds/readonly
Code: 500. Errors:
1 error occurred:
mssql: Grantor does not have GRANT permission.

I think I need to use other database, not master: (but that was wrong)

vault write database/config/mssql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=test-vault;app name=vault;' allowed_roles="readonly"

The following warnings were returned from the Vault server:
Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.

vault write database/roles/readonly db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}];" default_ttl="1h" max_ttl="24h"
Success! Data written to: database/roles/readonly

Success! Data written to: database/roles/readonly

vault read database/creds/readonly

Error reading database/creds/readonly: Error making API request.
URL: GET http://127.0.0.1:8200/v1/database/creds/readonly
Code: 500. Errors:
1 error occurred:
mssql: User must be in the master database.

Start over:

vault write database/config/mssql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="readonly"

vault write database/roles/readonly db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}];" default_ttl="1h" max_ttl="24h"

vault read database/creds/readonly

Key            	Value
---            	-----
lease_id       	database/creds/readonly/b115b3a6-6ab2-ba14-d996-3211956df5c0
lease_duration 	1h0m0s
lease_renewable	true
password       	A1a-8q762v9ptt986vrv
username       	v-token-readonly-qwz0zqtv256xz31vxy61-1513278868

mssql -s roger-sqlserver.database.windows.net -u v-token-readonly-qwz0zqtv256xz31vxy61-1513278868 -p A1a-8q762v9ptt986vrv -d master -e
Connecting to roger-sqlserver.database.windows.net...(node:88640) [DEP0064] DeprecationWarning: tls.createSecurePair() is deprecated. Please use tls.Socket instead.
done

sql-cli version 0.6.2
Enter ".help" for usage hints.
mssql>

That's a wrap!

mssql> .databases
name      
----------
master    
test-vault

2 row(s) returned

Executed in 1 ms

mssql> .tables
database  schema  name                         type      
--------  ------  ---------------------------  ----------
master    sys     bandwidth_usage              VIEW      
master    sys     database_connection_stats    VIEW      
master    sys     database_error_stats         VIEW      
master    sys     database_firewall_rules      VIEW      
master    sys     database_usage               VIEW      
master    sys     dm_database_copies           VIEW      
master    sys     elastic_pool_resource_stats  VIEW      
master    sys     event_log                    VIEW      
master    sys     firewall_rules               VIEW      
master    sys     geo_replication_links        VIEW      
master    sys     resource_stats               VIEW      
master    dbo     sysdac_history_internal      BASE TABLE
master    dbo     sysdac_instances             VIEW      
master    dbo     sysdac_instances_internal    BASE TABLE

14 row(s) returned

Executed in 1 ms


Cannot log into the test-vault database with those credentials:

mssql -s roger-sqlserver.database.windows.net -u v-token-readonly-qwz0zqtv256xz31vxy61-1513278868 -p A1a-8q762v9ptt986vrv -d test-vault -e
Connecting to roger-sqlserver.database.windows.net...(node:88646) [DEP0064] DeprecationWarning: tls.createSecurePair() is deprecated. Please use tls.Socket instead.
Error: Login failed for user 'v-token-readonly-qwz0zqtv256xz31vxy61-1513278868'.



second server: roger2

vault mount -path mssql2 database
Successfully mounted 'database' at 'mssql2'!

vault write database/config/mssql2 plugin_name=mssql-database-plugin connection_url='server=roger2.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="readonly"

unmounted

Trying with azuresql as path:

vault mount -path azuresql database
Successfully mounted 'database' at 'azuresql'!

vault write database/config/azuresql plugin_name=mssql-database-plugin connection_url='server=roger2.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="readonly_only_azuresql"

vault write database/roles/read_only_azuresql db_name=azuresql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}];" default_ttl="1h" max_ttl="24h"

Success! Data written to: database/roles/read_only_azuresql

vault read database/creds/read_only_azuresql

Error reading database/creds/read_only_azuresql: Error making API request.
URL: GET http://127.0.0.1:8200/v1/database/creds/read_only_azuresql
Code: 403. Errors:

1 error occurred:
permission denied



vault mount database

vault write database/config/mssql plugin_name=mssql-database-plugin connection_url='server=roger2.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="read_only"

vault write database/roles/read_only db_name=mssql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}] WITH DEFAULT_SCHEMA = dbo;" default_ttl="1h" max_ttl="24h"

vault read database/creds/read_only

Key            	Value
---            	-----
lease_id       	database/creds/read_only/0b843b47-4cfb-fb41-6ae3-3be2fd70a185
lease_duration 	1h0m0s
lease_renewable	true
password       	A1a-ty11us7376wyvsxw
username       	v-token-read_only-xq01rzr104pp5wtz5023-1513319965

and able to login

vault mount -path azuresql database

vault write database/config/azuresql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;app name=vault;' allowed_roles="read_only_azuresql"

vault write database/roles/read_only_azuresql db_name=azuresql  creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
   CREATE USER [{{name}}] FOR LOGIN [{{name}}];" default_ttl="1h" max_ttl="24h"

vault read database/creds/read_only_azuresql

Error reading database/creds/read_only_azuresql: Error making API request.
URL: GET http://127.0.0.1:8200/v1/database/creds/read_only_azuresql
Code: 500. Errors:
1 error occurred:
mssql: User must be in the master database.



Friday:

vault write database/config/azuresql plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="read_only_azuresql"

vault write database/roles/read_only_azuresql db_name=azuresql creation_statements= "\
CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; \
CREATE USER [{{name}}] FOR LOGIN [{{name}}]; \
GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" \ default_ttl="1h" max_ttl="24h"

vault read database/creds/read_only_azuresql


Saturday:

vault mount -path=azuresql database

vault write azuresql/config/master plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=master;app name=vault;' allowed_roles="master"

vault write azuresql/config/testvault plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=test-vault;app name=vault;' allowed_roles="testvault"

vault write azuresql/roles/master db_name=master creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; CREATE USER [{{name}}] FOR LOGIN [{{name}}]" default_ttl="1h" max_ttl="24h"


vault read azuresql/creds/master

password       	A1a-pv452qwzyxq65rxy
username       	v-token-master-28zqv7pswpqx2rv3893s-1513435214

password       	A1a-xuq15z0x061q929v
username       	v-token-master-4tvrvzyvz095ypwryvyx-1513436126

vault write azuresql/roles/testvault db_name=testvault creation_statements="CREATE USER [{{name}}] FOR LOGIN [v-token-master-4tvrvzyvz095ypwryvyx-1513436126]; ALTER ROLE [db_owner] ADD MEMBER [{{name}}]; GRANT CONNECT TO [{{name}}];" default_ttl="1h" max_ttl="24h"



vault read azuresql/creds/testvault
password       	
username       	v-token-testvault-0sqzuzzyp95p20896p1w-1513435787

password       	A1a-ttu9x76t1z8v0xsv
username       	v-token-testvault-9px5v4y1r689uxzw7079-1513436261

mssql -s roger-sqlserver.database.windows.net -u v-token-testvault-0sqzuzzyp95p20896p1w-1513435787 -p A1a-pv452qwzyxq65rxy -d test-vault -e

Error: Login failed for user 'v-token-testvault-8sqvs0syx4tpy96qwxx3-1513435051'


SELECT DB_NAME(DB_ID()) as DatabaseName, * FROM sys.sysusers

SELECT name FROM sys.sysusers;
SELECT name from sys.schemas;

DROP USER [<user>];


SELECT pr.principal_id, pr.name, pr.type_desc, pr.authentication_type_desc, pe.state_desc, pe.permission_name FROM sys.database_principals AS pr JOIN sys.database_permissions AS pe ON pe.grantee_principal_id = pr.principal_id where name = 'v-token-testvault-0p8yzsq3q2209xx1s8x9-1513434731';


vault read azuresql/creds/master
password       	A1a-pv452qwzyxq65rxy
username       	v-token-master-28zqv7pswpqx2rv3893s-1513435214

Try treating Azure db as contained database:
Means we should use "CREATE USER {{name}} WITH PASSWORD = '{{password}}'"

vault mount -path=azuresql database
Successfully mounted 'database' at 'azuresql'!

vault write azuresql/config/testvault plugin_name=mssql-database-plugin connection_url='server=roger-sqlserver.database.windows.net;port=1433;user id=roger;password=pAssw0rd;database=test-vault;app name=vault;' allowed_roles="testvault"

The following warnings were returned from the Vault server:
Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.

vault write azuresql/roles/testvault db_name=testvault creation_statements="CREATE USER [{{name}}] WITH PASSWORD = '{{password}}';" revocation_statements="DROP USER IF EXISTS [{{name}}]" default_ttl="2m" max_ttl="24h"

Success! Data written to: azuresql/roles/testvault

vault read azuresql/creds/testvault

Key            	Value
---            	-----
lease_id       	azuresql/creds/testvault/78aeb362-51c6-7a45-ab65-fd3aa85f6bd3
lease_duration 	1h0m0s
lease_renewable	true
password       	A1a-ytu7v2wxsq96xwu1
username       	v-token-testvault-yuxp3twxzx47416szwus-1513441448

mssql -s roger-sqlserver.database.windows.net -u v-token-testvault-yuxp3twxzx47416szwus-1513441448 -p A1a-ytu7v2wxsq96xwu1  -d test-vault -e

Connecting to roger-sqlserver.database.windows.net...(node:92509) [DEP0064] DeprecationWarning: tls.createSecurePair() is deprecated. Please use tls.Socket instead.
done

sql-cli version 0.6.2
Enter ".help" for usage hints.
mssql>

(With 2 minute ttl)
vault read azuresql/creds/testvault
Key            	Value
---            	-----
lease_id       	azuresql/creds/testvault/d5e4c71c-81a7-f749-aff8-b30b6dbd23c8
lease_duration 	2m0s
lease_renewable	true
password       	A1a-rv69784028p76xz7
username       	v-token-testvault-y402yy7x377prsy1qx98-1513442474

Key            	Value
---            	-----
lease_id       	azuresql/creds/testvault/c0bf1d4a-76c7-ef40-c9ef-e7ba99f5a85d
lease_duration 	2m0s
lease_renewable	true
password       	A1a-2r8q7pt62usv4s2x
username       	v-token-testvault-1us2prp99x4qs13yr70x-1513443070
