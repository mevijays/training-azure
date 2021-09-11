#!/bin/bash

##### create a resource group
az group create -n krlab -l eastus
##### Create a vnet  subnet
az network vnet create -g krlab -n devvnet --address-prefixes 10.0.0.0/16 --subnet-name devsubnet --subnet-prefixes 10.0.1.0/24

#az network vnet subnet create -n extrasubnet --vnet-name labvnet -g krlab  --address-prefixes 10.0.3.0/24
##### Create an Ubuntu VM
az vm create -n devvm1 -g krlab --image UbuntuLTS   --size Standard_B2s --public-ip-address '' --admin-username vijay  --vnet-name devvnet --subnet devsubnet --custom-data node-vm1.txt
sleep 30
az vm extension set   --resource-group krlab   --vm-name devvm1   --name customScript   --publisher Microsoft.Azure.Extensions   --settings '{"fileUris": ["https://raw.githubusercontent.com/sharmavijay86/ocexample/master/src/azurelb.sh"],"commandToExecute": "./azurelb.sh"}'

az vm create -n devvm2 -g krlab --image UbuntuLTS   --size Standard_B2s --public-ip-address '' --admin-username vijay  --vnet-name devvnet --subnet devsubnet --custom-data node-vm2.txt
sleep 30
az vm extension set   --resource-group krlab   --vm-name devvm2   --name customScript   --publisher Microsoft.Azure.Extensions   --settings '{"fileUris": ["https://raw.githubusercontent.com/sharmavijay86/ocexample/master/src/azurelb.sh"],"commandToExecute": "./azurelb.sh"}'
### LB public ip 
az network public-ip create --resource-group krlab --name lbPublicIP --sku Standard
### create LB

az network lb create --resource-group krlab --name webLoadBalancer --sku Standard --public-ip-address lbPublicIP --frontend-ip-name webvip --backend-pool-name webBackEndPool
## Health probe 

az network lb probe create \
    --resource-group krlab \
    --lb-name webLoadBalancer \
    --name myHealthProbe \
    --protocol tcp \
    --port 80

### Create lb rules

az network lb rule create \
    --resource-group krlab \
    --lb-name webLoadBalancer \
    --name myHTTPRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name webvip \
    --backend-pool-name webBackEndPool \
    --probe-name myHealthProbe \
    --disable-outbound-snat true \
    --idle-timeout 15 \
    --enable-tcp-reset true
