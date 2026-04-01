# Development environment configuration
# Override default values for development deployment

environment         = "dev"
location            = "Central India"
resource_group_name = "rg-aks-weather-mcp-dev"
cluster_name        = "aks-weather-mcp-dev"
dns_prefix          = "aks-weather-dev"

# Kubernetes version (use latest stable for dev)
kubernetes_version = "1.35.0"

# Node pool configuration for development
system_node_count     = 2
system_node_min_count = 1
system_node_max_count = 3
system_node_vm_size   = "Standard_D2s_v3"

# User node pool for application workloads (no critical addons taint)
user_node_count   = 2
user_node_vm_size = "Standard_D2s_v3"

# Replica counts
k8sgpt_replicas = 1
app_replicas    = 2

# HPA (Horizontal Pod Autoscaler) settings
k8sgpt_hpa_max = 3
app_hpa_max    = 5

# Additional tags for development
tags = {
  environment = "dev"
  project     = "weather-mcp"
  managed_by  = "terraform"
  cost_center = "engineering"
  owner       = "dev-team"
}
