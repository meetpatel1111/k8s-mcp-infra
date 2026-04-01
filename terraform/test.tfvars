# Test environment configuration
# Override default values for test deployment

environment         = "test"
location            = "East US"
resource_group_name = "rg-aks-weather-mcp-test"
cluster_name        = "aks-weather-mcp-test"
dns_prefix          = "aks-weather-test"

# Kubernetes version (use stable version for testing)
kubernetes_version = "1.28.3"

# Node pool configuration for testing
system_node_count     = 3
system_node_min_count = 2
system_node_max_count = 5
system_node_vm_size   = "Standard_DS3_v2"

# Additional tags for test environment
tags = {
  environment = "test"
  project     = "weather-mcp"
  managed_by  = "terraform"
  cost_center = "engineering"
  owner       = "qa-team"
}
