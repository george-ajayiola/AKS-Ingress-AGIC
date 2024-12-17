output "aks_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.this.fqdn
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}

 output "application_ip_address" {
   value = azurerm_public_ip.appgw-pip.ip_address
 }

