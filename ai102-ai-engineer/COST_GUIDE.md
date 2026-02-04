# AI-102 Cost Guide

## Overview

The AI-102 project uses Azure AI services which have generous free tiers. With careful usage, you can complete most of the project at minimal or no cost.

---

## Free Tier Summary

| Service | Free Tier | Notes |
|---------|-----------|-------|
| **Azure AI Services (Multi)** | 5,000 transactions/month | Most analysis tasks |
| **Computer Vision** | 5,000 transactions/month | Image analysis, OCR |
| **Language Service** | 5,000 text records/month | Sentiment, entities, QnA |
| **Document Intelligence** | 500 pages/month | Form processing |
| **Speech Services** | 5 hours STT, 0.5M chars TTS | Speech recognition/synthesis |
| **Custom Vision** | 2 projects, 1 hour training | Image classification |
| **Azure AI Search** | 50 MB storage, 3 indexes | Basic search |
| **Azure OpenAI** | Requires approval | Pay-as-you-go |

---

## Module-by-Module Costs

### Module 01: AI Foundations
**Estimated Cost: $0**
- Multi-service resource (F0 tier)
- Basic SDK calls within free tier

### Module 02: Document Intelligence
**Estimated Cost: $0-5**
- 500 free pages/month
- Use sample documents
- Clean up quickly

### Module 03: Language Analytics
**Estimated Cost: $0**
- 5,000 free text records/month
- Plenty for all exercises

### Module 04: Azure OpenAI
**Estimated Cost: $5-20**
- Requires paid usage
- GPT-4: ~$0.03-0.06 per 1K tokens
- Embeddings: ~$0.0001 per 1K tokens
- Use sparingly

### Module 05: Computer Vision
**Estimated Cost: $0**
- 5,000 free transactions/month
- Custom Vision: 2 free projects

### Module 06: Speech Services
**Estimated Cost: $0**
- 5 hours free STT/month
- 500K characters free TTS/month

### Module 07: Conversational AI
**Estimated Cost: $0**
- QnA included in Language Service
- Bot Framework is free
- Only pay for hosting

### Module 08: AI Search
**Estimated Cost: $0-5**
- Free tier: 50MB, 3 indexes
- Upgrade if needed for vectors

### Module 09: Capstone
**Estimated Cost: $10-30**
- Combines multiple services
- Most expensive module
- Clean up after completion

---

## Cost Optimization Strategies

### 1. Use Free Tiers
Always start with F0 (free) SKU:

```bash
# Create free tier resources
az cognitiveservices account create \
  --sku F0 \
  ...
```

### 2. Reuse Resources
Create a single multi-service resource:

```bash
# One resource for multiple services
az cognitiveservices account create \
  --kind CognitiveServices \
  --sku S0 \
  ...
```

### 3. Clean Up Immediately
Delete resources after each session:

```bash
# Delete resource group
az group delete --name rg-ai102-learning --yes --no-wait
```

### 4. Set Budget Alerts

```bash
# Create budget with alerts
az consumption budget create \
  --budget-name ai102-budget \
  --amount 25 \
  --time-grain monthly
```

### 5. Monitor Usage

```bash
# Check costs
az consumption usage list \
  --start-date 2024-01-01 \
  --end-date 2024-01-31
```

---

## Azure OpenAI Costs

Azure OpenAI is the main cost driver. Typical costs:

| Model | Input (1K tokens) | Output (1K tokens) |
|-------|------------------|-------------------|
| GPT-4 | $0.03 | $0.06 |
| GPT-4-32K | $0.06 | $0.12 |
| GPT-3.5-Turbo | $0.0015 | $0.002 |
| text-embedding-ada-002 | $0.0001 | N/A |

### Cost Reduction Tips:
1. Use GPT-3.5-Turbo for testing
2. Keep prompts concise
3. Limit max_tokens
4. Cache responses when possible
5. Use embeddings sparingly

---

## Resource Cleanup Commands

```bash
# List all AI resources
az cognitiveservices account list --query "[].name" -o tsv

# Delete specific resource
az cognitiveservices account delete \
  --name <resource-name> \
  --resource-group rg-ai102-learning

# Nuclear option: Delete entire resource group
az group delete --name rg-ai102-learning --yes --no-wait
```

---

## Monitoring Spend

### Azure Portal
1. Go to **Cost Management + Billing**
2. Select **Cost analysis**
3. Filter by resource group

### CLI
```bash
# Current costs
az consumption usage list --output table

# Forecast
az consumption forecast list
```

---

## Estimated Total Cost

| Completion Path | Cost |
|-----------------|------|
| Minimal (free tiers only) | $0 |
| Typical (some Azure OpenAI) | $15-30 |
| Full exercises + Capstone | $30-50 |

---

## Free Credits

### New Azure Account
- $200 credit for 30 days

### Visual Studio Subscription
- $50-150 monthly credit

### Azure for Students
- $100 credit

### GitHub Student Pack
- Azure credits included

---

**Remember: Always clean up resources after each session to avoid unexpected charges!** 💰
