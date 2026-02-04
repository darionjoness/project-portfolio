# Module 01: Identity & Governance

![Difficulty: Beginner](https://img.shields.io/badge/Difficulty-Beginner-green)
![Time: 2-3 hours](https://img.shields.io/badge/Time-2--3%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Create and organize resource groups with proper naming conventions
- Implement tagging strategies for cost management and organization
- Configure role-based access control (RBAC) for secure resource access
- Create custom roles for specific job functions
- Implement Azure Policy to enforce organizational standards
- Understand management groups and subscription organization

---

## 📖 Scenario

**Contoso Consulting** is setting up their Azure environment. As the new Azure Administrator, your first task is to establish the foundational governance framework. The company has three departments:
- **IT** - Manages infrastructure
- **Development** - Builds applications
- **Finance** - Needs read-only access to billing and costs

The CEO wants to ensure:
1. Resources are organized and easy to find
2. Only authorized personnel can access specific resources
3. All resources follow company naming and tagging standards
4. Costs can be tracked by department

---

## 📚 Pre-Reading (Optional but Recommended)

Before starting, review these concepts if needed:

| Topic | Microsoft Learn Link | Time |
|-------|---------------------|------|
| Resource Groups | [Manage resource groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal) | 15 min |
| Azure RBAC | [What is Azure RBAC?](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview) | 20 min |
| Azure Policy | [What is Azure Policy?](https://learn.microsoft.com/en-us/azure/governance/policy/overview) | 20 min |
| Tags | [Use tags to organize resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources) | 10 min |

---

## 🔧 Exercise 1: Create Resource Groups

### Background
Resource groups are logical containers for Azure resources. A good naming convention makes resources easy to find and manage.

### Contoso Naming Convention
```
<resource-type>-<app/workload>-<environment>-<region>-<instance>

Examples:
- rg-contoso-prod-eastus-001    (Production resource group)
- rg-contoso-dev-eastus-001     (Development resource group)
- vm-web-prod-eastus-001        (Production web VM)
```

### Tasks

#### 1.1 Create Production Resource Group

**Portal Method:**
1. Navigate to [Azure Portal](https://portal.azure.com)
2. Search for "Resource groups" in the top search bar
3. Click **+ Create**
4. Fill in:
   - **Subscription**: Select your subscription
   - **Resource group**: `rg-contoso-prod-eastus-001`
   - **Region**: East US (or your nearest region)
5. Click **Review + create**, then **Create**

**CLI Method:**
```bash
# Set variables
RESOURCE_GROUP="rg-contoso-prod-eastus-001"
LOCATION="eastus"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Verify creation
az group show --name $RESOURCE_GROUP --output table
```

#### 1.2 Create Development Resource Group

```bash
# Create dev resource group
az group create \
  --name "rg-contoso-dev-eastus-001" \
  --location "eastus"
```

#### 1.3 Create Shared Services Resource Group

```bash
# Create shared services resource group (for storage, monitoring, etc.)
az group create \
  --name "rg-contoso-shared-eastus-001" \
  --location "eastus"
```

### ✅ Checkpoint
Verify you have three resource groups:
```bash
az group list --output table
```

You should see:
| Name | Location | Status |
|------|----------|--------|
| rg-contoso-prod-eastus-001 | eastus | Succeeded |
| rg-contoso-dev-eastus-001 | eastus | Succeeded |
| rg-contoso-shared-eastus-001 | eastus | Succeeded |

---

## 🔧 Exercise 2: Implement Tags

### Background
Tags help organize resources for billing, automation, and management. Contoso requires the following tags on all resources:

| Tag Name | Purpose | Example Values |
|----------|---------|----------------|
| Environment | Identifies prod/dev/test | Production, Development, Test |
| Department | Cost allocation | IT, Development, Finance |
| CostCenter | Budget tracking | CC-1001, CC-1002 |
| Owner | Point of contact | email@contoso.com |
| Project | Project association | Contoso-Migration |

### Tasks

#### 2.1 Add Tags to Resource Groups

**Portal Method:**
1. Navigate to your Production resource group
2. Click **Tags** in the left menu
3. Add the following tags:
   - `Environment` = `Production`
   - `Department` = `IT`
   - `CostCenter` = `CC-1001`
   - `Owner` = `admin@contoso.com`
   - `Project` = `Contoso-Migration`
4. Click **Apply**

**CLI Method:**
```bash
# Tag the production resource group
az group update \
  --name "rg-contoso-prod-eastus-001" \
  --tags Environment=Production Department=IT CostCenter=CC-1001 Owner=admin@contoso.com Project=Contoso-Migration

# Tag the development resource group
az group update \
  --name "rg-contoso-dev-eastus-001" \
  --tags Environment=Development Department=Development CostCenter=CC-1002 Owner=dev@contoso.com Project=Contoso-Migration

# Tag the shared services resource group
az group update \
  --name "rg-contoso-shared-eastus-001" \
  --tags Environment=Shared Department=IT CostCenter=CC-1001 Owner=admin@contoso.com Project=Contoso-Migration
```

#### 2.2 Query Resources by Tag

```bash
# Find all resources with a specific tag
az group list --tag Environment=Production --output table

# Find all resources owned by a specific person
az group list --tag Owner=admin@contoso.com --output table
```

### ✅ Checkpoint
Verify tags are applied:
```bash
az group show --name "rg-contoso-prod-eastus-001" --query tags
```

---

## 🔧 Exercise 3: Configure RBAC

### Background
Contoso needs different access levels for different teams:
- **IT Team**: Full control of all resources
- **Development Team**: Can manage dev resources only
- **Finance Team**: Read-only access for cost analysis

### Common Built-in Roles

| Role | Description | Use Case |
|------|-------------|----------|
| Owner | Full access + can delegate | IT Admins |
| Contributor | Full access, no delegation | DevOps |
| Reader | Read-only access | Finance, Auditors |
| Virtual Machine Contributor | Manage VMs only | VM Admins |
| Storage Account Contributor | Manage storage only | Storage Admins |

📚 [Full list of built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)

### Tasks

#### 3.1 View Current Role Assignments

**Portal Method:**
1. Navigate to your Production resource group
2. Click **Access control (IAM)** in the left menu
3. Click **Role assignments** tab
4. Review existing assignments

**CLI Method:**
```bash
# List role assignments for a resource group
az role assignment list \
  --resource-group "rg-contoso-prod-eastus-001" \
  --output table
```

#### 3.2 Assign Contributor Role (Simulated)

> ⚠️ **Note:** If you're using a personal subscription, you may not have other users to assign roles to. In that case, document what command you *would* run.

**To assign a role to a user:**
```bash
# Syntax (DO NOT RUN unless you have another user)
az role assignment create \
  --assignee "user@domain.com" \
  --role "Contributor" \
  --resource-group "rg-contoso-dev-eastus-001"
```

#### 3.3 Assign Reader Role (Simulated)

```bash
# Syntax for read-only access
az role assignment create \
  --assignee "finance-user@domain.com" \
  --role "Reader" \
  --scope "/subscriptions/<subscription-id>"
```

#### 3.4 View Available Roles

```bash
# List all built-in roles
az role definition list --output table

# Get details of a specific role
az role definition list --name "Contributor" --output json
```

### ✅ Checkpoint
- You understand the difference between Owner, Contributor, and Reader
- You know how to view role assignments
- You can explain the principle of least privilege

---

## 🔧 Exercise 4: Create a Custom Role

### Background
Contoso needs a custom role for their VM operators who should:
- ✅ Start and stop VMs
- ✅ View VM status
- ❌ NOT delete VMs
- ❌ NOT create new VMs

### Tasks

#### 4.1 Create Custom Role Definition

Create a file named `vm-operator-role.json`:

```json
{
  "Name": "Contoso VM Operator",
  "Description": "Can start, stop, and restart virtual machines but cannot create or delete them",
  "IsCustom": true,
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/instanceView/read",
    "Microsoft.Network/networkInterfaces/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read"
  ],
  "NotActions": [],
  "AssignableScopes": [
    "/subscriptions/YOUR_SUBSCRIPTION_ID"
  ]
}
```

#### 4.2 Get Your Subscription ID

```bash
# Get your subscription ID
az account show --query id --output tsv
```

#### 4.3 Create the Custom Role

```bash
# Update the JSON file with your subscription ID, then run:
az role definition create --role-definition @vm-operator-role.json

# Verify the role was created
az role definition list --custom-role-only true --output table
```

#### 4.4 (Optional) Delete the Custom Role

```bash
# If you want to remove the custom role later
az role definition delete --name "Contoso VM Operator"
```

### 💡 Learning Note
Custom roles allow you to follow the **principle of least privilege** - giving users exactly the permissions they need, nothing more.

---

## 🔧 Exercise 5: Implement Azure Policy

### Background
Contoso wants to enforce these rules:
1. All resources MUST have required tags
2. Only approved VM sizes can be deployed
3. Resources can only be created in approved regions

### Tasks

#### 5.1 View Built-in Policies

**Portal Method:**
1. Search for "Policy" in the Azure Portal
2. Click **Definitions** under Authoring
3. Filter by Category: "Tags" or "Compute"

**CLI Method:**
```bash
# List built-in policies related to tags
az policy definition list \
  --query "[?contains(displayName, 'tag')].[displayName, name]" \
  --output table
```

#### 5.2 Assign "Require Tag" Policy

Let's enforce that all resources must have an "Environment" tag:

**Portal Method:**
1. Go to **Policy** → **Definitions**
2. Search for "Require a tag on resources"
3. Click on the policy, then click **Assign**
4. Set:
   - **Scope**: Your development resource group
   - **Tag Name**: `Environment`
5. Click **Review + create**

**CLI Method:**
```bash
# Get the policy definition ID
POLICY_ID=$(az policy definition list \
  --query "[?displayName=='Require a tag on resources'].name" \
  --output tsv)

# Assign the policy to the dev resource group
az policy assignment create \
  --name "require-environment-tag" \
  --display-name "Require Environment Tag" \
  --policy $POLICY_ID \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-contoso-dev-eastus-001" \
  --params '{"tagName": {"value": "Environment"}}'
```

#### 5.3 Test the Policy

Try creating a resource without the required tag:

```bash
# This should fail after policy takes effect (can take 15-30 minutes)
az storage account create \
  --name "stcontosotestpolicy$(date +%s)" \
  --resource-group "rg-contoso-dev-eastus-001" \
  --location "eastus" \
  --sku "Standard_LRS"
```

> **Note:** Policy enforcement can take 15-30 minutes to become active.

#### 5.4 View Policy Compliance

```bash
# Check compliance state
az policy state summarize \
  --resource-group "rg-contoso-dev-eastus-001"
```

### ✅ Checkpoint
- Policy is assigned to the development resource group
- You understand the difference between "Deny" and "Audit" effects
- You can view compliance status

---

## 🔧 Exercise 6: Resource Locks

### Background
The production resource group contains critical resources. Contoso wants to prevent accidental deletion.

### Tasks

#### 6.1 Create a Delete Lock

**Portal Method:**
1. Navigate to the Production resource group
2. Click **Locks** in the left menu
3. Click **+ Add**
4. Set:
   - **Lock name**: `prevent-deletion`
   - **Lock type**: Delete
   - **Notes**: `Prevents accidental deletion of production resources`
5. Click **OK**

**CLI Method:**
```bash
# Create a delete lock
az lock create \
  --name "prevent-deletion" \
  --resource-group "rg-contoso-prod-eastus-001" \
  --lock-type CanNotDelete \
  --notes "Prevents accidental deletion of production resources"

# Verify the lock
az lock list --resource-group "rg-contoso-prod-eastus-001" --output table
```

#### 6.2 Test the Lock

```bash
# Try to delete the resource group (this should fail)
az group delete --name "rg-contoso-prod-eastus-001" --yes
# Expected: Error - resource group is locked
```

#### 6.3 Remove Lock (for cleanup later)

```bash
# Remove the lock when you need to delete resources
az lock delete \
  --name "prevent-deletion" \
  --resource-group "rg-contoso-prod-eastus-001"
```

---

## 📝 Module Summary

### What You Accomplished
- ✅ Created organized resource groups with naming conventions
- ✅ Implemented tagging strategy for cost management
- ✅ Configured RBAC for secure access control
- ✅ Created a custom role for specific job functions
- ✅ Implemented Azure Policy for governance
- ✅ Applied resource locks to protect critical resources

### Key Concepts Learned
| Concept | Purpose |
|---------|---------|
| Resource Groups | Logical containers for organizing resources |
| Tags | Metadata for organization, billing, automation |
| RBAC | Control who can do what with resources |
| Custom Roles | Granular permissions beyond built-in roles |
| Azure Policy | Enforce organizational standards |
| Resource Locks | Prevent accidental deletion or modification |

### AZ-104 Skills Practiced
- Manage Azure identities and governance (15-20% of exam)
- Create and manage subscriptions and governance
- Configure access to Azure resources

---

## 🧹 Cleanup

> ⚠️ **Important:** Complete this section to avoid charges!

### Option A: Keep Resources for Next Module
If you're continuing to Module 2 immediately, you can keep the resource groups.

### Option B: Delete Everything

```bash
# First, remove any locks
az lock delete --name "prevent-deletion" --resource-group "rg-contoso-prod-eastus-001" 2>/dev/null

# Remove policy assignment
az policy assignment delete --name "require-environment-tag" --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-contoso-dev-eastus-001" 2>/dev/null

# Delete custom role
az role definition delete --name "Contoso VM Operator" 2>/dev/null

# Delete resource groups
az group delete --name "rg-contoso-prod-eastus-001" --yes --no-wait
az group delete --name "rg-contoso-dev-eastus-001" --yes --no-wait
az group delete --name "rg-contoso-shared-eastus-001" --yes --no-wait

echo "Cleanup initiated. Resource groups will be deleted in the background."
```

### Verify Cleanup
```bash
# Confirm resource groups are deleted (may take a few minutes)
az group list --output table
```

---

## 🎯 Knowledge Check

Before moving on, make sure you can answer these questions:

1. **What is the difference between Owner and Contributor roles?**
   <details>
   <summary>Click for answer</summary>
   Owner has full access AND can assign roles to others. Contributor has full access but cannot manage role assignments.
   </details>

2. **Why use tags on resources?**
   <details>
   <summary>Click for answer</summary>
   Tags help with cost tracking, automation, organization, and compliance. They make it easy to find resources and allocate costs to departments.
   </details>

3. **What's the difference between a "Deny" and "Audit" policy effect?**
   <details>
   <summary>Click for answer</summary>
   "Deny" prevents non-compliant resources from being created. "Audit" allows creation but logs a compliance warning.
   </details>

4. **When would you use a Read-Only lock vs. a Delete lock?**
   <details>
   <summary>Click for answer</summary>
   Delete lock prevents deletion but allows modifications. Read-Only lock prevents any changes, including modifications and deletion.
   </details>

---

## ➡️ Next Steps

Congratulations on completing Module 01! 🎉

In the next module, you'll set up storage solutions for Contoso, including:
- Blob storage for file uploads
- File shares for team collaboration
- Access tiers and lifecycle management

👉 [Continue to Module 02: Storage Solutions](../02-storage/README.md)

---

## 📚 Additional Resources

- [Azure Governance Documentation](https://learn.microsoft.com/en-us/azure/governance/)
- [RBAC Best Practices](https://learn.microsoft.com/en-us/azure/role-based-access-control/best-practices)
- [Azure Policy Samples](https://github.com/Azure/azure-policy)
- [Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
