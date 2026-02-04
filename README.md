# 🎓 AZ-104 Portfolio Project: Contoso Small Business Cloud Infrastructure

[![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com)
[![AZ-104](https://img.shields.io/badge/AZ--104-Certified-success?style=for-the-badge)](https://learn.microsoft.com/en-us/certifications/azure-administrator/)

> **Congratulations on passing AZ-104!** 🎉 This project will help you solidify your knowledge through hands-on practice by building a real-world cloud infrastructure from the ground up.

## 📋 Project Overview

You've been hired as the **Azure Administrator** for **Contoso Consulting**, a small business with 25 employees that is migrating from on-premises infrastructure to Azure. Your mission is to build out their entire cloud infrastructure following Azure best practices.

This project is designed in **building blocks** - start simple and progressively tackle more complex scenarios. Each module builds upon the previous one, simulating how real-world cloud projects evolve.

### 🎯 What You'll Build

By the end of this project, you will have deployed:
- A complete identity and governance framework
- Secure storage solutions for company files and backups
- Virtual machines for legacy application support
- A modern web application with high availability
- Enterprise-grade networking with security controls
- Comprehensive monitoring and alerting

---

## 📊 Project Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Contoso Azure Environment                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Identity   │  │  Governance  │  │  Monitoring  │          │
│  │  (Entra ID)  │  │   (Policy)   │  │  (Monitor)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
├─────────────────────────────────────────────────────────────────┤
│  Production Resource Group          Dev Resource Group           │
│  ┌─────────────────────────────┐   ┌─────────────────────────┐ │
│  │  ┌─────────┐  ┌─────────┐   │   │  ┌─────────┐            │ │
│  │  │   VM    │  │   VM    │   │   │  │ Web App │            │ │
│  │  │ (Web)   │  │ (DB)    │   │   │  │  (Dev)  │            │ │
│  │  └─────────┘  └─────────┘   │   │  └─────────┘            │ │
│  │       │            │        │   └─────────────────────────┘ │
│  │  ┌─────────────────────┐    │                               │
│  │  │   Load Balancer     │    │                               │
│  │  └─────────────────────┘    │                               │
│  │  ┌─────────────────────┐    │                               │
│  │  │   Storage Account   │    │                               │
│  │  │  (Files, Blobs)     │    │                               │
│  │  └─────────────────────┘    │                               │
│  └─────────────────────────────┘                               │
│  Virtual Network (10.0.0.0/16)                                  │
│  ├── Web Subnet (10.0.1.0/24)                                   │
│  ├── Data Subnet (10.0.2.0/24)                                  │
│  └── Mgmt Subnet (10.0.3.0/24)                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🗺️ Learning Path

| Module | Topic | Difficulty | Est. Time | Status |
|--------|-------|------------|-----------|--------|
| [01](./modules/01-identity-governance/) | Identity & Governance | ⭐ Beginner | 2-3 hours | ⬜ |
| [02](./modules/02-storage/) | Storage Solutions | ⭐ Beginner | 2-3 hours | ⬜ |
| [03](./modules/03-virtual-machines/) | Virtual Machines | ⭐⭐ Intermediate | 3-4 hours | ⬜ |
| [04](./modules/04-networking/) | Networking Fundamentals | ⭐⭐ Intermediate | 3-4 hours | ⬜ |
| [05](./modules/05-app-services/) | App Services | ⭐⭐ Intermediate | 2-3 hours | ⬜ |
| [06](./modules/06-monitoring/) | Monitoring & Maintenance | ⭐⭐ Intermediate | 2-3 hours | ⬜ |
| [07](./modules/07-advanced-networking/) | Advanced Networking | ⭐⭐⭐ Advanced | 4-5 hours | ⬜ |
| [08](./modules/08-capstone/) | Capstone Project | ⭐⭐⭐ Advanced | 6-8 hours | ⬜ |

**Total Estimated Time: 24-33 hours** (at your own pace - no rush!)

---

## ⏱️ Time Guidance

These time estimates are based on someone who has passed AZ-104 but is new to hands-on implementation:

| If you're spending... | What it means |
|----------------------|---------------|
| **Less than estimated** | Great! You're comfortable with these concepts |
| **Around estimated time** | Perfect - you're on track |
| **1.5x estimated time** | Normal - take time to understand deeply |
| **2x+ estimated time** | Consider reviewing the reference docs or asking for help |

> **💡 Pro Tip:** It's better to spend extra time understanding *why* something works than to rush through and just copy commands. This is learning, not a race!

---

## 💰 Cost Management

This project is designed to **minimize costs** using free-tier resources and short-lived deployments.

### Free Tier Resources Used
- **Azure Free Account**: 12 months of free services + $200 credit (30 days)
- **Always Free**: 750 hours B1S VMs, 5GB blob storage, etc.
- **Student Account**: If available, $100 credit via [Azure for Students](https://azure.microsoft.com/en-us/free/students/)

### Estimated Costs Per Module
| Module | Estimated Cost | Notes |
|--------|---------------|-------|
| 01 - Identity | **FREE** | Entra ID Free tier |
| 02 - Storage | **~$0.02** | Small blob/file storage |
| 03 - VMs | **~$5-10** | B1S VMs (can use free hours) |
| 04 - Networking | **FREE** | VNets, NSGs are free |
| 05 - App Services | **FREE** | F1 Free tier |
| 06 - Monitoring | **FREE** | Basic monitoring included |
| 07 - Advanced | **~$2-5** | VPN Gateway charges |
| 08 - Capstone | **~$5-10** | Combined resources |

### ⚠️ IMPORTANT: Cleanup Reminders

Each module includes a **🧹 Cleanup** section. **Always complete the cleanup steps** to avoid unexpected charges!

```bash
# Quick cleanup command (delete entire resource group)
az group delete --name <resource-group-name> --yes --no-wait
```

**Set a calendar reminder** after each session to verify resources are deleted!

---

## 📋 Prerequisites

Before starting, ensure you have:

### Required
- [ ] **Azure Subscription** - [Create Free Account](https://azure.microsoft.com/en-us/free/)
- [ ] **Azure CLI** installed - [Install Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [ ] **VS Code** with Azure extensions - [Download](https://code.visualstudio.com/)
- [ ] **Git** installed - [Download](https://git-scm.com/downloads)

### Recommended
- [ ] **Azure PowerShell** module - `Install-Module -Name Az -Scope CurrentUser`
- [ ] **Bicep** extension for VS Code
- [ ] **Azure Storage Explorer** - [Download](https://azure.microsoft.com/en-us/features/storage-explorer/)

### Verify Your Setup
```bash
# Check Azure CLI
az --version

# Login to Azure
az login

# Verify subscription
az account show --output table
```

---

## 📁 Repository Structure

```
az104-portfolio-project/
├── README.md                    # This file
├── COST_GUIDE.md               # Detailed cost management
├── TROUBLESHOOTING.md          # Common issues and solutions
├── modules/
│   ├── 01-identity-governance/
│   │   ├── README.md           # Module instructions
│   │   ├── exercises/          # Hands-on tasks
│   │   ├── solutions/          # Reference solutions
│   │   └── scripts/            # Automation scripts
│   ├── 02-storage/
│   ├── 03-virtual-machines/
│   ├── 04-networking/
│   ├── 05-app-services/
│   ├── 06-monitoring/
│   ├── 07-advanced-networking/
│   └── 08-capstone/
├── templates/                   # Reusable ARM/Bicep templates
├── scripts/                     # Utility scripts
└── assets/                      # Images and diagrams
```

---

## 🚀 Getting Started

### Step 1: Fork This Repository
Click the **Fork** button at the top right to create your own copy.

### Step 2: Clone Your Fork
```bash
git clone https://github.com/YOUR_USERNAME/az104-portfolio-project.git
cd az104-portfolio-project
```

### Step 3: Start Module 01
Navigate to [Module 01 - Identity & Governance](./modules/01-identity-governance/) and begin!

### Step 4: Track Your Progress
After completing each module, update this README by changing ⬜ to ✅ in the Learning Path table.

---

## 📚 Additional Resources

### Microsoft Learn Paths
- [AZ-104 Learning Path](https://docs.microsoft.com/en-us/learn/certifications/azure-administrator/)
- [Azure Administrator Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/)

### Practice Tools
- [Azure Portal](https://portal.azure.com)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure PowerShell Reference](https://docs.microsoft.com/en-us/powershell/azure/)

### Community
- [Microsoft Q&A](https://docs.microsoft.com/en-us/answers/topics/azure-virtual-machines.html)
- [Azure Subreddit](https://www.reddit.com/r/azure/)

---

## 🤝 Getting Help

**Stuck on a step?** Here's what to do:

1. **Check the Troubleshooting Guide** - [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. **Review the Reference Docs** - Each module links to relevant MS Learn content
3. **Check the Solutions Folder** - Each module has reference solutions
4. **Ask for Help** - Reach out to your mentor with:
   - What you're trying to do
   - What you've tried
   - The error message (if any)

---

## 📝 Progress Tracking

As you complete each module, commit your work with meaningful messages:

```bash
git add .
git commit -m "Complete Module 01: Identity & Governance"
git push origin main
```

This builds your GitHub activity and creates a portfolio of your work!

---

## 🏆 Completion Certificate

Once you've completed all modules including the capstone project, you'll have:
- A comprehensive understanding of Azure administration
- Real-world experience with common cloud scenarios
- A portfolio project to showcase to employers
- Hands-on skills that complement your AZ-104 certification

**Good luck, and enjoy your Azure journey!** 🚀

---

*Created with ❤️ to help Azure professionals grow*
