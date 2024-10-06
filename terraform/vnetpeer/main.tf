
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
  features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
   }
}


// Create a resource group
resource "azurerm_resource_group" "krlabrg" {
  name     = "krlab"
  location = "eastus"
}

// Create a virtual network within the resource group DEV VNET
resource "azurerm_virtual_network" "devvnet" {
  name                = "devvnet"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  address_space       = ["192.168.1.0/24"]
  depends_on          = [
    azurerm_resource_group.krlabrg,
  ]
}

// Create a dev subnet 
resource "azurerm_subnet" "devsubnet" {
  name                 = "devsubnet"
  resource_group_name  = azurerm_resource_group.krlabrg.name
  virtual_network_name = azurerm_virtual_network.devvnet.name
  address_prefixes     = ["192.168.1.0/25"]
  depends_on          = [
    azurerm_resource_group.krlabrg,
    azurerm_virtual_network.devvnet
  ]
}

## creating NSG with all inbound allow
resource "azurerm_network_security_group" "devvmnsg" {
  name                = "devvmnsg"
  location            = azurerm_resource_group.krlabrg.location
  resource_group_name = azurerm_resource_group.krlabrg.name

  security_rule {
    name                       = "allallow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Development"
  }
}

// associate NSG with vm subnet
resource "azurerm_subnet_network_security_group_association" "vmnetnsg" {
  subnet_id                 = azurerm_subnet.devsubnet.id
  network_security_group_id = azurerm_network_security_group.devvmnsg.id
}

// Create a virtual network within the resource group
resource "azurerm_virtual_network" "prodvnet" {
  name                = "prodvnet"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  address_space       = ["172.16.1.0/24"]
  depends_on          = [
    azurerm_resource_group.krlabrg,
  ]
}

# Create a prod vm subnet 
resource "azurerm_subnet" "prodsubnet" {
  name                 = "prodsubnet"
  resource_group_name  = azurerm_resource_group.krlabrg.name
  virtual_network_name = azurerm_virtual_network.prodvnet.name
  address_prefixes     = ["172.16.1.0/25"]
  depends_on          = [
    azurerm_resource_group.krlabrg,
    azurerm_virtual_network.prodvnet
  ]
}

## creating NSG with all inbound allow
resource "azurerm_network_security_group" "prodvmnsg" {
  name                = "prodvmnsg"
  location            = azurerm_resource_group.krlabrg.location
  resource_group_name = azurerm_resource_group.krlabrg.name

  security_rule {
    name                       = "allallow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

// associate NSG with vm subnet
resource "azurerm_subnet_network_security_group_association" "devvmnetnsg" {
  subnet_id                 = azurerm_subnet.prodsubnet.id
  network_security_group_id = azurerm_network_security_group.prodvmnsg.id
}

// creating public ips for devvm
resource "azurerm_public_ip" "deveip" {
  count               = 2
  name                = "devvmip-${count.index}"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  allocation_method   = "Static"

  tags = {
    environment = "Development"
  }
}

// NIC for vm

resource "azurerm_network_interface" "devvm" {
  count               = 2
  name                = "devvm${count.index}-nic"
  location            = azurerm_resource_group.krlabrg.location
  resource_group_name = azurerm_resource_group.krlabrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.deveip.*.id, count.index) 
  }
  depends_on          = [
        azurerm_subnet.devsubnet,
        azurerm_public_ip.deveip
 ]
}

resource "azurerm_linux_virtual_machine" "devvm" {
  count               = 2
  name                = "devvm-${count.index}"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  size                = "Standard_B1s"
  admin_username      = "vijay"
  network_interface_ids =  [element(azurerm_network_interface.devvm.*.id, count.index)]

  admin_ssh_key {
    username   = "vijay"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }
  depends_on          = [
        azurerm_subnet.devsubnet,
        azurerm_network_interface.devvm
 ]
}

data "template_file" "linux-vm-cloud-init" {
   template = file("azure-user-data.sh")
}


// setup prod vm

// creating public ips for devvm
resource "azurerm_public_ip" "prodeip" {
  count               = 2
  name                = "prodvmip-${count.index}"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

// NIC for vm

resource "azurerm_network_interface" "prodvm" {
  count               = 2
  name                = "prodvm${count.index}-nic"
  location            = azurerm_resource_group.krlabrg.location
  resource_group_name = azurerm_resource_group.krlabrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prodsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.prodeip.*.id, count.index) 
  }
  depends_on          = [
        azurerm_subnet.prodsubnet,
        azurerm_public_ip.prodeip
 ]
}

resource "azurerm_linux_virtual_machine" "prodvm" {
  count               = 2
  name                = "prodvm-${count.index}"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  size                = "Standard_B1s"
  admin_username      = "vijay"
  network_interface_ids =  [element(azurerm_network_interface.prodvm.*.id, count.index)]

  admin_ssh_key {
    username   = "vijay"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }
  depends_on          = [
        azurerm_subnet.prodsubnet,
        azurerm_network_interface.prodvm
 ]
}
