# AZ-305 Cost Guide

## Overview

AZ-305 focuses on **design**, not deployment. Most of your learning involves creating documentation, diagrams, and decision frameworks. However, some exercises create resources for validation.

---

## Cost-Conscious Approach

### Design Exercises (Zero Cost)
Most modules focus on:
- Architecture diagrams
- Technical specifications
- ADRs (Architecture Decision Records)
- Sizing calculations
- Policy definitions

These are documentation exercises—no Azure resources needed!

### Validation Exercises (Minimal Cost)
Some exercises deploy resources to validate designs:

| Module | Resources | Estimated Cost | Duration |
|--------|-----------|----------------|----------|
| 01 - Identity | Entra ID (free tier) | $0 | Ongoing |
| 02 - Data Storage | Cosmos DB serverless | $0-5 | 2-3 hours |
| 03 - Business Continuity | Recovery Services Vault | $0-5 | 2-3 hours |
| 04 - Infrastructure | VNets, NSGs | $0 | Ongoing |
| 05 - Migrations | Assessment tools | $0 | 2-3 hours |
| 06 - Capstone | Design only | $0 | Ongoing |

**Total estimated cost: $0-$10**

---

## Free Tier Resources

### Always Free
- **Azure Active Directory** - Free tier (50,000 objects)
- **Resource Groups** - Unlimited
- **Virtual Networks** - No charge for VNets themselves
- **Network Security Groups** - No charge
- **Azure Policy** - No charge for policy definitions
- **Management Groups** - No charge
- **Azure Advisor** - Free
- **Azure Service Health** - Free

### Free Trial Credits
- **Azure Free Account** - $200 credit for 30 days
- **Visual Studio Subscription** - $50-150/month
- **Azure for Students** - $100 credit

### Serverless (Pay Only for Use)
- **Cosmos DB Serverless** - $0.25 per million RUs
- **Azure Functions Consumption** - First 1M executions free
- **Logic Apps Consumption** - First few thousand runs free

---

## Cost Optimization for Learning

### 1. Use Design Tools Instead of Azure
For learning architecture concepts:

| Instead of... | Use... |
|---------------|--------|
| Deploying resources | Draw.io / Lucidchart |
| Running workloads | Azure Pricing Calculator |
| Testing HA | Architecture documentation |
| Migration tools | Assessment spreadsheets |

### 2. Clean Up Immediately
If you deploy validation resources:

```powershell
# Delete entire resource group
az group delete --name rg-az305-learning --yes --no-wait
```

### 3. Set Budget Alerts

```powershell
# Create a $10 budget with alerts
az consumption budget create \
  --budget-name az305-learning \
  --amount 10 \
  --time-grain monthly \
  --category cost \
  --resource-group rg-az305-learning
```

### 4. Use Azure Pricing Calculator
Always design with cost in mind:
[Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

---

## Module-Specific Guidance

### Module 01: Identity and Governance
**Cost: $0**
- Entra ID free tier supports all exercises
- Conditional Access requires P1/P2 (use trial if needed)
- All governance (Management Groups, Policy) is free

### Module 02: Data Storage
**Cost: $0-5**
- Cosmos DB serverless for brief testing
- Storage accounts with minimal data
- Clean up within 1-2 hours

### Module 03: Business Continuity
**Cost: $0-5**
- Recovery Services Vault: Free if no actual backups
- Traffic Manager: Minimal cost for profile only
- Focus on documentation, not deployment

### Module 04: Infrastructure
**Cost: $0**
- VNets, subnets, NSGs are free
- Don't deploy VMs for testing
- Use network diagrams instead

### Module 05: Migrations
**Cost: $0**
- Azure Migrate is free for assessment
- Don't actually migrate anything
- Focus on planning documents

### Module 06: Capstone
**Cost: $0**
- Pure design exercise
- All deliverables are documents
- No Azure deployment required

---

## When Real Deployment is Needed

If you must deploy for validation:

### Cheapest Compute Options
```powershell
# B1s VM (cheapest)
az vm create \
  --name test-vm \
  --size Standard_B1s \
  --image Ubuntu2204

# F1 App Service (free tier)
az appservice plan create \
  --name test-plan \
  --sku F1
```

### Cheapest Storage Options
```powershell
# LRS storage (cheapest redundancy)
az storage account create \
  --name teststore$(date +%s) \
  --sku Standard_LRS

# Cosmos DB serverless
az cosmosdb create \
  --name testcosmos \
  --capabilities EnableServerless
```

### Cheapest Database Options
```powershell
# SQL Database Basic tier
az sql db create \
  --name testdb \
  --server testserver \
  --service-objective Basic

# PostgreSQL Flexible (Burstable B1ms)
az postgres flexible-server create \
  --name testpg \
  --sku-name Standard_B1ms
```

---

## Cost Monitoring

### Check Current Spend
```powershell
# View cost analysis
az consumption usage list \
  --start-date 2024-01-01 \
  --end-date 2024-01-31 \
  --query "[].{Name:instanceName, Cost:pretaxCost}"
```

### Azure Portal Cost Analysis
1. Go to **Cost Management + Billing**
2. Select **Cost analysis**
3. Filter by resource group: `rg-az305-*`

---

## Emergency Cost Control

If costs are unexpected:

### Stop All VMs
```powershell
az vm stop --ids $(az vm list --query "[].id" -o tsv)
az vm deallocate --ids $(az vm list --query "[].id" -o tsv)
```

### Delete Learning Resources
```powershell
# List all AZ-305 resource groups
az group list --query "[?starts_with(name, 'rg-az305')].name" -o tsv

# Delete all of them
az group list --query "[?starts_with(name, 'rg-az305')].name" -o tsv | \
  ForEach-Object { az group delete --name $_ --yes --no-wait }
```

---

## The AZ-305 Advantage

Unlike hands-on admin exams, AZ-305 tests your **design ability**:
- You don't need to deploy to learn
- Architecture diagrams teach the same concepts
- Documentation exercises build portfolio value
- Cost calculations are part of the exam!

**Focus on design, not deployment. Your wallet will thank you!** 💰
