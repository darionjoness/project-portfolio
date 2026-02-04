# Module 02: Storage Solutions

![Difficulty: Beginner](https://img.shields.io/badge/Difficulty-Beginner-green)
![Time: 2-3 hours](https://img.shields.io/badge/Time-2--3%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Create and configure storage accounts with appropriate redundancy
- Work with blob storage including containers, access tiers, and SAS tokens
- Set up Azure File Shares for team collaboration
- Implement lifecycle management policies
- Configure storage security including firewalls and private endpoints
- Use Azure Storage Explorer and AzCopy

---

## 📖 Scenario

Contoso Consulting needs storage solutions for several use cases:

1. **Employee File Shares**: A shared drive accessible from all workstations
2. **Application Blob Storage**: Storage for application uploads and backups
3. **Archive Storage**: Long-term retention of old project files
4. **Public Website Assets**: Images and documents for the company website

Your task is to implement these storage solutions while optimizing for cost and security.

---

## 📚 Pre-Reading (Optional but Recommended)

| Topic | Microsoft Learn Link | Time |
|-------|---------------------|------|
| Storage Account Overview | [Introduction to Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-introduction) | 15 min |
| Blob Storage | [Introduction to Blob storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) | 15 min |
| Azure Files | [What is Azure Files?](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-introduction) | 10 min |
| Access Tiers | [Access tiers for blob data](https://learn.microsoft.com/en-us/azure/storage/blobs/access-tiers-overview) | 10 min |

---

## 💡 Key Concepts

### Storage Account Types
| Type | Use Case | Performance |
|------|----------|-------------|
| Standard (GPv2) | General purpose, cost-effective | HDD-based |
| Premium Block Blob | High-transaction blob workloads | SSD-based |
| Premium File Shares | Enterprise file shares | SSD-based |
| Premium Page Blobs | VM disks | SSD-based |

### Redundancy Options
| Option | Description | Cost | Durability |
|--------|-------------|------|------------|
| LRS | 3 copies in one datacenter | $ | 99.999999999% |
| ZRS | 3 copies across zones | $$ | 99.9999999999% |
| GRS | 6 copies (3 local + 3 remote) | $$$ | 99.99999999999999% |
| GZRS | ZRS + GRS | $$$$ | Highest |

### Access Tiers
| Tier | Use Case | Storage Cost | Access Cost |
|------|----------|--------------|-------------|
| Hot | Frequently accessed | Higher | Lower |
| Cool | Infrequently accessed (30+ days) | Lower | Higher |
| Cold | Rarely accessed (90+ days) | Lower | Higher |
| Archive | Long-term retention | Lowest | Highest (rehydration required) |

---

## 🔧 Exercise 1: Create a Storage Account

### Prerequisites
Make sure you have the resource groups from Module 01, or create them:
```bash
az group create --name "rg-contoso-shared-eastus-001" --location "eastus"
```

### Tasks

#### 1.1 Create a General Purpose Storage Account

**Naming Rules:**
- 3-24 characters
- Lowercase letters and numbers only
- Must be globally unique

**Portal Method:**
1. Navigate to [Azure Portal](https://portal.azure.com)
2. Search for "Storage accounts"
3. Click **+ Create**
4. Configure:
   - **Subscription**: Your subscription
   - **Resource group**: `rg-contoso-shared-eastus-001`
   - **Storage account name**: `stcontoso<unique-id>` (e.g., `stcontoso12345`)
   - **Region**: East US
   - **Performance**: Standard
   - **Redundancy**: Locally-redundant storage (LRS) - cheapest option
5. Click **Review + create**, then **Create**

**CLI Method:**
```bash
# Generate a unique suffix
SUFFIX=$(date +%s | tail -c 6)
STORAGE_NAME="stcontoso${SUFFIX}"

# Create storage account
az storage account create \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --location "eastus" \
  --sku "Standard_LRS" \
  --kind "StorageV2" \
  --access-tier "Hot" \
  --tags Environment=Shared Department=IT CostCenter=CC-1001

# Save the storage account name for later
echo "Storage account created: $STORAGE_NAME"
echo "export STORAGE_NAME=$STORAGE_NAME" >> ~/.bashrc
```

#### 1.2 Get Storage Account Keys

```bash
# List storage account keys (keep these secure!)
az storage account keys list \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --output table

# Store the key in a variable
STORAGE_KEY=$(az storage account keys list \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --query "[0].value" \
  --output tsv)
```

### ✅ Checkpoint
```bash
# Verify storage account exists
az storage account show \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --query "{Name:name, Location:location, Sku:sku.name}" \
  --output table
```

---

## 🔧 Exercise 2: Blob Storage

### Background
Contoso needs blob storage for:
- Application uploads (images, documents)
- Database backups
- Archive storage for old projects

### Tasks

#### 2.1 Create Blob Containers

```bash
# Create container for application uploads (private access)
az storage container create \
  --name "uploads" \
  --account-name $STORAGE_NAME \
  --public-access off

# Create container for website assets (public read access)
az storage container create \
  --name "public-assets" \
  --account-name $STORAGE_NAME \
  --public-access blob

# Create container for backups (private access)
az storage container create \
  --name "backups" \
  --account-name $STORAGE_NAME \
  --public-access off

# Create container for archive (private access)
az storage container create \
  --name "archive" \
  --account-name $STORAGE_NAME \
  --public-access off

# List containers
az storage container list \
  --account-name $STORAGE_NAME \
  --output table
```

#### 2.2 Upload Files to Blob Storage

**Create some test files:**
```bash
# Create a local directory for test files
mkdir -p ~/contoso-test-files

# Create test files
echo "This is a test document for Contoso" > ~/contoso-test-files/document.txt
echo "Sample configuration data" > ~/contoso-test-files/config.json
echo "<html><body>Hello World</body></html>" > ~/contoso-test-files/index.html
```

**Upload files:**
```bash
# Upload a single file
az storage blob upload \
  --account-name $STORAGE_NAME \
  --container-name "uploads" \
  --name "documents/document.txt" \
  --file ~/contoso-test-files/document.txt

# Upload to public container
az storage blob upload \
  --account-name $STORAGE_NAME \
  --container-name "public-assets" \
  --name "website/index.html" \
  --file ~/contoso-test-files/index.html

# List blobs in container
az storage blob list \
  --account-name $STORAGE_NAME \
  --container-name "uploads" \
  --output table
```

#### 2.3 Access Public Blobs

```bash
# Get the URL for a public blob
az storage blob url \
  --account-name $STORAGE_NAME \
  --container-name "public-assets" \
  --name "website/index.html" \
  --output tsv

# Test access (should work without authentication)
curl "https://${STORAGE_NAME}.blob.core.windows.net/public-assets/website/index.html"
```

#### 2.4 Download Files

```bash
# Download a file
az storage blob download \
  --account-name $STORAGE_NAME \
  --container-name "uploads" \
  --name "documents/document.txt" \
  --file ~/contoso-test-files/downloaded-document.txt

# Verify
cat ~/contoso-test-files/downloaded-document.txt
```

### ✅ Checkpoint
- You have created multiple containers with different access levels
- You can upload and download blobs
- You understand the difference between private and public containers

---

## 🔧 Exercise 3: Shared Access Signatures (SAS)

### Background
SAS tokens provide secure, time-limited access to storage resources without sharing account keys.

### Tasks

#### 3.1 Generate Account-Level SAS

```bash
# Generate a SAS token valid for 1 hour
END_DATE=$(date -u -d "+1 hour" '+%Y-%m-%dT%H:%MZ')

SAS_TOKEN=$(az storage account generate-sas \
  --account-name $STORAGE_NAME \
  --permissions rwdlacup \
  --services b \
  --resource-types sco \
  --expiry $END_DATE \
  --output tsv)

echo "SAS Token: $SAS_TOKEN"
```

#### 3.2 Generate Container-Level SAS

```bash
# Generate SAS for specific container (read-only, 30 minutes)
END_DATE=$(date -u -d "+30 minutes" '+%Y-%m-%dT%H:%MZ')

CONTAINER_SAS=$(az storage container generate-sas \
  --account-name $STORAGE_NAME \
  --name "uploads" \
  --permissions rl \
  --expiry $END_DATE \
  --output tsv)

echo "Container SAS: $CONTAINER_SAS"
```

#### 3.3 Generate Blob-Level SAS

```bash
# Generate SAS for a specific blob
BLOB_SAS=$(az storage blob generate-sas \
  --account-name $STORAGE_NAME \
  --container-name "uploads" \
  --name "documents/document.txt" \
  --permissions r \
  --expiry $END_DATE \
  --output tsv)

# Construct the full URL with SAS
BLOB_URL="https://${STORAGE_NAME}.blob.core.windows.net/uploads/documents/document.txt?${BLOB_SAS}"
echo "Blob URL with SAS: $BLOB_URL"

# Test access
curl "$BLOB_URL"
```

### 💡 SAS Best Practices
- Always use the shortest possible expiration time
- Use container or blob-level SAS instead of account-level when possible
- Consider using stored access policies for better management
- Never log or share SAS tokens in plain text

---

## 🔧 Exercise 4: Access Tiers

### Background
Contoso wants to optimize costs by using appropriate access tiers:
- **Active project files**: Hot tier
- **Completed project files**: Cool tier
- **Old project archives**: Archive tier

### Tasks

#### 4.1 Upload Blobs with Different Tiers

```bash
# Upload to Hot tier (default)
echo "Active project data" > ~/contoso-test-files/active-project.txt
az storage blob upload \
  --account-name $STORAGE_NAME \
  --container-name "uploads" \
  --name "projects/active-project.txt" \
  --file ~/contoso-test-files/active-project.txt \
  --tier Hot

# Upload to Cool tier
echo "Completed project data" > ~/contoso-test-files/completed-project.txt
az storage blob upload \
  --account-name $STORAGE_NAME \
  --container-name "uploads" \
  --name "projects/completed-project.txt" \
  --file ~/contoso-test-files/completed-project.txt \
  --tier Cool

# Upload to Archive tier
echo "Archived project data" > ~/contoso-test-files/archived-project.txt
az storage blob upload \
  --account-name $STORAGE_NAME \
  --container-name "archive" \
  --name "2023/old-project.txt" \
  --file ~/contoso-test-files/archived-project.txt \
  --tier Archive
```

#### 4.2 Change Blob Tier

```bash
# Change tier of existing blob
az storage blob set-tier \
  --account-name $STORAGE_NAME \
  --container-name "uploads" \
  --name "projects/active-project.txt" \
  --tier Cool

# View blob properties including tier
az storage blob show \
  --account-name $STORAGE_NAME \
  --container-name "uploads" \
  --name "projects/active-project.txt" \
  --query "{Name:name, Tier:properties.blobTier}" \
  --output table
```

#### 4.3 Rehydrate Archive Blob

```bash
# Rehydrate from archive (takes hours!)
az storage blob set-tier \
  --account-name $STORAGE_NAME \
  --container-name "archive" \
  --name "2023/old-project.txt" \
  --tier Hot \
  --rehydrate-priority Standard  # or High for faster (more expensive)

# Check rehydration status
az storage blob show \
  --account-name $STORAGE_NAME \
  --container-name "archive" \
  --name "2023/old-project.txt" \
  --query "{Name:name, Tier:properties.blobTier, RehydrationStatus:properties.archiveStatus}"
```

### 💡 Access Tier Notes
- **Archive rehydration takes hours** (Standard: up to 15 hours, High: up to 1 hour)
- Moving to a cooler tier is instant
- There are early deletion penalties for Cool (30 days) and Archive (180 days)

---

## 🔧 Exercise 5: Azure Files

### Background
Contoso needs a shared file system that employees can map as a network drive.

### Tasks

#### 5.1 Create a File Share

```bash
# Create file share for team documents
az storage share-rm create \
  --storage-account $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --name "team-documents" \
  --quota 5  # 5 GB quota (free tier friendly)

# Create file share for department files
az storage share-rm create \
  --storage-account $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --name "department-files" \
  --quota 5

# List file shares
az storage share-rm list \
  --storage-account $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --output table
```

#### 5.2 Create Directories and Upload Files

```bash
# Create directory structure
az storage directory create \
  --account-name $STORAGE_NAME \
  --share-name "team-documents" \
  --name "HR"

az storage directory create \
  --account-name $STORAGE_NAME \
  --share-name "team-documents" \
  --name "IT"

az storage directory create \
  --account-name $STORAGE_NAME \
  --share-name "team-documents" \
  --name "Finance"

# Upload a file
echo "HR Policy Document" > ~/contoso-test-files/hr-policy.txt
az storage file upload \
  --account-name $STORAGE_NAME \
  --share-name "team-documents" \
  --source ~/contoso-test-files/hr-policy.txt \
  --path "HR/hr-policy.txt"

# List files
az storage file list \
  --account-name $STORAGE_NAME \
  --share-name "team-documents" \
  --path "HR" \
  --output table
```

#### 5.3 Get Connection Script for Windows

```bash
# Get the mount script for Windows
az storage share show-connection-string \
  --account-name $STORAGE_NAME \
  --name "team-documents" \
  --output tsv
```

**Windows PowerShell Mount Command:**
```powershell
# Run in PowerShell on Windows
$storageAccountName = "<your-storage-account>"
$storageAccountKey = "<your-storage-key>"
$shareName = "team-documents"

# Create credential
$password = ConvertTo-SecureString -String $storageAccountKey -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$storageAccountName", $password

# Mount as Z: drive
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$storageAccountName.file.core.windows.net\$shareName" -Credential $credential -Persist
```

---

## 🔧 Exercise 6: Lifecycle Management

### Background
Contoso wants to automatically:
- Move files older than 30 days to Cool tier
- Move files older than 90 days to Archive tier
- Delete files older than 365 days

### Tasks

#### 6.1 Create Lifecycle Management Policy

**Portal Method:**
1. Navigate to your storage account
2. Click **Lifecycle management** under Data management
3. Click **+ Add a rule**

**CLI Method:**

Create a file `lifecycle-policy.json`:
```json
{
  "rules": [
    {
      "enabled": true,
      "name": "move-to-cool",
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["uploads/"]
        },
        "actions": {
          "baseBlob": {
            "tierToCool": {
              "daysAfterModificationGreaterThan": 30
            }
          }
        }
      }
    },
    {
      "enabled": true,
      "name": "move-to-archive",
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["uploads/"]
        },
        "actions": {
          "baseBlob": {
            "tierToArchive": {
              "daysAfterModificationGreaterThan": 90
            }
          }
        }
      }
    },
    {
      "enabled": true,
      "name": "delete-old-files",
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["uploads/"]
        },
        "actions": {
          "baseBlob": {
            "delete": {
              "daysAfterModificationGreaterThan": 365
            }
          }
        }
      }
    }
  ]
}
```

```bash
# Apply lifecycle policy
az storage account management-policy create \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --policy @lifecycle-policy.json

# View policy
az storage account management-policy show \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001"
```

---

## 🔧 Exercise 7: Storage Security

### Tasks

#### 7.1 Configure Firewall Rules

```bash
# Enable firewall and set default action to deny
az storage account update \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --default-action Deny

# Allow your current IP address
MY_IP=$(curl -s ifconfig.me)
az storage account network-rule add \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --ip-address $MY_IP

# Allow Azure services
az storage account update \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --bypass AzureServices

# View network rules
az storage account show \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --query networkRuleSet
```

#### 7.2 Enable Soft Delete

```bash
# Enable soft delete for blobs (7 day retention)
az storage account blob-service-properties update \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --enable-delete-retention true \
  --delete-retention-days 7

# Enable soft delete for containers
az storage account blob-service-properties update \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --enable-container-delete-retention true \
  --container-delete-retention-days 7
```

#### 7.3 Enable Versioning

```bash
# Enable blob versioning
az storage account blob-service-properties update \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --enable-versioning true
```

---

## 📝 Module Summary

### What You Accomplished
- ✅ Created and configured a storage account with appropriate settings
- ✅ Worked with blob storage containers and access levels
- ✅ Generated and used SAS tokens for secure access
- ✅ Implemented access tiers for cost optimization
- ✅ Set up Azure File Shares for team collaboration
- ✅ Created lifecycle management policies
- ✅ Configured storage security features

### Key Concepts Learned
| Concept | Purpose |
|---------|---------|
| Storage Account | Container for all storage services |
| Blob Storage | Object storage for unstructured data |
| Access Tiers | Cost optimization based on access patterns |
| SAS Tokens | Secure, time-limited access without sharing keys |
| Azure Files | Cloud-based file shares (SMB/NFS) |
| Lifecycle Management | Automated tier transitions and deletion |

### AZ-104 Skills Practiced
- Configure Azure Storage (15-20% of exam)
- Secure storage accounts
- Manage data in Azure Storage

---

## 🧹 Cleanup

> ⚠️ **Important:** Complete this section to avoid charges!

### Option A: Keep for Next Module
Keep the storage account if continuing immediately.

### Option B: Delete Storage Account

```bash
# Remove network rules first (if you added your IP)
az storage account network-rule remove \
  --account-name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --ip-address $(curl -s ifconfig.me) 2>/dev/null

# Delete the storage account
az storage account delete \
  --name $STORAGE_NAME \
  --resource-group "rg-contoso-shared-eastus-001" \
  --yes

# Clean up local test files
rm -rf ~/contoso-test-files

echo "Cleanup complete!"
```

---

## 🎯 Knowledge Check

1. **What's the difference between LRS and GRS redundancy?**
   <details>
   <summary>Click for answer</summary>
   LRS stores 3 copies in one datacenter. GRS stores 6 copies (3 local + 3 in a secondary region hundreds of miles away).
   </details>

2. **When should you use Archive tier?**
   <details>
   <summary>Click for answer</summary>
   For data that is rarely accessed and can tolerate hours of rehydration time, like compliance archives or backup data that's only needed for disaster recovery.
   </details>

3. **Why use SAS tokens instead of storage keys?**
   <details>
   <summary>Click for answer</summary>
   SAS tokens can be time-limited, scoped to specific resources, and granted with specific permissions. Storage keys provide full access and don't expire.
   </details>

4. **What happens when you try to read an Archive tier blob?**
   <details>
   <summary>Click for answer</summary>
   You get an error. Archive blobs must be rehydrated to Hot or Cool tier first, which can take up to 15 hours.
   </details>

---

## ➡️ Next Steps

Congratulations on completing Module 02! 🎉

In the next module, you'll deploy Virtual Machines for Contoso, including:
- Windows and Linux VMs
- Availability sets and zones
- VM extensions and diagnostics
- Backup and recovery

👉 [Continue to Module 03: Virtual Machines](../03-virtual-machines/README.md)

---

## 📚 Additional Resources

- [Azure Storage Documentation](https://learn.microsoft.com/en-us/azure/storage/)
- [Storage Pricing Calculator](https://azure.microsoft.com/en-us/pricing/details/storage/)
- [AzCopy Documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10)
- [Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)
