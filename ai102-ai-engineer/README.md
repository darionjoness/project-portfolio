# AI-102: Azure AI Engineer Portfolio Project

![Azure AI](https://img.shields.io/badge/Azure-AI%20Services-blue)
![Certification](https://img.shields.io/badge/Certification-AI--102-green)
![Level](https://img.shields.io/badge/Level-Associate-yellow)

## 🎯 Project Overview

Welcome to the **AI-102 Azure AI Engineer Portfolio Project**! This project provides hands-on experience with Azure AI services through a practical, real-world scenario.

### Who Is This For?
- Recently passed AI-102 and want practical experience
- Preparing for AI-102 and want hands-on labs
- Building an AI/ML portfolio for career advancement
- Learning to integrate AI services into applications

---

## 📖 The Scenario

### IntelliHealth Medical Solutions

You've been hired as an **AI Engineer** at IntelliHealth, a healthcare technology startup. Your mission is to build AI-powered solutions that improve patient care and operational efficiency.

**Company Context:**
- 50 healthcare provider clients
- Processing 10,000+ documents daily
- Multilingual patient base (English, Spanish, Chinese)
- Strict HIPAA compliance requirements
- Goal: 90% automation of document processing

### Your AI Platform Roadmap

| Quarter | Focus | AI Services |
|---------|-------|-------------|
| Q1 | Document Intelligence | Form Recognizer, Custom Models |
| Q2 | Language Understanding | Azure OpenAI, Language Service |
| Q3 | Vision Services | Custom Vision, Computer Vision |
| Q4 | Conversational AI | Azure Bot Service, Speech |

---

## 🗂️ Module Structure

### Module 01: Azure AI Foundations
**Time: 3-4 hours**
- Provision Azure AI Services
- Understand cognitive domains
- Implement authentication patterns
- Work with SDKs and REST APIs

### Module 02: Document Intelligence
**Time: 4-5 hours**
- Azure AI Document Intelligence (Form Recognizer)
- Prebuilt models (invoices, receipts, ID documents)
- Custom extraction models
- Layout and table extraction

### Module 03: Language & Text Analytics
**Time: 4-5 hours**
- Azure AI Language Service
- Sentiment analysis and opinion mining
- Entity recognition and linking
- Custom text classification

### Module 04: Azure OpenAI Service
**Time: 5-6 hours**
- GPT model deployment and management
- Prompt engineering techniques
- RAG (Retrieval Augmented Generation)
- Responsible AI practices

### Module 05: Computer Vision
**Time: 4-5 hours**
- Azure AI Vision
- Image analysis and tagging
- OCR and spatial analysis
- Custom Vision for classification/detection

### Module 06: Speech Services
**Time: 3-4 hours**
- Speech-to-Text and Text-to-Speech
- Real-time transcription
- Speech translation
- Custom voice and pronunciation

### Module 07: Conversational AI
**Time: 4-5 hours**
- Azure Bot Service
- Question Answering (formerly QnA Maker)
- Bot Framework SDK
- Multi-turn conversations

### Module 08: AI Search & RAG
**Time: 4-5 hours**
- Azure AI Search
- Indexers and skillsets
- Semantic search
- Vector search and embeddings

### Module 09: Capstone Project
**Time: 8-10 hours**
- End-to-end AI solution
- Multiple AI services integration
- Production deployment patterns
- Responsible AI implementation

---

## 🛠️ Prerequisites

### Azure Resources
- Azure subscription (free tier works for most exercises)
- Azure AI Services resource
- Storage account for documents

### Development Environment
- VS Code with Python extension
- Python 3.9+
- Azure CLI
- Git

### Knowledge Requirements
- Basic Python programming
- REST API concepts
- JSON data format
- Azure fundamentals (helpful)

---

## 🚀 Getting Started

### Step 1: Set Up Azure AI Services

```bash
# Create resource group
az group create --name rg-ai102-learning --location eastus

# Create multi-service Azure AI resource
az cognitiveservices account create \
  --name ai-intellihealth \
  --resource-group rg-ai102-learning \
  --kind CognitiveServices \
  --sku S0 \
  --location eastus \
  --yes
```

### Step 2: Get Your Keys

```bash
# Get endpoint
az cognitiveservices account show \
  --name ai-intellihealth \
  --resource-group rg-ai102-learning \
  --query "properties.endpoint"

# Get keys
az cognitiveservices account keys list \
  --name ai-intellihealth \
  --resource-group rg-ai102-learning
```

### Step 3: Set Environment Variables

```bash
# Windows PowerShell
$env:AZURE_AI_ENDPOINT = "https://your-resource.cognitiveservices.azure.com/"
$env:AZURE_AI_KEY = "your-key-here"

# Linux/Mac
export AZURE_AI_ENDPOINT="https://your-resource.cognitiveservices.azure.com/"
export AZURE_AI_KEY="your-key-here"
```

### Step 4: Start Learning!

Begin with [Module 01: Azure AI Foundations](./modules/01-ai-foundations/README.md)

---

## 💰 Cost Management

Most exercises use free tier or minimal resources:

| Service | Free Tier | Notes |
|---------|-----------|-------|
| Azure AI Services | 5K transactions/month | Most exercises |
| Document Intelligence | 500 pages/month | Prebuilt models |
| Azure OpenAI | $0 | Requires approval |
| Computer Vision | 5K transactions/month | Standard analysis |
| Speech | 5 hours/month | Speech-to-text |
| Language | 5K text records/month | Text analytics |

**Estimated Total: $0-$20 for complete project**

⚠️ **Clean up after each module!** See [COST_GUIDE.md](./COST_GUIDE.md)

---

## 📊 Skills Checklist

### By the End of This Project, You Will:

**Provision & Configure**
- [ ] Deploy Azure AI Services (multi-service and single-service)
- [ ] Implement secure key management with Key Vault
- [ ] Configure private endpoints and network security
- [ ] Set up monitoring and diagnostics

**Document Intelligence**
- [ ] Extract data from invoices, receipts, and IDs
- [ ] Build custom extraction models
- [ ] Process tables and complex layouts
- [ ] Handle handwritten text

**Language Services**
- [ ] Analyze sentiment and extract key phrases
- [ ] Recognize and classify entities
- [ ] Build custom text classifiers
- [ ] Implement language detection and translation

**Azure OpenAI**
- [ ] Deploy and manage GPT models
- [ ] Engineer effective prompts
- [ ] Implement RAG patterns
- [ ] Apply responsible AI guardrails

**Computer Vision**
- [ ] Analyze images for objects and scenes
- [ ] Extract text from images (OCR)
- [ ] Train custom image classifiers
- [ ] Detect custom objects

**Speech Services**
- [ ] Convert speech to text and text to speech
- [ ] Implement real-time transcription
- [ ] Translate speech between languages
- [ ] Create custom pronunciations

**Conversational AI**
- [ ] Build knowledge base for Q&A
- [ ] Create multi-turn bot dialogs
- [ ] Deploy bots to multiple channels
- [ ] Integrate with other AI services

---

## 📚 Exam Alignment

This project covers all AI-102 exam objectives:

| Domain | Weight | Modules |
|--------|--------|---------|
| Plan and manage Azure AI solutions | 15-20% | 1, 9 |
| Implement decision support solutions | 10-15% | 4, 8 |
| Implement computer vision solutions | 15-20% | 5 |
| Implement NLP solutions | 25-30% | 3, 4, 6, 7 |
| Implement knowledge mining solutions | 15-20% | 8 |
| Implement conversational AI solutions | 15-20% | 7 |

---

## 🤝 Contributing

Found an issue or want to add content?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📖 Additional Resources

- [AI-102 Exam Page](https://learn.microsoft.com/en-us/credentials/certifications/exams/ai-102/)
- [Azure AI Services Documentation](https://learn.microsoft.com/en-us/azure/ai-services/)
- [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Azure AI Samples](https://github.com/Azure-Samples/cognitive-services-quickstart-code)

---

**Ready to build intelligent applications?** Start with [Module 01: Azure AI Foundations](./modules/01-ai-foundations/README.md)! 🚀
