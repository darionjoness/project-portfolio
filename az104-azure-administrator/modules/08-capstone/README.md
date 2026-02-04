# Module 08: Capstone Project 🏆

![Difficulty: Advanced](https://img.shields.io/badge/Difficulty-Advanced-red)
![Time: 6-8 hours](https://img.shields.io/badge/Time-6--8%20hours-blue)

## 🎯 Overview

Congratulations on making it to the final module! This capstone project brings together everything you've learned to build a complete, production-ready Azure environment.

**This module is intentionally less guided.** You'll receive requirements and goals, but you'll need to figure out the implementation using skills from previous modules.

---

## 📖 The Challenge

### Scenario

Contoso Consulting has been acquired by a larger company. As part of the integration, you need to set up a new Azure environment from scratch that demonstrates best practices for:

- **Security**: Proper network segmentation and access controls
- **High Availability**: Applications must survive zone failures
- **Cost Optimization**: Use free tiers where possible, auto-shutdown non-prod
- **Monitoring**: Comprehensive visibility into all resources
- **Governance**: Tags, policies, and proper naming conventions

### What You'll Build

A complete three-tier web application environment:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Contoso Integration Environment                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                     Production VNet                          │   │
│   │   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐      │   │
│   │   │  Web Tier   │   │  App Tier   │   │  Data Tier  │      │   │
│   │   │  (App Svc)  │──▶│  (Function) │──▶│  (Storage)  │      │   │
│   │   └─────────────┘   └─────────────┘   └─────────────┘      │   │
│   │         │                                    │               │   │
│   │   ┌─────────────┐              ┌─────────────────────┐     │   │
│   │   │ App Gateway │              │  Private Endpoint   │     │   │
│   │   │    (WAF)    │              │     (Storage)       │     │   │
│   │   └─────────────┘              └─────────────────────┘     │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                     ┌────────────────┐                              │
│                     │   Monitoring   │                              │
│                     │ (Log Analytics)│                              │
│                     └────────────────┘                              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Requirements

### Phase 1: Foundation (Governance & Identity)
**Time Estimate: 1-2 hours**

| Requirement | Details | Verification |
|-------------|---------|--------------|
| Create Resource Groups | Production, Development, Shared Services | 3 RGs with proper naming |
| Implement Tagging | Environment, Owner, CostCenter, Project | All RGs tagged |
| Create Custom Role | "Contoso Operator" - can restart VMs, view all resources | Role exists and works |
| Assign Policy | Require "Environment" tag on all resources | Policy in effect |

**Deliverables:**
- [ ] Screenshot of resource groups with tags
- [ ] JSON export of custom role definition
- [ ] Policy compliance report

---

### Phase 2: Networking
**Time Estimate: 1-2 hours**

| Requirement | Details | Verification |
|-------------|---------|--------------|
| Create VNet | 10.0.0.0/16 with 4 subnets | VNet created |
| Configure NSGs | Web, App, Data tiers with proper rules | NSGs associated |
| Private DNS Zone | contoso.local for internal resolution | DNS zone linked |

**Network Design:**
| Subnet | Address Range | Purpose |
|--------|--------------|---------|
| snet-web | 10.0.1.0/24 | Web tier |
| snet-app | 10.0.2.0/24 | Application tier |
| snet-data | 10.0.3.0/24 | Data tier |
| snet-endpoints | 10.0.4.0/24 | Private endpoints |

**NSG Rules:**
- Web tier: Allow 80/443 from Internet
- App tier: Allow 443 from Web tier only
- Data tier: Allow 443 from App tier only

**Deliverables:**
- [ ] Network diagram (hand-drawn is fine!)
- [ ] NSG rules screenshot
- [ ] Effective routes from a test VM

---

### Phase 3: Compute & Application
**Time Estimate: 2-3 hours**

| Requirement | Details | Verification |
|-------------|---------|--------------|
| Deploy Web App | App Service with staging slot | URL accessible |
| Deploy Function App | Consumption plan | Function runs |
| Configure Storage | With private endpoint | Accessible only from VNet |

**Web Application Requirements:**
- Deploy to Standard S1 App Service Plan
- Create staging slot
- Enable HTTPS only
- Configure auto-scale (1-3 instances based on CPU)

**Function App:**
- Consumption plan (pay per execution)
- Triggered by HTTP
- Should read from storage account

**Storage Account:**
- No public access
- Private endpoint in snet-endpoints
- Lifecycle management (30 day cool, 90 day archive)

**Deliverables:**
- [ ] Web app URL working
- [ ] Function app URL working
- [ ] Storage accessible only from VNet (test from VM)

---

### Phase 4: Monitoring & Alerting
**Time Estimate: 1-2 hours**

| Requirement | Details | Verification |
|-------------|---------|--------------|
| Log Analytics | Centralized logging | Workspace created |
| Diagnostic Settings | All resources streaming logs | Settings configured |
| Alerts | CPU, errors, availability | Alerts firing |
| Dashboard | Executive overview | Dashboard saved |

**Alerts to Create:**
| Alert | Condition | Severity |
|-------|-----------|----------|
| High CPU | App Service CPU > 70% for 5 min | Sev 2 |
| HTTP Errors | 5xx errors > 10 in 5 min | Sev 1 |
| Storage Availability | < 99% | Sev 1 |

**Deliverables:**
- [ ] Dashboard screenshot
- [ ] Alert rules list
- [ ] Sample KQL query results

---

## 🎯 Bonus Challenges

Complete these for extra credit:

### Challenge 1: Infrastructure as Code
Deploy everything using Azure CLI scripts or ARM/Bicep templates.

**Deliverable:** Script/template files that can recreate the environment

### Challenge 2: CI/CD Pipeline
Set up automated deployment from GitHub to App Service.

**Deliverable:** GitHub Actions workflow file

### Challenge 3: Cost Optimization Report
Analyze your environment using Azure Advisor and Cost Management.

**Deliverable:** PDF report with recommendations

### Challenge 4: Disaster Recovery Plan
Document the recovery process if the primary region fails.

**Deliverable:** Written DR plan with RTO/RPO

---

## 📝 Submission Checklist

When you're done, you should have:

### Documentation
- [ ] Architecture diagram
- [ ] Network diagram with IP addresses
- [ ] Security documentation (NSG rules, RBAC assignments)

### Screenshots
- [ ] Resource groups with tags
- [ ] Policy compliance
- [ ] Web application running
- [ ] Monitoring dashboard
- [ ] Alert configuration

### Code/Scripts
- [ ] Any deployment scripts used
- [ ] Custom role JSON
- [ ] Policy definition JSON
- [ ] KQL queries for monitoring

### Cleanup Confirmation
- [ ] All resources deleted to avoid charges
- [ ] Verification screenshot showing empty resource groups

---

## 💡 Hints and Tips

### If You Get Stuck

1. **Review previous modules** - The solutions are all in modules 1-7
2. **Check Microsoft Learn** - Search for specific topics
3. **Use Azure Portal Help** - The "?" icon has great docs
4. **Break it down** - Focus on one component at a time

### Common Mistakes to Avoid

- ❌ Creating resources before planning
- ❌ Forgetting NSG associations
- ❌ Not testing connectivity between tiers
- ❌ Skipping diagnostic settings
- ❌ Forgetting to clean up!

### Time Management

| Phase | Should Take | If Taking Longer |
|-------|-------------|------------------|
| Phase 1 | 1-2 hours | Review Module 01 |
| Phase 2 | 1-2 hours | Review Module 04 |
| Phase 3 | 2-3 hours | Review Modules 02, 03, 05 |
| Phase 4 | 1-2 hours | Review Module 06 |

---

## 🧹 Cleanup Procedure

> ⚠️ **CRITICAL**: Complete this to avoid charges!

```bash
# Delete all resource groups
az group delete --name "rg-contoso-prod-capstone" --yes --no-wait
az group delete --name "rg-contoso-dev-capstone" --yes --no-wait
az group delete --name "rg-contoso-shared-capstone" --yes --no-wait

# Delete any custom roles
az role definition delete --name "Contoso Operator"

# Delete any policy assignments at subscription level
az policy assignment delete --name "require-environment-tag"

# Verify everything is deleted
az group list --output table
```

### Cleanup Verification
1. Go to Azure Portal → Resource Groups
2. Confirm all capstone resource groups are deleted
3. Check Cost Management for any residual charges
4. Set calendar reminder to check again in 24 hours

---

## 🏆 Completion

### You Did It! 🎉

By completing this capstone project, you have demonstrated proficiency in:

- ✅ Azure governance and identity management
- ✅ Virtual networking and security
- ✅ Compute resource deployment
- ✅ Storage configuration and security
- ✅ Monitoring and alerting
- ✅ Cost management and optimization

### What's Next?

1. **Add to Your Portfolio**
   - Upload your architecture diagrams to GitHub
   - Write a blog post about what you learned
   - Add screenshots to your LinkedIn profile

2. **Continue Learning**
   - [AZ-305: Azure Solutions Architect](https://learn.microsoft.com/en-us/certifications/azure-solutions-architect/)
   - [AZ-400: Azure DevOps Engineer](https://learn.microsoft.com/en-us/certifications/devops-engineer/)
   - [AZ-500: Azure Security Engineer](https://learn.microsoft.com/en-us/certifications/azure-security-engineer/)

3. **Real World Projects**
   - Migrate a personal project to Azure
   - Contribute to open source Azure tools
   - Help others studying for AZ-104

---

## 📚 Reference Materials

### Quick Links
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [ARM Template Reference](https://learn.microsoft.com/en-us/azure/templates/)

### Architecture Patterns
- [Web Application Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/app-service-web-app/basic-web-app)
- [Multi-tier Architecture](https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/n-tier)

---

**Congratulations on completing the AZ-104 Portfolio Project!**

You're now ready to apply these skills in real-world scenarios. Keep learning, keep building, and keep sharing your knowledge with others.

*Good luck on your Azure journey!* 🚀
