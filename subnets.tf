# AKS nodes subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  address_prefixes     = ["10.1.0.0/22"]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

# application gateway subnet
resource "azurerm_subnet" "app-gw-subnet" {
  name                 = var.appgw_subnet_name
  address_prefixes     = ["10.1.32.0/19"]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}