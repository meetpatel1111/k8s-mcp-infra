provider "azurerm" {
  features {}
  
  # Force stable AKS API version to avoid preview APIs
  provider_source = "hashicorp/azurerm"
  version        = "~>3.0"
}

terraform {
  required_version = ">=1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.95.0"
    }
  }
}
