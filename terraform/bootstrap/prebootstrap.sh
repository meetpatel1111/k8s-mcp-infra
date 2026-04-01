#!/usr/bin/env bash
set -euo pipefail

# Terraform Backend Pre-bootstrap Script
# Creates Azure Storage Account and Container for Terraform remote state
# Follows Azure security and reliability best practices

RG_NAME=$1
SA_NAME=$2
CONTAINER_NAME=$3
LOCATION=${4:-eastus}

# Validate inputs
if [[ -z "$RG_NAME" || -z "$SA_NAME" || -z "$CONTAINER_NAME" ]]; then
    echo "Error: Missing required parameters"
    echo "Usage: $0 <resource-group> <storage-account> <container> [location]"
    exit 1
fi

# Check Azure CLI authentication
if ! az account show >/dev/null 2>&1; then
    echo "Error: Azure CLI not authenticated. Run 'az login' first."
    exit 1
fi

echo "Setting up Terraform backend infrastructure..."
echo "Resource Group: $RG_NAME"
echo "Storage Account: $SA_NAME"
echo "Container: $CONTAINER_NAME"
echo "Location: $LOCATION"

# Create Resource Group if not exists
if ! az group show -n "$RG_NAME" >/dev/null 2>&1; then
    echo "Creating Resource Group: $RG_NAME"
    az group create \
        -n "$RG_NAME" \
        -l "$LOCATION" \
        --tags "purpose=terraform-state" "environment=shared" >/dev/null
else
    echo "Resource Group '$RG_NAME' already exists"
fi

# Create Storage Account if not exists (with best practices)
if ! az storage account show -n "$SA_NAME" -g "$RG_NAME" >/dev/null 2>&1; then
    echo "Creating Storage Account: $SA_NAME"
    az storage account create \
        -n "$SA_NAME" \
        -g "$RG_NAME" \
        -l "$LOCATION" \
        --sku Standard_RAGRS \
        --kind StorageV2 \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access false \
        --enable-hierarchical-namespace false \
        --default-action Allow \
        --access-tier Hot \
        --tags "purpose=terraform-state" "environment=shared" >/dev/null
else
    echo "Storage Account '$SA_NAME' already exists"
fi

# Get Account Key
ACCOUNT_KEY=$(az storage account keys list -n "$SA_NAME" -g "$RG_NAME" --query '[0].value' -o tsv)

# Create Container if not exists
if ! az storage container show -n "$CONTAINER_NAME" --account-name "$SA_NAME" --account-key "$ACCOUNT_KEY" >/dev/null 2>&1; then
  echo "Creating Container $CONTAINER_NAME"
  az storage container create -n "$CONTAINER_NAME" --account-name "$SA_NAME" --account-key "$ACCOUNT_KEY" >/dev/null
else
  echo "Container '$CONTAINER_NAME' already exists"
fi

echo "Backend ready: rg=$RG_NAME sa=$SA_NAME container=$CONTAINER_NAME"
    --account-name "$SA_NAME" \
    --account-key "$ACCOUNT_KEY" \
    --query "name" -o tsv >/dev/null

echo "✅ Terraform backend setup completed successfully!"
echo "Backend details:"
echo "  Resource Group: $RG_NAME"
echo "  Storage Account: $SA_NAME"
echo "  Container: $CONTAINER_NAME"
echo "  Location: $LOCATION"
echo "  State file path: aks/<environment>.tfstate"
