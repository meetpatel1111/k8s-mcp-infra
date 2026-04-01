# Terraform variables for AKS Weather MCP Project
# Follows naming conventions and includes comprehensive descriptions

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "Central India"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-aks-weather-mcp"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be between 1 and 90 characters and can contain alphanumeric, underscore, parentheses, hyphen, and period characters."
  }
}

variable "cluster_name" {
  description = "Name of the Azure Kubernetes Service cluster"
  type        = string
  default     = "aks-weather-mcp"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,63}$", var.cluster_name))
    error_message = "Cluster name must be between 1 and 63 characters and can contain alphanumeric, underscore, parentheses, hyphen, and period characters."
  }
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-weather"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,45}$", var.dns_prefix))
    error_message = "DNS prefix must be between 1 and 45 characters and can contain alphanumeric, underscore, parentheses, hyphen, and period characters."
  }
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.28.3"

  validation {
    condition     = can(regex("^1\\.[0-9]{1,2}\\.[0-9]{1,2}$", var.kubernetes_version))
    error_message = "Kubernetes version must be in format x.y.z (e.g., 1.28.3)."
  }
}

variable "system_node_count" {
  description = "Number of nodes in the system node pool"
  type        = number
  default     = 2

  validation {
    condition     = var.system_node_count >= 1 && var.system_node_count <= 5
    error_message = "System node count must be between 1 and 5."
  }
}

variable "system_node_min_count" {
  description = "Minimum number of nodes for auto-scaling"
  type        = number
  default     = 1

  validation {
    condition     = var.system_node_min_count >= 1 && var.system_node_min_count <= 5
    error_message = "Minimum node count must be between 1 and 5."
  }
}

variable "system_node_max_count" {
  description = "Maximum number of nodes for auto-scaling"
  type        = number
  default     = 3

  validation {
    condition     = var.system_node_max_count >= 1 && var.system_node_max_count <= 10
    error_message = "Maximum node count must be between 1 and 10."
  }
}

variable "system_node_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_DS2_v2"

  validation {
    condition     = contains(["Standard_DS2_v2", "Standard_DS3_v2", "Standard_DS4_v2", "Standard_D2s_v3", "Standard_D4s_v3"], var.system_node_vm_size)
    error_message = "VM size must be a valid Azure VM size for AKS."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
