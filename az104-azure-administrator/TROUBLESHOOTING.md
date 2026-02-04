# 🔧 Troubleshooting Guide

Common issues and solutions for the AZ-104 Portfolio Project.

---

## Table of Contents
- [Azure CLI Issues](#azure-cli-issues)
- [Authentication Problems](#authentication-problems)
- [Resource Creation Failures](#resource-creation-failures)
- [Virtual Machine Issues](#virtual-machine-issues)
- [Networking Problems](#networking-problems)
- [Storage Issues](#storage-issues)
- [App Service Problems](#app-service-problems)
- [Monitoring Issues](#monitoring-issues)
- [Permission Errors](#permission-errors)

---

## Azure CLI Issues

### "az: command not found"

**Problem:** Azure CLI is not installed or not in PATH.

**Solution:**
```bash
# Install Azure CLI
# Windows (PowerShell Admin)
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installation
az --version
```

### "Please run 'az login' to setup account"

**Problem:** Not logged in to Azure.

**Solution:**
```bash
# Interactive login (opens browser)
az login

# Service principal login (automated)
az login --service-principal -u <app-id> -p <password> --tenant <tenant-id>

# Verify login
az account show
```

### "The subscription could not be found"

**Problem:** Wrong subscription selected or subscription expired.

**Solution:**
```bash
# List available subscriptions
az account list --output table

# Set the correct subscription
az account set --subscription "Your Subscription Name"

# Verify
az account show --output table
```

---

## Authentication Problems

### "AADSTS50076: Multi-factor authentication required"

**Problem:** MFA is required but not completed.

**Solution:**
```bash
# Use device code flow for MFA
az login --use-device-code

# Follow the instructions to complete MFA
```

### "AADSTS700016: Application not found"

**Problem:** Azure AD application configuration issue.

**Solution:**
1. Check if using the correct tenant
2. Verify the application registration
3. Try logging out and back in:
```bash
az logout
az login
```

### Token Expired

**Problem:** Authentication token has expired.

**Solution:**
```bash
# Refresh tokens
az account get-access-token --resource https://management.azure.com/

# Or simply re-login
az login
```

---

## Resource Creation Failures

### "The resource group could not be found"

**Problem:** Resource group doesn't exist.

**Solution:**
```bash
# Create the resource group first
az group create --name "rg-name" --location "eastus"

# Verify it exists
az group show --name "rg-name"
```

### "The subscription is not registered to use namespace"

**Problem:** Resource provider not registered.

**Solution:**
```bash
# Register the provider
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Network

# Check registration status
az provider show --namespace Microsoft.Compute --query "registrationState"
```

### "Deployment failed with error"

**Problem:** Various deployment issues.

**Solution:**
```bash
# Get detailed error message
az deployment group show \
  --name "deployment-name" \
  --resource-group "rg-name" \
  --query "properties.error"

# Check activity log
az monitor activity-log list \
  --resource-group "rg-name" \
  --offset 1h \
  --output table
```

### "QuotaExceeded"

**Problem:** Hit subscription limits.

**Solution:**
```bash
# Check current usage
az vm list-usage --location "eastus" --output table

# Request quota increase via Portal:
# Help + Support → New support request → Quota
```

### "The requested size is not available"

**Problem:** VM size not available in the region.

**Solution:**
```bash
# List available sizes
az vm list-sizes --location "eastus" --output table

# Try a different size or region
az vm create --size "Standard_B1s" ...  # B1s is usually available
```

---

## Virtual Machine Issues

### "OS Provisioning Timed Out"

**Problem:** VM failed to boot or configure.

**Solution:**
1. Check boot diagnostics:
```bash
az vm boot-diagnostics get-boot-log --name "vm-name" --resource-group "rg-name"
```

2. Delete and recreate the VM with a different image:
```bash
az vm delete --name "vm-name" --resource-group "rg-name" --yes
az vm create --name "vm-name" --image "Ubuntu2204" ...
```

### Can't SSH/RDP to VM

**Problem:** Connectivity issues.

**Solutions:**

1. **Check VM is running:**
```bash
az vm show --name "vm-name" --resource-group "rg-name" --show-details --query "powerState"
```

2. **Check public IP:**
```bash
az vm show --name "vm-name" --resource-group "rg-name" -d --query "publicIps"
```

3. **Check NSG rules:**
```bash
az network nsg rule list --nsg-name "nsg-name" --resource-group "rg-name" --output table
```

4. **Open the port:**
```bash
az vm open-port --name "vm-name" --resource-group "rg-name" --port 22  # SSH
az vm open-port --name "vm-name" --resource-group "rg-name" --port 3389  # RDP
```

### VM is slow or unresponsive

**Problem:** Resource constraints.

**Solution:**
```bash
# Check VM size
az vm show --name "vm-name" --resource-group "rg-name" --query "hardwareProfile.vmSize"

# Resize VM (requires restart)
az vm resize --name "vm-name" --resource-group "rg-name" --size "Standard_B2s"
```

---

## Networking Problems

### "SubnetNotInSameVnet"

**Problem:** Trying to use a subnet from a different VNet.

**Solution:**
```bash
# List subnets in VNet
az network vnet subnet list --vnet-name "vnet-name" --resource-group "rg-name" --output table

# Use the correct subnet
az vm create --subnet "correct-subnet-name" --vnet-name "correct-vnet-name" ...
```

### "NetworkSecurityGroupCannotBeAttachedToGatewaySubnet"

**Problem:** Can't attach NSG to GatewaySubnet.

**Solution:** GatewaySubnet is special - it cannot have an NSG. Use a different subnet for your resources.

### VMs can't communicate

**Problem:** Network connectivity between VMs.

**Solutions:**

1. **Check they're in the same VNet:**
```bash
az vm show --name "vm1" --resource-group "rg-name" --query "networkProfile.networkInterfaces[0].id"
```

2. **Check NSG rules allow traffic:**
```bash
az network nsg rule list --nsg-name "nsg-name" --resource-group "rg-name" --output table
```

3. **Use Network Watcher to diagnose:**
```bash
az network watcher test-ip-flow \
  --direction Inbound \
  --protocol TCP \
  --local "10.0.1.4:22" \
  --remote "10.0.2.4:12345" \
  --nic "nic-name" \
  --resource-group "rg-name"
```

### "SubnetIsFull"

**Problem:** No more IP addresses available in subnet.

**Solution:**
```bash
# Check subnet address space
az network vnet subnet show \
  --vnet-name "vnet-name" \
  --name "subnet-name" \
  --resource-group "rg-name" \
  --query "addressPrefix"

# Delete unused NICs
az network nic list --query "[?virtualMachine==null].name" --output table
az network nic delete --name "nic-name" --resource-group "rg-name"
```

---

## Storage Issues

### "StorageAccountAlreadyTaken"

**Problem:** Storage account name already exists globally.

**Solution:**
```bash
# Add random suffix to name
az storage account create --name "mystorageaccount$(date +%s)" ...
```

### "AuthorizationFailure" when accessing storage

**Problem:** No permissions or firewall blocking.

**Solutions:**

1. **Check if public access is enabled:**
```bash
az storage account show --name "storage-name" --query "publicNetworkAccess"
```

2. **Add your IP to firewall:**
```bash
az storage account network-rule add \
  --account-name "storage-name" \
  --resource-group "rg-name" \
  --ip-address $(curl -s ifconfig.me)
```

3. **Or allow all networks (for testing only):**
```bash
az storage account update \
  --name "storage-name" \
  --resource-group "rg-name" \
  --default-action Allow
```

### "ContainerNotFound"

**Problem:** Container doesn't exist.

**Solution:**
```bash
# Create the container
az storage container create \
  --name "container-name" \
  --account-name "storage-name"

# List containers
az storage container list --account-name "storage-name" --output table
```

---

## App Service Problems

### "Web app is stopped"

**Problem:** App Service is not running.

**Solution:**
```bash
# Start the app
az webapp start --name "app-name" --resource-group "rg-name"

# Check state
az webapp show --name "app-name" --resource-group "rg-name" --query "state"
```

### "Application Error" when browsing

**Problem:** Application crash or configuration issue.

**Solutions:**

1. **Check logs:**
```bash
az webapp log tail --name "app-name" --resource-group "rg-name"
```

2. **Enable detailed errors:**
```bash
az webapp config set \
  --name "app-name" \
  --resource-group "rg-name" \
  --detailed-error-messages-enabled true
```

3. **Check application settings:**
```bash
az webapp config appsettings list \
  --name "app-name" \
  --resource-group "rg-name" \
  --output table
```

### "Conflict: Site already exists"

**Problem:** App name already taken globally.

**Solution:**
```bash
# Add unique suffix
az webapp create --name "myapp-$(date +%s)" ...
```

### Deployment fails

**Problem:** Code won't deploy.

**Solutions:**

1. **Check deployment log:**
```bash
az webapp log download \
  --name "app-name" \
  --resource-group "rg-name" \
  --log-file deployment.zip
```

2. **Restart after deploy:**
```bash
az webapp restart --name "app-name" --resource-group "rg-name"
```

---

## Monitoring Issues

### "WorkspaceNotFound"

**Problem:** Log Analytics workspace doesn't exist.

**Solution:**
```bash
# Create workspace
az monitor log-analytics workspace create \
  --resource-group "rg-name" \
  --workspace-name "law-name"
```

### No data in Log Analytics

**Problem:** Diagnostic settings not configured.

**Solution:**
```bash
# Configure diagnostic settings
az monitor diagnostic-settings create \
  --name "diag-settings" \
  --resource "resource-id" \
  --workspace "workspace-id" \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --logs '[{"category":"AllLogs","enabled":true}]'
```

### Alerts not firing

**Problem:** Alert conditions not met or misconfigured.

**Solutions:**

1. **Check alert rule:**
```bash
az monitor metrics alert show \
  --name "alert-name" \
  --resource-group "rg-name"
```

2. **Verify action group:**
```bash
az monitor action-group show \
  --name "action-group-name" \
  --resource-group "rg-name"
```

---

## Permission Errors

### "AuthorizationFailed"

**Problem:** Insufficient permissions.

**Solution:**
```bash
# Check your role assignments
az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --output table

# If you need Owner role (have an admin run):
az role assignment create \
  --assignee "your-email@domain.com" \
  --role "Owner" \
  --scope "/subscriptions/<subscription-id>"
```

### "PrincipalNotFound"

**Problem:** User or service principal doesn't exist.

**Solution:**
```bash
# Find the correct principal
az ad user list --display-name "partial-name" --output table

# Or find service principal
az ad sp list --display-name "partial-name" --output table
```

---

## General Debugging Tips

### 1. Enable Verbose Output
```bash
az vm create ... --debug
```

### 2. Check Activity Log
```bash
az monitor activity-log list --resource-group "rg-name" --offset 1h
```

### 3. Use Azure Resource Explorer
Go to: https://resources.azure.com

### 4. Check Resource Health
```bash
az resource show --ids <resource-id> --query "properties.provisioningState"
```

### 5. Start Fresh
When all else fails:
```bash
# Delete and recreate
az group delete --name "rg-name" --yes
az group create --name "rg-name" --location "eastus"
```

---

## Getting More Help

### Microsoft Resources
- [Azure Documentation](https://docs.microsoft.com/azure)
- [Azure Status](https://status.azure.com)
- [Azure Q&A](https://docs.microsoft.com/answers/products/azure)

### Community
- [Stack Overflow - Azure](https://stackoverflow.com/questions/tagged/azure)
- [Reddit - r/azure](https://reddit.com/r/azure)
- [Azure Discord](https://discord.gg/azure)

### Azure Support
- Free accounts include free support for billing/subscription issues
- Paid support plans for technical issues
- [Create support request](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)

---

*If your issue isn't listed here, try searching the error message at [docs.microsoft.com](https://docs.microsoft.com) or [stackoverflow.com](https://stackoverflow.com)*
