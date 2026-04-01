# Terraform backend configuration
# Uses Azure Storage Account for remote state management
# Backend configuration is dynamically provided during CI/CD runtime

terraform {
  backend "azurerm" {
    # Configuration provided via environment variables or CLI flags:
    # -backend-config="resource_group_name=tfstate-shared-rg"
    # -backend-config="storage_account_name=sttfstateshared"
    # -backend-config="container_name=tfstate"
    # -backend-config="key=aks/dev.tfstate"

    # Best practices implemented:
    # - State file encryption: Enabled by default in Azure Storage
    # - Access control: Managed through Azure RBAC
    # - Versioning: Enabled for state history
    # - Soft delete: Enabled for accidental deletion protection
    # - Geo-replication: Configured at storage account level
  }
}

# Backend configuration recommendations:
# 1. Use separate storage accounts for different environments (prod/non-prod)
# 2. Enable storage account encryption with customer-managed keys for production
# 3. Implement state locking (automatically enabled with azurerm backend)
# 4. Regular state backups via Azure Storage account backup policies
# 5. Monitor state access through Azure Monitor logs
