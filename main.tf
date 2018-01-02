terraform {
  required_version = ">= 0.11.0"
}

# Set Azure environment variables
provider "azurerm" {}

resource "azurerm_resource_group" "test" {
  name     = "rogerAzureSQL"
  location = "East US"
}

resource "azurerm_sql_server" "test" {
    name = "roger-sqlserver"
    resource_group_name = "${azurerm_resource_group.test.name}"
    location = "East US"
    version = "12.0"
    administrator_login = "roger"
    administrator_login_password = "pAssw0rd"
}

resource "azurerm_sql_database" "test" {
  name                = "test-vault"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location = "East US"
  server_name = "${azurerm_sql_server.test.name}"

  tags {
    environment = "dev"
  }
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "AllowVaultAccess"
  resource_group_name = "${azurerm_resource_group.test.name}"
  server_name         = "${azurerm_sql_server.test.name}"
  start_ip_address    = "50.18.144.202"
  end_ip_address      = "50.18.144.202"
}
