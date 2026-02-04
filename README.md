# 🎓 Azure Certification Portfolio Projects

[![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com)
[![AZ-104](https://img.shields.io/badge/AZ--104-Administrator-0078D4?style=for-the-badge)](https://learn.microsoft.com/certifications/azure-administrator/)
[![AZ-305](https://img.shields.io/badge/AZ--305-Architect-0078D4?style=for-the-badge)](https://learn.microsoft.com/certifications/azure-solutions-architect/)
[![AI-102](https://img.shields.io/badge/AI--102-AI%20Engineer-0078D4?style=for-the-badge)](https://learn.microsoft.com/certifications/azure-ai-engineer/)

> **Hands-on portfolio projects to solidify your Azure certification knowledge through real-world scenarios.**

---

## 📋 Overview

This repository contains **three comprehensive portfolio projects**, each designed to reinforce skills from a specific Azure certification. Projects follow a **building blocks approach** - start simple and progressively tackle more complex scenarios.

| Project | Certification | Scenario | Modules | Est. Time |
|---------|--------------|----------|---------|-----------|
| [AZ-104 Administrator](./az104-azure-administrator/) | Azure Administrator | Contoso Consulting | 8 modules | 30-40 hrs |
| [AZ-305 Architect](./az305-solutions-architect/) | Solutions Architect | Northwind Traders | 6 modules | 25-35 hrs |
| [AI-102 AI Engineer](./ai102-ai-engineer/) | Azure AI Engineer | IntelliHealth | 9 modules | 40-50 hrs |

---

## 🗂️ Repository Structure

```
project-portfolio/
├── README.md                          ← You are here
│
├── az104-azure-administrator/         ← AZ-104 Project
│   ├── README.md
│   ├── COST_GUIDE.md
│   ├── TROUBLESHOOTING.md
│   └── modules/
│       ├── 01-identity-governance/
│       ├── 02-storage/
│       ├── 03-virtual-machines/
│       ├── 04-networking/
│       ├── 05-app-services/
│       ├── 06-monitoring/
│       ├── 07-advanced-networking/
│       └── 08-capstone/
│
├── az305-solutions-architect/         ← AZ-305 Project
│   ├── README.md
│   ├── COST_GUIDE.md
│   ├── TROUBLESHOOTING.md
│   └── modules/
│       ├── 01-governance-identity/
│       ├── 02-data-storage/
│       ├── 03-business-continuity/
│       ├── 04-infrastructure/
│       ├── 05-application-architecture/
│       └── 06-capstone/
│
└── ai102-ai-engineer/                 ← AI-102 Project
    ├── README.md
    ├── COST_GUIDE.md
    ├── TROUBLESHOOTING.md
    └── modules/
        ├── 01-azure-ai-fundamentals/
        ├── 02-computer-vision/
        ├── 03-natural-language/
        ├── 04-knowledge-mining/
        ├── 05-document-intelligence/
        ├── 06-azure-openai/
        ├── 07-conversational-ai/
        ├── 08-responsible-ai/
        └── 09-capstone/
```

---

## 🎯 Learning Approach

### Building Blocks Philosophy

Each project follows the same progressive learning pattern:

1. **Start Simple** → Deploy basic resources, learn core concepts
2. **Add Complexity** → Integrate services, implement security
3. **Real-World Scenarios** → Build production-like solutions
4. **Capstone** → Combine everything in a comprehensive project

### What's Included in Each Module

- 📖 **Detailed Instructions** - Step-by-step guidance
- 🎯 **Learning Objectives** - Clear goals aligned with exam domains
- 💻 **Hands-On Exercises** - Portal + CLI/PowerShell approaches
- 🧹 **Cleanup Steps** - Avoid unexpected charges
- ✅ **Validation Checks** - Verify your work
- 📚 **Additional Resources** - Links to MS Learn content

---

## 💰 Cost Estimates

All projects are designed to minimize costs using free-tier resources.

| Project | Estimated Total Cost | Notes |
|---------|---------------------|-------|
| AZ-104 | **$15-25** | Uses VM free hours, F1 apps |
| AZ-305 | **$5-15** | Design-focused, minimal deployments |
| AI-102 | **$20-40** | AI services have free tiers |

> ⚠️ **Always complete cleanup steps** after each session to avoid charges!

---

## 🚀 Getting Started

### Prerequisites

- [ ] **Azure Subscription** - [Create Free Account](https://azure.microsoft.com/free/)
- [ ] **Azure CLI** - [Install Guide](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [ ] **VS Code** with Azure extensions
- [ ] **Git** installed

### Choose Your Path

| If you have... | Start with... |
|----------------|---------------|
| AZ-104 certification | [AZ-104 Project](./az104-azure-administrator/) |
| AZ-305 certification | [AZ-305 Project](./az305-solutions-architect/) |
| AI-102 certification | [AI-102 Project](./ai102-ai-engineer/) |
| Multiple certifications | Any order - projects are independent |

### Quick Start

```bash
# Clone this repository
git clone https://github.com/KyleMonteagudo/project-portfolio.git
cd project-portfolio

# Navigate to your chosen project
cd az104-azure-administrator  # or az305-solutions-architect or ai102-ai-engineer

# Start with Module 01
# Follow the README.md in each module folder
```

---

## 📊 Project Details

### AZ-104: Azure Administrator
**Scenario**: You're the Azure Administrator for **Contoso Consulting** (25 employees), migrating from on-premises to Azure.

| Module | Topic | Skills |
|--------|-------|--------|
| 01 | Identity & Governance | Entra ID, RBAC, Policy |
| 02 | Storage | Blobs, Files, Replication |
| 03 | Virtual Machines | VMs, Availability, Backup |
| 04 | Networking | VNets, NSGs, Load Balancers |
| 05 | App Services | Web Apps, Deployment Slots |
| 06 | Monitoring | Monitor, Alerts, Diagnostics |
| 07 | Advanced Networking | VPN, Peering, Private Endpoints |
| 08 | Capstone | Full Infrastructure Project |

### AZ-305: Solutions Architect
**Scenario**: You're the Solutions Architect for **Northwind Traders**, designing their Azure migration strategy.

| Module | Topic | Skills |
|--------|-------|--------|
| 01 | Governance & Identity | Multi-tenant, B2B/B2C, PIM |
| 02 | Data Storage | Partitioning, Caching, Residency |
| 03 | Business Continuity | DR, Backup, HA Patterns |
| 04 | Infrastructure | Compute Selection, Migrations |
| 05 | Application Architecture | Microservices, Messaging |
| 06 | Capstone | Complete Architecture Design |

### AI-102: Azure AI Engineer
**Scenario**: You're the AI Engineer for **IntelliHealth**, building an intelligent healthcare platform.

| Module | Topic | Skills |
|--------|-------|--------|
| 01 | Azure AI Fundamentals | Services, SDKs, Security |
| 02 | Computer Vision | Image Analysis, OCR, Custom Vision |
| 03 | Natural Language | Text Analytics, Translator |
| 04 | Knowledge Mining | Cognitive Search, Indexing |
| 05 | Document Intelligence | Form Recognizer, Extraction |
| 06 | Azure OpenAI | GPT, Embeddings, Prompt Engineering |
| 07 | Conversational AI | Bot Framework, LUIS |
| 08 | Responsible AI | Ethics, Transparency, Fairness |
| 09 | Capstone | Full AI Healthcare Platform |

---

## 🏆 Portfolio Benefits

Upon completing these projects, you'll have:

- ✅ **Hands-on experience** with real Azure services
- ✅ **GitHub portfolio** demonstrating your skills
- ✅ **Documentation skills** from architecture decisions
- ✅ **Troubleshooting experience** from debugging issues
- ✅ **Cost management awareness** from budget exercises
- ✅ **Interview talking points** for each certification domain

---

## 📝 Progress Tracking

Track your progress by updating checkboxes in each project's README, and commit your changes:

```bash
git add .
git commit -m "Complete AZ-104 Module 03: Virtual Machines"
git push origin main
```

---

## 🤝 Contributing

Found an issue or have a suggestion? Feel free to:
- Open an issue
- Submit a pull request
- Reach out with feedback

---

## 📚 Additional Resources

- [Microsoft Learn](https://learn.microsoft.com)
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)

---

*Created with ❤️ to help Azure professionals grow their skills through hands-on practice*
