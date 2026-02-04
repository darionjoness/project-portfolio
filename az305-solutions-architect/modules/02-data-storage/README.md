# Module 02: Design Data Storage Solutions

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will be able to:
- Recommend a data storage solution based on requirements
- Design for data redundancy and high availability
- Design data integration solutions
- Recommend a database solution based on requirements
- Design strategies for data protection and encryption

---

## 📖 Scenario

Northwind Traders needs a comprehensive data platform that supports:

1. **E-commerce database**: 10M customers, 50M orders/year, sub-100ms response
2. **Data warehouse**: Historical analytics, 5+ years of data
3. **File storage**: 50TB of product images and documents
4. **Global distribution**: Data accessible from all regions
5. **Compliance**: GDPR data residency, encryption at rest

---

## 💡 Key Concepts

### Storage Decision Tree

```
                    ┌─────────────────┐
                    │ What type of    │
                    │ data?           │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Structured      │ │ Semi-structured │ │ Unstructured    │
│ (Relational)    │ │ (JSON/XML)      │ │ (Files/Blobs)   │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ • Azure SQL     │ │ • Cosmos DB     │ │ • Blob Storage  │
│ • SQL MI        │ │ • Table Storage │ │ • Azure Files   │
│ • PostgreSQL    │ │ • MongoDB       │ │ • Data Lake     │
│ • MySQL         │ │   (Cosmos API)  │ │ • NetApp Files  │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Database Comparison

| Service | Use Case | Scaling | Consistency | Global Dist |
|---------|----------|---------|-------------|-------------|
| Azure SQL | OLTP, ERP | Vertical + Read replicas | Strong | Geo-replication |
| SQL MI | Lift-shift | Vertical + Read replicas | Strong | Failover groups |
| Cosmos DB | Global apps | Horizontal | Tunable | Multi-region writes |
| PostgreSQL | Open source OLTP | Vertical | Strong | Read replicas |
| Synapse | Analytics | Massively parallel | Eventual | N/A |

---

## 🔧 Exercise 1: Analyze Data Requirements

### Task 1.1: Document Data Requirements

```markdown
# Northwind Data Requirements Analysis

## Data Workloads

### 1. E-Commerce Transactional Database
- **Data Type**: Relational (Orders, Customers, Products)
- **Volume**: 10M customers, 50M orders/year
- **Growth**: 20% annually
- **Access Pattern**: OLTP - many small transactions
- **Latency Requirement**: < 100ms read, < 200ms write
- **Availability**: 99.99% (mission critical)
- **Geographic**: Primary US, read from EU/APAC

### 2. Product Catalog
- **Data Type**: Semi-structured (varying attributes per category)
- **Volume**: 1M products
- **Access Pattern**: High read, low write
- **Latency Requirement**: < 50ms (cached)
- **Geographic**: Global reads with local caching

### 3. Analytics Data Warehouse
- **Data Type**: Structured (fact/dimension tables)
- **Volume**: 5 years history, 10TB+
- **Access Pattern**: Complex queries, batch updates
- **Latency Requirement**: < 30 seconds for complex queries
- **Availability**: 99.9%

### 4. Product Images & Documents
- **Data Type**: Unstructured (images, PDFs)
- **Volume**: 50TB current, 10TB/year growth
- **Access Pattern**: High read, sequential write
- **Latency Requirement**: < 500ms (CDN acceptable)
- **Retention**: Active 2 years, archive 7 years

### 5. Customer Analytics
- **Data Type**: Semi-structured (clickstream, behavior)
- **Volume**: 1TB/day ingestion
- **Access Pattern**: Write-heavy, batch read
- **Latency Requirement**: Near real-time ingestion
```

### Task 1.2: Create Data Architecture Diagram

Design a comprehensive data platform:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Northwind Data Platform Architecture                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        DATA SOURCES                                  │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │ E-comm   │  │ Partner  │  │ IoT/     │  │ Social   │            │   │
│  │  │ Website  │  │ APIs     │  │ Sensors  │  │ Media    │            │   │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘            │   │
│  └───────┼─────────────┼─────────────┼─────────────┼────────────────────┘   │
│          │             │             │             │                        │
│          ▼             ▼             ▼             ▼                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     INGESTION LAYER                                  │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │ Event Hubs   │  │ Data Factory │  │ API Mgmt     │              │   │
│  │  │ (Streaming)  │  │ (Batch ETL)  │  │ (REST APIs)  │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│          ┌─────────────────────────┼─────────────────────────┐             │
│          ▼                         ▼                         ▼              │
│  ┌───────────────┐        ┌───────────────┐        ┌───────────────┐       │
│  │ OPERATIONAL   │        │ ANALYTICAL    │        │ UNSTRUCTURED  │       │
│  │ DATA STORE    │        │ DATA STORE    │        │ DATA STORE    │       │
│  │               │        │               │        │               │       │
│  │ ┌───────────┐ │        │ ┌───────────┐ │        │ ┌───────────┐ │       │
│  │ │Azure SQL  │ │        │ │Synapse    │ │        │ │Data Lake  │ │       │
│  │ │(Orders)   │ │───────►│ │Analytics  │ │◄───────│ │Gen2       │ │       │
│  │ └───────────┘ │        │ └───────────┘ │        │ └───────────┘ │       │
│  │ ┌───────────┐ │        │               │        │ ┌───────────┐ │       │
│  │ │Cosmos DB  │ │        │               │        │ │Blob + CDN │ │       │
│  │ │(Catalog)  │ │        │               │        │ │(Images)   │ │       │
│  │ └───────────┘ │        │               │        │ └───────────┘ │       │
│  └───────────────┘        └───────────────┘        └───────────────┘       │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     CONSUMPTION LAYER                                │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │ Power BI     │  │ ML/AI        │  │ Applications │              │   │
│  │  │ (Reporting)  │  │ (Predictions)│  │ (APIs)       │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Exercise 2: Design Relational Database Solution

### Task 2.1: Choose Database Service

**ADR: Azure SQL Database vs SQL Managed Instance**

| Criteria | Azure SQL DB | SQL MI | Decision |
|----------|-------------|--------|----------|
| Feature parity | 95% | 99% | SQL MI ✓ |
| Management overhead | Low | Medium | SQL DB ✓ |
| Pricing model | DTU/vCore | vCore only | SQL DB ✓ |
| Cross-DB queries | No | Yes | SQL MI ✓ |
| SQL Agent | No | Yes | SQL MI ✓ |
| Linked servers | No | Yes | SQL MI ✓ |

**Decision**: Azure SQL Database (Hyperscale tier) for new workloads - Northwind doesn't need legacy SQL Server features.

### Task 2.2: Design Database Architecture

```bash
# Azure SQL Database - Hyperscale Configuration

# Primary Region (East US 2)
# - Hyperscale tier (scalable compute/storage)
# - 8 vCores, Gen5
# - 100GB - 100TB auto-scale storage
# - 4 HA replicas (included)
# - 2 named read replicas

# Secondary Region (West US 2)
# - Geo-replica for disaster recovery
# - Lower tier (can scale up if activated)

# Estimated Cost: ~$1,500/month
```

### Task 2.3: Implement Database (Hands-On)

```bash
# Create SQL Server
az sql server create \
  --name "sql-northwind-prod-001" \
  --resource-group "rg-northwind-data" \
  --location "eastus2" \
  --admin-user "sqladmin" \
  --admin-password "$(openssl rand -base64 24)"

# Create Hyperscale database
az sql db create \
  --name "sqldb-ecommerce" \
  --server "sql-northwind-prod-001" \
  --resource-group "rg-northwind-data" \
  --edition "Hyperscale" \
  --compute-model "Provisioned" \
  --family "Gen5" \
  --capacity 4 \
  --read-replicas 2

# Create geo-replica
az sql db replica create \
  --name "sqldb-ecommerce" \
  --server "sql-northwind-prod-001" \
  --resource-group "rg-northwind-data" \
  --partner-server "sql-northwind-dr-001" \
  --partner-resource-group "rg-northwind-data-dr"
```

---

## 🔧 Exercise 3: Design NoSQL Solution

### Task 3.1: Choose Cosmos DB API and Configuration

**Product Catalog Requirements:**
- Flexible schema (products have different attributes)
- Global reads with low latency
- Occasional writes from admin system

**Design Decision:**

```markdown
# Cosmos DB Configuration for Product Catalog

## API Selection: NoSQL (Core SQL)
- Native Cosmos DB API
- Familiar SQL-like queries
- Best performance and features

## Consistency Level: Session
- Balance between consistency and performance
- Same user sees their own writes
- Eventually consistent across regions

## Partitioning Strategy
Partition Key: /categoryId
- Products grouped by category
- Even distribution (no hot partitions)
- Supports common query patterns

## Regions
- Primary: East US 2 (Write)
- Read Replicas: West US 2, West Europe, Southeast Asia

## Throughput
- Autoscale: 400 - 4000 RU/s
- Estimated monthly: ~$300
```

### Task 3.2: Implement Cosmos DB (Hands-On)

```bash
# Create Cosmos DB account
az cosmosdb create \
  --name "cosmos-northwind-prod" \
  --resource-group "rg-northwind-data" \
  --locations regionName="eastus2" failoverPriority=0 isZoneRedundant=true \
  --locations regionName="westus2" failoverPriority=1 \
  --locations regionName="westeurope" failoverPriority=2 \
  --default-consistency-level "Session" \
  --enable-automatic-failover true

# Create database
az cosmosdb sql database create \
  --account-name "cosmos-northwind-prod" \
  --resource-group "rg-northwind-data" \
  --name "ProductCatalog"

# Create container with partition key
az cosmosdb sql container create \
  --account-name "cosmos-northwind-prod" \
  --resource-group "rg-northwind-data" \
  --database-name "ProductCatalog" \
  --name "Products" \
  --partition-key-path "/categoryId" \
  --throughput 400
```

---

## 🔧 Exercise 4: Design Storage Solution

### Task 4.1: Design Storage Account Architecture

```markdown
# Storage Architecture for Northwind

## Storage Account 1: Product Images (Hot)
- **Name**: stnorthwindimages
- **Performance**: Standard
- **Redundancy**: RA-GRS (read from secondary)
- **Access Tier**: Hot
- **CDN**: Azure CDN (Verizon Premium)
- **Container**: product-images (Blob, anonymous read)

## Storage Account 2: Documents (Hot/Cool)
- **Name**: stnorthwinddocs
- **Performance**: Standard
- **Redundancy**: GRS
- **Access Tier**: Cool (default)
- **Lifecycle Policy**: 
  - Move to Cool after 30 days
  - Move to Archive after 365 days
  - Delete after 2555 days (7 years)

## Storage Account 3: Data Lake (Analytics)
- **Name**: dlsnorthwindanalytics
- **Performance**: Standard
- **Redundancy**: LRS (analytics not mission-critical)
- **Hierarchical Namespace**: Enabled
- **Containers**: 
  - raw (Landing zone)
  - processed (Cleaned data)
  - curated (Analytics-ready)
```

### Task 4.2: Design Lifecycle Management

```json
{
  "rules": [
    {
      "name": "MoveToArchive",
      "enabled": true,
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["documents/"]
        },
        "actions": {
          "baseBlob": {
            "tierToCool": {
              "daysAfterModificationGreaterThan": 30
            },
            "tierToArchive": {
              "daysAfterModificationGreaterThan": 365
            },
            "delete": {
              "daysAfterModificationGreaterThan": 2555
            }
          }
        }
      }
    }
  ]
}
```

---

## 🔧 Exercise 5: Design Data Protection

### Task 5.1: Design Encryption Strategy

| Data State | Method | Key Management |
|------------|--------|----------------|
| At Rest (Storage) | AES-256 | Customer-managed (Key Vault) |
| At Rest (SQL) | TDE | Service-managed |
| At Rest (Cosmos) | AES-256 | Customer-managed (Key Vault) |
| In Transit | TLS 1.2+ | Azure-managed |
| In Use | Always Encrypted | Customer-managed |

### Task 5.2: Design Backup Strategy

| Service | Backup Method | RPO | Retention |
|---------|--------------|-----|-----------|
| Azure SQL | Automated | 5-10 min | 7 days (default), 35 days LTR |
| Cosmos DB | Continuous | Point-in-time | 7 days |
| Storage | Soft delete + Versioning | Instant | 30 days |
| Data Lake | Snapshots | Daily | 7 days |

---

## 📝 Module Deliverables

1. **Data Requirements Document**
   - Workload analysis
   - Volume and growth projections
   - Access patterns

2. **Database Design Document**
   - Service selection rationale
   - Schema design (high-level)
   - Scaling strategy

3. **Storage Architecture Document**
   - Account configuration
   - Lifecycle policies
   - CDN integration

4. **Data Protection Document**
   - Encryption strategy
   - Backup/restore procedures
   - Compliance mapping

---

## 🧹 Cleanup

```bash
# Delete Cosmos DB
az cosmosdb delete \
  --name "cosmos-northwind-prod" \
  --resource-group "rg-northwind-data" \
  --yes

# Delete SQL Server (deletes databases too)
az sql server delete \
  --name "sql-northwind-prod-001" \
  --resource-group "rg-northwind-data" \
  --yes

# Delete storage accounts
az storage account delete \
  --name "stnorthwindimages" \
  --resource-group "rg-northwind-data" \
  --yes
```

---

## ➡️ Next Steps

👉 [Continue to Module 03: Design Business Continuity](../03-business-continuity/README.md)

---

## 📚 Additional Resources

- [Azure Storage Documentation](https://learn.microsoft.com/en-us/azure/storage/)
- [Azure SQL Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/)
- [Cosmos DB Documentation](https://learn.microsoft.com/en-us/azure/cosmos-db/)
- [Data Architecture Guide](https://learn.microsoft.com/en-us/azure/architecture/data-guide/)
