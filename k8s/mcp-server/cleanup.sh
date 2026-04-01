#!/bin/bash

# Kubernetes MCP Server Cleanup Script
# This script removes all MCP Server resources from your AKS cluster

set -e

echo "🧹 Cleaning up Kubernetes MCP Server..."

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: kubectl is not configured or cluster is not accessible"
    exit 1
fi

echo "✅ kubectl is configured"

# Delete ingress
echo "🗑️  Removing ingress..."
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true

# Delete deployments and services
echo "🗑️  Removing deployments and services..."
kubectl delete -f k8s/service.yaml --ignore-not-found=true
kubectl delete -f k8s/deployment.yaml --ignore-not-found=true

# Delete RBAC and namespace
echo "🗑️  Removing RBAC and namespace..."
kubectl delete -f k8s/rbac.yaml --ignore-not-found=true

# Wait for namespace to be deleted
echo "⏳ Waiting for namespace cleanup..."
kubectl wait --for=delete namespace/sre-copilot --timeout=120s || true

echo "✅ MCP Server cleanup completed!"
echo ""
echo "🔍 Verify cleanup with:"
echo "   kubectl get namespaces | grep sre-copilot"
echo "   kubectl get clusterroles | grep k8s-mcp"
echo "   kubectl get clusterrolebindings | grep k8s-mcp"
echo "   kubectl get ingress -n sre-copilot | grep k8s-mcp"
