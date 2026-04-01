#!/bin/bash

# Kubernetes MCP Server Setup Script
# This script deploys the MCP Server and Web UI to your AKS cluster

set -e

echo "🚀 Setting up Kubernetes MCP Server..."

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: kubectl is not configured or cluster is not accessible"
    exit 1
fi

echo "✅ kubectl is configured"

# Get external IP for ingress
EXTERNAL_IP=$(kubectl get service -l app=nginx-ingress-controller -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
if [ -z "$EXTERNAL_IP" ]; then
    echo "⚠️  Warning: Could not auto-detect external IP. You may need to set EXTERNAL_IP manually."
    echo "   You can set it with: export EXTERNAL_IP=<your-external-ip>"
fi

# Create namespace and RBAC
echo "📋 Creating namespace and RBAC..."
kubectl apply -f k8s/rbac.yaml

# Deploy the application
echo "🚀 Deploying MCP Server Web UI..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Deploy ingress for external access
if [ ! -z "$EXTERNAL_IP" ]; then
    echo "🌐 Creating ingress for external access..."
    envsubst < k8s/ingress.yaml | kubectl apply -f -
else
    echo "⚠️  Skipping ingress creation (no external IP detected)"
fi

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl -n sre-copilot wait --for=condition=available deployment/k8s-mcp-web --timeout=300s

# Verify deployment
echo "🔍 Verifying deployment..."
kubectl -n sre-copilot get pods
kubectl -n sre-copilot get services

# Get the pod name
POD_NAME=$(kubectl -n sre-copilot get pods -l app=k8s-mcp-web -o jsonpath='{.items[0].metadata.name}')
echo "📦 Pod name: $POD_NAME"

# Check pod logs
echo "📋 Checking pod logs..."
kubectl -n sre-copilot logs deploy/k8s-mcp-web --tail=20

echo "✅ MCP Server deployment completed!"
echo ""
if [ ! -z "$EXTERNAL_IP" ]; then
    echo "🌐 MCP Server Web UI URL: http://k8s-mcp.${EXTERNAL_IP}.nip.io/"
    echo "📊 Access the Web UI at the URL above"
else
    echo "🌐 To access the Web UI locally:"
    echo "   kubectl -n sre-copilot port-forward svc/k8s-mcp-web 8000:80"
    echo "   Then open: http://localhost:8000"
fi
echo ""
echo "🔧 To run the MCP server locally:"
echo "   cd temp_mcp_server"
echo "   python -m venv .venv && source .venv/bin/activate"
echo "   pip install -e .[dev]"
echo "   python src/mcp_server.py"
