# 🏗️ AZ-305 Portfolio Project: Enterprise Cloud Architecture

[![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com)
[![AZ-305](https://img.shields.io/badge/AZ--305-Certified-success?style=for-the-badge)](https://learn.microsoft.com/en-us/certifications/azure-solutions-architect/)

> **Ready to think like an architect!** 🎉 This project takes you beyond administration into solution design, helping you make the right architectural decisions for enterprise scenarios.

## 📋 Project Overview

You've been promoted to **Cloud Solutions Architect** at **Northwind Traders**, a global e-commerce company with:
- 50,000 employees across 30 countries
- 10 million active customers
- $2B annual revenue
- Aggressive cloud-first strategy

Your mission is to **design and implement** enterprise-grade solutions that balance cost, security, performance, and scalability.

### 🎯 What You'll Design

By the end of this project, you will have architected:
- Multi-region, highly available infrastructure
- Enterprise identity with B2B/B2C scenarios
- Data platform with analytics and AI integration
- Business continuity with defined RTO/RPO
- Cost-optimized solutions with governance controls
- Migration strategy for legacy applications

---

## 📊 Project Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Northwind Enterprise Architecture                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  Management Group: Northwind-Root                                            │
│  ├── mg-platform (Shared Services)                                          │
│  ├── mg-production (Production Workloads)                                   │
│  └── mg-sandbox (Development/Testing)                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────┐    ┌─────────────────────┐                       │
│   │   Primary Region    │    │  Secondary Region   │                       │
│   │    (East US 2)      │◄──►│    (West US 2)      │                       │
│   │                     │    │                     │                       │
│   │  ┌───────────────┐  │    │  ┌───────────────┐  │                       │
│   │  │ Hub VNet      │  │    │  │ Hub VNet      │  │                       │
│   │  │ - Firewall    │  │    │  │ - Firewall    │  │                       │
│   │  │ - Bastion     │  │    │  │ - Bastion     │  │                       │
│   │  │ - VPN GW      │  │    │  │ - VPN GW      │  │                       │
│   │  └───────┬───────┘  │    │  └───────────────┘  │                       │
│   │          │          │    │                     │                       │
│   │  ┌───────┴───────┐  │    │                     │                       │
│   │  │ Spoke VNets   │  │    │                     │                       │
│   │  │ - Web Tier    │  │    │                     │                       │
│   │  │ - App Tier    │  │    │                     │                       │
│   │  │ - Data Tier   │  │    │                     │                       │
│   │  └───────────────┘  │    │                     │                       │
│   └─────────────────────┘    └─────────────────────┘                       │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Global Services: Traffic Manager, Front Door, Cosmos DB, Key Vault │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🗺️ Learning Path

| Module | Topic | Difficulty | Est. Time | Status |
|--------|-------|------------|-----------|--------|
| [01](./modules/01-identity-governance/) | Design Identity, Governance & Monitoring | ⭐⭐ Intermediate | 4-5 hours | ⬜ |
| [02](./modules/02-data-storage/) | Design Data Storage Solutions | ⭐⭐ Intermediate | 4-5 hours | ⬜ |
| [03](./modules/03-business-continuity/) | Design Business Continuity | ⭐⭐⭐ Advanced | 4-5 hours | ⬜ |
| [04](./modules/04-infrastructure/) | Design Infrastructure Solutions | ⭐⭐⭐ Advanced | 5-6 hours | ⬜ |
| [05](./modules/05-migrations/) | Design Migrations | ⭐⭐ Intermediate | 3-4 hours | ⬜ |
| [06](./modules/06-capstone/) | Capstone: Full Architecture | ⭐⭐⭐ Advanced | 8-10 hours | ⬜ |

**Total Estimated Time: 28-35 hours**

---

## 🧠 Architect Mindset

AZ-305 is different from AZ-104. You're not just implementing—you're **deciding**.

### Key Differences

| AZ-104 (Administrator) | AZ-305 (Architect) |
|------------------------|-------------------|
| "How do I deploy this?" | "Should we use this?" |
| Single service focus | Cross-service integration |
| Follow instructions | Make trade-off decisions |
| Technical execution | Business alignment |

### Decision Framework

For every design decision, consider:
1. **Requirements** - What are the functional/non-functional requirements?
2. **Constraints** - Budget? Timeline? Compliance? Skills?
3. **Trade-offs** - What do you gain/lose with each option?
4. **Justification** - Why is this the right choice?

---

## 💰 Cost Management

> ⚠️ **Architecture projects can get expensive.** Many exercises are **design-focused** (documentation, diagrams) to minimize costs.

### Cost-Saving Approach
- Modules 01-03: Heavy on design documentation, light on deployment
- Modules 04-05: Deploy, validate, then delete immediately
- Module 06: Capstone deploys full architecture (budget $50-100)

### Estimated Costs
| Module | Estimated Cost | Notes |
|--------|---------------|-------|
| 01 - Identity | $0-$5 | Mostly Entra ID (free tier) |
| 02 - Data | $5-$15 | Storage, Cosmos DB |
| 03 - BC/DR | $10-$20 | Backup vaults, secondary region |
| 04 - Infrastructure | $15-$25 | VMs, networking, firewall |
| 05 - Migrations | $5-$10 | Assessment tools |
| 06 - Capstone | $50-$100 | Full deployment |

---

## 📋 Prerequisites

### Required
- [ ] **AZ-104 certification** (or equivalent experience)
- [ ] **Azure Subscription** with Owner access
- [ ] **Azure CLI** and **Azure PowerShell**
- [ ] **VS Code** with Azure extensions
- [ ] **Visio/Draw.io/Diagrams.net** for architecture diagrams

### Recommended
- [ ] **Bicep** knowledge for IaC
- [ ] Experience with Azure Portal
- [ ] Understanding of networking fundamentals
- [ ] Familiarity with identity concepts (SAML, OAuth, etc.)

---

## 📁 Repository Structure

```
az305-portfolio-project/
├── README.md
├── COST_GUIDE.md
├── DESIGN_PATTERNS.md
├── TROUBLESHOOTING.md
├── modules/
│   ├── 01-identity-governance/
│   │   ├── README.md
│   │   ├── design-documents/
│   │   ├── exercises/
│   │   └── solutions/
│   ├── 02-data-storage/
│   ├── 03-business-continuity/
│   ├── 04-infrastructure/
│   ├── 05-migrations/
│   └── 06-capstone/
├── templates/
│   ├── design-document-template.md
│   ├── architecture-decision-record.md
│   └── bicep/
├── diagrams/
└── scripts/
```

---

## 🚀 Getting Started

### Step 1: Fork and Clone
```bash
git clone https://github.com/YOUR_USERNAME/az305-portfolio-project.git
cd az305-portfolio-project
```

### Step 2: Set Up Your Design Environment
- Install [Draw.io](https://draw.io) or use the VS Code extension
- Create an Azure DevOps or GitHub project for tracking

### Step 3: Start with Module 01
Navigate to [Module 01 - Identity & Governance](./modules/01-identity-governance/)

---

## 📚 Additional Resources

### Microsoft Learn
- [AZ-305 Learning Path](https://learn.microsoft.com/en-us/certifications/azure-solutions-architect/)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)

### Reference Architectures
- [Azure Reference Architectures](https://learn.microsoft.com/en-us/azure/architecture/browse/)
- [Azure Solution Ideas](https://learn.microsoft.com/en-us/azure/architecture/solution-ideas/)

---

*Created for aspiring Azure Solutions Architects* 🏗️
