# Kubernetes MCP Server Integration Guide

## 🎯 Overview
This guide shows how to integrate the Kubernetes MCP Server with your AKS Weather MCP Project to provide SRE capabilities and cluster management tools.

## 📋 What You'll Get
- **MCP Server**: Kubernetes management tools via MCP protocol
- **Web UI**: SRE dashboard for cluster health monitoring
- **Automation**: Programmatic cluster operations
- **Integration**: Works alongside your weather application

## 🚀 Quick Start

### Prerequisites
- AKS cluster deployed and running
- kubectl configured to connect to your cluster
- Docker installed (for local testing)

### Step 1: Deploy MCP Server
```bash
# Make setup script executable
chmod +x mcp-server/setup.sh

# Run the setup script
./mcp-server/setup.sh
```

### Step 2: Access Web UI
```bash
# Port forward to access the Web UI
kubectl -n sre-copilot port-forward svc/k8s-mcp-web 8000:80

# Open in browser
open http://localhost:8000
```

### Step 3: Test MCP Server
```bash
# Run the test script
chmod +x mcp-server/test-mcp.sh
./mcp-server/test-mcp.sh
```

## 🔧 MCP Server Features

### Available Tools
The MCP Server provides these Kubernetes management tools:

| Tool | Description |
|------|-------------|
| `list_contexts()` | List available kube contexts |
| `get_namespaces()` | Get all namespaces |
| `get_nodes()` | Get cluster nodes |
| `get_services()` | Get services in namespace |
| `get_pods()` | Get pods in namespace |
| `get_pod_health()` | Check pod health status |
| `get_deployments()` | Get deployments |
| `describe_resource()` | Describe any resource |
| `get_pod_logs()` | Get pod logs |
| `rollout_status()` | Check deployment rollout |
| `restart_pod()` | Restart a pod |
| `scale_deployment()` | Scale deployment |
| `restart_deployment()` | Restart deployment |
| `cordon_node()` | Cordon a node |
| `uncordon_node()` | Uncordon a node |
| `get_recent_events()` | Get recent events |
| `cluster_health_summary()` | Get cluster health |

### Web UI Features
- **Namespace Management**: Auto-suggest from live namespace list
- **Cluster Health**: Overview of cluster status
- **Node Monitoring**: Readiness table for all nodes
- **Pod Health**: Readiness/liveness status
- **Deployment Status**: Readiness and restart capabilities
- **Event Monitoring**: Recent cluster events
- **Quick Actions**: Restart deployments from UI

## 🌐 Integration with Weather Application

### Monitor Weather Application
```bash
# Get weather app pods
kubectl get pods -n weather-mcp

# Check weather app health
kubectl -n sre-copilot exec -it deployment/k8s-mcp-web -- python -c "
import subprocess
result = subprocess.run(['kubectl', 'get', 'pods', '-n', 'weather-mcp'], capture_output=True, text=True)
print(result.stdout)
"
```

### Automated Operations
The MCP Server can automate:
- **Health Checks**: Monitor weather application pods
- **Restart Operations**: Restart deployments if needed
- **Log Analysis**: Get logs from weather application
- **Scaling**: Scale weather application based on load
- **Event Monitoring**: Track cluster events affecting weather app

## 📱 Using the Web UI

### Access Methods

#### Method 1: Port Forward (Recommended for development)
```bash
kubectl -n sre-copilot port-forward svc/k8s-mcp-web 8000:80
# Open: http://localhost:8000
```

#### Method 2: Ingress (For production)
```yaml
# Create ingress for production access
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: k8s-mcp-ingress
  namespace: sre-copilot
spec:
  rules:
  - host: mcp.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: k8s-mcp-web
            port:
              number: 80
```

### UI Navigation
1. **Dashboard**: Cluster overview and health
2. **Namespaces**: Switch between different namespaces
3. **Pods**: View pod status and health
4. **Deployments**: Manage deployments and restart
5. **Nodes**: Monitor node health
6. **Events**: View recent cluster events

## 🔐 Security Considerations

### RBAC Permissions
The provided RBAC grants:
- ✅ Read access to pods, logs, events, namespaces, nodes
- ✅ Read and patch access to deployments and replicasets
- ✅ Restart capabilities for deployments

### Production Hardening
```yaml
# Example: Tightened RBAC for production
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: k8s-mcp-restricted
  namespace: weather-mcp
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "events"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "patch"]
```

## 🧪 Testing and Troubleshooting

### Test MCP Server Functionality
```bash
# Run comprehensive tests
./mcp-server/test-mcp.sh

# Manual testing
kubectl -n sre-copilot logs -f deploy/k8s-mcp-web
```

### Common Issues
1. **Pod not starting**: Check logs and RBAC permissions
2. **UI not accessible**: Verify port-forwarding
3. **Permission denied**: Check service account permissions

### Debug Commands
```bash
# Check pod status
kubectl -n sre-copilot get pods -o wide

# Check service endpoints
kubectl -n sre-copilot get endpoints

# Check RBAC
kubectl auth can-i get pods --as=system:serviceaccount:sre-copilot:k8s-mcp-sa
```

## 🔄 MCP Client Integration

### Configure MCP Client
```json
{
  "mcpServers": {
    "kubernetes": {
      "command": "python",
      "args": ["src/mcp_server.py"],
      "cwd": "/path/to/MCP_Servers"
    }
  }
}
```

### Example MCP Client Usage
```python
# Example: Using MCP tools programmatically
import asyncio
from mcp import Client

async def main():
    client = Client()
    await client.connect_to("kubernetes")
    
    # Get cluster health
    health = await client.call_tool("cluster_health_summary", {"namespace": "weather-mcp"})
    print(health)
    
    # Get weather app pods
    pods = await client.call_tool("get_pods", {"namespace": "weather-mcp"})
    print(pods)

asyncio.run(main())
```

## 🚀 Production Deployment

### Scaling Considerations
```yaml
# Example: Production deployment
spec:
  replicas: 2
  resources:
    requests:
      cpu: "200m"
      memory: "256Mi"
    limits:
      cpu: "1000m"
      memory: "1Gi"
```

### Monitoring and Alerting
```yaml
# Example: Add monitoring
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: k8s-mcp-monitor
  namespace: sre-copilot
spec:
  selector:
    matchLabels:
      app: k8s-mcp-web
  endpoints:
  - port: http
    path: /metrics
```

## 📚 Next Steps

1. **Deploy the MCP Server** to your AKS cluster
2. **Test the Web UI** functionality
3. **Configure MCP Client** for programmatic access
4. **Integrate with CI/CD** pipelines
5. **Set up monitoring** and alerting
6. **Customize RBAC** for your security requirements

## 🤝 Support

- **Documentation**: Check the MCP Server README
- **Issues**: Report issues on the MCP_Servers repository
- **Community**: Join the Kubernetes MCP community

## 📝 License

The Kubernetes MCP Server is licensed under the same terms as the original repository.
