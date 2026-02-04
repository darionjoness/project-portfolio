# Module 05: App Services

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 2-3 hours](https://img.shields.io/badge/Time-2--3%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Create and configure Azure App Service plans
- Deploy web applications to App Service
- Configure deployment slots for staging environments
- Set up custom domains and SSL certificates
- Implement auto-scaling based on metrics
- Configure application settings and connection strings

---

## 📖 Scenario

Contoso Consulting is modernizing their web presence. They need:

1. **Company Website**: A public-facing website for customers
2. **Employee Portal**: An internal application for staff
3. **Zero-downtime deployments**: Ability to test changes before going live

Your task is to deploy these applications using Azure App Service with proper staging environments and scaling.

---

## 📚 Pre-Reading (Optional but Recommended)

| Topic | Microsoft Learn Link | Time |
|-------|---------------------|------|
| App Service Overview | [App Service overview](https://learn.microsoft.com/en-us/azure/app-service/overview) | 10 min |
| App Service Plans | [App Service plan overview](https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans) | 10 min |
| Deployment Slots | [Set up staging environments](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots) | 15 min |
| Scaling | [Scale up an app](https://learn.microsoft.com/en-us/azure/app-service/manage-scale-up) | 10 min |

---

## 💡 Key Concepts

### App Service Plan Tiers

| Tier | Features | Use Case | Cost |
|------|----------|----------|------|
| **Free (F1)** | 1 GB storage, 60 min/day | Testing | FREE |
| **Shared (D1)** | Custom domains | Dev/Test | $ |
| **Basic (B1-B3)** | Manual scale, staging slots | Small production | $$ |
| **Standard (S1-S3)** | Auto-scale, 5 slots | Production | $$$ |
| **Premium (P1-P3)** | More scale, VNet integration | Enterprise | $$$$ |

### Deployment Options
| Method | Best For |
|--------|----------|
| Git (Local/GitHub) | Developers |
| Azure DevOps | CI/CD pipelines |
| ZIP Deploy | Quick deployments |
| FTP | Legacy apps |
| Containers | Docker apps |

---

## 🔧 Exercise 1: Create an App Service Plan

### Tasks

#### 1.1 Create Free Tier App Service Plan (for testing)

```bash
# Create resource group if not exists
az group create \
  --name "rg-contoso-prod-eastus-001" \
  --location "eastus"

# Create Free tier App Service Plan
az appservice plan create \
  --name "asp-contoso-free" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --sku "F1" \
  --is-linux

# Verify
az appservice plan show \
  --name "asp-contoso-free" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --output table
```

#### 1.2 Create Standard Tier Plan (for production features)

```bash
# Create Standard tier plan (needed for deployment slots)
az appservice plan create \
  --name "asp-contoso-prod" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --sku "S1" \
  --is-linux \
  --tags Environment=Production

# View plan details
az appservice plan show \
  --name "asp-contoso-prod" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --query "{Name:name, Tier:sku.tier, Size:sku.name, Workers:sku.capacity}"
```

### ✅ Checkpoint
- Two App Service plans created (Free and Standard)

---

## 🔧 Exercise 2: Deploy a Web Application

### Tasks

#### 2.1 Create a Web App

```bash
# Generate unique name
WEBAPP_NAME="app-contoso-web-$(date +%s | tail -c 6)"

# Create web app
az webapp create \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --plan "asp-contoso-prod" \
  --runtime "NODE:18-lts" \
  --tags Environment=Production Application=Website

# Save the name for later
echo "Web App created: $WEBAPP_NAME"
echo "URL: https://${WEBAPP_NAME}.azurewebsites.net"
```

#### 2.2 Deploy Sample Application

```bash
# Create a simple Node.js app
mkdir -p ~/contoso-website
cd ~/contoso-website

# Create package.json
cat << 'EOF' > package.json
{
  "name": "contoso-website",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js"
  }
}
EOF

# Create server.js
cat << 'EOF' > server.js
const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Contoso Consulting</title>
      <style>
        body { font-family: Arial; margin: 40px; background: #f0f0f0; }
        .container { background: white; padding: 40px; border-radius: 10px; max-width: 600px; margin: auto; }
        h1 { color: #0078d4; }
        .env { background: #e8f4fd; padding: 10px; border-radius: 5px; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🏢 Welcome to Contoso Consulting</h1>
        <p>Your trusted partner for cloud solutions.</p>
        <div class="env">
          <strong>Environment:</strong> ${process.env.ENVIRONMENT || 'Development'}<br>
          <strong>Server Time:</strong> ${new Date().toISOString()}
        </div>
      </div>
    </body>
    </html>
  `);
});

server.listen(port, () => {
  console.log(\`Server running on port \${port}\`);
});
EOF

# Create ZIP package
zip -r deploy.zip .

# Deploy to Azure
az webapp deployment source config-zip \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --src deploy.zip

# Cleanup
cd ~
rm -rf ~/contoso-website
```

#### 2.3 Test the Deployment

```bash
# Get the URL
echo "Testing: https://${WEBAPP_NAME}.azurewebsites.net"

# Test with curl
curl -s "https://${WEBAPP_NAME}.azurewebsites.net" | head -20
```

### ✅ Checkpoint
- Web app deployed and accessible

---

## 🔧 Exercise 3: Application Settings

### Background
Application settings are environment variables for your app, useful for configuration without code changes.

### Tasks

#### 3.1 Configure Application Settings

**Portal Method:**
1. Navigate to your Web App
2. Go to **Configuration** → **Application settings**
3. Click **+ New application setting**
4. Add settings

**CLI Method:**
```bash
# Add application settings
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --settings \
    ENVIRONMENT="Production" \
    COMPANY_NAME="Contoso Consulting" \
    API_ENDPOINT="https://api.contoso.com"

# View settings
az webapp config appsettings list \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --output table
```

#### 3.2 Configure Connection Strings

```bash
# Add a connection string (example)
az webapp config connection-string set \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --connection-string-type SQLAzure \
  --settings \
    DefaultConnection="Server=tcp:server.database.windows.net;Database=contosodb;User ID=admin;Password=secret;"
```

#### 3.3 View Updated Application

```bash
# Refresh the page to see ENVIRONMENT variable
curl -s "https://${WEBAPP_NAME}.azurewebsites.net" | grep -A2 "Environment"
```

---

## 🔧 Exercise 4: Deployment Slots

### Background
Deployment slots allow you to deploy and test changes before swapping to production.

### Tasks

#### 4.1 Create a Staging Slot

```bash
# Create staging slot
az webapp deployment slot create \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --slot "staging"

# View slots
az webapp deployment slot list \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --output table
```

#### 4.2 Configure Staging Slot Settings

```bash
# Set staging-specific settings (slot setting = doesn't swap)
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --slot "staging" \
  --slot-settings ENVIRONMENT="Staging"

# Also set regular settings that will swap
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --slot "staging" \
  --settings COMPANY_NAME="Contoso Consulting"
```

#### 4.3 Deploy to Staging

```bash
# Create updated version for staging
mkdir -p ~/contoso-staging
cd ~/contoso-staging

# Create package.json
cat << 'EOF' > package.json
{
  "name": "contoso-website",
  "version": "2.0.0",
  "scripts": {
    "start": "node server.js"
  }
}
EOF

# Create updated server.js
cat << 'EOF' > server.js
const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Contoso Consulting - V2</title>
      <style>
        body { font-family: Arial; margin: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .container { background: white; padding: 40px; border-radius: 15px; max-width: 600px; margin: auto; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }
        h1 { color: #667eea; }
        .new-badge { background: #28a745; color: white; padding: 5px 10px; border-radius: 5px; font-size: 12px; }
        .env { background: #e8f4fd; padding: 15px; border-radius: 8px; margin-top: 20px; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🏢 Contoso Consulting <span class="new-badge">V2.0</span></h1>
        <p>Your trusted partner for cloud solutions.</p>
        <p><strong>New Features:</strong></p>
        <ul>
          <li>✨ Updated design</li>
          <li>🚀 Improved performance</li>
          <li>🔒 Enhanced security</li>
        </ul>
        <div class="env">
          <strong>Environment:</strong> ${process.env.ENVIRONMENT || 'Development'}<br>
          <strong>Version:</strong> 2.0.0<br>
          <strong>Server Time:</strong> ${new Date().toISOString()}
        </div>
      </div>
    </body>
    </html>
  `);
});

server.listen(port);
EOF

# Deploy to staging
zip -r deploy.zip .
az webapp deployment source config-zip \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --slot "staging" \
  --src deploy.zip

# Cleanup
cd ~
rm -rf ~/contoso-staging
```

#### 4.4 Test Staging Slot

```bash
# Staging URL format: <app-name>-<slot-name>.azurewebsites.net
STAGING_URL="https://${WEBAPP_NAME}-staging.azurewebsites.net"
echo "Staging URL: $STAGING_URL"

# Test staging
curl -s "$STAGING_URL" | head -30
```

#### 4.5 Swap Slots (Zero-Downtime Deployment)

```bash
# Preview what will be swapped
az webapp deployment slot list \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001"

# Swap staging to production
az webapp deployment slot swap \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --slot "staging" \
  --target-slot "production"

# Verify production now has v2
curl -s "https://${WEBAPP_NAME}.azurewebsites.net" | head -30
```

### ✅ Checkpoint
- Staging slot created and deployed
- Successfully swapped to production

---

## 🔧 Exercise 5: Scaling

### Tasks

#### 5.1 Manual Scale Out

```bash
# Scale the App Service Plan to 2 instances
az appservice plan update \
  --name "asp-contoso-prod" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --number-of-workers 2

# Verify
az appservice plan show \
  --name "asp-contoso-prod" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --query "sku.capacity"
```

#### 5.2 Configure Auto-Scale (Portal Walkthrough)

**Portal Method:**
1. Navigate to your App Service Plan
2. Click **Scale out (App Service plan)**
3. Click **Custom autoscale**
4. Configure:
   - **Minimum instances**: 1
   - **Maximum instances**: 3
   - **Default instances**: 1
5. Add a rule:
   - **Metric**: CPU Percentage
   - **Operator**: Greater than
   - **Threshold**: 70%
   - **Duration**: 5 minutes
   - **Action**: Increase count by 1
6. Add scale-in rule:
   - **Metric**: CPU Percentage
   - **Operator**: Less than
   - **Threshold**: 30%
   - **Duration**: 5 minutes
   - **Action**: Decrease count by 1
7. Save

**CLI Method:**
```bash
# Create autoscale setting
az monitor autoscale create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --resource "asp-contoso-prod" \
  --resource-type "Microsoft.Web/serverfarms" \
  --name "autoscale-contoso" \
  --min-count 1 \
  --max-count 3 \
  --count 1

# Add scale-out rule (CPU > 70%)
az monitor autoscale rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --autoscale-name "autoscale-contoso" \
  --condition "CpuPercentage > 70 avg 5m" \
  --scale out 1

# Add scale-in rule (CPU < 30%)
az monitor autoscale rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --autoscale-name "autoscale-contoso" \
  --condition "CpuPercentage < 30 avg 5m" \
  --scale in 1
```

#### 5.3 Scale Back Down

```bash
# Scale back to 1 instance (save costs)
az appservice plan update \
  --name "asp-contoso-prod" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --number-of-workers 1
```

---

## 🔧 Exercise 6: Monitoring and Logs

### Tasks

#### 6.1 Enable Application Logging

```bash
# Enable file system logging
az webapp log config \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001" \
  --application-logging filesystem \
  --level information \
  --web-server-logging filesystem

# View logs in real-time
az webapp log tail \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001"
# Press Ctrl+C to exit
```

#### 6.2 View Metrics

**Portal Method:**
1. Navigate to your Web App
2. Click **Metrics** under Monitoring
3. Add metrics:
   - HTTP Server Errors
   - Response Time
   - CPU Time
   - Memory working set

**CLI Method:**
```bash
# Get average response time for last hour
az monitor metrics list \
  --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-contoso-prod-eastus-001/providers/Microsoft.Web/sites/$WEBAPP_NAME" \
  --metric "AverageResponseTime" \
  --interval PT1H \
  --output table
```

---

## 📝 Module Summary

### What You Accomplished
- ✅ Created App Service plans (Free and Standard tiers)
- ✅ Deployed a Node.js web application
- ✅ Configured application settings and connection strings
- ✅ Set up deployment slots for staging
- ✅ Performed zero-downtime slot swap
- ✅ Configured manual and auto-scaling
- ✅ Enabled logging and monitoring

### Key Concepts Learned
| Concept | Purpose |
|---------|---------|
| App Service Plan | Defines compute resources for apps |
| Deployment Slots | Test changes before production |
| Slot Swap | Zero-downtime deployments |
| App Settings | Configuration without code changes |
| Auto-scale | Automatic capacity management |

### AZ-104 Skills Practiced
- Create and configure an App Service
- Configure scaling settings
- Deploy an App Service
- Configure deployment slots

---

## 🧹 Cleanup

```bash
# Delete autoscale setting
az monitor autoscale delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "autoscale-contoso"

# Delete web app (includes slots)
az webapp delete \
  --name $WEBAPP_NAME \
  --resource-group "rg-contoso-prod-eastus-001"

# Delete App Service Plans
az appservice plan delete \
  --name "asp-contoso-prod" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --yes

az appservice plan delete \
  --name "asp-contoso-free" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --yes

echo "Cleanup complete!"
```

---

## ➡️ Next Steps

👉 [Continue to Module 06: Monitoring](../06-monitoring/README.md)

---

## 📚 Additional Resources

- [App Service Documentation](https://learn.microsoft.com/en-us/azure/app-service/)
- [App Service Pricing](https://azure.microsoft.com/en-us/pricing/details/app-service/)
- [Deployment Best Practices](https://learn.microsoft.com/en-us/azure/app-service/deploy-best-practices)
