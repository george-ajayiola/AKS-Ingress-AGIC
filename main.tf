 # Locals block for hardcoded names
 locals {
   backend_address_pool_name      = "${azurerm_virtual_network.this.name}-beap"
   frontend_port_name             = "${azurerm_virtual_network.this.name}-feport"
   frontend_ip_configuration_name = "${azurerm_virtual_network.this.name}-feip"
   http_setting_name              = "${azurerm_virtual_network.this.name}-be-htst"
   listener_name                  = "${azurerm_virtual_network.this.name}-httplstn"
   request_routing_rule_name      = "${azurerm_virtual_network.this.name}-rqrt"
 }

resource "azurerm_user_assigned_identity" "aks" {
  location            = azurerm_resource_group.this.location
  name                = "uami-${var.aks_name}"
  resource_group_name = azurerm_resource_group.this.name
}

 resource "azurerm_public_ip" "appgw-pip" {
   name                = "appgw-public-ip"
   resource_group_name = azurerm_resource_group.this.name
   location            = azurerm_resource_group.this.location
   allocation_method   = "Static"
   sku                 = "Standard"
 }

resource "azurerm_application_gateway" "appgw" {
   name                = var.app_gateway_name
   resource_group_name = azurerm_resource_group.this.name
   location            = azurerm_resource_group.this.location

   sku {
     name     = var.app_gateway_tier
     tier     = var.app_gateway_tier
     capacity = 1
   }

   gateway_ip_configuration {
     name      = "appGatewayIpConfig"
     subnet_id = azurerm_subnet.app-gw-subnet.id
   }

   frontend_port {
     name = local.frontend_port_name
     port = 80
   }

   frontend_ip_configuration {
     name                 = local.frontend_ip_configuration_name
     public_ip_address_id = azurerm_public_ip.appgw-pip.id
   }

   backend_address_pool {
     name = local.backend_address_pool_name
   }

   backend_http_settings {
     name                  = local.http_setting_name
     cookie_based_affinity = "Disabled"
     port                  = 80
     protocol              = "Http"
     request_timeout       = 1
   }

   http_listener {
     name                           = local.listener_name
     frontend_ip_configuration_name = local.frontend_ip_configuration_name
     frontend_port_name             = local.frontend_port_name
     protocol                       = "Http"
   }

   request_routing_rule {
     name                       = local.request_routing_rule_name
     priority                   = 1
     rule_type                  = "Basic"
     http_listener_name         = local.listener_name
     backend_address_pool_name  = local.backend_address_pool_name
     backend_http_settings_name = local.http_setting_name
   }

   lifecycle {
     ignore_changes = [
       tags,
       backend_address_pool,
       backend_http_settings,
       http_listener,
       probe,
       request_routing_rule,
     ]
   }
 }


 data "azurerm_user_assigned_identity" "ingress" {
   name                = "ingressapplicationgateway-${azurerm_kubernetes_cluster.this.name}"
   resource_group_name = azurerm_kubernetes_cluster.this.node_resource_group
 }


resource "azurerm_kubernetes_cluster" "this" {
  name                      = "${var.env}-${var.aks_name}"
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  dns_prefix                = "${var.env}-aks"
  kubernetes_version        = var.aks_version
  oidc_issuer_enabled    = true
  private_cluster_enabled   = false


  sku_tier = "Free"


  
    identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }


 network_profile {
  network_plugin     = "azure" # Azure CNI
  service_cidr       = "10.1.4.0/22"
  dns_service_ip     = "10.1.4.10"
}


ingress_application_gateway {
  gateway_id = azurerm_application_gateway.appgw.id
}

  default_node_pool {
    name                 = "newpool"
    vm_size              = "Standard_D2_v2"
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
    node_count           = 2
  }


   depends_on = [
     azurerm_application_gateway.appgw
   ]

  tags = {
    env = var.env
  }
}
 # Role assignments
 resource "azurerm_role_assignment" "ra1" {
   scope                = azurerm_resource_group.this.id
   role_definition_name = "Reader"
   principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
 }

 resource "azurerm_role_assignment" "ra2" {
   scope                = azurerm_virtual_network.this.id
   role_definition_name = "Network Contributor"
   principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
 }

 resource "azurerm_role_assignment" "ra3" {
   scope                = azurerm_application_gateway.appgw.id
   role_definition_name = "Contributor"
   principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
 }

resource "azurerm_role_assignment" "cluster_admin" {
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}
