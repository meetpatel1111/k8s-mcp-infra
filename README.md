# AKS Weather MCP Project

This project deploys a weather application on Azure Kubernetes Service (AKS) with MCP (Model Context Protocol) integration using GitHub Actions for CI/CD.

## Project Structure

```
├── app/                 # Weather application
│   ├── index.js        # Main Node.js application
│   ├── package.json    # Dependencies and scripts
│   ├── Dockerfile      # Container configuration
│   ├── .env.example    # Environment variables template
│   └── tests/          # Test suite
├── terraform/          # Azure infrastructure as code
│   ├── main.tf         # Main Azure resources (AKS, ACR, RG)
│   ├── provider.tf     # Azure provider configuration
│   ├── variables.tf    # Input variables
│   ├── outputs.tf      # Output values
│   ├── backend.tf      # Terraform backend configuration
│   ├── dev.tfvars      # Development environment variables
│   ├── test.tfvars     # Test environment variables
│   └── bootstrap/      # Backend setup scripts
├── k8s/                # Kubernetes manifests
│   ├── weather-deployment.yaml
│   ├── weather-service.yaml
│   └── weather-ingress.yaml
└── .github/workflows/  # GitHub Actions workflows
    └── deploy.yml      # Parameter-based deployment workflow
```

## Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.6.0
- kubectl
- Docker (for building container images)
- GitHub repository with `AZURE_CREDENTIALS` secret

## GitHub Actions Deployment

This project uses a parameter-based GitHub Actions workflow for deployment. Navigate to **Actions** → **One-Click Weather MCP Deployment (Azure)** in your GitHub repository to trigger deployments.

### Deployment Parameters

- **Environment**: Choose between `dev` or `test`
- **Terraform Action**: Select `apply`, `destroy`, or `refresh`
- **Run Security Scan**: Enable/disable security scanning
- **Run Terraform**: Enable/disable infrastructure deployment
- **Run Application Deployment**: Enable/disable application deployment

### Deployment Steps

1. **Security Scan** (optional): Runs tfsec and Trivy security scans
2. **Terraform Operations**: Deploys/destroys/refreshes Azure infrastructure
3. **Application Deployment**: Builds and deploys the weather application to AKS

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

## Required GitHub Secrets

Add these secrets to your GitHub repository:

- `AZURE_CREDENTIALS`: JSON object with Azure service principal credentials
- `OPENAI_API_KEY`: OpenAI API key (if using AI features)
- `GEMINI_API_KEY`: Google Gemini API key (if using AI features)

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
kubectl logs -f deployment/weather-app

# Check pod status
kubectl get pods -l app=weather

# View service endpoints
kubectl get svc weather-app
```

## API Endpoints

Once deployed, the weather application provides:

- `GET /health` - Health check endpoint
- `GET /weather/current/:city` - Current weather for a city
- `GET /weather/forecast/:city` - 5-day weather forecast
- `POST /mcp/weather` - MCP endpoint for weather data

## Cleanup

To destroy all resources:

1. Go to GitHub Actions → **One-Click Weather MCP Deployment (Azure)**
2. Select your environment
3. Set **Terraform Action** to `destroy`
4. Enable **Run Terraform**
5. Click **Run workflow**

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
