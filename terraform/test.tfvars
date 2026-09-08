# Test environment configuration
# Override default values for test deployment

environment         = "test"
location            = "Central India"
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

# Replica counts
weather_app_replicas = 2
weather_app_hpa_max  = 5
vote_app_replicas    = 2
vote_app_hpa_max     = 5
game_app_replicas    = 1
game_app_hpa_max     = 3
httpbin_app_replicas = 1
httpbin_app_hpa_max  = 3
whoami_app_replicas  = 1
whoami_app_hpa_max   = 3

# Additional tags for test environment
tags = {
  environment = "test"
  project     = "weather-mcp"
  managed_by  = "terraform"
  cost_center = "engineering"
  owner       = "qa-team"
}
