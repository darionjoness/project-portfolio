# Module 03: Design Business Continuity

![Difficulty: Advanced](https://img.shields.io/badge/Difficulty-Advanced-red)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Design a solution for backup and recovery
- Design for high availability
- Design a disaster recovery solution
- Identify and mitigate data loss
- Recommend a solution for recovery in different regions

---

## 📖 Scenario

Northwind Traders has experienced a regional outage that cost them $2M in lost sales. Leadership demands:

1. **99.99% availability** for the e-commerce platform
2. **RPO < 5 minutes** for transactional data
3. **RTO < 1 hour** for full recovery
4. **Multi-region** failover capability
5. **Regular testing** of DR procedures

---

## 💡 Key Concepts

### Availability Targets

| SLA | Downtime/Year | Downtime/Month | Strategy Required |
|-----|--------------|----------------|-------------------|
| 99% | 3.65 days | 7.2 hours | Basic redundancy |
| 99.9% | 8.76 hours | 43.8 minutes | Zone redundancy |
| 99.95% | 4.38 hours | 21.9 minutes | Multi-region active-passive |
| 99.99% | 52.6 minutes | 4.38 minutes | Multi-region active-active |
| 99.999% | 5.26 minutes | 26.3 seconds | Complex, very expensive |

### Recovery Objectives

```
        ◄──────── RPO ────────►│◄──────── RTO ────────►
                               │
        Data Loss Window       │    Recovery Time
                               │
   ─────────────────────────── ● ───────────────────────►
                            Disaster               Back to
                            Occurs                 Normal
```

**RPO (Recovery Point Objective)**: Maximum acceptable data loss (time)
**RTO (Recovery Time Objective)**: Maximum acceptable downtime

---

## 🔧 Exercise 1: Define Availability Requirements

### Task 1.1: Business Impact Analysis

```markdown
# Business Impact Analysis - Northwind Traders

## Critical Business Processes

| Process | Impact/Hour Down | Criticality | Tier |
|---------|------------------|-------------|------|
| E-commerce checkout | $200,000 | Critical | Tier 1 |
| Product catalog | $50,000 | High | Tier 1 |
| Order processing | $100,000 | Critical | Tier 1 |
| Customer portal | $25,000 | Medium | Tier 2 |
| Reporting | $5,000 | Low | Tier 3 |
| Email marketing | $1,000 | Low | Tier 3 |

## Tier Definitions

### Tier 1 - Mission Critical
- RTO: 15 minutes
- RPO: 5 minutes
- Availability: 99.99%
- Multi-region active-active

### Tier 2 - Business Critical
- RTO: 1 hour
- RPO: 15 minutes
- Availability: 99.95%
- Multi-region active-passive

### Tier 3 - Business Support
- RTO: 4 hours
- RPO: 1 hour
- Availability: 99.9%
- Single region with backup
```

### Task 1.2: Map Services to Tiers

| Service | Tier | HA Strategy | DR Strategy |
|---------|------|-------------|-------------|
| Azure SQL (Orders) | Tier 1 | Zone-redundant | Auto-failover group |
| Cosmos DB (Catalog) | Tier 1 | Multi-region writes | Built-in |
| App Service (Web) | Tier 1 | Zone-redundant | Traffic Manager |
| Azure Functions | Tier 1 | Zone-redundant | Deployment stamps |
| Storage (Images) | Tier 2 | RA-GRS | Failover to secondary |
| Log Analytics | Tier 3 | N/A | Single region |

---

## 🔧 Exercise 2: Design High Availability

### Task 2.1: Design Multi-Region Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Multi-Region High Availability                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                         ┌───────────────────┐                               │
│                         │   Azure Front     │                               │
│                         │   Door / TM       │                               │
│                         └─────────┬─────────┘                               │
│                                   │                                         │
│                    ┌──────────────┼──────────────┐                          │
│                    ▼                             ▼                          │
│   ┌────────────────────────────┐  ┌────────────────────────────┐           │
│   │      East US 2 (Primary)   │  │    West US 2 (Secondary)   │           │
│   │                            │  │                            │           │
│   │  ┌──────────────────────┐  │  │  ┌──────────────────────┐  │           │
│   │  │ App Service (ZR)     │  │  │  │ App Service (ZR)     │  │           │
│   │  │ 3 Availability Zones │  │  │  │ 3 Availability Zones │  │           │
│   │  └──────────┬───────────┘  │  │  └──────────┬───────────┘  │           │
│   │             │              │  │             │              │           │
│   │  ┌──────────▼───────────┐  │  │  ┌──────────▼───────────┐  │           │
│   │  │ Azure SQL (ZR)       │◄─┼──┼─►│ Azure SQL (Replica)  │  │           │
│   │  │ Primary R/W          │  │  │  │ Read-only            │  │           │
│   │  └──────────────────────┘  │  │  └──────────────────────┘  │           │
│   │                            │  │                            │           │
│   │  ┌──────────────────────┐  │  │  ┌──────────────────────┐  │           │
│   │  │ Cosmos DB (Primary)  │◄─┼──┼─►│ Cosmos DB (Replica)  │  │           │
│   │  │ Multi-region writes  │  │  │  │ Multi-region writes  │  │           │
│   │  └──────────────────────┘  │  │  └──────────────────────┘  │           │
│   │                            │  │                            │           │
│   └────────────────────────────┘  └────────────────────────────┘           │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                        Global Services                               │   │
│   │  • Storage (RA-GRS)  • Key Vault (Paired regions)  • CDN            │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Task 2.2: Configure SQL Auto-Failover Group

```bash
# Create failover group
az sql failover-group create \
  --name "fog-northwind-ecommerce" \
  --server "sql-northwind-prod-001" \
  --resource-group "rg-northwind-data" \
  --partner-server "sql-northwind-dr-001" \
  --partner-resource-group "rg-northwind-data-dr" \
  --databases "sqldb-ecommerce" \
  --failover-policy Automatic \
  --grace-period 60

# Test failover (DR drill)
az sql failover-group set-primary \
  --name "fog-northwind-ecommerce" \
  --server "sql-northwind-dr-001" \
  --resource-group "rg-northwind-data-dr"
```

---

## 🔧 Exercise 3: Design Disaster Recovery

### Task 3.1: Create DR Runbook

```markdown
# Disaster Recovery Runbook - E-Commerce Platform

## Scenario: Complete Primary Region Failure

### Pre-Conditions
- [ ] Primary region (East US 2) is unavailable
- [ ] Secondary region (West US 2) is healthy
- [ ] DR declared by authorized personnel

### Recovery Steps

#### Phase 1: Detection and Declaration (0-15 min)
1. **Automated Detection**
   - Azure Monitor alerts trigger on availability drop
   - PagerDuty escalates to on-call team
   
2. **Assess Impact**
   - Confirm regional outage vs. service-specific issue
   - Check Azure Status page
   
3. **Declare Disaster**
   - Requires: CTO or VP of Engineering approval
   - Document: Time, reason, authorizer

#### Phase 2: Failover Execution (15-45 min)

##### 2.1 Database Failover
```bash
# Force failover (when primary unavailable)
az sql failover-group set-primary \
  --name "fog-northwind-ecommerce" \
  --server "sql-northwind-dr-001" \
  --resource-group "rg-northwind-data-dr" \
  --allow-data-loss
```

##### 2.2 Traffic Manager Failover
- Automatic (health probes detect failure)
- Manual verification in Azure Portal

##### 2.3 Storage Failover
```bash
# Initiate storage account failover
az storage account failover \
  --name "stnorthwindimages" \
  --resource-group "rg-northwind-storage"
```

#### Phase 3: Validation (45-60 min)
- [ ] Verify website accessible
- [ ] Test checkout flow
- [ ] Validate order processing
- [ ] Check payment processing
- [ ] Verify inventory updates

#### Phase 4: Communication
- [ ] Update status page
- [ ] Notify customer support
- [ ] Send internal communications
- [ ] Prepare customer communications if needed

### Post-Incident
- [ ] Root cause analysis
- [ ] Update runbook with lessons learned
- [ ] Schedule failback during maintenance window
```

### Task 3.2: Define RPO/RTO Matrix

| Component | RPO Target | RPO Actual | RTO Target | RTO Actual |
|-----------|-----------|------------|-----------|------------|
| Azure SQL | 5 min | ~5 sec (sync) | 30 min | ~30 sec |
| Cosmos DB | 0 min | 0 (multi-write) | 0 min | ~0 sec |
| App Service | N/A | N/A | 5 min | ~2 min |
| Storage | 15 min | ~15 min (async) | 1 hour | ~1 hour |
| Functions | N/A | N/A | 5 min | ~2 min |

---

## 🔧 Exercise 4: Design Backup Strategy

### Task 4.1: Backup Architecture

```markdown
# Backup Strategy - Northwind Traders

## Azure SQL Database

### Short-Term (Operational Recovery)
- **Method**: Point-in-time restore
- **Retention**: 7 days (default)
- **RPO**: 5-10 minutes
- **Use Case**: Accidental deletion, corruption

### Long-Term Retention (Compliance)
- **Method**: LTR backup policies
- **Retention**: 
  - Weekly: 4 weeks
  - Monthly: 12 months
  - Yearly: 10 years
- **Use Case**: Compliance, legal hold

## Cosmos DB
- **Method**: Continuous backup
- **Retention**: 30 days
- **Granularity**: Point-in-time to the second
- **Use Case**: Any data recovery scenario

## Virtual Machines
- **Method**: Azure Backup (Recovery Services Vault)
- **Schedule**: Daily at 2 AM UTC
- **Retention**: 
  - Daily: 7 days
  - Weekly: 4 weeks
  - Monthly: 12 months
- **Use Case**: Full VM recovery, file-level restore

## Storage Accounts
- **Method**: Soft delete + Versioning + Snapshots
- **Soft Delete Retention**: 14 days
- **Versioning**: Enabled (30 days)
- **Snapshots**: Daily, 7 days retention
- **Use Case**: Accidental deletion, ransomware recovery
```

### Task 4.2: Implement Backup (Hands-On)

```bash
# Create Recovery Services Vault
az backup vault create \
  --name "rsv-northwind-prod-001" \
  --resource-group "rg-northwind-infra" \
  --location "eastus2"

# Configure SQL LTR policy
az sql db ltr-policy set \
  --server "sql-northwind-prod-001" \
  --database "sqldb-ecommerce" \
  --resource-group "rg-northwind-data" \
  --weekly-retention "P4W" \
  --monthly-retention "P12M" \
  --yearly-retention "P10Y" \
  --week-of-year 1
```

---

## 🔧 Exercise 5: DR Testing Strategy

### Task 5.1: Define Test Types

| Test Type | Frequency | Scope | Impact |
|-----------|-----------|-------|--------|
| Tabletop | Monthly | Full DR plan | None |
| Component | Weekly | Individual services | None |
| Failover Drill | Quarterly | Full failover | Brief outage |
| Full DR Test | Annually | Complete recovery | Planned downtime |

### Task 5.2: Create Test Plan

```markdown
# Quarterly DR Failover Drill - Test Plan

## Pre-Test Preparation (1 week before)
- [ ] Schedule maintenance window
- [ ] Notify stakeholders
- [ ] Prepare rollback plan
- [ ] Stage monitoring dashboards

## Test Execution

### Scenario 1: Database Failover
**Objective**: Validate SQL auto-failover group
**Steps**:
1. Initiate manual failover to secondary
2. Verify application connectivity
3. Validate data consistency
4. Initiate failback
5. Verify normal operations

**Success Criteria**:
- Failover completes in < 60 seconds
- Zero data loss
- Application reconnects automatically

### Scenario 2: Regional Failover
**Objective**: Validate complete regional failover
**Steps**:
1. Disable primary region endpoints
2. Verify traffic routes to secondary
3. Validate all application functions
4. Re-enable primary region
5. Verify traffic returns to primary

**Success Criteria**:
- Traffic fails over in < 5 minutes
- All application functions operational
- No data loss or corruption

## Post-Test Activities
- [ ] Document results
- [ ] Identify gaps
- [ ] Update runbooks
- [ ] Schedule remediation
```

---

## 📝 Module Deliverables

1. **Business Impact Analysis**
   - Critical processes identified
   - Cost of downtime calculated
   - Tier assignments

2. **HA Architecture Document**
   - Multi-region design
   - Zone redundancy configuration
   - Load balancing strategy

3. **DR Runbook**
   - Step-by-step procedures
   - Role assignments
   - Communication templates

4. **Backup Strategy Document**
   - Backup schedules
   - Retention policies
   - Recovery procedures

5. **DR Test Plan**
   - Test scenarios
   - Success criteria
   - Schedule

---

## 🧹 Cleanup

```bash
# Delete failover group
az sql failover-group delete \
  --name "fog-northwind-ecommerce" \
  --server "sql-northwind-prod-001" \
  --resource-group "rg-northwind-data"

# Delete Recovery Services Vault
az backup vault delete \
  --name "rsv-northwind-prod-001" \
  --resource-group "rg-northwind-infra" \
  --yes
```

---

## ➡️ Next Steps

👉 [Continue to Module 04: Design Infrastructure Solutions](../04-infrastructure/README.md)

---

## 📚 Additional Resources

- [Azure Business Continuity](https://learn.microsoft.com/en-us/azure/architecture/framework/resiliency/)
- [Azure Backup Documentation](https://learn.microsoft.com/en-us/azure/backup/)
- [Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/)
- [DR for Azure SQL](https://learn.microsoft.com/en-us/azure/azure-sql/database/disaster-recovery-guidance)
