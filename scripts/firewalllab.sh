#!/bin/bash

##### create a resource group
az group create -n krlab -l eastus
##### Create a vnet with first subnet
az network vnet create -g krlab -n labvnet --address-prefixes 10.0.0.0/16 --subnet-name AzureFirewallSubnet --subnet-prefixes 10.0.1.0/24

### Create second subnet in the vnet
az network vnet subnet create -n vmsubnet --vnet-name labvnet -g krlab  --address-prefixes 10.0.2.0/24
##### Create a Windows App1 name VM
az vm create -n appvm1 -g krlab --image win2016datacenter   --size Standard_B2s --public-ip-address "" --admin-username vijay --admin-password 'Redhat@123go' --vnet-name labvnet --subnet vmsubnet 
az vm create -n appvm2 -g krlab --image UbuntuLTS   --size Standard_B2s --public-ip-address "" --admin-username vijay --vnet-name labvnet --subnet vmsubnet
### Open the extra 80 port in NSG to use for IIS lab
az vm open-port --port 80 --resource-group krlab --name appvm1
#### Create dedicated subnet for Bastion
#az network vnet subnet create -n AzureBastionSubnet --vnet-name labvnet -g krlab  --address-prefixes 10.0.5.0/24
#### Create a Public IP required to Bastian 
#az network public-ip create --resource-group krlab --name bIp --sku Standard --location eastus
####  Create bastian service
#az network bastion create --name MyBastion --public-ip-address bIP --resource-group krlab --vnet-name labvnet --location eastus
