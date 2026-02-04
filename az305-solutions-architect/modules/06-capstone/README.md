# Module 06: Capstone - Full Architecture Design

![Difficulty: Advanced](https://img.shields.io/badge/Difficulty-Advanced-red)
![Time: 8-10 hours](https://img.shields.io/badge/Time-8--10%20hours-blue)

## 🎯 Overview

This capstone brings together all your AZ-305 learning into a comprehensive architecture design. You'll create a complete solution architecture with documentation worthy of a real enterprise project.

---

## 📖 The Challenge

### Scenario

**TechStart Inc.** is a fast-growing SaaS company that needs to redesign their architecture for enterprise scale. They've hired you as their Cloud Solutions Architect.

**Current State:**
- 500,000 users, expecting 5M in 2 years
- Monolithic .NET application on VMs
- Single SQL Server database (2TB)
- All infrastructure in one datacenter
- No disaster recovery
- Limited monitoring

**Requirements:**
1. Support 10x growth in users
2. 99.99% availability SLA
3. < 15-minute RPO, < 1-hour RTO
4. SOC 2 and GDPR compliance
5. Global presence (US, EU, APAC)
6. Microservices architecture
7. CI/CD with blue-green deployments
8. Cost optimization

---

## 📋 Deliverables

### 1. Architecture Design Document (40%)
Complete technical architecture including:
- High-level architecture diagram
- Detailed component diagrams
- Data flow diagrams
- Network topology

### 2. Technical Specifications (30%)
- Compute sizing and scaling
- Database architecture
- Network design with IP planning
- Security architecture

### 3. Operations Design (20%)
- Monitoring and alerting strategy
- Backup and DR procedures
- Incident response plan
- Cost management approach

### 4. Presentation (10%)
- Executive summary
- Architecture walkthrough
- Risk assessment
- Implementation roadmap

---

## 🔧 Part 1: High-Level Architecture

### Task 1.1: Create Architecture Diagram

Design a multi-region, highly available architecture:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     TechStart Global SaaS Architecture                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                           ┌──────────────────┐                              │
│                           │   Azure Front    │                              │
│                           │     Door         │                              │
│                           │   (WAF + CDN)    │                              │
│                           └────────┬─────────┘                              │
│                                    │                                        │
│         ┌──────────────────────────┼──────────────────────────┐            │
│         │                          │                          │            │
│         ▼                          ▼                          ▼            │
│  ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐    │
│  │   US Region     │      │   EU Region     │      │  APAC Region    │    │
│  │   (East US 2)   │      │ (West Europe)   │      │ (Southeast Asia)│    │
│  │                 │      │                 │      │                 │    │
│  │ ┌─────────────┐ │      │ ┌─────────────┐ │      │ ┌─────────────┐ │    │
│  │ │ App Service │ │      │ │ App Service │ │      │ │ App Service │ │    │
│  │ │ Environment │ │      │ │ Environment │ │      │ │ Environment │ │    │
│  │ └─────────────┘ │      │ └─────────────┘ │      │ └─────────────┘ │    │
│  │       │         │      │       │         │      │       │         │    │
│  │ ┌─────────────┐ │      │ ┌─────────────┐ │      │ ┌─────────────┐ │    │
│  │ │     AKS     │ │      │ │     AKS     │ │      │ │     AKS     │ │    │
│  │ │ (Microsvcs) │ │      │ │ (Microsvcs) │ │      │ │ (Microsvcs) │ │    │
│  │ └─────────────┘ │      │ └─────────────┘ │      │ └─────────────┘ │    │
│  │       │         │      │       │         │      │       │         │    │
│  │ ┌─────────────┐ │      │ ┌─────────────┐ │      │ ┌─────────────┐ │    │
│  │ │  Cosmos DB  │◄├──────┼─┤  Cosmos DB  │◄├──────┼─┤  Cosmos DB  │ │    │
│  │ │(Multi-write)│ │      │ │(Multi-write)│ │      │ │(Multi-write)│ │    │
│  │ └─────────────┘ │      │ └─────────────┘ │      │ └─────────────┘ │    │
│  └─────────────────┘      └─────────────────┘      └─────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Global Services                               │   │
│  │  • Entra ID (Identity)     • Key Vault (Secrets)                    │   │
│  │  • API Management          • Azure Monitor (Observability)          │   │
│  │  • Azure DNS               • Azure DevOps (CI/CD)                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Task 1.2: Document Architecture Decisions

Create ADRs for key decisions:

1. **ADR-001**: Why Azure Front Door vs Traffic Manager?
2. **ADR-002**: Why Cosmos DB vs Azure SQL for primary data?
3. **ADR-003**: Why AKS vs Container Apps for microservices?
4. **ADR-004**: Why App Service Environment vs multi-tenant App Service?

---

## 🔧 Part 2: Detailed Design

### Task 2.1: Identity Architecture

```markdown
# Identity Architecture

## Entra ID Configuration
- Tenant: techstart.com
- License: Entra ID P2

## User Types
| Type | Directory | Authentication | Count |
|------|-----------|----------------|-------|
| Employees | Entra ID | SSO + MFA | 500 |
| Customers | Azure AD B2C | Social + Email | 5M |
| Partners | B2B Guests | Federation | 100 |

## Applications
| App | Auth Method | Permissions |
|-----|-------------|-------------|
| Web Portal | OIDC | User.Read, api.access |
| Mobile App | OIDC + PKCE | User.Read, offline_access |
| API | OAuth2 Bearer | Varies by endpoint |
| Admin Portal | OIDC + Conditional Access | Admin roles |

## Conditional Access Policies
[Document your policies here]
```

### Task 2.2: Data Architecture

Design the data layer:

```markdown
# Data Architecture

## Primary Database: Cosmos DB
- API: NoSQL (Core SQL)
- Consistency: Session
- Regions: US, EU, APAC (multi-write)
- Partition Key Strategy: /tenantId

## Analytical Store
- Azure Synapse Analytics
- Synapse Link from Cosmos DB
- Power BI for reporting

## Caching Layer
- Azure Cache for Redis (Premium)
- Geo-replication across regions
- Session state + API caching

## File Storage
- Azure Blob Storage (RA-GRS)
- CDN for static assets
- Lifecycle management policies
```

### Task 2.3: Network Architecture

```markdown
# Network Architecture

## Global Networking
- Azure Front Door for global load balancing
- DDoS Protection Standard
- WAF with OWASP rules

## Regional Networks (Per Region)
- Hub-spoke topology
- Hub: Firewall, Bastion, VPN Gateway
- Spoke 1: Web tier (App Service VNet Integration)
- Spoke 2: App tier (AKS)
- Spoke 3: Data tier (Private Endpoints)

## IP Address Plan
| Region | VNet CIDR | Purpose |
|--------|-----------|---------|
| East US 2 | 10.0.0.0/16 | Hub |
| East US 2 | 10.1.0.0/16 - 10.4.0.0/16 | Spokes |
| West Europe | 10.10.0.0/16 | Hub |
| West Europe | 10.11.0.0/16 - 10.14.0.0/16 | Spokes |
| Southeast Asia | 10.20.0.0/16 | Hub |
| Southeast Asia | 10.21.0.0/16 - 10.24.0.0/16 | Spokes |

## Security
- All PaaS via Private Endpoints
- NSGs on all subnets
- Azure Firewall for egress filtering
```

---

## 🔧 Part 3: Operations Design

### Task 3.1: Monitoring Strategy

```markdown
# Monitoring and Observability

## Pillars

### Metrics
- Azure Monitor Metrics
- Application Insights
- Custom metrics via SDK

### Logs
- Log Analytics Workspace (per region + central)
- Diagnostic settings on all resources
- Application logs to App Insights

### Traces
- Distributed tracing with App Insights
- Correlation IDs across services
- Dependency tracking

## Key Dashboards
1. Executive Overview (availability, users, revenue)
2. SRE Dashboard (latency, errors, saturation)
3. Security Dashboard (threats, compliance)
4. Cost Dashboard (spend, trends, anomalies)

## Alerting Tiers
| Tier | Response | Examples |
|------|----------|----------|
| P1 | 15 min | Site down, data loss |
| P2 | 1 hour | Degraded performance, partial outage |
| P3 | 4 hours | Non-critical service impact |
| P4 | Next business day | Warnings, optimizations |
```

### Task 3.2: DR and Backup

```markdown
# Business Continuity

## Availability Targets
- SLA: 99.99%
- RPO: 5 minutes
- RTO: 30 minutes

## DR Strategy
- Active-Active across 3 regions
- Cosmos DB multi-region writes (no failover needed)
- AKS deployed to all regions
- Front Door automatic failover

## Backup Strategy
| Component | Method | RPO | Retention |
|-----------|--------|-----|-----------|
| Cosmos DB | Continuous | Point-in-time | 30 days |
| Blob Storage | Soft delete + versioning | Instant | 30 days |
| AKS Config | GitOps (Flux) | N/A | Git history |
| Secrets | Key Vault soft delete | Instant | 90 days |

## DR Testing
- Monthly: Component failover tests
- Quarterly: Full regional failover drill
- Annually: Chaos engineering exercise
```

### Task 3.3: Cost Optimization

```markdown
# Cost Management

## Estimated Monthly Cost
| Category | Service | Monthly Cost |
|----------|---------|--------------|
| Compute | AKS (3 regions) | $15,000 |
| Compute | App Service | $5,000 |
| Database | Cosmos DB | $20,000 |
| Networking | Front Door + Traffic | $3,000 |
| Storage | Blob + CDN | $2,000 |
| Security | Firewall + WAF | $4,000 |
| Monitoring | Log Analytics + App Insights | $3,000 |
| **Total** | | **$52,000** |

## Optimization Strategies
1. Reserved Instances for predictable workloads (40% savings)
2. Spot instances for batch processing (90% savings)
3. Autoscaling for variable load
4. Lifecycle policies for storage
5. Right-sizing based on monitoring data

## FinOps Practices
- Monthly cost review meetings
- Budget alerts at 50%, 75%, 90%, 100%
- Tagging for cost allocation
- Showback reports by team
```

---

## 📝 Final Deliverables Checklist

### Architecture Design Document
- [ ] Executive summary
- [ ] Solution overview
- [ ] High-level architecture diagram
- [ ] Component architecture diagrams
- [ ] Data flow diagrams
- [ ] Network topology diagram

### Technical Specifications
- [ ] Compute specifications (sizing, scaling)
- [ ] Database design (schema, partitioning)
- [ ] Network design (IP planning, security)
- [ ] Identity design (auth flows, policies)

### Operations Design
- [ ] Monitoring strategy
- [ ] Alerting definitions
- [ ] Backup procedures
- [ ] DR runbooks
- [ ] Incident response plan

### Implementation Plan
- [ ] Migration waves
- [ ] Resource dependencies
- [ ] Timeline (Gantt chart)
- [ ] Risk assessment

### Cost Analysis
- [ ] TCO estimate
- [ ] Optimization opportunities
- [ ] Reserved capacity recommendations

---

## 🏆 Success Criteria

Your architecture should demonstrate:

1. **Scalability**: Clear path from 500K to 5M users
2. **Availability**: 99.99% achievable with design
3. **Security**: Zero-trust principles applied
4. **Compliance**: GDPR and SOC 2 requirements addressed
5. **Cost Efficiency**: Optimizations identified
6. **Operability**: Clear monitoring and runbooks
7. **Documentation**: Professional, complete, clear

---

## 📚 Resources

- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)
- [Azure Reference Architectures](https://learn.microsoft.com/en-us/azure/architecture/browse/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)

---

**Congratulations on completing the AZ-305 Portfolio Project!** 🏗️

You now have a comprehensive architecture portfolio demonstrating your ability to design enterprise-grade Azure solutions.
