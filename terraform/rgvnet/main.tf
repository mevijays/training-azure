terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "krlabrg" {
  name     = "krlab"
  location = "eastus"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "labvnet" {
  name                = "labvnet"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  address_space       = ["10.0.0.0/16"]
}

# Create a vm subnet 
resource "azurerm_subnet" "vmsubnet" {
  name                 = "vmsubnet"
  resource_group_name  = azurerm_resource_group.krlabrg.name
  virtual_network_name = azurerm_virtual_network.labvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create a dev subnet 
resource "azurerm_subnet" "devsubnet" {
  name                 = "devsubnet"
  resource_group_name  = azurerm_resource_group.krlabrg.name
  virtual_network_name = azurerm_virtual_network.labvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
# Create a vm subnet 
resource "azurerm_subnet" "prodsubnet" {
  name                 = "prodsubnet"
  resource_group_name  = azurerm_resource_group.krlabrg.name
  virtual_network_name = azurerm_virtual_network.labvnet.name
  address_prefixes     = ["10.0.3.0/24"]
}
