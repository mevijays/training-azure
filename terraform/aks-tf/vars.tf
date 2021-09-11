variable "resource_group_name" {
    default = "krlab"
}
variable "location" {
  default = "West Europe"
}
variable "aks_name" {
  default = "demo-aks"
}
variable "node_pool_name" {
  default = "akspool"
}
variable "vm_size" {
  default = "Standard_B2s"
}
variable "max_node" {
  default = "8"
}
variable "min_node" {
  default = "1"
}
variable "desired_node" {
  default = "1"
}