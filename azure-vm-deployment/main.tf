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

# Holding variable resource_group for the RG
# Due to UK South & my subscription not supporting VMs
# changed to North Europe
locals {
    resource_group = "app-grp"
    location = "North Europe"
}

data "azurerm_subnet" "subnetA" {
    name = "subnetA"
    virtual_network_name = "app-network"
    resource_group_name = local.resource_group
}

# Create RG named app_grp, located in North Europe now
resource "azurerm_resource_group" "app_grp" {
  name = local.resource_group
  location = local.location
}

 resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = local.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = ["10.0.0.0/16"]

  depends_on = [ azurerm_resource_group.app_grp ]

  subnet {
    name             = "subnetA"
    address_prefixes = ["10.0.1.0/24"]
  }
}

resource "azurerm_network_interface" "app_interface" {
  name                = "app-interface"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.app_network
  ] 
}

resource "azurerm_windows_virtual_machine" "app_vm" {
  name                = "appvm"
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_B1s"
  admin_username      = ""
  admin_password      = ""
  network_interface_ids = [
    azurerm_network_interface.app_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  depends_on = [ 
    azurerm_network_interface.app_interface
   ]
}  