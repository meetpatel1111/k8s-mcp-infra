# Kubernetes MCP Server Integration

## Overview
This directory contains the Kubernetes manifests and setup instructions for deploying the Kubernetes MCP Server and SRE Web UI to your AKS cluster using nip.io for external access.

## Features
- **MCP Tools**: Kubernetes management actions via MCP protocol
- **Web UI**: SRE dashboard for cluster health and operations
- **RBAC**: Proper permissions for cluster operations
- **Containerized**: Docker-based deployment
- **External Access**: Uses nip.io for web access like other services

## Available MCP Tools
- `list_contexts()` - List available kube contexts
- `get_namespaces()` - Get all namespaces
- `get_nodes()` - Get cluster nodes
- `get_services()` - Get services in namespace
- `get_pods()` - Get pods in namespace
- `get_pod_health()` - Check pod health status
- `get_deployments()` - Get deployments
- `describe_resource()` - Describe any resource
- `get_pod_logs()` - Get pod logs
- `rollout_status()` - Check deployment rollout
- `restart_pod()` - Restart a pod
- `scale_deployment()` - Scale deployment
- `restart_deployment()` - Restart deployment
- `cordon_node()` - Cordon a node
- `uncordon_node()` - Uncordon a node
- `get_recent_events()` - Get recent events
- `cluster_health_summary()` - Get cluster health

## Deployment Steps

### Prerequisites
- AKS cluster deployed and running
- kubectl configured to connect to your cluster
- NGINX Ingress Controller deployed (for external access)
- Docker installed (for local testing)

### Step 1: Deploy MCP Server
```bash
# Make setup script executable
chmod +x mcp-server/setup.sh

# Run the setup script
./mcp-server/setup.sh
```

The setup script will:
- Auto-detect external IP from NGINX ingress controller
- Deploy RBAC, namespace, and application
- Create ingress for external access using nip.io
- Display the Web UI URL

### Step 2: Access Web UI
After deployment, you'll get a URL like:
```
MCP Server Web UI URL: http://k8s-mcp.52.183.12.45.nip.io/
```

### Step 3: Verify Deployment
```bash
kubectl -n sre-copilot get pods
kubectl -n sre-copilot get services
kubectl -n sre-copilot get ingress
kubectl -n sre-copilot logs deploy/k8s-mcp-web
```

## External Access with nip.io

### URL Pattern
- **MCP Server Web UI**: `http://k8s-mcp.${EXTERNAL_IP}.nip.io/`
- **NGINX Demo**: `http://nginx.${EXTERNAL_IP}.nip.io/`
- **K8sGPT API**: `http://k8sgpt.${EXTERNAL_IP}.nip.io/`

### Ingress Configuration
The ingress is automatically configured using the external IP from your NGINX ingress controller:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: k8s-mcp-ingress
  namespace: sre-copilot
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: k8s-mcp.${EXTERNAL_IP}.nip.io
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

## MCP Server Usage

### Local Testing
```bash
# Use your local temp_mcp_server
cd temp_mcp_server
python -m venv .venv
source .venv/bin/activate
pip install -e .[dev]

# Run MCP server
python src/mcp_server.py
```

### Container Usage
```bash
# Build image from your local directory
cd temp_mcp_server
docker build -t k8s-mcp-mvp:latest .

# Run MCP server container
docker run --rm -it \
  -v "$HOME/.kube:/kube:ro" \
  -e KUBECONFIG=/kube/config \
  k8s-mcp-mvp:latest mcp
```

## Configuration

### Environment Variables
- `KUBECONFIG`: Path to kubeconfig file (default: ~/.kube/config)
- `EXTERNAL_IP`: External IP for nip.io URLs (auto-detected)

### RBAC Permissions
The provided RBAC grants permissions for:
- Reading pods, logs, events, namespaces, nodes
- Reading and patching deployments and replicasets
- Restarting deployments

### Security Notes
- The provided RBAC is broad enough for MVP use
- Consider tightening permissions for production
- Review RBAC policies before production deployment

## Troubleshooting

### Common Issues
1. **External IP not detected**: Set `EXTERNAL_IP` manually
2. **Ingress not working**: Ensure NGINX ingress controller is deployed
3. **Pod not starting**: Check logs and RBAC permissions
4. **UI not accessible**: Verify nip.io URL and ingress status

### Debug Commands
```bash
# Check external IP
kubectl get service -l app=nginx-ingress-controller

# Check pod status
kubectl -n sre-copilot get pods -o wide

# Check ingress status
kubectl -n sre-copilot get ingress

# Check events
kubectl -n sre-copilot get events

# Check logs
kubectl -n sre-copilot logs -f deploy/k8s-mcp-web
```

## Integration with Weather MCP Project

The Kubernetes MCP Server can be used alongside your weather application to:
- Monitor the weather application pods
- Restart deployments if needed
- Check cluster health
- Automate SRE tasks via MCP protocol
- Access all services via consistent nip.io URLs

## Service URLs Summary

After deployment, you'll have access to:
- **Weather App**: `http://weather.${EXTERNAL_IP}.nip.io/`
- **NGINX Demo**: `http://nginx.${EXTERNAL_IP}.nip.io/`
- **K8sGPT API**: `http://k8sgpt.${EXTERNAL_IP}.nip.io/`
- **MCP Server Web UI**: `http://k8s-mcp.${EXTERNAL_IP}.nip.io/`

## Next Steps
1. Deploy the manifests to your AKS cluster
2. Test the Web UI functionality via nip.io URL
3. Configure MCP client to use the server
4. Integrate with your existing workflows
