terraform {
  required_version = ">= 0.11.0"
}

# Set Azure environment variables before doing plan and apply
provider "azurerm" {}

variable "resource_group_name" {
  description = "name of resource group"
}

variable "location" {
  description = "Azure location"
  default = "US East"
}

variable "sqlserver_name" {
  description = "name of Azure sqlserver"
}

variable "admin_name" {
  description = "name of Azure sqlserver admin user"
  default = "admin"
}

variable "admin_password" {
  description = "password of Azure sqlserver admin user"
  default = "pAssw0rd"
}

variable "db_name" {
  description = "name of Azure SQL database"
}

resource "azurerm_resource_group" "rg" {
  name = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_sql_server" "sqlserver" {
    name = "${var.sqlserver_name}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "${var.location}"
    version = "12.0"
    administrator_login = "${var.admin_name}"
    administrator_login_password = "${var.admin_password}"
}

resource "azurerm_sql_database" "db" {
  name = "${var.db_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location = "${var.location}"
  server_name = "${azurerm_sql_server.sqlserver.name}"

  tags {
    environment = "dev"
  }
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "AllowAllAccess"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_sql_server.sqlserver.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
