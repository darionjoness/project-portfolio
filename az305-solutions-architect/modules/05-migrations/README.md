# Module 05: Design Migrations

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 3-4 hours](https://img.shields.io/badge/Time-3--4%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Evaluate migration with Azure Migrate
- Describe Azure Data Migration tools
- Recommend a migration strategy for applications
- Design database migration strategies
- Plan for offline and online migrations

---

## 📖 Scenario

Northwind Traders is migrating from their on-premises datacenter:

1. **200 VMs** running various workloads
2. **5 SQL Server** databases (total 10TB)
3. **Legacy .NET Framework** applications
4. **File servers** with 50TB of data
5. **Timeline**: 12 months to vacate datacenter

---

## 💡 Key Concepts

### Migration Strategies (6 Rs)

| Strategy | Description | When to Use | Effort |
|----------|-------------|-------------|--------|
| Rehost | "Lift and shift" to VMs | Quick wins, legacy apps | Low |
| Refactor | Move to PaaS with minimal changes | Web apps to App Service | Medium |
| Rearchitect | Significant code changes | Modernization | High |
| Rebuild | Rewrite from scratch | Major changes needed | Very High |
| Replace | Switch to SaaS | Commodity applications | Low |
| Retire | Decommission | No longer needed | Low |

### Migration Phases

```
┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
│ Assess  │──►│  Plan   │──►│ Deploy  │──►│ Migrate │──►│Optimize │
└─────────┘   └─────────┘   └─────────┘   └─────────┘   └─────────┘
     │             │             │             │             │
     ▼             ▼             ▼             ▼             ▼
  Discover      Design        Landing      Execute       Review
  Assess        Timeline      Zone         Cutover       Improve
  Prioritize    Resources     Setup        Validate      Optimize
```

---

## 🔧 Exercise 1: Assess Current Environment

### Task 1.1: Inventory and Dependencies

```markdown
# Northwind Migration Assessment

## Application Portfolio

### Tier 1 - Mission Critical
| Application | Technology | Dependencies | Migration Strategy |
|-------------|------------|--------------|-------------------|
| E-commerce Web | .NET 6 | SQL Server, Redis | Refactor → App Service |
| Order Processing | .NET Framework 4.8 | SQL Server, MSMQ | Rearchitect → AKS |
| Payment Gateway | Java Spring | Oracle (moving to vendor cloud) | Replace → SaaS |

### Tier 2 - Business Critical
| Application | Technology | Dependencies | Migration Strategy |
|-------------|------------|--------------|-------------------|
| Inventory Mgmt | .NET 6 | SQL Server | Refactor → App Service |
| Customer Portal | Angular + Node.js | MongoDB, Redis | Refactor → ACA |
| Reporting | SSRS | SQL Server | Refactor → Power BI |

### Tier 3 - Business Support
| Application | Technology | Dependencies | Migration Strategy |
|-------------|------------|--------------|-------------------|
| HR System | Vendor COTS | SQL Server | Rehost → VMs |
| File Servers | Windows Server | None | Refactor → Azure Files |
| Print Services | Windows Server | None | Retire |

## Database Inventory

| Database | Engine | Size | Migration Strategy |
|----------|--------|------|-------------------|
| EcommerceDB | SQL 2019 | 2TB | Azure SQL Hyperscale |
| InventoryDB | SQL 2019 | 500GB | Azure SQL Standard |
| ReportingDW | SQL 2019 | 5TB | Synapse Analytics |
| CustomerDB | MongoDB 4.4 | 200GB | Cosmos DB (MongoDB API) |
| CacheDB | Redis 6 | 50GB | Azure Cache for Redis |
```

### Task 1.2: Use Azure Migrate (Hands-On)

```bash
# Create Azure Migrate project
az group create --name "rg-migration" --location "eastus2"

# Azure Migrate is primarily Portal-driven
# Navigate to: Azure Portal → Azure Migrate → Create project

# Key steps:
# 1. Create Azure Migrate project
# 2. Download and deploy Azure Migrate appliance (OVA/VHD)
# 3. Configure appliance and connect to vCenter/Hyper-V
# 4. Start discovery
# 5. Create assessments
```

### Task 1.3: Document Assessment Results

```markdown
# Azure Migrate Assessment Summary

## VM Assessment

### Readiness Summary
| Readiness | Count | Percentage |
|-----------|-------|------------|
| Ready for Azure | 180 | 90% |
| Ready with conditions | 15 | 7.5% |
| Not ready | 5 | 2.5% |

### Right-Sizing Recommendations
| Current Size | Recommended Azure Size | Monthly Cost |
|--------------|----------------------|--------------|
| 8 vCPU, 32GB | Standard_D4s_v3 | $140 |
| 4 vCPU, 16GB | Standard_D2s_v3 | $70 |
| 16 vCPU, 64GB | Standard_D8s_v3 | $280 |

### Total Estimated Monthly Cost
- Compute: $25,000
- Storage: $5,000
- Networking: $2,000
- **Total**: $32,000/month

## Database Assessment (DMA)

### SQL Server → Azure SQL
| Database | Compatibility | Issues | Recommendation |
|----------|--------------|--------|----------------|
| EcommerceDB | 100% | None | Azure SQL Hyperscale |
| InventoryDB | 98% | 2 breaking changes | Fix, then Azure SQL |
| LegacyDB | 85% | Multiple issues | SQL MI or Rewrite |
```

---

## 🔧 Exercise 2: Design Migration Waves

### Task 2.1: Create Migration Wave Plan

```markdown
# Migration Wave Plan - 12 Month Timeline

## Wave 1: Foundation (Month 1-2)
**Objective**: Establish Azure landing zone and shared services

### Workloads
- Azure AD Connect (hybrid identity)
- VPN Gateway / ExpressRoute
- Azure Firewall
- Bastion
- Log Analytics

### Success Criteria
- Hybrid identity working
- Network connectivity established
- Monitoring operational

## Wave 2: Low-Risk Migrations (Month 3-4)
**Objective**: Build confidence with simple migrations

### Workloads
- File servers → Azure Files
- Dev/Test VMs → Azure VMs
- Static websites → Azure Storage

### Success Criteria
- 20 VMs migrated
- 10TB data migrated
- No production impact

## Wave 3: Business Support Apps (Month 5-6)
**Objective**: Migrate Tier 3 applications

### Workloads
- HR System (VM rehost)
- Internal tools (VM rehost)
- Non-critical databases

### Success Criteria
- 50 VMs migrated
- 3 databases migrated
- Users transitioned

## Wave 4: Business Critical Apps (Month 7-9)
**Objective**: Migrate Tier 2 applications

### Workloads
- Inventory Management → App Service
- Customer Portal → ACA
- Reporting → Power BI

### Success Criteria
- All Tier 2 apps running in Azure
- 5 databases migrated
- Performance validated

## Wave 5: Mission Critical Apps (Month 10-11)
**Objective**: Migrate Tier 1 applications

### Workloads
- E-commerce Web → App Service
- Order Processing → AKS
- Core databases → Azure SQL

### Success Criteria
- Zero-downtime cutover
- Performance equal or better
- All SLAs met

## Wave 6: Cleanup & Optimization (Month 12)
**Objective**: Decommission on-premises, optimize Azure

### Activities
- Decommission remaining on-prem
- Right-size Azure resources
- Implement FinOps practices
- Document lessons learned
```

### Task 2.2: Create Migration Timeline (Gantt Chart)

```
Month:        1    2    3    4    5    6    7    8    9   10   11   12
              ├────├────├────├────├────├────├────├────├────├────├────├────┤
Wave 1        ████████
Wave 2                  ████████
Wave 3                            ████████
Wave 4                                      ████████████████
Wave 5                                                        ████████
Wave 6                                                                  ████

Legend:
████ = Active migration work
```

---

## 🔧 Exercise 3: Design Database Migrations

### Task 3.1: SQL Server to Azure SQL Migration

```markdown
# Database Migration Strategy - EcommerceDB

## Source
- SQL Server 2019 Enterprise
- Size: 2TB
- Daily transactions: 1M+
- Acceptable downtime: 4 hours (maintenance window)

## Target
- Azure SQL Database Hyperscale
- 8 vCores Gen5
- 100TB storage (auto-scale)

## Migration Method: Online (DMS)

### Phase 1: Preparation
1. Run Data Migration Assistant (DMA)
2. Fix compatibility issues (none identified)
3. Create Azure SQL Database
4. Set up Azure DMS

### Phase 2: Initial Sync
1. Start DMS replication
2. Wait for initial full copy (~24-48 hours for 2TB)
3. Validate row counts

### Phase 3: Cutover (During maintenance window)
1. Stop application writes
2. Wait for final sync (minutes)
3. Update connection strings
4. Validate application
5. Start application writes

### Rollback Plan
- Keep source database running for 7 days
- Connection string quick-switch capability
- Data sync monitoring

## Migration Timeline
| Phase | Duration | Downtime |
|-------|----------|----------|
| Prep | 2 days | None |
| Initial sync | 2 days | None |
| Cutover | 2 hours | 2 hours |
| Validation | 4 hours | None |
```

### Task 3.2: MongoDB to Cosmos DB Migration

```markdown
# Database Migration - CustomerDB (MongoDB → Cosmos DB)

## Source
- MongoDB 4.4 on-premises
- Size: 200GB
- Documents: 50M

## Target
- Cosmos DB for MongoDB API
- Serverless or Autoscale (1000-10000 RU/s)

## Migration Method: Online (DMS for MongoDB)

### Steps
1. Create Cosmos DB account with MongoDB API
2. Create database and collections
3. Configure indexing (match source)
4. Run DMS with MongoDB source
5. Cutover during low-traffic period

### Considerations
- Shard key selection (optimize for query patterns)
- Index migration (compound indexes may differ)
- Connection string changes (MongoDB compatible)
```

---

## 🔧 Exercise 4: Design Application Migrations

### Task 4.1: .NET App to App Service

```markdown
# Application Migration - E-commerce Web

## Source
- .NET 6 Web Application
- Hosted on: Windows Server 2022 / IIS
- Dependencies: SQL Server, Redis, Azure Blob

## Target
- Azure App Service (Windows)
- Premium V3 (P1V3)
- Deployment slots: Production, Staging

## Migration Approach

### Code Changes Required
1. Update connection strings (use App Configuration)
2. Update Redis connection (Azure Cache for Redis)
3. Update blob storage connection
4. Implement managed identity authentication
5. Add health check endpoint

### Deployment Strategy
1. Set up Azure DevOps pipeline
2. Deploy to staging slot
3. Run integration tests
4. Swap to production

### Testing Checklist
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Load test (baseline comparison)
- [ ] Security scan
- [ ] Accessibility check
```

### Task 4.2: Create Migration Runbook

```markdown
# Migration Runbook - E-commerce Web

## Pre-Migration (1 week before)
- [ ] Final code changes merged
- [ ] Staging slot tested
- [ ] Load test completed (>= on-prem performance)
- [ ] Rollback procedure documented
- [ ] Communication sent to stakeholders

## Migration Day (Saturday 2 AM - 6 AM)

### T-60 min: Preparation
- [ ] Join war room bridge
- [ ] Verify Azure resources
- [ ] Verify DNS TTL lowered (done 24h prior)
- [ ] Confirm rollback readiness

### T-0: Cutover Start
- [ ] Put application in maintenance mode
- [ ] Verify no active transactions
- [ ] Take final database backup

### T+15 min: DNS Switch
- [ ] Update Traffic Manager/DNS
- [ ] Verify traffic routing to Azure
- [ ] Monitor for errors

### T+30 min: Validation
- [ ] Smoke tests (login, browse, checkout)
- [ ] Check application logs
- [ ] Verify database connectivity
- [ ] Monitor performance metrics

### T+60 min: Go/No-Go Decision
- [ ] All validations passed → Proceed
- [ ] Critical issues → Execute rollback

### T+120 min: Stabilization
- [ ] Continue monitoring
- [ ] Disable maintenance mode
- [ ] Notify stakeholders of success

## Post-Migration (Next 7 days)
- [ ] Monitor closely
- [ ] Keep rollback capability
- [ ] Gather user feedback
- [ ] Decommission on-prem after 7 days
```

---

## 📝 Module Deliverables

1. **Assessment Report**
   - Application inventory
   - Database inventory
   - Azure Migrate assessment results
   - Dependency mapping

2. **Migration Wave Plan**
   - Timeline with waves
   - Resource requirements
   - Risk assessment

3. **Database Migration Strategy**
   - Per-database plans
   - Online vs. offline decisions
   - Rollback procedures

4. **Application Migration Runbooks**
   - Step-by-step procedures
   - Testing checklists
   - Rollback plans

---

## 🧹 Cleanup

```bash
# Delete Azure Migrate project
az group delete --name "rg-migration" --yes --no-wait

# Delete any test VMs or databases created
```

---

## ➡️ Next Steps

👉 [Continue to Module 06: Capstone Project](../06-capstone/README.md)

---

## 📚 Additional Resources

- [Azure Migrate Documentation](https://learn.microsoft.com/en-us/azure/migrate/)
- [Cloud Adoption Framework - Migration](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/migrate/)
- [Database Migration Guide](https://learn.microsoft.com/en-us/data-migration/)
- [Azure Database Migration Service](https://learn.microsoft.com/en-us/azure/dms/)
