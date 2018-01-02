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
