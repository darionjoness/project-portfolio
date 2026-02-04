# AZ-305 Troubleshooting Guide

## Common Issues and Solutions

### Architecture Diagramming

#### Issue: Can't decide between services
**Problem**: Unsure whether to use Service A or Service B

**Solution**: Create a decision matrix:
```markdown
| Criteria | Weight | Service A | Service B |
|----------|--------|-----------|-----------|
| Cost | 20% | 3 | 4 |
| Performance | 25% | 4 | 3 |
| Scalability | 25% | 5 | 4 |
| Complexity | 15% | 3 | 4 |
| Compliance | 15% | 4 | 4 |
| **Total** | 100% | **3.9** | **3.75** |
```

#### Issue: Architecture diagrams are messy
**Problem**: Diagrams become cluttered and hard to understand

**Solution**: Use layered views:
1. **L1 - Context**: System and external actors only
2. **L2 - Container**: Major components (apps, databases)
3. **L3 - Component**: Internal service structure
4. **L4 - Code**: Class/sequence diagrams (when needed)

---

### Identity and Access

#### Issue: Can't determine right authentication method
**Problem**: OIDC vs OAuth vs SAML confusion

**Solution**: Quick reference:
| Scenario | Protocol | Why |
|----------|----------|-----|
| User login to web app | OIDC | Get user identity + tokens |
| API authorization | OAuth 2.0 | Token-based API access |
| Enterprise federation | SAML | Legacy SSO integration |
| Mobile app | OIDC + PKCE | Secure public client auth |

#### Issue: Conditional Access policy conflicts
**Problem**: Policies blocking legitimate access

**Solution**:
1. Check policy order (most restrictive first)
2. Use "What If" tool in Entra ID
3. Exclude break-glass accounts
4. Test in "Report Only" mode first

---

### Data Architecture

#### Issue: Can't decide between SQL and NoSQL
**Solution**: Use this decision tree:

```
Need ACID transactions across entities?
├── Yes → Relational (Azure SQL, PostgreSQL)
└── No → 
    Need flexible schema?
    ├── Yes → Document (Cosmos DB NoSQL)
    └── No →
        Read-heavy with simple queries?
        ├── Yes → Key-Value (Cosmos DB Table, Redis)
        └── No → Relational
```

#### Issue: Cosmos DB partition key selection
**Problem**: Poor performance due to hot partitions

**Solution**: Good partition key characteristics:
- ✅ High cardinality (many distinct values)
- ✅ Even distribution of data
- ✅ Frequently used in WHERE clauses
- ❌ Avoid low cardinality (status, type)
- ❌ Avoid time-based unless with tenant

Example:
```
Good: /tenantId (multi-tenant app)
Good: /userId (user-specific data)
Bad: /status (only a few values)
Bad: /createdDate (time-series pattern)
```

---

### Networking

#### Issue: Hub-spoke design decisions
**Problem**: Not sure what goes in hub vs spoke

**Solution**:
| Hub (Shared Services) | Spoke (Workloads) |
|-----------------------|-------------------|
| Azure Firewall | Application VMs/containers |
| Bastion | Databases |
| VPN/ExpressRoute Gateway | App Services |
| DNS servers | Storage accounts |
| Domain controllers | AKS clusters |

#### Issue: Private Endpoint IP exhaustion
**Problem**: Running out of IPs in subnet

**Solution**:
1. Each Private Endpoint needs 1 IP
2. Plan subnet size: /27 (32 IPs) or /26 (64 IPs)
3. Use dedicated subnet for Private Endpoints
4. Consider Private Link Service for consolidation

---

### High Availability

#### Issue: Calculating composite SLA
**Problem**: Multiple services, what's the combined SLA?

**Solution**: 
- **Series (all must work)**: Multiply SLAs
  - Web App (99.95%) × SQL (99.99%) = 99.94%
- **Parallel (either works)**: 1 - ((1-SLA₁) × (1-SLA₂))
  - Two regions (99.95% each) = 99.999975%

Calculator:
```
Composite SLA = SLA₁ × SLA₂ × SLA₃ × ...

Example: Web tier
- Front Door: 99.99%
- App Service: 99.95%
- SQL DB: 99.99%
Composite: 0.9999 × 0.9995 × 0.9999 = 99.93%
```

#### Issue: RPO/RTO confusion
**Solution**:
- **RPO (Recovery Point Objective)**: How much data can you lose?
  - 15 min RPO = backups every 15 min
- **RTO (Recovery Time Objective)**: How long until recovered?
  - 1 hour RTO = must be back online in 1 hour

---

### Migrations

#### Issue: Dependency discovery
**Problem**: Don't know all app dependencies

**Solution**:
1. Run Azure Migrate for 30+ days
2. Use network flow logs
3. Interview application teams
4. Check IIS/Apache logs for external calls
5. Review connection strings in config files

#### Issue: Database migration sizing
**Problem**: Target size/tier unclear

**Solution**:
1. Capture current metrics (CPU, IOPS, memory)
2. Use Azure Database Migration Service assessment
3. Start one tier higher than calculated
4. Right-size after 2 weeks of production data

---

### Cost Optimization

#### Issue: Cost estimates vary widely
**Problem**: Azure Pricing Calculator gives different numbers

**Solution**: Check these often-missed items:
- [ ] Data egress (bandwidth out)
- [ ] Inter-region traffic
- [ ] Premium storage IOPS
- [ ] Log Analytics ingestion
- [ ] Backup storage
- [ ] Reserved vs pay-as-you-go
- [ ] Dev/test vs production pricing

#### Issue: Unexpected costs
**Common culprits**:
1. **Log Analytics**: High ingestion volume
2. **Bandwidth**: Cross-region data transfer
3. **Storage**: Snapshots accumulating
4. **Premium features**: Accidentally enabled
5. **Orphaned resources**: NICs, disks, IPs

---

### Exam Preparation

#### Issue: Design questions are vague
**Problem**: Exam questions lack specific requirements

**Solution**: Make reasonable assumptions:
- Assume "enterprise" means high availability
- Assume security is always important
- Assume cost optimization matters
- When in doubt, choose the most scalable option

#### Issue: Multiple "correct" answers
**Problem**: Several options seem valid

**Solution**: Look for key differentiators:
- Which option is most **complete**?
- Which option addresses **all** requirements?
- Which follows **Azure best practices**?
- Which aligns with **Well-Architected Framework**?

---

### Tools and Resources

#### Architecture Diagramming
- [Draw.io](https://app.diagrams.net/) - Free, Azure icons included
- [Lucidchart](https://www.lucidchart.com/) - Professional, templates
- [Azure Diagrams](https://azurediagrams.com/) - Azure-specific

#### Reference Architectures
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)

#### Sizing and Pricing
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [TCO Calculator](https://azure.microsoft.com/pricing/tco/calculator/)
- [Azure Advisor](https://portal.azure.com/#blade/Microsoft_Azure_Expert/AdvisorMenuBlade)

---

## Getting Help

1. **Microsoft Learn**: Official training paths
2. **Azure Architecture Center**: Reference designs
3. **Well-Architected Review**: Assessment tool
4. **Azure Support**: For production issues
5. **Stack Overflow**: Community help (azure tag)

---

Remember: AZ-305 tests **design thinking**, not implementation. Focus on understanding **why** you choose certain services, not just **how** to configure them.
