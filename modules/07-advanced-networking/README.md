# Module 07: Advanced Networking

![Difficulty: Advanced](https://img.shields.io/badge/Difficulty-Advanced-red)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Implement Azure Application Gateway for layer 7 load balancing
- Configure Network Watcher for network diagnostics
- Understand VPN Gateway concepts and configurations
- Implement User Defined Routes (UDRs)
- Configure Service Endpoints and Private Endpoints
- Implement network traffic analytics

---

## 📖 Scenario

Contoso Consulting is expanding. They need:

1. **Web Application Firewall**: Protect web apps from common attacks
2. **Network diagnostics**: Tools to troubleshoot connectivity issues
3. **Secure connectivity**: Understanding hybrid connectivity options
4. **Traffic control**: Route traffic through security appliances

---

## 📚 Pre-Reading (Highly Recommended)

| Topic | Microsoft Learn Link | Time |
|-------|---------------------|------|
| Application Gateway | [What is Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/application-gateway/overview) | 20 min |
| Network Watcher | [What is Azure Network Watcher?](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-overview) | 15 min |
| VPN Gateway | [What is VPN Gateway?](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways) | 20 min |
| Private Endpoints | [What is a private endpoint?](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) | 15 min |

---

## 💡 Key Concepts

### Load Balancing Comparison

| Feature | Load Balancer | Application Gateway |
|---------|--------------|---------------------|
| Layer | 4 (TCP/UDP) | 7 (HTTP/HTTPS) |
| SSL Termination | No | Yes |
| URL Routing | No | Yes |
| WAF | No | Yes |
| Cost | $ | $$$ |

### Private Endpoint vs Service Endpoint

| Feature | Service Endpoint | Private Endpoint |
|---------|-----------------|------------------|
| Traffic path | Over Microsoft backbone | Into your VNet |
| IP Address | Public IP (secured) | Private IP in VNet |
| On-premises access | No | Yes |
| DNS | No change | Requires private DNS |
| Cost | Free | $ |

---

## 🔧 Exercise 1: Application Gateway with WAF

### Prerequisites
```bash
# Ensure VNet exists with dedicated subnet
az network vnet subnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-appgw" \
  --address-prefixes "10.0.5.0/24"
```

### Tasks

#### 1.1 Create Public IP for Application Gateway

```bash
# Create public IP (Standard SKU required)
az network public-ip create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "pip-appgw-contoso" \
  --sku "Standard" \
  --allocation-method "Static"
```

#### 1.2 Create Application Gateway

> ⚠️ **Cost Warning**: Application Gateway costs ~$0.20/hour. Create it to learn, then delete quickly!

```bash
# Create Application Gateway with WAF (takes 15-20 minutes)
az network application-gateway create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "appgw-contoso-prod" \
  --location "eastus" \
  --sku "WAF_v2" \
  --capacity 1 \
  --vnet-name "vnet-contoso-prod-001" \
  --subnet "snet-appgw" \
  --public-ip-address "pip-appgw-contoso" \
  --http-settings-cookie-based-affinity "Disabled" \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol "Http" \
  --priority 100

# This will take 15-20 minutes to deploy
```

#### 1.3 Configure WAF Policy

```bash
# Create WAF policy
az network application-gateway waf-policy create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "wafpolicy-contoso"

# Configure managed rules (OWASP)
az network application-gateway waf-policy managed-rule rule-set add \
  --resource-group "rg-contoso-prod-eastus-001" \
  --policy-name "wafpolicy-contoso" \
  --type "OWASP" \
  --version "3.2"

# Set WAF mode to Detection (not blocking yet)
az network application-gateway waf-policy policy-setting update \
  --resource-group "rg-contoso-prod-eastus-001" \
  --policy-name "wafpolicy-contoso" \
  --mode "Detection" \
  --state "Enabled"
```

#### 1.4 Add Backend Pool (if you have VMs)

```bash
# Add a backend server (replace with actual IP)
az network application-gateway address-pool create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --gateway-name "appgw-contoso-prod" \
  --name "backend-webservers" \
  --servers "10.0.1.4" "10.0.1.5"
```

### ✅ Checkpoint
- Application Gateway deployed with WAF
- WAF in Detection mode

---

## 🔧 Exercise 2: Network Watcher

### Background
Network Watcher provides network diagnostic and monitoring tools.

### Tasks

#### 2.1 Enable Network Watcher

```bash
# Enable Network Watcher for your region
az network watcher configure \
  --resource-group "NetworkWatcherRG" \
  --locations "eastus" \
  --enabled true
```

#### 2.2 IP Flow Verify

Test if traffic is allowed between two points:

```bash
# First, create a test VM if you don't have one
az vm create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-test-nw" \
  --image "Ubuntu2204" \
  --size "Standard_B1s" \
  --admin-username "azureuser" \
  --generate-ssh-keys \
  --vnet-name "vnet-contoso-prod-001" \
  --subnet "snet-web"

# Get NIC ID
NIC_ID=$(az vm show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-test-nw" \
  --query "networkProfile.networkInterfaces[0].id" \
  --output tsv)

# Test if SSH is allowed from internet
az network watcher test-ip-flow \
  --resource-group "rg-contoso-prod-eastus-001" \
  --direction "Inbound" \
  --protocol "TCP" \
  --local "10.0.1.4:22" \
  --remote "8.8.8.8:12345" \
  --nic $NIC_ID
```

#### 2.3 Next Hop

Determine where traffic is routed:

```bash
# Check next hop for outbound traffic
az network watcher show-next-hop \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vm "vm-test-nw" \
  --source-ip "10.0.1.4" \
  --dest-ip "8.8.8.8"
```

#### 2.4 Connection Troubleshoot

```bash
# Test connectivity from VM to a destination
az network watcher test-connectivity \
  --resource-group "rg-contoso-prod-eastus-001" \
  --source-resource "vm-test-nw" \
  --dest-address "www.microsoft.com" \
  --dest-port 443
```

#### 2.5 NSG Flow Logs (Optional - requires storage account)

```bash
# Enable NSG flow logs
NSG_ID=$(az network nsg show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "nsg-web-prod" \
  --query id --output tsv)

# Create storage account for flow logs
FLOW_STORAGE="stcontosoflow$(date +%s | tail -c 6)"
az storage account create \
  --name $FLOW_STORAGE \
  --resource-group "rg-contoso-prod-eastus-001" \
  --sku "Standard_LRS"

# Enable flow logs
az network watcher flow-log create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "flowlog-nsg-web" \
  --nsg $NSG_ID \
  --storage-account $FLOW_STORAGE \
  --enabled true \
  --format JSON \
  --log-version 2 \
  --retention 7
```

---

## 🔧 Exercise 3: User Defined Routes (UDRs)

### Background
UDRs let you control traffic flow by overriding Azure's default routing.

### Tasks

#### 3.1 Create a Route Table

```bash
# Create route table
az network route-table create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "rt-contoso-web" \
  --location "eastus"
```

#### 3.2 Add Custom Routes

```bash
# Route all internet traffic through a firewall (example IP)
# In real scenario, this would be a Network Virtual Appliance
az network route-table route create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --route-table-name "rt-contoso-web" \
  --name "route-to-firewall" \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type "VirtualAppliance" \
  --next-hop-ip-address "10.0.4.4"

# Route to on-premises network through VPN (example)
az network route-table route create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --route-table-name "rt-contoso-web" \
  --name "route-to-onprem" \
  --address-prefix "192.168.0.0/16" \
  --next-hop-type "VirtualAppliance" \
  --next-hop-ip-address "10.0.4.4"
```

#### 3.3 Associate Route Table with Subnet

```bash
# Associate with web subnet
az network vnet subnet update \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-web" \
  --route-table "rt-contoso-web"

# View effective routes on a NIC
az network nic show-effective-route-table \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-test-nwVMNic" \
  --output table
```

---

## 🔧 Exercise 4: Service Endpoints

### Background
Service Endpoints extend your VNet to Azure services over the Microsoft backbone.

### Tasks

#### 4.1 Enable Service Endpoint for Storage

```bash
# Enable Microsoft.Storage service endpoint on subnet
az network vnet subnet update \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-web" \
  --service-endpoints "Microsoft.Storage"

# Verify
az network vnet subnet show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-web" \
  --query serviceEndpoints
```

#### 4.2 Restrict Storage Account to VNet

```bash
# Get subnet ID
SUBNET_ID=$(az network vnet subnet show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-web" \
  --query id --output tsv)

# Create storage account
SE_STORAGE="stcontosose$(date +%s | tail -c 6)"
az storage account create \
  --name $SE_STORAGE \
  --resource-group "rg-contoso-prod-eastus-001" \
  --sku "Standard_LRS"

# Restrict to VNet only
az storage account network-rule add \
  --account-name $SE_STORAGE \
  --resource-group "rg-contoso-prod-eastus-001" \
  --subnet $SUBNET_ID

# Set default action to deny
az storage account update \
  --name $SE_STORAGE \
  --resource-group "rg-contoso-prod-eastus-001" \
  --default-action Deny
```

---

## 🔧 Exercise 5: Private Endpoints

### Background
Private Endpoints bring Azure services into your VNet with a private IP.

### Tasks

#### 5.1 Create Subnet for Private Endpoints

```bash
# Create a dedicated subnet for private endpoints
az network vnet subnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-privateendpoints" \
  --address-prefixes "10.0.6.0/24" \
  --disable-private-endpoint-network-policies true
```

#### 5.2 Create Storage Account with Private Endpoint

```bash
# Create storage account
PE_STORAGE="stcontosope$(date +%s | tail -c 6)"
az storage account create \
  --name $PE_STORAGE \
  --resource-group "rg-contoso-prod-eastus-001" \
  --sku "Standard_LRS"

# Get storage account ID
STORAGE_ID=$(az storage account show \
  --name $PE_STORAGE \
  --resource-group "rg-contoso-prod-eastus-001" \
  --query id --output tsv)

# Create private endpoint
az network private-endpoint create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "pe-storage-blob" \
  --vnet-name "vnet-contoso-prod-001" \
  --subnet "snet-privateendpoints" \
  --private-connection-resource-id $STORAGE_ID \
  --group-id "blob" \
  --connection-name "storage-blob-connection"
```

#### 5.3 Configure Private DNS Zone

```bash
# Create private DNS zone for blob storage
az network private-dns zone create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "privatelink.blob.core.windows.net"

# Link to VNet
az network private-dns link vnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --zone-name "privatelink.blob.core.windows.net" \
  --name "link-blob-vnet" \
  --virtual-network "vnet-contoso-prod-001" \
  --registration-enabled false

# Get private endpoint NIC IP
PE_IP=$(az network private-endpoint show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "pe-storage-blob" \
  --query "customDnsConfigs[0].ipAddresses[0]" \
  --output tsv)

# Add DNS record
az network private-dns record-set a create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --zone-name "privatelink.blob.core.windows.net" \
  --name $PE_STORAGE

az network private-dns record-set a add-record \
  --resource-group "rg-contoso-prod-eastus-001" \
  --zone-name "privatelink.blob.core.windows.net" \
  --record-set-name $PE_STORAGE \
  --ipv4-address $PE_IP
```

#### 5.4 Test Private Endpoint Resolution

```bash
# From a VM in the VNet, test DNS resolution
# SSH into a VM and run:
nslookup ${PE_STORAGE}.blob.core.windows.net
# Should return private IP (10.0.6.x)
```

---

## 🔧 Exercise 6: VPN Gateway Concepts

### Background
VPN Gateway enables secure connections between Azure and on-premises networks.

> ⚠️ **Cost Warning**: VPN Gateway costs ~$0.04-$0.36/hour depending on SKU. Review concepts but don't deploy unless needed.

### Understanding VPN Gateway

#### Gateway SKUs
| SKU | Throughput | S2S Tunnels | P2S Connections | Cost/Hour |
|-----|-----------|-------------|-----------------|-----------|
| VpnGw1 | 650 Mbps | 30 | 250 | ~$0.19 |
| VpnGw2 | 1 Gbps | 30 | 500 | ~$0.49 |
| VpnGw3 | 1.25 Gbps | 30 | 1000 | ~$1.25 |

#### VPN Types
- **Route-based**: More flexible, supports P2S
- **Policy-based**: Legacy, specific scenarios

### Conceptual Deployment (Read-Only)

```bash
# 1. Create Gateway Subnet (required /27 or larger)
az network vnet subnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "GatewaySubnet" \
  --address-prefixes "10.0.255.0/27"

# 2. Create Public IP for VPN Gateway
az network public-ip create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "pip-vpngw-contoso" \
  --sku "Standard" \
  --allocation-method "Static"

# 3. Create VPN Gateway (takes 30-45 minutes, ~$140/month minimum)
# DO NOT RUN unless you need it
# az network vnet-gateway create \
#   --resource-group "rg-contoso-prod-eastus-001" \
#   --name "vpngw-contoso-prod" \
#   --vnet "vnet-contoso-prod-001" \
#   --public-ip-address "pip-vpngw-contoso" \
#   --gateway-type Vpn \
#   --vpn-type RouteBased \
#   --sku VpnGw1 \
#   --no-wait
```

---

## 📝 Module Summary

### What You Accomplished
- ✅ Deployed Application Gateway with WAF
- ✅ Used Network Watcher diagnostic tools
- ✅ Created User Defined Routes
- ✅ Implemented Service Endpoints
- ✅ Configured Private Endpoints
- ✅ Understood VPN Gateway concepts

### Key Concepts Learned
| Concept | Purpose |
|---------|---------|
| Application Gateway | Layer 7 load balancing with WAF |
| Network Watcher | Network diagnostics and monitoring |
| UDRs | Custom traffic routing |
| Service Endpoints | Secure Azure service access |
| Private Endpoints | Private connectivity to Azure services |
| VPN Gateway | Hybrid connectivity |

### AZ-104 Skills Practiced
- Implement and manage virtual networking (20-25% of exam)
- Configure load balancing
- Implement Azure Private Link

---

## 🧹 Cleanup

> ⚠️ **Application Gateway costs money!** Clean up promptly.

```bash
# Delete Application Gateway (takes several minutes)
az network application-gateway delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "appgw-contoso-prod" \
  --no-wait

# Delete WAF policy
az network application-gateway waf-policy delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "wafpolicy-contoso"

# Delete public IPs
az network public-ip delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "pip-appgw-contoso"

# Delete test VM
az vm delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-test-nw" \
  --yes

# Delete flow logs
az network watcher flow-log delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "flowlog-nsg-web"

# Delete storage accounts
az storage account delete --name $FLOW_STORAGE -g "rg-contoso-prod-eastus-001" --yes
az storage account delete --name $SE_STORAGE -g "rg-contoso-prod-eastus-001" --yes
az storage account delete --name $PE_STORAGE -g "rg-contoso-prod-eastus-001" --yes

# Delete private endpoint
az network private-endpoint delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "pe-storage-blob"

# Delete private DNS zone
az network private-dns link vnet delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --zone-name "privatelink.blob.core.windows.net" \
  --name "link-blob-vnet" --yes

az network private-dns zone delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "privatelink.blob.core.windows.net" --yes

# Delete route table
az network route-table delete \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "rt-contoso-web"

# Remove service endpoints from subnet
az network vnet subnet update \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-web" \
  --service-endpoints ""

echo "Cleanup complete!"
```

---

## ➡️ Next Steps

You've mastered advanced networking! Now it's time for the final challenge:

👉 [Continue to Module 08: Capstone Project](../08-capstone/README.md)

---

## 📚 Additional Resources

- [Application Gateway Documentation](https://learn.microsoft.com/en-us/azure/application-gateway/)
- [Network Watcher Documentation](https://learn.microsoft.com/en-us/azure/network-watcher/)
- [VPN Gateway Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/)
- [Private Link Documentation](https://learn.microsoft.com/en-us/azure/private-link/)
