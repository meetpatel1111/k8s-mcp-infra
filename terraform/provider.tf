provider "azurerm" {
  features {}
  
  # Force stable AKS API version to avoid preview APIs
  provider_source = "hashicorp/azurerm"
  version        = "~>4.0"
}

terraform {
  required_version = ">=1.14.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.8.0"
    }
  }
}
