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
  features { }
}

# Holding variable resource_group for the RG
# Due to UK South & my subscription not supporting VMs
# changed to North Europe
locals {
    resource_group = "app-grp"
    location = "North Europe"
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
}

# Create subnet
resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]

  # Depends on the creation of the virtual network first.
  depends_on = [ 
    azurerm_virtual_network.app_network,
   ]
}

# Creates a network interface: app_interface
resource "azurerm_network_interface" "app_interface" {
  name                = "app-interface"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.app_public_ip.id
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_public_ip.app_public_ip,
    azurerm_subnet.SubnetA
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
  availability_set_id = azurerm_availability_set.app_set.id

  network_interface_ids = [
    azurerm_network_interface.app_interface.id,    
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

  # It'll check if these two resource blocks are created, and then it'll create the VM after.
  depends_on = [ 
    azurerm_network_interface.app_interface,
    azurerm_availability_set.app_set
   ]
}  

# Creating public IP address and linking it to RG & location.
resource "azurerm_public_ip" "app_public_ip" {
  name                = "app-public-ip"
  resource_group_name = local.resource_group
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ 
    azurerm_resource_group.app_grp
   ]
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

# This creates an availability set named: app_set
resource "azurerm_availability_set" "app_set" {
  name                = "app-set"
  location            = local.location
  resource_group_name = local.resource_group
  platform_fault_domain_count = 3
  platform_update_domain_count = 3

  depends_on = [ 
    azurerm_resource_group.app_grp
   ]

}

# Here we are creating a storage account.
resource "azurerm_storage_account" "appstore" {
  name                     = "appstore993"
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
}

# We are creating a container which depends on the storage account.
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_id    =  azurerm_storage_account.appstore.id
  container_access_type = "blob"
  

  depends_on = [ 
    azurerm_storage_account.appstore
   ]
} 

# Here we're uploading our IIS config script as a blob to the storage account.
resource "azurerm_storage_blob" "IIS_config" {
  name                   = "IIS_Config.ps1"
  storage_account_name   = azurerm_storage_account.appstore.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "IIS_Config.ps1"

  depends_on = [ 
    azurerm_storage_container.data
   ]
}

# Create virtual machine extension aand deploy it
resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  depends_on = [ 
    azurerm_storage_blob.IIS_config
   ]

  settings = <<SETTINGS
 {
  "fileUris": ["https://${azurerm_storage_account.appstore.name}.blob.core.windows.net/data/IIS_Config.ps1"],
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"
 }
SETTINGS
}