#!/bin/bash

##### create a resource group
az group create -n krlab -l eastus
##### Create a vnet with first subnet
az network vnet create -g krlab -n labvnet --address-prefixes 10.0.0.0/16 --subnet-name vmsubnet --subnet-prefixes 10.0.1.0/24

### Create second subnet in the vnet
az network vnet subnet create -n azresourcesubnet --vnet-name labvnet -g krlab  --address-prefixes 10.0.2.0/24
### Create second subnet in the vnet
az network vnet subnet create -n extrasubnet --vnet-name labvnet -g krlab  --address-prefixes 10.0.3.0/24
##### Create an Ubuntu VM
az vm create -n appvm1 -g networkdemo   --image UbuntuLTS   --size Standard_B2s --admin-username vijay  --vnet-name prodvnet --subnet vmsubnet --custom-data node.txt
az vm create -n appvm2 -g networkdemo   --image UbuntuLTS   --size Standard_B2s --admin-username vijay  --vnet-name prodvnet --subnet vmsubnet --custom-data node.txt
