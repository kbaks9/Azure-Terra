terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.51.0"
    }
  }
}

# Use EXPORT for tenant ID (etc) into CLI, rather than putting the detail on here
provider "azurerm" {
  features {}
}

# Holds Storage Account in a variable
variable "storage_account_name" {
    type = string
    description = "Please enter the storage account name"
}

# Holding variable resource_group for the RG
locals {
    resource_group = "app-grp"
    location = "UK South"
}

# Create RG named app_grp, located in UK south
resource "azurerm_resource_group" "app_grp" {
  name = local.resource_group
  location = local.location
}

# This is used to create a storage account
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# This is used to create a container
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "blob"
  depends_on = [ 
    azurerm_storage_account.storage_account
   ]
}

# This is used to upload a local file onto the container
resource "azurerm_storage_blob" "sample" {
  name                   = "sample.txt"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "sample.txt"
  depends_on = [ 
    azurerm_storage_container.data
    ]
} 