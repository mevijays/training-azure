#!/bin/bash

##### create a resource group
az group create -n krlab -l eastus
##### Create a vnet with first subnet
az network vnet create -g krlab -n devvnet --address-prefixes 10.0.0.0/16 --subnet-name devsubnet --subnet-prefixes 10.0.1.0/24
az network vnet create -g krlab -n prodvnet --address-prefixes 10.1.0.0/16 --subnet-name prodsubnet --subnet-prefixes 10.1.1.0/24

#az network vnet subnet create -n extrasubnet --vnet-name labvnet -g krlab  --address-prefixes 10.0.3.0/24
##### Create an Ubuntu VM
az vm create -n devvm1 -g krlab --image UbuntuLTS   --size Standard_B2s --admin-username vijay  --vnet-name devvnet --subnet devsubnet
az vm create -n prodvm1 -g krlab --image UbuntuLTS   --size Standard_B2s --admin-username vijay  --vnet-name prodvnet --subnet prodsubnet

##### dns private zone 

az network private-dns zone create -g krlab -n mylab.lan
az network private-dns link vnet create -g krlab -n devDNSLink -z mylab.lan -v devvnet -e true
az network private-dns link vnet create -g krlab -n prodDNSLink -z mylab.lan -v prodvnet -e true
az network private-dns record-set a add-record -g krlab-z mylab.lan -n db -a 10.2.0.4
az storage account create -n krnloggingsa -g krlab -l eastus --kind StorageV2 --sku Standard_LRS
