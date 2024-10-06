
terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "4.4.0"
    }
  }
   cloud {
    organization = "mevijays"

    workspaces {
      name = "training-azure"
    }
  }
}
provider "azurerm" {
  use_oidc = true
  subscription_id = var.subscription_id
  features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
   }
}
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}
variable "VMCOUNT" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}
variable "PUBLIC" {
  description = "If publc ip required"
  type = bool
  default = true
}

variable "location" {
  description = "RG Location"
  type = string
  default = "eastus"
}
variable "rgname" {
  description = "RG name"
  type = string
  default = "nsgrg"
}


resource "azurerm_resource_group" "main" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "devvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  count                = 3
  name                 = "devsubnet-${count.index}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}


resource "azurerm_public_ip" "this" {
  count               = var.PUBLIC ? var.VMCOUNT : 0
  name                = "webvmip-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_network_interface" "main" {
  count               = var.VMCOUNT
  name                = "main-nic-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "main-ipconfig"
    subnet_id                     = azurerm_subnet.main[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.PUBLIC ? azurerm_public_ip.this[count.index].id : null
  }
}

resource "azurerm_linux_virtual_machine" "webvm" {
  count                 = var.VMCOUNT
  name                  = "webvm-${count.index}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B1s"
  admin_username        = "vijay"
  network_interface_ids = [azurerm_network_interface.main[count.index].id]

  admin_ssh_key {
    username   = "vijay"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  custom_data = filebase64("azure-user-data.sh")
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }
}
