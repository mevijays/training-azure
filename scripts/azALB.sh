#!/bin/bash

##### create a resource group
#az group create -n krlab -l eastus
##### Create a vnet  subnet
#az network vnet create -g krlab -n devvnet --address-prefixes 10.0.0.0/16 --subnet-name devsubnet --subnet-prefixes 10.0.1.0/24

#az network vnet subnet create -n agssubnet --vnet-name devvnet -g krlab  --address-prefixes 10.0.3.0/24
#az network vnet subnet create -n extrasubnet --vnet-name devvnet -g krlab  --address-prefixes 10.0.3.0/24
##### Create an Ubuntu VM
az vm create -n prodvm1 -g krlab --image UbuntuLTS   --size Standard_B2s --public-ip-address '' --admin-username vijay  --vnet-name devvnet --subnet devsubnet --custom-data node-vm1.txt
sleep 30
az vm extension set   --resource-group krlab   --vm-name prodvm1   --name customScript   --publisher Microsoft.Azure.Extensions   --settings '{"fileUris": ["https://raw.githubusercontent.com/sharmavijay86/ocexample/master/src/azurelb.sh"],"commandToExecute": "./azurelb.sh"}'

az vm create -n prodvm2 -g krlab --image UbuntuLTS   --size Standard_B2s --public-ip-address '' --admin-username vijay  --vnet-name devvnet --subnet devsubnet --custom-data node-vm2.txt
sleep 30
az vm extension set   --resource-group krlab   --vm-name prodvm2   --name customScript   --publisher Microsoft.Azure.Extensions   --settings '{"fileUris": ["https://raw.githubusercontent.com/sharmavijay86/ocexample/master/src/azurelb.sh"],"commandToExecute": "./azurelb.sh"}'
### LB public ip 
#az network public-ip create --resource-group krlab --name lbPublicIP --sku Standard
### create LB

