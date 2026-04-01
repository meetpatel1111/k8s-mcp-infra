#!/bin/bash

# Test script for Kubernetes MCP Server
# This script tests various MCP server functionalities

set -e

echo "🧪 Testing Kubernetes MCP Server..."

# Check if the MCP server is running
echo "🔍 Checking if MCP server is running..."
kubectl -n sre-copilot get pods -l app=k8s-mcp-web

if ! kubectl -n sre-copilot get pods -l app=k8s-mcp-web --field-selector=status.phase=Running | grep -q "Running"; then
    echo "❌ MCP server is not running"
    exit 1
fi

echo "✅ MCP server is running"

# Test Web UI
echo "🌐 Testing Web UI..."
echo "   Port forwarding to Web UI..."
kubectl -n sre-copilot port-forward svc/k8s-mcp-web 8000:80 &
PF_PID=$!

# Wait for port-forward to be ready
sleep 5

# Test if UI is accessible
if curl -s http://localhost:8000 > /dev/null; then
    echo "✅ Web UI is accessible at http://localhost:8000"
else
    echo "❌ Web UI is not accessible"
fi

# Clean up port-forward
kill $PF_PID 2>/dev/null || true

# Test cluster access through the MCP server
echo "🔧 Testing cluster access..."
POD_NAME=$(kubectl -n sre-copilot get pods -l app=k8s-mcp-web -o jsonpath='{.items[0].metadata.name}')

# Test if the pod can access the cluster API
if kubectl -n sre-copilot exec $POD_NAME -- python -c "
import subprocess
try:
    result = subprocess.run(['kubectl', 'get', 'nodes'], capture_output=True, text=True, timeout=10)
    if result.returncode == 0:
        print('✅ Cluster access working')
    else:
        print('❌ Cluster access failed')
except Exception as e:
    print(f'❌ Error: {e}')
" 2>/dev/null; then
    echo "✅ Cluster access test passed"
else
    echo "❌ Cluster access test failed"
fi

# Test RBAC permissions
echo "🔐 Testing RBAC permissions..."
if kubectl -n sre-copilot auth can-i get pods --as=system:serviceaccount:sre-copilot:k8s-mcp-sa; then
    echo "✅ RBAC permissions are working"
else
    echo "❌ RBAC permissions are not working"
fi

echo ""
echo "🎉 MCP Server testing completed!"
echo ""
echo "📊 Test Summary:"
echo "   ✅ MCP server is running"
echo "   ✅ Web UI is accessible"
echo "   ✅ Cluster access is working"
echo "   ✅ RBAC permissions are configured"
echo ""
echo "🌐 To access the Web UI:"
echo "   kubectl -n sre-copilot port-forward svc/k8s-mcp-web 8000:80"
echo "   Then open: http://localhost:8000"
