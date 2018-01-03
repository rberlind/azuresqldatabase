# Deploying Azure SQL (PaaS) Database and Generating Dynamic Credentials With Vault

## Provision the Azure SQL Server and Database
Please do the following:
1. Edit the variables in azuresql.auto.tfvars to provide the resource group name, sqlserver name, and database name you want to use. I used the defaults below which are "rogerAzureSQL", "roger-sqlserver", and "test-vault".
1. Run `terraform init` to initialize Terraform.
1. Run `terraform plan` to do a plan.
1. Run `terraform apply` to create the resource group, sql server, and database.

## Install homebrew and mssql on Mac to Test Credentials
If you want to test the database credentials that Vault dynamically generates on a Mac, you could use the [mssql](https://blogs.msdn.microsoft.com/joseph_idzioreks_blog/2015/10/26/azure-sql-database-cli-on-mac-os-x/) tool.

Install homebrew and mssql client on Mac:
```
brew install node
npm install -g sql-cli
```
## Connect to Database with Admin User Credentials
Connect to your database with:
```
mssql -s roger-sqlserver.database.windows.net -u roger -p pAssw0rd -d test-vault –e
```

Note that "-e" means encrypt and "-d" indicates database

Use `.quit` to exit mssql tool

## Configure Vault Database Backend for MSSQL

Mount a database backend at path azuresql:
```
vault mount -path=azuresql database
Successfully mounted 'database' at 'azuresql'!
```

Configure the azuresql auth backend:
```
vault write azuresql/config/testvault \
  plugin_name=mssql-database-plugin \
  connection_url='server=roger-sqlserver.database.windows.net;port=1433; \
  user id=roger;password=pAssw0rd;database=test-vault;app name=vault;' \
  allowed_roles="testvault"
The following warnings were returned from the Vault server:
Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.
```

Configure testvault role for the auth backend with time to live of 2 minutes:
```
vault write azuresql/roles/testvault \
  db_name=testvault \
  creation_statements="CREATE USER [{{name}}] WITH PASSWORD = '{{password}}';" \
  revocation_statements="DROP USER IF EXISTS [{{name}}]" \
  default_ttl="2m" max_ttl="24h"
Success! Data written to: azuresql/roles/testvault
```

## Generate and Test Dynamic Credentials for Azure SQL Database
Generate credentials:
```
vault read azuresql/creds/testvault

Key            	Value
---            	-----
lease_id       	azuresql/creds/testvault/78aeb362-51c6-7a45-ab65-fd3aa85f6bd3
lease_duration 	1h0m0s
lease_renewable	true
password       	A1a-ytu7v2wxsq96xwu1
username       	v-token-testvault-yuxp3twxzx47416szwus-1513441448
```

Login to the database with the credentials:
```
mssql -s roger-sqlserver.database.windows.net -u v-token-testvault-yuxp3twxzx47416szwus-1513441448 -p A1a-ytu7v2wxsq96xwu1  -d test-vault -e
Connecting to roger-sqlserver.database.windows.net...(node:92509) [DEP0064] DeprecationWarning: tls.createSecurePair() is deprecated. Please use tls.Socket instead.
done

sql-cli version 0.6.2
Enter ".help" for usage hints.
mssql>
```

Note that after 2 minutes, I could no longer do any commands in the existing mssql session and could not login again.
