# Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = "weather-mcp"
    managed_by  = "terraform"
  }
}

# Random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true

  keepers = {
    rg_name = azurerm_resource_group.rg.name
  }
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acr${var.environment}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true

  tags = {
    environment = var.environment
    project     = "weather-mcp"
    managed_by  = "terraform"
  }
}

# Azure Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Use managed identity
  identity {
    type = "SystemAssigned"
  }

  # Default node pool with best practices
  default_node_pool {
    name                         = "system"
    node_count                   = var.system_node_count
    vm_size                      = var.system_node_vm_size
    os_disk_size_gb              = 30
    os_disk_type                 = "Ephemeral"
    vnet_subnet_id               = azurerm_subnet.aks.id
    enable_auto_scaling          = true
    min_count                    = var.system_node_min_count
    max_count                    = var.system_node_max_count
    only_critical_addons_enabled = true
  }

  # Network configuration
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    service_cidr   = "10.96.0.0/12"
    dns_service_ip = "10.96.0.10"
  }

  tags = {
    environment = var.environment
    project     = "weather-mcp"
    managed_by  = "terraform"
  }
}

# Virtual Network for AKS
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = var.environment
    project     = "weather-mcp"
    managed_by  = "terraform"
  }
}

# Subnet for AKS
resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = var.environment
    project     = "weather-mcp"
    managed_by  = "terraform"
  }
}

# Role assignment for ACR pull access
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id

  depends_on = [azurerm_kubernetes_cluster.aks]
}
