# AKS Multi-App Project

This project deploys three working applications on Azure Kubernetes Service (AKS) using GitHub Actions for CI/CD.

## Applications

| App | Description | Image | URL pattern |
|-----|-------------|-------|-------------|
| `app` | WeatherPulse static weather site (built from `app_repo_url`) | Built + pushed to ACR | `http://app.<IP>.nip.io` |
| `vote` | Microsoft Azure Voting App (front + Redis back) | `mcr.microsoft.com/azuredocs/azure-vote-front:v1` / `mcr.microsoft.com/oss/bitnami/redis:6.0.8` | `http://vote.<IP>.nip.io` |
| `game` | 2048 demo game | `alexwhen/docker-2048:latest` | `http://game.<IP>.nip.io` |

## Project Structure

```
├── terraform/          # Azure infrastructure as code
│   ├── main.tf         # Main Azure resources (AKS, ACR, RG)
│   ├── provider.tf     # Azure provider configuration
│   ├── variables.tf    # Input variables (incl. per-app replica counts)
│   ├── outputs.tf      # Output values
│   ├── backend.tf      # Terraform backend configuration
│   ├── dev.tfvars      # Development environment variables
│   ├── test.tfvars     # Test environment variables
│   └── bootstrap/      # Backend setup scripts
├── k8s/                # Kubernetes manifests
│   ├── app-deployment.yaml   # Weather app Deployment + Service + HPA
│   ├── vote-deployment.yaml  # Voting app (front + redis) + Services + HPA
│   ├── game-deployment.yaml  # 2048 game Deployment + Service + HPA
│   └── main-ingress.yaml     # Shared nginx ingress (app/vote/game hosts)
└── .github/workflows/  # GitHub Actions workflows
    ├── deploy.yml      # Parameter-based deployment workflow
    └── delete-k8s.yml  # App deletion workflow
```

## Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.6.0
- kubectl
- Docker (for building container images)
- GitHub repository with `AZURE_CREDENTIALS` secret

## GitHub Actions Deployment

Navigate to **Actions** → **One-Click App Deployment (Azure)** in your GitHub repository to trigger deployments.

### Deployment Parameters

- **Environment**: Choose between `dev` or `test`
- **Terraform Action**: Select `apply`, `destroy`, or `refresh`
- **App Repository URL / Branch / Dockerfile**: Source for the weather `app` image
- **Run Security Scan**: Enable/disable security scanning
- **Run Terraform**: Enable/disable infrastructure deployment
- **Run Application Deployment**: Enable/disable application deployment (deploys all three apps: weather, vote, game)

### Deployment Steps

1. **Security Scan** (optional): Runs tfsec and Trivy security scans
2. **Terraform Operations**: Deploys/destroys/refreshes Azure infrastructure
3. **Application Deployment**: Builds the weather app image, then deploys all three apps + shared ingress to AKS

## Local Development

### Environment Setup

```bash
# Copy environment template
cp app/.env.example app/.env

# Add your OpenWeatherMap API key to app/.env
echo "WEATHER_API_KEY=your_api_key_here" >> app/.env
```

### Running Locally

```bash
# Navigate to app directory
cd app

# Install dependencies
npm install

# Run locally
npm start

# Or in development mode
npm run dev
```

### Building and Testing

```bash
# Run tests
npm test

# Run linting
npm run lint

# Fix linting issues
npm run lint:fix

# Build Docker image
npm run docker:build

# Run Docker container
npm run docker:run
```

## Environment Variables

Key variables to configure in your `.tfvars` files:

- `resource_group_name`: Name of the Azure resource group
- `location`: Azure region (e.g., "East US")
- `cluster_name`: AKS cluster name
- `dns_prefix`: DNS prefix for the AKS cluster
- `weather_app_replicas` / `weather_app_hpa_max`: Weather app scaling
- `vote_app_replicas` / `vote_app_hpa_max`: Voting app scaling
- `game_app_replicas` / `game_app_hpa_max`: 2048 game scaling

## Required GitHub Secrets

Add these secrets to your GitHub repository:

- `AZURE_CREDENTIALS`: JSON object with Azure service principal credentials
- `OPENAI_API_KEY`: OpenAI API key (stored in `weather-app-secret`)
- `GEMINI_API_KEY`: Google Gemini API key (stored in `weather-app-secret`)

Example `AZURE_CREDENTIALS` format:
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "tenantId": "your-tenant-id",
  "subscriptionId": "your-subscription-id"
}
```

## Terraform Backend

The workflow uses a shared Azure Storage Account for Terraform state management. The backend is automatically configured during the first run.

## Monitoring and Logs

After deployment:

```bash
# View pod logs
kubectl logs -f deployment/app
kubectl logs -f deployment/vote-front
kubectl logs -f deployment/game

# Check pod status
kubectl get pods -l app=app
kubectl get pods -l app=vote-front
kubectl get pods -l app=game

# View services and ingress
kubectl get svc app-service vote-front-service game-service
kubectl get ingress
```

## Access URLs

Once deployed (via `nip.io` + ingress-nginx LoadBalancer IP):

- Weather app: `http://app.<DASHED-IP>.nip.io`
- Voting app: `http://vote.<DASHED-IP>.nip.io`
- 2048 game: `http://game.<DASHED-IP>.nip.io`

## Cleanup

To destroy all resources:

1. Go to GitHub Actions → **One-Click App Deployment (Azure)**
2. Select your environment
3. Set **Terraform Action** to `destroy`
4. Enable **Run Terraform**
5. Click **Run workflow**

To delete only the Kubernetes apps (keep infrastructure), use the **Delete Kubernetes Applications (AKS)** workflow with `apps_to_delete: app,vote,game,ingress`.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
