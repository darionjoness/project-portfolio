# Module 04: Networking Fundamentals

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 3-4 hours](https://img.shields.io/badge/Time-3--4%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Design and implement virtual networks with proper address spaces
- Configure subnets for different workload types
- Implement Network Security Groups (NSGs) with security rules
- Set up Azure Load Balancer for high availability
- Configure Azure DNS for name resolution
- Understand VNet peering and connectivity options

---

## 📖 Scenario

Contoso Consulting's infrastructure is growing. They need:

1. **Proper network segmentation**: Separate subnets for web, application, and data tiers
2. **Security controls**: Only allow necessary traffic between tiers
3. **Load balancing**: Distribute traffic across multiple web servers
4. **DNS management**: Custom domain name resolution

Your task is to design and implement a secure, scalable network architecture.

---

## 📚 Pre-Reading (Optional but Recommended)

| Topic | Microsoft Learn Link | Time |
|-------|---------------------|------|
| VNet Overview | [What is Azure Virtual Network?](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) | 15 min |
| NSGs | [Network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) | 15 min |
| Load Balancer | [What is Azure Load Balancer?](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview) | 15 min |
| Azure DNS | [What is Azure DNS?](https://learn.microsoft.com/en-us/azure/dns/dns-overview) | 10 min |

---

## 💡 Key Concepts

### IP Address Planning
| CIDR | Usable IPs | Use Case |
|------|-----------|----------|
| /16 | 65,534 | Large VNet |
| /24 | 254 | Standard subnet |
| /27 | 30 | Small subnet |
| /28 | 14 | Very small subnet |

### Reserved IP Addresses per Subnet
Azure reserves 5 IPs in each subnet:
- `.0` - Network address
- `.1` - Default gateway
- `.2`, `.3` - Azure DNS
- `.255` - Broadcast

### NSG Rule Priority
- Lower number = higher priority
- Default rules start at 65000
- Custom rules: 100-4096 recommended

---

## 🔧 Exercise 1: Create a Virtual Network

### Network Design for Contoso

```
VNet: vnet-contoso-prod (10.0.0.0/16)
├── snet-web (10.0.1.0/24)      - Web servers
├── snet-app (10.0.2.0/24)      - Application servers
├── snet-data (10.0.3.0/24)     - Database servers
└── snet-mgmt (10.0.4.0/24)     - Management/Bastion
```

### Tasks

#### 1.1 Create the Virtual Network

**Portal Method:**
1. Navigate to **Virtual networks** → **+ Create**
2. Configure:
   - **Resource group**: `rg-contoso-prod-eastus-001`
   - **Name**: `vnet-contoso-prod-001`
   - **Region**: East US
3. Go to **IP Addresses** tab:
   - **IPv4 address space**: `10.0.0.0/16`
4. Add subnets (click **+ Add subnet** for each)
5. Review + create

**CLI Method:**
```bash
# Create the virtual network
az network vnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vnet-contoso-prod-001" \
  --address-prefixes "10.0.0.0/16" \
  --location "eastus" \
  --tags Environment=Production

# Create subnets
az network vnet subnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-web" \
  --address-prefixes "10.0.1.0/24"

az network vnet subnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-app" \
  --address-prefixes "10.0.2.0/24"

az network vnet subnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-data" \
  --address-prefixes "10.0.3.0/24"

az network vnet subnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-mgmt" \
  --address-prefixes "10.0.4.0/24"

# Verify
az network vnet subnet list \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --output table
```

### ✅ Checkpoint
- VNet is created with `/16` address space
- Four subnets exist with `/24` ranges

---

## 🔧 Exercise 2: Network Security Groups

### Background
NSGs act as virtual firewalls, controlling inbound and outbound traffic.

### Contoso Security Requirements
| Source | Destination | Port | Action |
|--------|-------------|------|--------|
| Internet | Web tier | 80, 443 | Allow |
| Web tier | App tier | 8080 | Allow |
| App tier | Data tier | 1433 | Allow |
| Management | All tiers | 22, 3389 | Allow |
| Any | Any | * | Deny (default) |

### Tasks

#### 2.1 Create NSG for Web Tier

```bash
# Create NSG
az network nsg create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "nsg-web-prod" \
  --tags Environment=Production Tier=Web

# Allow HTTP from Internet
az network nsg rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --nsg-name "nsg-web-prod" \
  --name "Allow-HTTP" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes Internet \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 80

# Allow HTTPS from Internet
az network nsg rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --nsg-name "nsg-web-prod" \
  --name "Allow-HTTPS" \
  --priority 110 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes Internet \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 443

# Allow SSH from Management subnet
az network nsg rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --nsg-name "nsg-web-prod" \
  --name "Allow-SSH-Mgmt" \
  --priority 200 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes "10.0.4.0/24" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 22
```

#### 2.2 Create NSG for App Tier

```bash
# Create NSG
az network nsg create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "nsg-app-prod" \
  --tags Environment=Production Tier=App

# Allow 8080 from Web tier only
az network nsg rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --nsg-name "nsg-app-prod" \
  --name "Allow-Web-Tier" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes "10.0.1.0/24" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 8080

# Allow RDP from Management subnet
az network nsg rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --nsg-name "nsg-app-prod" \
  --name "Allow-RDP-Mgmt" \
  --priority 200 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes "10.0.4.0/24" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 3389
```

#### 2.3 Create NSG for Data Tier

```bash
# Create NSG
az network nsg create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "nsg-data-prod" \
  --tags Environment=Production Tier=Data

# Allow SQL from App tier only
az network nsg rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --nsg-name "nsg-data-prod" \
  --name "Allow-SQL-App" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes "10.0.2.0/24" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 1433

# Deny all other inbound (explicit)
az network nsg rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --nsg-name "nsg-data-prod" \
  --name "Deny-All-Inbound" \
  --priority 4096 \
  --direction Inbound \
  --access Deny \
  --protocol "*" \
  --source-address-prefixes "*" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges "*"
```

#### 2.4 Associate NSGs with Subnets

```bash
# Associate NSG with Web subnet
az network vnet subnet update \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-web" \
  --network-security-group "nsg-web-prod"

# Associate NSG with App subnet
az network vnet subnet update \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-app" \
  --network-security-group "nsg-app-prod"

# Associate NSG with Data subnet
az network vnet subnet update \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --name "snet-data" \
  --network-security-group "nsg-data-prod"

# Verify associations
az network vnet subnet list \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --query "[].{Subnet:name, NSG:networkSecurityGroup.id}" \
  --output table
```

### ✅ Checkpoint
- Three NSGs created with appropriate rules
- NSGs associated with their respective subnets

---

## 🔧 Exercise 3: Deploy VMs into VNet

### Tasks

#### 3.1 Create Web Server in Web Subnet

```bash
# Create web server in the web subnet
az vm create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-net-001" \
  --image "Ubuntu2204" \
  --size "Standard_B1s" \
  --admin-username "azureuser" \
  --generate-ssh-keys \
  --vnet-name "vnet-contoso-prod-001" \
  --subnet "snet-web" \
  --public-ip-address "pip-web-001" \
  --tags Environment=Production Tier=Web

# Get the private IP
az vm show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-net-001" \
  --query "privateIps" \
  --output tsv
```

#### 3.2 Create App Server in App Subnet (No Public IP)

```bash
# Create app server without public IP
az vm create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-app-net-001" \
  --image "Win2022Datacenter" \
  --size "Standard_B2s" \
  --admin-username "contosoadmin" \
  --admin-password "C0nt0s0P@ssw0rd123!" \
  --vnet-name "vnet-contoso-prod-001" \
  --subnet "snet-app" \
  --public-ip-address "" \
  --tags Environment=Production Tier=App
```

#### 3.3 Test Network Connectivity

```bash
# Get public IP of web server
WEB_IP=$(az vm show -g "rg-contoso-prod-eastus-001" -n "vm-web-net-001" -d --query publicIps -o tsv)

# SSH into web server
ssh azureuser@$WEB_IP

# From inside web server, test connectivity to app server (should work on port 8080)
# Get app server private IP first
APP_PRIVATE_IP="10.0.2.4"  # Replace with actual IP

# Test ping (may be blocked by default)
ping -c 4 $APP_PRIVATE_IP

# Exit
exit
```

---

## 🔧 Exercise 4: Azure Load Balancer

### Background
A Load Balancer distributes traffic across multiple VMs for high availability.

### Tasks

#### 4.1 Create Public Load Balancer

```bash
# Create public IP for load balancer
az network public-ip create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "pip-lb-web" \
  --sku "Standard" \
  --allocation-method "Static"

# Create load balancer
az network lb create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "lb-web-prod" \
  --sku "Standard" \
  --public-ip-address "pip-lb-web" \
  --frontend-ip-name "lb-frontend" \
  --backend-pool-name "lb-backend-web"
```

#### 4.2 Create Health Probe

```bash
# Create HTTP health probe
az network lb probe create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --lb-name "lb-web-prod" \
  --name "probe-http" \
  --protocol "Http" \
  --port 80 \
  --path "/" \
  --interval 15 \
  --threshold 2
```

#### 4.3 Create Load Balancing Rule

```bash
# Create load balancing rule for HTTP
az network lb rule create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --lb-name "lb-web-prod" \
  --name "rule-http" \
  --protocol "Tcp" \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name "lb-frontend" \
  --backend-pool-name "lb-backend-web" \
  --probe-name "probe-http" \
  --idle-timeout 4
```

#### 4.4 Add VMs to Backend Pool

```bash
# Get the NIC name of the web VM
NIC_NAME=$(az vm show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-net-001" \
  --query "networkProfile.networkInterfaces[0].id" \
  --output tsv | xargs basename)

# Get IP config name
IP_CONFIG=$(az network nic show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name $NIC_NAME \
  --query "ipConfigurations[0].name" \
  --output tsv)

# Add NIC to backend pool
az network nic ip-config update \
  --resource-group "rg-contoso-prod-eastus-001" \
  --nic-name $NIC_NAME \
  --name $IP_CONFIG \
  --lb-name "lb-web-prod" \
  --lb-address-pools "lb-backend-web"

# Get load balancer public IP
az network public-ip show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "pip-lb-web" \
  --query "ipAddress" \
  --output tsv
```

### ✅ Checkpoint
- Load balancer created with public IP
- Health probe configured
- Web VM added to backend pool

---

## 🔧 Exercise 5: Azure DNS

### Background
Azure DNS lets you host DNS zones and manage DNS records.

### Tasks

#### 5.1 Create a Private DNS Zone

```bash
# Create private DNS zone for internal resolution
az network private-dns zone create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "contoso.internal"

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --zone-name "contoso.internal" \
  --name "link-vnet-contoso" \
  --virtual-network "vnet-contoso-prod-001" \
  --registration-enabled true
```

#### 5.2 Add DNS Records

```bash
# Get private IP of web server
WEB_PRIVATE_IP=$(az vm show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vm-web-net-001" \
  -d --query privateIps -o tsv)

# Add A record for web server
az network private-dns record-set a add-record \
  --resource-group "rg-contoso-prod-eastus-001" \
  --zone-name "contoso.internal" \
  --record-set-name "web" \
  --ipv4-address $WEB_PRIVATE_IP

# Add CNAME record
az network private-dns record-set cname set-record \
  --resource-group "rg-contoso-prod-eastus-001" \
  --zone-name "contoso.internal" \
  --record-set-name "www" \
  --cname "web.contoso.internal"

# List records
az network private-dns record-set list \
  --resource-group "rg-contoso-prod-eastus-001" \
  --zone-name "contoso.internal" \
  --output table
```

#### 5.3 Test DNS Resolution

```bash
# SSH into web server
ssh azureuser@$WEB_IP

# Test DNS resolution (from inside the VNet)
nslookup web.contoso.internal
nslookup www.contoso.internal

exit
```

---

## 🔧 Exercise 6: VNet Peering (Optional)

### Background
VNet Peering connects two virtual networks, enabling resources to communicate.

### Tasks

#### 6.1 Create a Second VNet

```bash
# Create dev VNet
az network vnet create \
  --resource-group "rg-contoso-dev-eastus-001" \
  --name "vnet-contoso-dev-001" \
  --address-prefixes "10.1.0.0/16" \
  --location "eastus" \
  --subnet-name "snet-dev" \
  --subnet-prefixes "10.1.1.0/24"
```

#### 6.2 Create Peering Connections

```bash
# Get VNet IDs
PROD_VNET_ID=$(az network vnet show \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "vnet-contoso-prod-001" \
  --query id --output tsv)

DEV_VNET_ID=$(az network vnet show \
  --resource-group "rg-contoso-dev-eastus-001" \
  --name "vnet-contoso-dev-001" \
  --query id --output tsv)

# Create peering from Prod to Dev
az network vnet peering create \
  --resource-group "rg-contoso-prod-eastus-001" \
  --name "peer-prod-to-dev" \
  --vnet-name "vnet-contoso-prod-001" \
  --remote-vnet $DEV_VNET_ID \
  --allow-vnet-access

# Create peering from Dev to Prod
az network vnet peering create \
  --resource-group "rg-contoso-dev-eastus-001" \
  --name "peer-dev-to-prod" \
  --vnet-name "vnet-contoso-dev-001" \
  --remote-vnet $PROD_VNET_ID \
  --allow-vnet-access

# Verify peering status
az network vnet peering list \
  --resource-group "rg-contoso-prod-eastus-001" \
  --vnet-name "vnet-contoso-prod-001" \
  --output table
```

---

## 📝 Module Summary

### What You Accomplished
- ✅ Designed and implemented a multi-tier VNet
- ✅ Created subnets with proper address planning
- ✅ Implemented NSGs with security rules
- ✅ Deployed Azure Load Balancer
- ✅ Configured Azure DNS for name resolution
- ✅ Understood VNet peering for connectivity

### Key Concepts Learned
| Concept | Purpose |
|---------|---------|
| Virtual Network | Isolated network environment in Azure |
| Subnets | Network segmentation for different tiers |
| NSGs | Traffic filtering with security rules |
| Load Balancer | High availability and traffic distribution |
| Azure DNS | Name resolution for Azure resources |
| VNet Peering | Connect VNets for cross-network communication |

### AZ-104 Skills Practiced
- Implement and manage virtual networking (20-25% of exam)
- Configure virtual networks
- Configure secure access to virtual networks
- Configure load balancing
- Configure name resolution

---

## 🧹 Cleanup

```bash
# Delete VMs first
az vm delete -g "rg-contoso-prod-eastus-001" -n "vm-web-net-001" --yes --no-wait
az vm delete -g "rg-contoso-prod-eastus-001" -n "vm-app-net-001" --yes --no-wait

# Delete load balancer
az network lb delete -g "rg-contoso-prod-eastus-001" -n "lb-web-prod"
az network public-ip delete -g "rg-contoso-prod-eastus-001" -n "pip-lb-web"

# Delete VNet peering
az network vnet peering delete -g "rg-contoso-prod-eastus-001" -n "peer-prod-to-dev" --vnet-name "vnet-contoso-prod-001"
az network vnet peering delete -g "rg-contoso-dev-eastus-001" -n "peer-dev-to-prod" --vnet-name "vnet-contoso-dev-001"

# Delete private DNS
az network private-dns link vnet delete -g "rg-contoso-prod-eastus-001" -z "contoso.internal" -n "link-vnet-contoso" --yes
az network private-dns zone delete -g "rg-contoso-prod-eastus-001" -n "contoso.internal" --yes

# Delete NSGs
az network nsg delete -g "rg-contoso-prod-eastus-001" -n "nsg-web-prod"
az network nsg delete -g "rg-contoso-prod-eastus-001" -n "nsg-app-prod"
az network nsg delete -g "rg-contoso-prod-eastus-001" -n "nsg-data-prod"

# Delete VNets
az network vnet delete -g "rg-contoso-prod-eastus-001" -n "vnet-contoso-prod-001"
az network vnet delete -g "rg-contoso-dev-eastus-001" -n "vnet-contoso-dev-001"

echo "Cleanup complete!"
```

---

## ➡️ Next Steps

👉 [Continue to Module 05: App Services](../05-app-services/README.md)

---

## 📚 Additional Resources

- [Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [NSG Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Load Balancer Documentation](https://learn.microsoft.com/en-us/azure/load-balancer/)
- [Azure DNS Documentation](https://learn.microsoft.com/en-us/azure/dns/)
