# Module 01: Design Identity, Governance & Monitoring

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Design authentication and authorization solutions
- Design identity governance including PIM, access reviews, and entitlement management
- Design a solution for logging and monitoring
- Recommend governance solutions including management groups and policies
- Design solutions for secure administration

---

## 📖 Scenario

**Northwind Traders** is expanding globally and needs a comprehensive identity strategy that supports:

1. **50,000 employees** across 30 countries with different access needs
2. **10,000 external partners** (B2B) needing limited resource access
3. **10 million customers** (B2C) for their e-commerce platform
4. **Compliance requirements**: GDPR (EU), CCPA (California), SOC 2
5. **Privileged access management** for 200 IT administrators

---

## 📚 Pre-Reading (Required)

| Topic | Microsoft Learn Link | Time |
|-------|---------------------|------|
| Entra ID Overview | [What is Microsoft Entra ID?](https://learn.microsoft.com/en-us/entra/fundamentals/whatis) | 20 min |
| B2B Collaboration | [External Identities overview](https://learn.microsoft.com/en-us/entra/external-id/external-identities-overview) | 20 min |
| Azure AD B2C | [Azure AD B2C overview](https://learn.microsoft.com/en-us/azure/active-directory-b2c/overview) | 20 min |
| PIM | [What is Privileged Identity Management?](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure) | 20 min |
| Conditional Access | [Conditional Access overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) | 15 min |

---

## 💡 Key Concepts

### Identity Solution Comparison

| Scenario | Solution | Key Features |
|----------|----------|--------------|
| Internal employees | Entra ID (Corporate) | SSO, MFA, device management |
| Partners/Vendors | Entra External ID (B2B) | Guest accounts, access reviews |
| Customers | Azure AD B2C | Custom branding, social logins |
| Applications | Managed Identities | No credentials in code |
| On-premises sync | Entra Connect | Hybrid identity |

### Governance Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Governance Hierarchy                      │
├─────────────────────────────────────────────────────────────┤
│  Management Groups (Organizational structure)                │
│       └── Subscriptions (Billing boundary)                  │
│              └── Resource Groups (Lifecycle grouping)        │
│                     └── Resources (Individual services)      │
├─────────────────────────────────────────────────────────────┤
│  Applied At Each Level:                                      │
│  • RBAC (Access Control)                                    │
│  • Azure Policy (Compliance)                                │
│  • Blueprints (Standardized environments)                   │
│  • Cost Management (Budget controls)                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Exercise 1: Design Identity Architecture

### Task 1.1: Document Requirements

Create a design document analyzing Northwind's identity requirements:

**Template: `design-documents/identity-requirements.md`**

```markdown
# Northwind Traders - Identity Requirements Analysis

## Stakeholder Requirements

### Business Requirements
- [ ] Support 50,000 employees across 30 countries
- [ ] Enable secure partner collaboration (10,000 partners)
- [ ] Provide seamless customer sign-in experience
- [ ] Meet compliance requirements (GDPR, CCPA, SOC 2)

### Technical Requirements
- [ ] Single Sign-On (SSO) for all corporate applications
- [ ] Multi-Factor Authentication (MFA) for all users
- [ ] Conditional Access based on risk level
- [ ] Privileged access management for IT admins

### Security Requirements
- [ ] Zero-trust architecture
- [ ] Just-in-time (JIT) privileged access
- [ ] Regular access reviews
- [ ] Audit logging for all identity events

## User Personas

| Persona | Count | Access Needs | Authentication |
|---------|-------|--------------|----------------|
| Office Worker | 40,000 | Email, Teams, SharePoint | SSO + MFA |
| Field Worker | 8,000 | Mobile apps, limited data | Phone-based MFA |
| IT Admin | 500 | Azure Portal, servers | PIM + hardware key |
| Partner | 10,000 | Specific apps only | Guest + MFA |
| Customer | 10M | E-commerce site | Social/email login |
```

### Task 1.2: Create Architecture Decision Record (ADR)

**Template: `design-documents/adr-001-identity-provider.md`**

```markdown
# ADR-001: Identity Provider Selection

## Status
Proposed

## Context
Northwind Traders needs an identity solution that supports employees, partners, and customers with different authentication requirements.

## Decision Drivers
- Security (Zero-trust model)
- User experience (SSO, passwordless)
- Compliance (GDPR, SOC 2)
- Cost optimization
- Integration with existing systems

## Options Considered

### Option 1: Single Entra ID Tenant
- **Pros**: Simple management, unified directory
- **Cons**: Customer data mixed with corporate, complex B2C scenarios

### Option 2: Entra ID + Azure AD B2C (Recommended)
- **Pros**: Separation of concerns, optimized for each audience
- **Cons**: Two directories to manage

### Option 3: Third-party IdP (Okta/Auth0)
- **Pros**: Feature-rich, vendor neutral
- **Cons**: Additional cost, integration complexity with Azure

## Decision
**Option 2: Entra ID + Azure AD B2C**

Rationale:
1. Corporate users managed in Entra ID with full governance features
2. Customer identities isolated in B2C with consumer-focused features
3. Native Azure integration reduces complexity
4. Cost-effective at scale

## Consequences
- Two identity directories to manage
- B2B guests invited to corporate tenant
- Need B2C custom policies for complex flows
```

---

## 🔧 Exercise 2: Design Conditional Access

### Task 2.1: Design Conditional Access Policies

Create a conditional access policy matrix:

| Policy Name | Users | Apps | Conditions | Grant Controls |
|-------------|-------|------|------------|----------------|
| Require MFA - All Users | All employees | All cloud apps | Any location | Require MFA |
| Block Legacy Auth | All users | All cloud apps | Legacy auth protocols | Block |
| Require Compliant Device | All employees | Office 365 | Outside corporate network | Require compliant device |
| Privileged Access | Admin roles | Azure Portal | Any | Require MFA + compliant device + PIM |
| High-Risk Sign-in | All users | All cloud apps | High sign-in risk | Block or require password change |
| Guest Access | Guest users | Specific apps | Any | Require MFA + ToU acceptance |

### Task 2.2: Implement Named Locations

```bash
# This is conceptual - Conditional Access is configured in Portal
# Document the named locations you would create:

# Corporate Networks
# - Headquarters: 203.0.113.0/24
# - Branch Offices: 198.51.100.0/24, 192.0.2.0/24
# - VPN Exit Points: 10.0.0.0/8

# Trusted Partners (if applicable)
# - Partner VPN: specific IPs

# Blocked Locations (based on risk assessment)
# - Countries with no business operations
```

### Task 2.3: Design the Policy Flow

```
┌─────────────────────────────────────────────────────────────┐
│              Conditional Access Decision Flow                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  User Sign-in ───► Evaluate ALL applicable policies        │
│                            │                                │
│                            ▼                                │
│               ┌───────────────────────┐                    │
│               │ Check Conditions      │                    │
│               │ • User/Group          │                    │
│               │ • Application         │                    │
│               │ • Location            │                    │
│               │ • Device state        │                    │
│               │ • Risk level          │                    │
│               └───────────┬───────────┘                    │
│                           │                                 │
│              ┌────────────┴────────────┐                   │
│              ▼                         ▼                    │
│    ┌──────────────────┐    ┌──────────────────┐           │
│    │ Grant Controls   │    │ Session Controls │           │
│    │ • Require MFA    │    │ • Sign-in freq   │           │
│    │ • Require device │    │ • Persistent     │           │
│    │ • Require app    │    │ • App enforced   │           │
│    │ • Block          │    │                  │           │
│    └──────────────────┘    └──────────────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Exercise 3: Design Privileged Identity Management

### Task 3.1: Identify Privileged Roles

Document which roles need PIM:

| Role | Scope | Justification Required | Max Duration | Approvers |
|------|-------|----------------------|--------------|-----------|
| Global Administrator | Tenant | Yes | 2 hours | Security Team |
| Subscription Owner | Subscription | Yes | 4 hours | Platform Team |
| User Administrator | Tenant | Yes | 8 hours | IT Manager |
| Application Administrator | Tenant | No | 8 hours | Self-approval |
| Security Reader | Tenant | No | 24 hours | Self-approval |

### Task 3.2: Design Access Review Schedule

| Review Name | Scope | Frequency | Reviewers | Auto-remove |
|-------------|-------|-----------|-----------|-------------|
| Admin Role Review | All admin roles | Monthly | Role owners | After 30 days |
| Guest Access Review | All B2B guests | Quarterly | Group owners | After 90 days |
| Sensitive Apps Review | Critical apps | Monthly | App owners | After 30 days |
| External Collab Review | External users | Quarterly | Managers | After 90 days |

### Task 3.3: Implement PIM (Hands-On)

```bash
# PIM requires Entra ID P2 license
# If you have P2 trial, configure these settings:

# 1. Enable PIM for a role
# Portal: Entra ID → Identity Governance → Privileged Identity Management

# 2. Configure role settings
# - Activation maximum duration: 4 hours
# - Require MFA on activation: Yes
# - Require justification: Yes
# - Require approval: Yes (for critical roles)

# 3. Assign eligible roles
# - Make users "eligible" rather than "active"
# - Set assignment end date for contractors
```

---

## 🔧 Exercise 4: Design Governance Structure

### Task 4.1: Design Management Group Hierarchy

```
Root Management Group
├── mg-northwind-root (Top-level policies)
│   ├── mg-platform (Shared services)
│   │   ├── sub-connectivity (Hub networking)
│   │   ├── sub-identity (Entra Connect servers)
│   │   └── sub-management (Monitoring, automation)
│   │
│   ├── mg-landing-zones (Workload subscriptions)
│   │   ├── mg-corp (Internal applications)
│   │   │   ├── sub-corp-prod-001
│   │   │   └── sub-corp-dev-001
│   │   │
│   │   └── mg-online (External-facing)
│   │       ├── sub-ecommerce-prod
│   │       └── sub-ecommerce-dev
│   │
│   ├── mg-sandbox (Development/Testing)
│   │   └── sub-sandbox-001
│   │
│   └── mg-decommissioned (Retired subscriptions)
```

### Task 4.2: Design Policy Assignments

| Policy | Scope | Effect | Purpose |
|--------|-------|--------|---------|
| Allowed Locations | mg-northwind-root | Deny | Enforce data residency |
| Require Tags | mg-landing-zones | Deny | Cost management |
| Allowed VM SKUs | mg-landing-zones | Deny | Cost control |
| Audit HTTPS | mg-landing-zones | Audit | Security baseline |
| Deploy Diagnostics | mg-landing-zones | DeployIfNotExists | Monitoring |
| Deny Public IP | mg-corp | Deny | Network security |

### Task 4.3: Implement Management Groups (Hands-On)

```bash
# Create management group structure
az account management-group create \
  --name "mg-northwind-root" \
  --display-name "Northwind Root"

az account management-group create \
  --name "mg-platform" \
  --display-name "Platform" \
  --parent "mg-northwind-root"

az account management-group create \
  --name "mg-landing-zones" \
  --display-name "Landing Zones" \
  --parent "mg-northwind-root"

az account management-group create \
  --name "mg-sandbox" \
  --display-name "Sandbox" \
  --parent "mg-northwind-root"

# View hierarchy
az account management-group list --output table
```

---

## 🔧 Exercise 5: Design Monitoring Solution

### Task 5.1: Design Log Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 Centralized Logging Architecture             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│   │ Azure       │  │ Azure       │  │ On-premises │        │
│   │ Resources   │  │ AD Logs     │  │ Servers     │        │
│   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│          │                │                │                │
│          ▼                ▼                ▼                │
│   ┌─────────────────────────────────────────────────────┐  │
│   │              Log Analytics Workspace                 │  │
│   │   ┌─────────────────────────────────────────────┐   │  │
│   │   │ Tables:                                      │   │  │
│   │   │ • AzureActivity (90 days)                   │   │  │
│   │   │ • SignInLogs (30 days)                      │   │  │
│   │   │ • AuditLogs (90 days)                       │   │  │
│   │   │ • SecurityEvent (90 days)                   │   │  │
│   │   │ • Perf (30 days)                            │   │  │
│   │   └─────────────────────────────────────────────┘   │  │
│   └─────────────────────────────────────────────────────┘  │
│                           │                                 │
│          ┌────────────────┼────────────────┐               │
│          ▼                ▼                ▼                │
│   ┌───────────┐    ┌───────────┐    ┌───────────┐         │
│   │ Workbooks │    │ Alerts    │    │ Sentinel  │         │
│   └───────────┘    └───────────┘    └───────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Task 5.2: Define Alert Strategy

| Alert Category | Examples | Severity | Response |
|---------------|----------|----------|----------|
| Security | Failed MFA, impossible travel | Critical | Immediate investigation |
| Identity | Mass password resets, admin changes | High | Investigate within 1 hour |
| Availability | Service health, VM down | High | On-call notification |
| Performance | CPU > 90%, memory pressure | Medium | Ticket creation |
| Cost | Budget threshold exceeded | Low | Weekly review |

### Task 5.3: Design Retention Strategy

| Log Type | Hot Tier | Cool Tier | Archive | Total Retention |
|----------|----------|-----------|---------|-----------------|
| Security Events | 90 days | 1 year | 6 years | 7 years |
| Sign-in Logs | 30 days | 11 months | 6 years | 7 years |
| Azure Activity | 90 days | 9 months | 2 years | 3 years |
| Performance | 30 days | 60 days | - | 90 days |
| Application | 30 days | 60 days | - | 90 days |

---

## 📝 Module Deliverables

### Required Documents

1. **Identity Architecture Document**
   - User personas and requirements
   - Identity provider selection rationale
   - Diagram showing identity flows

2. **Conditional Access Policy Matrix**
   - Complete policy definitions
   - Named locations
   - Exception handling process

3. **PIM Configuration Document**
   - Privileged roles inventory
   - Access review schedule
   - Approval workflows

4. **Governance Structure Document**
   - Management group hierarchy
   - Policy assignments
   - Naming conventions

5. **Monitoring Design Document**
   - Log architecture diagram
   - Alert definitions
   - Retention policies

---

## 🧹 Cleanup

```bash
# Delete management groups (must remove subscriptions first)
az account management-group delete --name "mg-sandbox"
az account management-group delete --name "mg-landing-zones"
az account management-group delete --name "mg-platform"
az account management-group delete --name "mg-northwind-root"

# PIM and Conditional Access settings persist in tenant
# Disable or delete policies as needed via Portal
```

---

## ➡️ Next Steps

👉 [Continue to Module 02: Design Data Storage Solutions](../02-data-storage/README.md)

---

## 📚 Additional Resources

- [Microsoft Entra Documentation](https://learn.microsoft.com/en-us/entra/)
- [Azure Governance Documentation](https://learn.microsoft.com/en-us/azure/governance/)
- [Cloud Adoption Framework - Governance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/govern/)
- [Zero Trust Architecture](https://learn.microsoft.com/en-us/security/zero-trust/)
