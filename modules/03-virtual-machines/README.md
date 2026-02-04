# Module 03: Virtual Machines

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 3-4 hours](https://img.shields.io/badge/Time-3--4%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Deploy Windows and Linux virtual machines
- Configure VM sizing, disks, and networking
- Implement availability sets and availability zones
- Use VM extensions for automation and monitoring
- Configure Azure Backup for VMs
- Manage VM costs with auto-shutdown and reserved instances
- Use custom data and cloud-init scripts

---

## 📖 Scenario

Contoso Consulting is migrating their legacy applications to Azure. They need:

1. **Web Server (Linux)**: Hosts their internal documentation wiki
2. **Application Server (Windows)**: Runs a legacy .NET application
3. **Database considerations**: Understand VM-hosted vs. managed databases

Your task is to deploy these VMs with proper high availability, security, and cost controls.

---

## 📚 Pre-Reading (Optional but Recommended)

| Topic | Microsoft Learn Link | Time |
|-------|---------------------|------|
| VM Overview | [Introduction to Azure VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/overview) | 15 min |
| VM Sizes | [Sizes for VMs in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes) | 15 min |
| Availability Options | [Availability options for VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/availability) | 15 min |
| Azure Backup | [About Azure VM backup](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-introduction) | 10 min |

---

## 💡 Key Concepts

### VM Size Families (Free-Tier Friendly)
| Series | Use Case | Free Tier |
|--------|----------|-----------|
| B-series | Burstable, low-cost | ✅ B1S (750 hrs/month) |
| D-series | General purpose | ❌ |
| E-series | Memory optimized | ❌ |
| F-series | Compute optimized | ❌ |

### Availability Options
| Option | Protection Against | SLA |
|--------|-------------------|-----|
| Single VM (Premium SSD) | Disk failures | 99.9% |
| Availability Set | Rack/Update failures | 99.95% |
| Availability Zones | Datacenter failures | 99.99% |

### Disk Types
| Type | IOPS | Use Case | Cost |
|------|------|----------|------|
| Standard HDD | 500 | Dev/Test | $ |
| Standard SSD | 6,000 | Web servers | $$ |
| Premium SSD | 20,000 | Production | $$$ |
| Ultra Disk | 160,000 | Databases | $$$$ |

---

## 🔧 Exercise 1: Deploy a Linux VM

### Prerequisites
Ensure you have the Production resource group:
```bash
az group create --name "rg-contoso-prod-eastus-001" --location "eastus" \
  --tags Environment=Production Department=IT
```

### Tasks

#### 1.1 Create a Linux VM (Web Server)

**Portal Method:**
1. Navigate to [Azure Portal](https://portal.azure.com)
2. Search for "Virtual machines" → **+ Create** → **Azure virtual machine**
3. Configure Basics:
   - **Resource group**: `rg-contoso-prod-eastus-001`
   - **VM name**: `vm-web-prod-001`
   - **Region**: East US
   - **Availability options**: No infrastructure redundancy required (for now)
   - **Image**: Ubuntu Server 22.04 LTS - x64 Gen2
   - **Size**: Standard_B1s (free tier eligible!)
   - **Authentication**: SSH public key
   - **Username**: `azureuser`
4. Configure Disks:
   - **OS disk type**: Standard SSD (cost effective)
5. Configure Networking:
   - Keep defaults (we'll customize in Module 04)
6. Review + create

**CLI Method:**
```bash
# Create the VM
az vm create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --image "Ubuntu2204" \
  --size "Standard_B1s" \
  --admin-username "azureuser" \
  --generate-ssh-keys \
  --os-disk-size-gb 30 \
  --storage-sku "StandardSSD_LRS" \
  --public-ip-sku "Standard" \
  --tags Environment=Production Department=IT Application=WebServer

# Get the public IP
az vm show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --show-details \
  --query "publicIps" \
  --output tsv
```

#### 1.2 Connect to the Linux VM

```bash
# Get the public IP
VM_IP=$(az vm show -g "rg-contoso-prod-eastus-001" -n "vm-web-prod-001" -d --query publicIps -o tsv)

# SSH into the VM
ssh azureuser@$VM_IP

# Once connected, verify you're in Azure
curl -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | python3 -m json.tool

# Exit the VM
exit
```

#### 1.3 Install Web Server Using Cloud-Init

Let's recreate the VM with automated software installation:

```bash
# First, delete the existing VM
az vm delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --yes

# Create cloud-init file
cat << 'EOF' > cloud-init-web.yaml
#cloud-config
package_upgrade: true
packages:
  - nginx
  - git
runcmd:
  - systemctl start nginx
  - systemctl enable nginx
  - echo "<h1>Welcome to Contoso Web Server</h1><p>Deployed with cloud-init!</p>" > /var/www/html/index.html
EOF

# Create VM with cloud-init
az vm create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --image "Ubuntu2204" \
  --size "Standard_B1s" \
  --admin-username "azureuser" \
  --generate-ssh-keys \
  --custom-data cloud-init-web.yaml \
  --public-ip-sku "Standard" \
  --tags Environment=Production Application=WebServer

# Open port 80 for web traffic
az vm open-port \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --port 80 \
  --priority 1001

# Get the IP and test
VM_IP=$(az vm show -g "rg-contoso-prod-eastus-001" -n "vm-web-prod-001" -d --query publicIps -o tsv)
echo "Web server URL: http://$VM_IP"
curl http://$VM_IP
```

### ✅ Checkpoint
- VM is created and running
- You can SSH into the VM
- Nginx is serving the custom webpage

---

## 🔧 Exercise 2: Deploy a Windows VM

### Tasks

#### 2.1 Create Windows VM (Application Server)

```bash
# Create the Windows VM
az vm create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-app-prod-001" \
  --image "Win2022Datacenter" \
  --size "Standard_B2s" \
  --admin-username "contosoadmin" \
  --admin-password "C0nt0s0P@ssw0rd123!" \
  --os-disk-size-gb 127 \
  --storage-sku "StandardSSD_LRS" \
  --public-ip-sku "Standard" \
  --tags Environment=Production Department=IT Application=AppServer
```

> ⚠️ **Security Note:** In production, never use simple passwords. Use Azure Key Vault or managed identities.

#### 2.2 Open RDP Port

```bash
# Open port 3389 for RDP
az vm open-port \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-app-prod-001" \
  --port 3389 \
  --priority 1002
```

#### 2.3 Connect via RDP

```bash
# Get the public IP
WIN_IP=$(az vm show -g "rg-contoso-prod-eastus-001" -n "vm-app-prod-001" -d --query publicIps -o tsv)
echo "RDP to: $WIN_IP"
```

**Connect from Windows:**
1. Open Remote Desktop Connection (`mstsc`)
2. Enter the IP address
3. Use credentials: `contosoadmin` / `C0nt0s0P@ssw0rd123!`

**Connect from Mac/Linux:**
- Use Microsoft Remote Desktop app
- Or use `xfreerdp`: `xfreerdp /v:$WIN_IP /u:contosoadmin`

### ✅ Checkpoint
- Windows VM is created and running
- You can RDP into the VM

---

## 🔧 Exercise 3: VM Management Operations

### Tasks

#### 3.1 Stop and Start VMs

```bash
# Stop VM (deallocate - no charges for compute)
az vm deallocate \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001"

# Check status
az vm get-instance-view \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --query "instanceView.statuses[1].displayStatus"

# Start VM
az vm start \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001"
```

#### 3.2 Resize a VM

```bash
# List available sizes in the region
az vm list-vm-resize-options \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --output table

# Resize (requires restart)
az vm resize \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --size "Standard_B1ms"
```

#### 3.3 Add a Data Disk

```bash
# Add a 32GB data disk to Linux VM
az vm disk attach \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vm-name "vm-web-prod-001" \
  --name "disk-web-data-001" \
  --size-gb 32 \
  --sku "StandardSSD_LRS" \
  --new

# SSH into VM and format the disk
ssh azureuser@$VM_IP

# Inside the VM - find the new disk
lsblk

# Create partition and filesystem (assumes disk is /dev/sdc)
sudo parted /dev/sdc mklabel gpt
sudo parted /dev/sdc mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/sdc1
sudo mkdir /data
sudo mount /dev/sdc1 /data

# Add to fstab for persistence
echo '/dev/sdc1 /data ext4 defaults 0 2' | sudo tee -a /etc/fstab

exit
```

---

## 🔧 Exercise 4: VM Extensions

### Background
VM Extensions allow you to automate post-deployment configuration.

### Tasks

#### 4.1 Install Azure Monitor Agent

```bash
# Install Azure Monitor Agent on Linux VM
az vm extension set \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vm-name "vm-web-prod-001" \
  --name "AzureMonitorLinuxAgent" \
  --publisher "Microsoft.Azure.Monitor" \
  --version "1.0"

# Verify extension
az vm extension list \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vm-name "vm-web-prod-001" \
  --output table
```

#### 4.2 Run Custom Script Extension

```bash
# Create a script to run on the VM
cat << 'EOF' > configure-web.sh
#!/bin/bash
echo "Configuring web server at $(date)" >> /var/log/contoso-config.log
nginx -v >> /var/log/contoso-config.log
EOF

# Upload to a public location or use inline
az vm run-command invoke \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --command-id RunShellScript \
  --scripts "echo 'Hello from custom script' && hostname && date"
```

#### 4.3 Install IIS on Windows VM

```bash
# Run PowerShell script on Windows VM
az vm run-command invoke \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-app-prod-001" \
  --command-id RunPowerShellScript \
  --scripts "Install-WindowsFeature -Name Web-Server -IncludeManagementTools"

# Open port 80
az vm open-port \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-app-prod-001" \
  --port 80 \
  --priority 1003
```

---

## 🔧 Exercise 5: Auto-Shutdown (Cost Savings)

### Background
Auto-shutdown helps reduce costs by turning off VMs during off-hours.

### Tasks

#### 5.1 Configure Auto-Shutdown

**Portal Method:**
1. Navigate to your VM
2. Click **Auto-shutdown** under Operations
3. Enable and set time (e.g., 7:00 PM)
4. Configure notification email
5. Save

**CLI Method:**
```bash
# Enable auto-shutdown at 7 PM EST
az vm auto-shutdown \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-001" \
  --time 1900 \
  --timezone "Eastern Standard Time"

# With email notification
az vm auto-shutdown \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-app-prod-001" \
  --time 1900 \
  --timezone "Eastern Standard Time" \
  --email "admin@contoso.com"
```

---

## 🔧 Exercise 6: Availability Sets

### Background
Availability Sets protect against hardware failures within a datacenter.

### Tasks

#### 6.1 Create an Availability Set

```bash
# Create availability set
az vm availability-set create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "avset-web-prod" \
  --platform-fault-domain-count 2 \
  --platform-update-domain-count 5

# View availability set
az vm availability-set show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "avset-web-prod" \
  --output table
```

#### 6.2 Create VMs in Availability Set

```bash
# Create second web server in availability set
az vm create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-prod-002" \
  --image "Ubuntu2204" \
  --size "Standard_B1s" \
  --admin-username "azureuser" \
  --generate-ssh-keys \
  --availability-set "avset-web-prod" \
  --public-ip-sku "Standard" \
  --tags Environment=Production Application=WebServer
```

### 💡 Understanding Fault/Update Domains
- **Fault Domains**: Physical rack separation (max 3)
- **Update Domains**: Logical grouping for maintenance (max 20)

---

## 🔧 Exercise 7: Azure Backup

### Background
Azure Backup provides simple, secure, and cost-effective backup for VMs.

### Tasks

#### 7.1 Create Recovery Services Vault

```bash
# Create vault
az backup vault create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "rsv-contoso-prod-001" \
  --location "eastus"
```

#### 7.2 Enable Backup for VM

```bash
# Set backup policy (DefaultPolicy)
az backup protection enable-for-vm \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vault-name "rsv-contoso-prod-001" \
  --vm "vm-web-prod-001" \
  --policy-name "DefaultPolicy"

# Trigger immediate backup
az backup protection backup-now \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vault-name "rsv-contoso-prod-001" \
  --container-name "vm-web-prod-001" \
  --item-name "vm-web-prod-001" \
  --backup-management-type AzureIaasVM \
  --retain-until $(date -u -d "+30 days" '+%d-%m-%Y')
```

#### 7.3 Check Backup Status

```bash
# List backup jobs
az backup job list \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vault-name "rsv-contoso-prod-001" \
  --output table
```

---

## 📝 Module Summary

### What You Accomplished
- ✅ Deployed Windows and Linux VMs
- ✅ Configured VM sizing, disks, and networking
- ✅ Used cloud-init for automated configuration
- ✅ Implemented VM extensions for monitoring
- ✅ Configured auto-shutdown for cost savings
- ✅ Created availability sets for high availability
- ✅ Set up Azure Backup for disaster recovery

### Key Concepts Learned
| Concept | Purpose |
|---------|---------|
| VM Sizes | Choose based on workload (CPU, memory, storage) |
| Availability Sets | Protect against datacenter hardware failures |
| VM Extensions | Automate post-deployment configuration |
| Auto-Shutdown | Cost control for non-production workloads |
| Azure Backup | Point-in-time recovery for VMs |

### AZ-104 Skills Practiced
- Deploy and manage Azure compute resources (20-25% of exam)
- Create and configure VMs
- Automate deployment using templates
- Configure VMs for high availability

---

## 🧹 Cleanup

> ⚠️ **Important:** VMs incur charges even when stopped (for storage). Complete cleanup to avoid charges!

```bash
# Stop VMs to save compute costs (storage still charged)
az vm deallocate -g "rg-contoso-prod-eastus-001" -n "vm-web-prod-001" --no-wait
az vm deallocate -g "rg-contoso-prod-eastus-001" -n "vm-web-prod-002" --no-wait
az vm deallocate -g "rg-contoso-prod-eastus-001" -n "vm-app-prod-001" --no-wait

# OR - Delete all VMs (recommended if not continuing immediately)
az vm delete -g "rg-contoso-prod-eastus-001" -n "vm-web-prod-001" --yes --no-wait
az vm delete -g "rg-contoso-prod-eastus-001" -n "vm-web-prod-002" --yes --no-wait
az vm delete -g "rg-contoso-prod-eastus-001" -n "vm-app-prod-001" --yes --no-wait

# Delete associated resources (NICs, disks, public IPs)
az disk delete -g "rg-contoso-prod-eastus-001" -n "disk-web-data-001" --yes --no-wait

# Delete backup vault (must disable backup first)
az backup protection disable \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vault-name "rsv-contoso-prod-001" \
  --container-name "vm-web-prod-001" \
  --item-name "vm-web-prod-001" \
  --backup-management-type AzureIaasVM \
  --delete-backup-data true --yes

az backup vault delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "rsv-contoso-prod-001" \
  --yes

# Delete availability set
az vm availability-set delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "avset-web-prod"

# Clean up local files
rm -f cloud-init-web.yaml configure-web.sh

echo "Cleanup initiated!"
```

---

## 🎯 Knowledge Check

1. **What's the difference between stopping a VM vs. deallocating it?**
   <details>
   <summary>Click for answer</summary>
   Stopping keeps the VM allocated (still incurs compute charges). Deallocating releases the compute resources (no compute charges, but storage still charged).
   </details>

2. **When would you use an availability set vs. availability zones?**
   <details>
   <summary>Click for answer</summary>
   Availability sets protect against rack-level failures (99.95% SLA). Availability zones protect against entire datacenter failures (99.99% SLA) but require a region with zones.
   </details>

3. **What's the benefit of using cloud-init?**
   <details>
   <summary>Click for answer</summary>
   Cloud-init automates VM configuration at first boot, reducing manual setup and enabling consistent deployments.
   </details>

4. **Why would you add a data disk instead of using the OS disk?**
   <details>
   <summary>Click for answer</summary>
   Data disks can be detached and attached to other VMs, have separate backup policies, can be independently resized, and separating data from OS improves manageability.
   </details>

---

## ➡️ Next Steps

Congratulations on completing Module 03! 🎉

In the next module, you'll configure networking for Contoso, including:
- Virtual Networks and subnets
- Network Security Groups (NSGs)
- Load balancers for high availability
- Azure DNS

👉 [Continue to Module 04: Networking](../04-networking/README.md)

---

## 📚 Additional Resources

- [VM Documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/)
- [VM Pricing Calculator](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
- [Azure Backup Documentation](https://learn.microsoft.com/en-us/azure/backup/)
