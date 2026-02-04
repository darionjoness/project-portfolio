# Module 04: Design Infrastructure Solutions

![Difficulty: Advanced](https://img.shields.io/badge/Difficulty-Advanced-red)
![Time: 5-6 hours](https://img.shields.io/badge/Time-5--6%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Design a compute solution
- Design an application architecture
- Design network solutions
- Design migrations
- Recommend an appropriate compute solution

---

## 📖 Scenario

Northwind Traders needs to modernize their infrastructure:

1. **Hub-spoke network** for centralized security
2. **Compute selection** for various workloads
3. **Container strategy** for new microservices
4. **Landing zone** following Cloud Adoption Framework

---

## 💡 Key Concepts

### Compute Decision Tree

```
                    ┌─────────────────┐
                    │ What are you    │
                    │ running?        │
                    └────────┬────────┘
                             │
      ┌──────────────────────┼──────────────────────┐
      ▼                      ▼                      ▼
┌───────────┐         ┌───────────┐          ┌───────────┐
│ Full OS   │         │ Containers│          │ Functions │
│ Required  │         │           │          │ (Code)    │
└─────┬─────┘         └─────┬─────┘          └─────┬─────┘
      │                     │                      │
      ▼                     ▼                      ▼
┌───────────┐         ┌───────────┐          ┌───────────┐
│ VMs       │         │ AKS / ACA │          │ Functions │
│ VMSS      │         │ Web App   │          │ Logic Apps│
│ AVD       │         │ Container │          │           │
└───────────┘         └───────────┘          └───────────┘
```

### Network Topology Comparison

| Pattern | Use Case | Complexity | Cost |
|---------|----------|------------|------|
| Flat VNet | Small, single workload | Low | $ |
| Hub-Spoke | Enterprise, centralized | Medium | $$ |
| Virtual WAN | Global, many branches | High | $$$ |
| Mesh | Complex, many connections | Very High | $$$$ |

---

## 🔧 Exercise 1: Design Hub-Spoke Network

### Task 1.1: Design Network Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Hub-Spoke Network Architecture                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                              ┌───────────────┐                              │
│                              │   On-Premises │                              │
│                              │   (Datacenter)│                              │
│                              └───────┬───────┘                              │
│                                      │ ExpressRoute / VPN                   │
│                                      ▼                                      │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                            HUB VNET                                  │   │
│   │                        (10.0.0.0/16)                                │   │
│   │                                                                     │   │
│   │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐           │   │
│   │  │ GatewaySubnet │  │ AzureFirewall │  │ Bastion       │           │   │
│   │  │ 10.0.0.0/27   │  │ 10.0.1.0/26   │  │ 10.0.2.0/27   │           │   │
│   │  └───────────────┘  └───────┬───────┘  └───────────────┘           │   │
│   │                             │                                       │   │
│   │  ┌──────────────────────────┼──────────────────────────┐           │   │
│   │  │                          │                          │           │   │
│   └──┼──────────────────────────┼──────────────────────────┼───────────┘   │
│      │                          │                          │               │
│      │ Peering                  │ Peering                  │ Peering      │
│      ▼                          ▼                          ▼               │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐               │
│   │ Spoke 1      │    │ Spoke 2      │    │ Spoke 3      │               │
│   │ (Ecommerce)  │    │ (Corp Apps)  │    │ (Data)       │               │
│   │ 10.1.0.0/16  │    │ 10.2.0.0/16  │    │ 10.3.0.0/16  │               │
│   │              │    │              │    │              │               │
│   │ ┌──────────┐ │    │ ┌──────────┐ │    │ ┌──────────┐ │               │
│   │ │ Web Tier │ │    │ │ App Tier │ │    │ │ SQL MI   │ │               │
│   │ │10.1.1/24 │ │    │ │10.2.1/24 │ │    │ │10.3.1/24 │ │               │
│   │ └──────────┘ │    │ └──────────┘ │    │ └──────────┘ │               │
│   │ ┌──────────┐ │    │ ┌──────────┐ │    │ ┌──────────┐ │               │
│   │ │ App Tier │ │    │ │ Backend  │ │    │ │ Private  │ │               │
│   │ │10.1.2/24 │ │    │ │10.2.2/24 │ │    │ │ Endpoints│ │               │
│   │ └──────────┘ │    │ └──────────┘ │    │ │10.3.2/24 │ │               │
│   └──────────────┘    └──────────────┘    │ └──────────┘ │               │
│                                           └──────────────┘               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Task 1.2: IP Address Planning

```markdown
# IP Address Planning - Northwind Azure Network

## Summary
- Total IP space: 10.0.0.0/8 (reserved for Azure)
- Hub: 10.0.0.0/16
- Spokes: 10.1.0.0/16 - 10.254.0.0/16

## Detailed Allocation

### Hub VNet (10.0.0.0/16)
| Subnet | CIDR | Purpose | Usable IPs |
|--------|------|---------|------------|
| GatewaySubnet | 10.0.0.0/27 | VPN/ER Gateway | 27 |
| AzureFirewallSubnet | 10.0.1.0/26 | Azure Firewall | 59 |
| AzureBastionSubnet | 10.0.2.0/27 | Azure Bastion | 27 |
| JumpboxSubnet | 10.0.3.0/27 | Jump servers | 27 |
| DNSSubnet | 10.0.4.0/27 | Private DNS resolvers | 27 |
| Reserved | 10.0.5.0/24 - 10.0.255.0/24 | Future use | - |

### Spoke 1 - Ecommerce (10.1.0.0/16)
| Subnet | CIDR | Purpose | Usable IPs |
|--------|------|---------|------------|
| snet-web | 10.1.1.0/24 | Web tier (App Service VNet Int) | 251 |
| snet-app | 10.1.2.0/24 | App tier (AKS) | 251 |
| snet-cache | 10.1.3.0/24 | Redis cache | 251 |
| snet-pe | 10.1.4.0/24 | Private endpoints | 251 |

### Spoke 2 - Corporate Apps (10.2.0.0/16)
| Subnet | CIDR | Purpose | Usable IPs |
|--------|------|---------|------------|
| snet-app | 10.2.1.0/24 | Application tier | 251 |
| snet-backend | 10.2.2.0/24 | Backend services | 251 |
| snet-pe | 10.2.3.0/24 | Private endpoints | 251 |

### Spoke 3 - Data (10.3.0.0/16)
| Subnet | CIDR | Purpose | Usable IPs |
|--------|------|---------|------------|
| snet-sqlmi | 10.3.1.0/24 | SQL Managed Instance | 251 |
| snet-pe | 10.3.2.0/24 | Private endpoints | 251 |
| snet-synapse | 10.3.3.0/24 | Synapse managed VNet | 251 |
```

### Task 1.3: Implement Hub VNet (Hands-On)

```bash
# Create Hub VNet
az network vnet create \
  --name "vnet-hub-eastus2-001" \
  --resource-group "rg-connectivity" \
  --location "eastus2" \
  --address-prefixes "10.0.0.0/16"

# Create subnets
az network vnet subnet create \
  --vnet-name "vnet-hub-eastus2-001" \
  --resource-group "rg-connectivity" \
  --name "GatewaySubnet" \
  --address-prefixes "10.0.0.0/27"

az network vnet subnet create \
  --vnet-name "vnet-hub-eastus2-001" \
  --resource-group "rg-connectivity" \
  --name "AzureFirewallSubnet" \
  --address-prefixes "10.0.1.0/26"

az network vnet subnet create \
  --vnet-name "vnet-hub-eastus2-001" \
  --resource-group "rg-connectivity" \
  --name "AzureBastionSubnet" \
  --address-prefixes "10.0.2.0/27"
```

---

## 🔧 Exercise 2: Design Compute Strategy

### Task 2.1: Workload Analysis

| Workload | Type | Scaling | State | Recommendation |
|----------|------|---------|-------|----------------|
| E-commerce Web | Web frontend | Horizontal | Stateless | App Service |
| API Gateway | API routing | Horizontal | Stateless | API Management |
| Microservices | Containers | Horizontal | Mixed | AKS |
| Batch Processing | Background jobs | Vertical | Stateless | Functions |
| Legacy .NET | Windows app | Vertical | Stateful | VM Scale Set |
| Dev/Test VMs | Development | None | Stateful | VMs (spot) |

### Task 2.2: Container Strategy

```markdown
# Container Platform Decision - Northwind

## Options Evaluated

### Azure Kubernetes Service (AKS)
- **Pros**: Full orchestration, ecosystem, flexibility
- **Cons**: Complexity, operational overhead
- **Best For**: Large microservices, DevOps-mature teams

### Azure Container Apps (ACA)
- **Pros**: Serverless, simple, managed
- **Cons**: Less control, newer service
- **Best For**: Microservices, event-driven apps

### Azure Container Instances (ACI)
- **Pros**: Simple, per-second billing
- **Cons**: No orchestration, basic networking
- **Best For**: Burst capacity, simple workloads

## Decision

**Primary Platform: AKS** for e-commerce microservices
- Complex scaling requirements
- Need for service mesh (Istio/Linkerd)
- Existing Kubernetes expertise

**Secondary: ACA** for new event-driven services
- Background job processing
- API-based microservices
- Teams ramping up on containers

## AKS Architecture

```
┌───────────────────────────────────────────────────┐
│                    AKS Cluster                     │
├───────────────────────────────────────────────────┤
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │              System Node Pool                │ │
│  │  • 3 nodes (Standard_D4s_v3)               │ │
│  │  • CoreDNS, metrics-server, etc.           │ │
│  └─────────────────────────────────────────────┘ │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │           Frontend Node Pool                 │ │
│  │  • 2-10 nodes (Standard_D4s_v3)            │ │
│  │  • Web workloads, ingress                  │ │
│  │  • Autoscaler enabled                      │ │
│  └─────────────────────────────────────────────┘ │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │           Backend Node Pool                  │ │
│  │  • 3-20 nodes (Standard_D8s_v3)            │ │
│  │  • API services, business logic            │ │
│  │  • Autoscaler enabled                      │ │
│  └─────────────────────────────────────────────┘ │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │              Spot Node Pool                  │ │
│  │  • 0-10 nodes (Standard_D8s_v3, Spot)      │ │
│  │  • Batch processing, tolerates eviction    │ │
│  └─────────────────────────────────────────────┘ │
│                                                   │
└───────────────────────────────────────────────────┘
```
```

### Task 2.3: Implement AKS (Hands-On)

```bash
# Create AKS cluster
az aks create \
  --name "aks-northwind-prod-001" \
  --resource-group "rg-compute" \
  --location "eastus2" \
  --kubernetes-version "1.28" \
  --node-count 3 \
  --node-vm-size "Standard_D4s_v3" \
  --enable-managed-identity \
  --network-plugin azure \
  --vnet-subnet-id "/subscriptions/.../subnets/snet-aks" \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 10 \
  --zones 1 2 3

# Add user node pool
az aks nodepool add \
  --cluster-name "aks-northwind-prod-001" \
  --resource-group "rg-compute" \
  --name "userpool" \
  --node-count 3 \
  --node-vm-size "Standard_D8s_v3" \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 20 \
  --zones 1 2 3
```

---

## 🔧 Exercise 3: Design Network Security

### Task 3.1: Design Firewall Rules

```markdown
# Azure Firewall Rule Collections

## Network Rules

### Allow-Internal
| Priority | Name | Source | Destination | Port | Protocol |
|----------|------|--------|-------------|------|----------|
| 100 | AllowSpokes | 10.0.0.0/8 | 10.0.0.0/8 | * | Any |

### Allow-Azure-Services
| Priority | Name | Source | Destination | Port | Protocol |
|----------|------|--------|-------------|------|----------|
| 200 | AllowAzureMonitor | 10.0.0.0/8 | AzureMonitor | 443 | TCP |
| 201 | AllowStorage | 10.0.0.0/8 | Storage.EastUS2 | 443 | TCP |
| 202 | AllowKeyVault | 10.0.0.0/8 | AzureKeyVault | 443 | TCP |

### Allow-Internet-Outbound
| Priority | Name | Source | Destination | Port | Protocol |
|----------|------|--------|-------------|------|----------|
| 300 | AllowHTTPS | 10.0.0.0/8 | * | 443 | TCP |

## Application Rules

### Allow-Updates
| Priority | Name | Source | Target FQDNs | Protocol |
|----------|------|--------|--------------|----------|
| 100 | WindowsUpdate | 10.0.0.0/8 | *.windowsupdate.com | HTTPS |
| 101 | UbuntuUpdate | 10.0.0.0/8 | *.ubuntu.com | HTTPS |

### Allow-GitHub
| Priority | Name | Source | Target FQDNs | Protocol |
|----------|------|--------|--------------|----------|
| 200 | GitHub | 10.1.0.0/16 | *.github.com | HTTPS |
| 201 | Packages | 10.1.0.0/16 | *.npmjs.org | HTTPS |
```

### Task 3.2: Design Private Endpoints Strategy

| Service | Endpoint | DNS Zone |
|---------|----------|----------|
| Azure SQL | pe-sql-ecommerce | privatelink.database.windows.net |
| Cosmos DB | pe-cosmos-catalog | privatelink.documents.azure.com |
| Storage (Blob) | pe-storage-images | privatelink.blob.core.windows.net |
| Key Vault | pe-kv-secrets | privatelink.vaultcore.azure.net |
| ACR | pe-acr-containers | privatelink.azurecr.io |

---

## 🔧 Exercise 4: Design App Services Architecture

### Task 4.1: App Service Design

```markdown
# App Service Architecture - E-Commerce Frontend

## App Service Plan Configuration
- **Tier**: Premium V3
- **SKU**: P1V3 (2 vCPU, 8 GB)
- **Instances**: 3 minimum, 10 maximum
- **Zone Redundancy**: Enabled

## Scaling Rules
| Metric | Operator | Threshold | Scale Action | Cooldown |
|--------|----------|-----------|--------------|----------|
| CPU | > | 70% avg 5min | Scale out +1 | 5 min |
| CPU | < | 30% avg 10min | Scale in -1 | 10 min |
| HTTP Queue | > | 100 avg 5min | Scale out +2 | 5 min |
| Memory | > | 80% avg 5min | Scale out +1 | 5 min |

## Deployment Slots
| Slot | Purpose | Traffic |
|------|---------|---------|
| Production | Live traffic | 100% |
| Staging | Pre-release testing | 0% |
| Canary | Gradual rollout | 5% (when active) |

## VNet Integration
- Subnet: snet-app-integration (10.1.5.0/24)
- Regional VNet integration
- Route all traffic through VNet
```

---

## 📝 Module Deliverables

1. **Network Architecture Document**
   - Hub-spoke topology diagram
   - IP address allocation plan
   - Peering configuration

2. **Compute Strategy Document**
   - Workload-to-service mapping
   - AKS cluster design
   - Scaling configuration

3. **Security Design Document**
   - Firewall rules
   - NSG configurations
   - Private endpoint plan

4. **Implementation Scripts**
   - Bicep/ARM templates
   - Azure CLI scripts

---

## 🧹 Cleanup

```bash
# Delete AKS cluster
az aks delete \
  --name "aks-northwind-prod-001" \
  --resource-group "rg-compute" \
  --yes --no-wait

# Delete VNets
az network vnet delete \
  --name "vnet-hub-eastus2-001" \
  --resource-group "rg-connectivity"
```

---

## ➡️ Next Steps

👉 [Continue to Module 05: Design Migrations](../05-migrations/README.md)

---

## 📚 Additional Resources

- [Azure Networking Documentation](https://learn.microsoft.com/en-us/azure/networking/)
- [Hub-Spoke Reference Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
