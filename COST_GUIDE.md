# 💰 Cost Management Guide

This guide helps you minimize costs while completing the AZ-104 Portfolio Project.

## Free Tier Overview

### Azure Free Account Benefits
| Benefit | Duration | Details |
|---------|----------|---------|
| $200 Credit | First 30 days | Use on any service |
| Free Services | 12 months | Specific services (see below) |
| Always Free | Forever | 55+ services |

**Sign up:** [azure.microsoft.com/free](https://azure.microsoft.com/en-us/free/)

### Azure for Students
| Benefit | Duration | Details |
|---------|----------|---------|
| $100 Credit | 12 months | No credit card required |
| Free Services | 12 months | Same as free account |

**Sign up:** [azure.microsoft.com/free/students](https://azure.microsoft.com/en-us/free/students/)

---

## Free Services Used in This Project

### Always Free (No Expiration)
| Service | Free Amount | Used In |
|---------|-------------|---------|
| Azure Active Directory | Free tier | Module 01 |
| Azure Policy | Unlimited | Module 01 |
| Network Security Groups | Unlimited | Module 04 |
| Virtual Network | Unlimited | Module 04 |
| Load Balancer (Basic) | Unlimited | Module 04 |
| Azure DNS (Internal) | Unlimited | Module 04 |

### 12-Month Free Tier
| Service | Free Amount | Used In |
|---------|-------------|---------|
| Virtual Machines (B1S) | 750 hours/month | Module 03 |
| Storage (LRS) | 5 GB blob, 5 GB file | Module 02 |
| SQL Database | 250 GB (S0) | N/A |
| Cosmos DB | 1000 RU/s | N/A |
| App Service | 10 apps (F1) | Module 05 |
| Functions | 1M requests/month | Module 07 |
| Log Analytics | 5 GB/month | Module 06 |

---

## Cost Estimates by Module

### Module 01: Identity & Governance
| Resource | Cost | Notes |
|----------|------|-------|
| Resource Groups | FREE | No charge |
| Tags | FREE | No charge |
| Azure Policy | FREE | Built-in policies |
| Custom Roles | FREE | RBAC included |
| **Total** | **$0** | |

### Module 02: Storage
| Resource | Cost | Notes |
|----------|------|-------|
| Storage Account (LRS) | ~$0.02/GB | 5 GB free |
| Blob Operations | ~$0.004/10K | Minimal |
| File Share | ~$0.06/GB | 5 GB free |
| **Total** | **~$0-$0.50** | If under free tier |

### Module 03: Virtual Machines
| Resource | Cost | Notes |
|----------|------|-------|
| B1S Linux VM | ~$0.01/hr | 750 hrs free |
| B2S Windows VM | ~$0.05/hr | NOT free |
| Managed Disk (32GB) | ~$1.54/month | |
| Public IP | ~$0.004/hr | |
| **Total** | **~$5-15** | Delete promptly |

### Module 04: Networking
| Resource | Cost | Notes |
|----------|------|-------|
| Virtual Network | FREE | |
| Subnets | FREE | |
| NSGs | FREE | |
| Load Balancer (Basic) | FREE | |
| Azure DNS (Private) | FREE | |
| **Total** | **$0** | |

### Module 05: App Services
| Resource | Cost | Notes |
|----------|------|-------|
| F1 Free Plan | FREE | 60 min CPU/day |
| S1 Standard Plan | ~$0.10/hr | For slots |
| Deployment Slots | Included | With S1+ |
| **Total** | **~$0-$5** | Use F1 when possible |

### Module 06: Monitoring
| Resource | Cost | Notes |
|----------|------|-------|
| Log Analytics | ~$2.30/GB | 5 GB free |
| Azure Monitor | FREE | Basic metrics |
| Alerts | FREE | First 100 alert rules |
| **Total** | **~$0** | Under free tier |

### Module 07: Advanced Networking
| Resource | Cost | Notes |
|----------|------|-------|
| Application Gateway | ~$0.20/hr | ⚠️ Expensive! |
| WAF | ~$0.12/hr | Included with AppGW |
| VPN Gateway | ~$0.04/hr | ⚠️ $30+/month |
| Private Endpoints | ~$0.01/hr | |
| **Total** | **~$5-20** | Delete immediately! |

### Module 08: Capstone
| Resource | Estimated | Notes |
|----------|-----------|-------|
| All resources combined | ~$10-30 | Complete within 1 day |

---

## Cost Saving Tips

### 1. Use Free Tier Resources
```bash
# Always use B1S for VMs
az vm create --size "Standard_B1s" ...

# Use F1 for App Service when possible
az appservice plan create --sku "F1" ...

# Use Standard LRS for storage
az storage account create --sku "Standard_LRS" ...
```

### 2. Stop VMs When Not in Use
```bash
# Deallocate VM (stops compute charges)
az vm deallocate --name vm-name --resource-group rg-name

# Start when needed
az vm start --name vm-name --resource-group rg-name
```

### 3. Use Auto-Shutdown
```bash
# Auto-shutdown at 7 PM
az vm auto-shutdown --name vm-name --resource-group rg-name --time 1900
```

### 4. Delete Expensive Resources Immediately
After completing exercises with:
- Application Gateway
- VPN Gateway
- Premium storage
- Standard App Service Plans

### 5. Set Budget Alerts
```bash
# Create a budget (via Portal is easier)
# Go to: Cost Management → Budgets → Add
# Set monthly budget: $25
# Alert at: 50%, 75%, 100%
```

---

## Monitoring Your Costs

### Check Current Spend
1. Go to **Cost Management + Billing**
2. Click **Cost analysis**
3. View by:
   - Resource group
   - Service name
   - Time period

### Set Up Alerts
1. Go to **Cost Management + Billing**
2. Click **Budgets**
3. Create budget with email alerts

### Azure CLI Cost Check
```bash
# View cost for current billing period
az consumption usage list \
  --start-date 2024-01-01 \
  --end-date 2024-01-31 \
  --output table
```

---

## Cleanup Procedures

### Quick Cleanup (Delete Everything)
```bash
# List all resource groups
az group list --output table

# Delete all project resource groups
az group delete --name "rg-contoso-prod-eastus-001" --yes --no-wait
az group delete --name "rg-contoso-dev-eastus-001" --yes --no-wait
az group delete --name "rg-contoso-shared-eastus-001" --yes --no-wait
```

### Verify Cleanup
```bash
# Confirm deletion (wait a few minutes)
az group list --output table

# Should show no contoso resource groups
```

### What to Check After Cleanup
1. **Resource Groups**: Should be empty/deleted
2. **Disks**: Orphaned disks may remain
3. **Public IPs**: Check for unattached IPs
4. **Network Interfaces**: Delete orphaned NICs

```bash
# Find orphaned disks
az disk list --query "[?managedBy==null].[name,resourceGroup]" --output table

# Find orphaned public IPs
az network public-ip list --query "[?ipConfiguration==null].[name,resourceGroup]" --output table

# Find orphaned NICs
az network nic list --query "[?virtualMachine==null].[name,resourceGroup]" --output table
```

---

## Emergency: Unexpected Charges

### If You See Unexpected Charges

1. **Identify the resource**
   ```bash
   az resource list --output table
   ```

2. **Check cost analysis** in Azure Portal

3. **Delete the resource immediately**
   ```bash
   az resource delete --ids <resource-id>
   ```

4. **Contact Azure Support** if charges are significant
   - Free accounts get free support
   - Explain it was a learning environment

### Common Culprits
- VPN Gateway left running (~$30/month)
- Application Gateway left running (~$140/month)
- Premium storage accounts
- Windows VMs (higher cost than Linux)
- Public IP addresses (small but adds up)

---

## Cost Summary Table

| Module | Expected Cost | Risk Level |
|--------|--------------|------------|
| 01 - Identity | $0 | 🟢 None |
| 02 - Storage | $0-$1 | 🟢 Low |
| 03 - VMs | $5-$15 | 🟡 Medium |
| 04 - Networking | $0 | 🟢 None |
| 05 - App Services | $0-$5 | 🟢 Low |
| 06 - Monitoring | $0 | 🟢 None |
| 07 - Advanced | $5-$20 | 🔴 High |
| 08 - Capstone | $10-$30 | 🟡 Medium |

**Total Project Cost: ~$20-70** (if you clean up promptly)

---

## Best Practices Summary

1. ✅ Always delete resources after each module
2. ✅ Use free tier sizes (B1S, F1, Standard_LRS)
3. ✅ Set up budget alerts
4. ✅ Check costs daily during active learning
5. ✅ Use auto-shutdown for VMs
6. ✅ Complete Module 07 exercises in one sitting
7. ✅ Verify cleanup with `az group list`

---

*Last Updated: 2024*
