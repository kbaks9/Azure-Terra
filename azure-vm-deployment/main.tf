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

# Creates a virtual network named: app_network
resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = local.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = ["10.0.0.0/16"]

  depends_on = [ 
    azurerm_resource_group.app_grp 
  ]

  subnet {
    name             = "subnetA"
    address_prefixes = ["10.0.1.0/24"]
  }
}

# Creates a network interface: app_interface
resource "azurerm_network_interface" "app_interface" {
  name                = "app-interface"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.app_public_ip.id
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_public_ip.app_public_ip
  ] 
}

# Creates Windows VM named: app_vm
resource "azurerm_windows_virtual_machine" "app_vm" {
  name                = "appvm"
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_B2s"
  admin_username      = ""
  admin_password      = ""
  network_interface_ids = [
    azurerm_network_interface.app_interface.id
  ]

  # The virtual hard drive that holds the operating system.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Shows what operating system you'll use when creating VM.
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  # Depends on the creation of the network interface: app_interface
  depends_on = [ 
    azurerm_network_interface.app_interface
   ]
}  

# Creating public IP address and linking it to RG & location.
resource "azurerm_public_ip" "app_public_ip" {
  name                = "app-public-ip"
  resource_group_name = local.resource_group
  location            = local.location
  allocation_method   = "Static"
}

# Creating data disks.
resource "azurerm_managed_disk" "data_disk" {
  name                 = "data-disk"
  location             = local.location
  resource_group_name  = local.resource_group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "16"
}

# After data disk is created, attach the disk to the virtual machine.
resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.app_vm.id
  lun                = "0"
  caching            = "ReadWrite"

  # Depends on the creation of the virtual machine: app_vm
  depends_on = [ 
    azurerm_windows_virtual_machine.app_vm,
    azurerm_managed_disk.data_disk
   ]
}

