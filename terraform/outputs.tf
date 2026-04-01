# Terraform outputs for AKS Weather MCP Project
# Provides essential information for CI/CD and external systems

output "resource_group_name" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.rg.name

  depends_on = [
    azurerm_resource_group.rg
  ]
}

output "cluster_name" {
  description = "Name of the Azure Kubernetes Service cluster"
  value       = azurerm_kubernetes_cluster.aks.name

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name

  depends_on = [
    azurerm_container_registry.acr
  ]
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server

  depends_on = [
    azurerm_container_registry.acr
  ]
}

output "acr_admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_username

  depends_on = [
    azurerm_container_registry.acr
  ]

  sensitive = true
}

output "acr_admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_password

  depends_on = [
    azurerm_container_registry.acr
  ]

  sensitive = true
}

output "aks_kube_config" {
  description = "Kubernetes configuration for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]

  sensitive = true
}

output "aks_host" {
  description = "Kubernetes API server hostname"
  value       = azurerm_kubernetes_cluster.aks.fqdn

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

output "aks_client_certificate" {
  description = "Client certificate for Kubernetes authentication"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]

  sensitive = true
}

output "aks_client_key" {
  description = "Client key for Kubernetes authentication"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]

  sensitive = true
}

output "aks_cluster_ca_certificate" {
  description = "Cluster CA certificate for Kubernetes authentication"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]

  sensitive = true
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

output "subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id

  depends_on = [
    azurerm_subnet.aks
  ]
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.law.id

  depends_on = [
    azurerm_log_analytics_workspace.law
  ]
}

output "log_analytics_workspace_key" {
  description = "Primary key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.law.primary_shared_key

  depends_on = [
    azurerm_log_analytics_workspace.law
  ]

  sensitive = true
}

output "node_resource_group" {
  description = "Resource group containing AKS node resources"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}
