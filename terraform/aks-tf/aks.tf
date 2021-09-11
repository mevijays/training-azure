resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = "devaks"

  default_node_pool {
    name       = var.node_pool_name
    vm_size    = var.vm_size
    enable_auto_scaling = "true"
    max_count  = var.max_node
    min_count = var.min_node
    node_count = var.desired_node
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }

  network_profile {
          network_plugin     = "kubenet"
          network_policy     = "calico"
          pod_cidr           = "10.23.0.0/16"
    }
  role_based_access_control {
      enabled = true
  }
}