# Module 06: Monitoring & Maintenance

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 2-3 hours](https://img.shields.io/badge/Time-2--3%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Configure Azure Monitor for comprehensive visibility
- Create and manage Log Analytics workspaces
- Set up alerts based on metrics and logs
- Use diagnostic settings to capture logs
- Create custom dashboards for monitoring
- Implement Azure Backup and recovery

---

## 📖 Scenario

Contoso Consulting's Azure environment is growing. The IT team needs:

1. **Centralized monitoring**: Single place to view all resource health
2. **Proactive alerting**: Get notified before issues impact users
3. **Log analysis**: Troubleshoot issues with historical data
4. **Custom dashboards**: Executive view of system health

Your task is to implement a comprehensive monitoring solution.

---

## 📚 Pre-Reading (Optional but Recommended)

| Topic | Microsoft Learn Link | Time |
|-------|---------------------|------|
| Azure Monitor | [Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/overview) | 15 min |
| Log Analytics | [Log Analytics overview](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview) | 15 min |
| Alerts | [Azure Monitor alerts](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview) | 10 min |
| KQL Basics | [KQL quick reference](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference) | 15 min |

---

## 💡 Key Concepts

### Azure Monitor Components

```
┌─────────────────────────────────────────────────────────────┐
│                      Azure Monitor                           │
├─────────────────────────────────────────────────────────────┤
│  Data Sources          │  Data Platform    │  Consumption   │
│  ─────────────         │  ─────────────    │  ───────────   │
│  • Applications        │  • Metrics        │  • Dashboards  │
│  • VMs & Containers    │  • Logs           │  • Alerts      │
│  • Azure Resources     │                   │  • Workbooks   │
│  • Custom Sources      │                   │  • Power BI    │
└─────────────────────────────────────────────────────────────┘
```

### Log Analytics Pricing Tiers

| Tier | Data Included | Best For | Cost |
|------|---------------|----------|------|
| Pay-as-you-go | None | Small deployments | ~$2.30/GB |
| Commitment Tier (100 GB) | 100 GB/day | Medium deployments | ~$196/day |
| Free | 5 GB/month | Testing/Learning | FREE |

### Common Alert Severity Levels

| Severity | Use Case |
|----------|----------|
| Sev 0 | Critical - immediate action required |
| Sev 1 | Error - prompt attention needed |
| Sev 2 | Warning - should be investigated |
| Sev 3 | Informational - for awareness |
| Sev 4 | Verbose - debugging purposes |

---

## 🔧 Exercise 1: Create Log Analytics Workspace

### Tasks

#### 1.1 Create Log Analytics Workspace

```bash
# Create workspace
az monitor log-analytics workspace create \
  --resource-group "rg-contoso-shared-eastus-001" \
  --workspace-name "law-contoso-prod-001" \
  --location "eastus" \
  --sku "PerGB2018" \
  --tags Environment=Production Purpose=Monitoring

# Get workspace ID (needed later)
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group "rg-contoso-shared-eastus-001" \
  --workspace-name "law-contoso-prod-001" \
  --query customerId \
  --output tsv)

echo "Workspace ID: $WORKSPACE_ID"
```

#### 1.2 Configure Workspace Settings

```bash
# Set retention period (30 days is free, up to 730 days)
az monitor log-analytics workspace update \
  --resource-group "rg-contoso-shared-eastus-001" \
  --workspace-name "law-contoso-prod-001" \
  --retention-time 30

# View workspace details
az monitor log-analytics workspace show \
  --resource-group "rg-contoso-shared-eastus-001" \
  --workspace-name "law-contoso-prod-001" \
  --output table
```

### ✅ Checkpoint
- Log Analytics workspace created
- Retention set to 30 days (free tier)

---

## 🔧 Exercise 2: Configure Diagnostic Settings

### Background
Diagnostic settings stream logs and metrics from Azure resources to Log Analytics.

### Tasks

#### 2.1 Enable Diagnostics for a Resource Group

First, let's create a simple resource to monitor:

```bash
# Create a storage account to monitor
STORAGE_NAME="stcontosomonitor$(date +%s | tail -c 6)"

az storage account create \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --location "eastus" \
  --sku "Standard_LRS"
```

#### 2.2 Create Diagnostic Setting for Storage Account

```bash
# Get the storage account resource ID
STORAGE_ID=$(az storage account show \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --query id \
  --output tsv)

# Get Log Analytics workspace resource ID
WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace show \
  --resource-group "rg-contoso-shared-eastus-001" \
  --workspace-name "law-contoso-prod-001" \
  --query id \
  --output tsv)

# Create diagnostic setting
az monitor diagnostic-settings create \
  --name "diag-storage-logs" \
  --resource $STORAGE_ID \
  --workspace $WORKSPACE_RESOURCE_ID \
  --metrics '[{"category":"Transaction","enabled":true}]'
```

#### 2.3 Create Activity Log Diagnostic Setting

```bash
# Get subscription ID
SUB_ID=$(az account show --query id -o tsv)

# Create diagnostic setting for Activity Log
az monitor diagnostic-settings subscription create \
  --name "diag-activity-log" \
  --subscription $SUB_ID \
  --workspace $WORKSPACE_RESOURCE_ID \
  --logs '[
    {"category":"Administrative","enabled":true},
    {"category":"Security","enabled":true},
    {"category":"Alert","enabled":true},
    {"category":"Policy","enabled":true}
  ]'
```

### ✅ Checkpoint
- Diagnostic settings created for storage account
- Activity Log streaming to Log Analytics

---

## 🔧 Exercise 3: Query Logs with KQL

### Background
Kusto Query Language (KQL) is used to query Log Analytics data.

### Tasks

#### 3.1 Basic KQL Queries

**Navigate to Log Analytics in Portal:**
1. Go to your Log Analytics workspace
2. Click **Logs** in the left menu

**Try these queries:**

```kql
// View all tables
search * 
| distinct $table

// View Azure Activity logs (if available)
AzureActivity
| take 10

// Count activities by operation
AzureActivity
| summarize count() by OperationNameValue
| top 10 by count_

// View resource health events
AzureActivity
| where CategoryValue == "Administrative"
| project TimeGenerated, Caller, OperationNameValue, ActivityStatusValue
| order by TimeGenerated desc
| take 20
```

#### 3.2 Query Storage Metrics

```kql
// View storage account metrics
AzureMetrics
| where ResourceProvider == "MICROSOFT.STORAGE"
| project TimeGenerated, MetricName, Average, Maximum, Resource
| order by TimeGenerated desc
| take 50
```

#### 3.3 Create a Saved Query

**Portal Method:**
1. In Log Analytics, run a query
2. Click **Save** → **Save as query**
3. Name: "Storage Transactions Last Hour"
4. Category: "Contoso"

---

## 🔧 Exercise 4: Create Alerts

### Background
Alerts notify you when specific conditions are met.

### Tasks

#### 4.1 Create an Action Group

```bash
# Create an action group for email notifications
az monitor action-group create \
  --name "ag-contoso-admins" \
  --resource-group "rg-contoso-shared-eastus-001" \
  --short-name "ContosoAdm" \
  --action email admin-email admin@contoso.com
```

#### 4.2 Create a Metric Alert

```bash
# Create alert for high storage transactions
az monitor metrics alert create \
  --name "alert-storage-high-transactions" \
  --resource-group "rg-contoso-shared-eastus-001" \
  --scopes $STORAGE_ID \
  --condition "total Transactions > 1000" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 2 \
  --action $ACTION_GROUP_ID \
  --description "Alert when storage transactions exceed 1000 in 5 minutes"
```

#### 4.3 Create a Log-Based Alert

**Portal Method:**
1. Go to Log Analytics → Logs
2. Run query:
   ```kql
   AzureActivity
   | where OperationNameValue contains "delete"
   | where ActivityStatusValue == "Success"
   ```
3. Click **+ New alert rule**
4. Configure:
   - **Threshold**: Greater than 0
   - **Evaluation period**: 5 minutes
   - **Frequency**: 5 minutes
   - **Severity**: Sev 1
5. Select action group: `ag-contoso-admins`
6. Alert rule name: "Contoso - Resource Deletion Alert"
7. Create

#### 4.4 View and Manage Alerts

```bash
# List all alert rules
az monitor metrics alert list \
  --resource-group "rg-contoso-shared-eastus-001" \
  --output table

# View fired alerts (in Portal)
# Go to Azure Monitor → Alerts → All alerts
```

---

## 🔧 Exercise 5: Create a Dashboard

### Tasks

#### 5.1 Create a Custom Dashboard

**Portal Method:**
1. In Azure Portal, click **Dashboard** in the left menu
2. Click **+ New dashboard** → **Blank dashboard**
3. Name: "Contoso Operations Dashboard"

#### 5.2 Add Tiles to Dashboard

**Add Resource Group tile:**
1. Click **+ Add tile**
2. Select **Markdown**
3. Add content:
   ```markdown
   ## Contoso Azure Environment
   
   | Resource Group | Purpose |
   |---------------|---------|
   | rg-contoso-prod-eastus-001 | Production |
   | rg-contoso-dev-eastus-001 | Development |
   | rg-contoso-shared-eastus-001 | Shared Services |
   ```

**Add Metrics Chart:**
1. Navigate to your storage account
2. Click **Metrics**
3. Add metric: Transactions
4. Click **Pin to dashboard**
5. Select your dashboard

**Add Log Analytics Query:**
1. Go to Log Analytics → Logs
2. Run a useful query
3. Click **Pin to dashboard**

#### 5.3 Share the Dashboard

```bash
# Dashboards can be shared via Portal:
# 1. Open your dashboard
# 2. Click "Share" at the top
# 3. Publish to resource group
# 4. Grant access to team members via RBAC
```

---

## 🔧 Exercise 6: Azure Monitor Workbooks

### Background
Workbooks combine text, queries, metrics, and parameters into rich reports.

### Tasks

#### 6.1 Create a Workbook

**Portal Method:**
1. Go to Azure Monitor → Workbooks
2. Click **+ New**
3. Add elements:

**Add a Text Block:**
```markdown
# Contoso Infrastructure Health Report

This workbook provides an overview of the Contoso Azure environment.

Generated: {TimeGenerated}
```

**Add a Query:**
```kql
AzureActivity
| where TimeGenerated > ago(24h)
| summarize OperationCount = count() by OperationNameValue
| top 10 by OperationCount
| render barchart
```

**Add a Metric Chart:**
1. Click **+ Add** → **Add metric**
2. Select your storage account
3. Choose "Transactions" metric

4. Save the workbook as "Contoso-Daily-Report"

---

## 🔧 Exercise 7: Service Health

### Background
Azure Service Health tracks Azure service issues that may affect your resources.

### Tasks

#### 7.1 Create Service Health Alert

```bash
# Create a service health alert
az monitor activity-log alert create \
  --name "alert-azure-service-health" \
  --resource-group "rg-contoso-shared-eastus-001" \
  --condition category=ServiceHealth \
  --action-group $ACTION_GROUP_ID \
  --description "Alert for Azure service health events"
```

#### 7.2 View Service Health

**Portal Method:**
1. Search for "Service Health" in Azure Portal
2. View:
   - **Service issues**: Current Azure problems
   - **Planned maintenance**: Upcoming maintenance
   - **Health advisories**: Recommendations
   - **Health history**: Past incidents

---

## 📝 Module Summary

### What You Accomplished
- ✅ Created Log Analytics workspace
- ✅ Configured diagnostic settings for resources
- ✅ Wrote KQL queries to analyze logs
- ✅ Created metric and log-based alerts
- ✅ Built a custom monitoring dashboard
- ✅ Created an Azure Monitor workbook
- ✅ Set up Service Health alerts

### Key Concepts Learned
| Concept | Purpose |
|---------|---------|
| Log Analytics | Centralized log storage and querying |
| Diagnostic Settings | Stream logs to Log Analytics |
| KQL | Query language for log analysis |
| Alerts | Proactive notifications |
| Dashboards | Visual overview of resources |
| Workbooks | Rich interactive reports |

### AZ-104 Skills Practiced
- Monitor resources by using Azure Monitor (10-15% of exam)
- Configure and interpret metrics and logs
- Configure action groups and alerts
- Configure Log Analytics

---

## 🧹 Cleanup

```bash
# Delete alerts
az monitor metrics alert delete \
  --name "alert-storage-high-transactions" \
  --resource-group "rg-contoso-shared-eastus-001"

az monitor activity-log alert delete \
  --name "alert-azure-service-health" \
  --resource-group "rg-contoso-shared-eastus-001"

# Delete action group
az monitor action-group delete \
  --name "ag-contoso-admins" \
  --resource-group "rg-contoso-shared-eastus-001"

# Delete diagnostic settings
az monitor diagnostic-settings delete \
  --name "diag-storage-logs" \
  --resource $STORAGE_ID

# Delete storage account
az storage account delete \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --yes

# Delete Log Analytics workspace
az monitor log-analytics workspace delete \
  --resource-group "rg-contoso-shared-eastus-001" \
  --workspace-name "law-contoso-prod-001" \
  --force --yes

# Delete dashboards and workbooks via Portal

echo "Cleanup complete!"
```

---

## ➡️ Next Steps

Congratulations on completing Module 06! 🎉

You're now ready for the advanced modules:

👉 [Continue to Module 07: Advanced Networking](../07-advanced-networking/README.md)

Or jump to the final challenge:

👉 [Module 08: Capstone Project](../08-capstone/README.md)

---

## 📚 Additional Resources

- [Azure Monitor Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/)
- [KQL Reference](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Sample KQL Queries](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/queries)
- [Azure Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)
