variable "env" {
  description = "The environment name"
  type        = string
  default     = "dev"
}

 variable "aks_subnet_name" {
   type        = string
   description = "Name of the subnet."
   default     = "akssubnet"
 }

variable "region" {
  description = "The Azure region"
  type        = string
  default     = "westus2"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "devops-stuff"
}

variable "aks_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "django-rest-api-cluster"
}

variable "aks_version" {
  description = "The version of the AKS cluster"
  type        = string
  default     = "1.29.7"
}

 variable "appgw_subnet_name" {
   type        = string
   description = "Name of the subset."
   default     = "appgwsubnet"
 }
  variable "app_gateway_subnet_address_prefix" {
   type        = string
   description = "Subnet address prefix."
   default     = "10.1.4.0/24"
 }

 variable "app_gateway_name" {
   description = "Name of the Application Gateway"
   type        = string
   default     = "ApplicationGateway1"
 }

 variable "app_gateway_tier" {
   description = "Tier of the Application Gateway tier."
   type        = string
   default     = "Standard_v2"
 }