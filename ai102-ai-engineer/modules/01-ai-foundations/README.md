# Module 01: Azure AI Foundations

![Difficulty: Beginner](https://img.shields.io/badge/Difficulty-Beginner-green)
![Time: 3-4 hours](https://img.shields.io/badge/Time-3--4%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will:
- Understand Azure AI service offerings and pricing tiers
- Provision single-service and multi-service resources
- Implement secure authentication patterns
- Use SDKs and REST APIs to call AI services
- Configure monitoring and logging

---

## 📖 Understanding Azure AI Services

### The Azure AI Landscape

Azure AI Services (formerly Cognitive Services) provides pre-built AI capabilities across these domains:

```
┌─────────────────────────────────────────────────────────────────┐
│                      Azure AI Services                          │
├────────────────┬────────────────┬────────────────┬─────────────┤
│     Vision     │    Language    │     Speech     │   Decision  │
├────────────────┼────────────────┼────────────────┼─────────────┤
│ Computer Vision│ Language       │ Speech-to-Text │ Content     │
│ Custom Vision  │ Translator     │ Text-to-Speech │ Safety      │
│ Face           │ Azure OpenAI   │ Translation    │ Personalizer│
│ Document Intel │ QnA            │ Speaker Recog  │             │
└────────────────┴────────────────┴────────────────┴─────────────┘
```

### Deployment Options

| Option | Best For | Pros | Cons |
|--------|----------|------|------|
| **Multi-service** | Experimentation, small projects | Single endpoint, simpler billing | Can't mix regions |
| **Single-service** | Production, specific needs | Independent scaling, region flexibility | More management |
| **Containers** | On-premises, air-gapped | Data stays local | Self-managed infrastructure |

---

## 🔧 Exercise 1: Provision Azure AI Resources

### Task 1.1: Create a Multi-Service Resource

```bash
# Create resource group for AI-102 learning
az group create \
  --name rg-ai102-learning \
  --location eastus

# Create multi-service Azure AI resource
az cognitiveservices account create \
  --name ai-intellihealth-multi \
  --resource-group rg-ai102-learning \
  --kind CognitiveServices \
  --sku S0 \
  --location eastus \
  --yes

# Get the endpoint
az cognitiveservices account show \
  --name ai-intellihealth-multi \
  --resource-group rg-ai102-learning \
  --query "properties.endpoint" -o tsv

# Get the keys
az cognitiveservices account keys list \
  --name ai-intellihealth-multi \
  --resource-group rg-ai102-learning \
  --query "key1" -o tsv
```

### Task 1.2: Create Single-Service Resources

```bash
# Create a Computer Vision resource
az cognitiveservices account create \
  --name ai-intellihealth-vision \
  --resource-group rg-ai102-learning \
  --kind ComputerVision \
  --sku F0 \
  --location eastus \
  --yes

# Create a Language resource
az cognitiveservices account create \
  --name ai-intellihealth-language \
  --resource-group rg-ai102-learning \
  --kind TextAnalytics \
  --sku F0 \
  --location eastus \
  --yes

# Create a Speech resource
az cognitiveservices account create \
  --name ai-intellihealth-speech \
  --resource-group rg-ai102-learning \
  --kind SpeechServices \
  --sku F0 \
  --location eastus \
  --yes
```

### Task 1.3: Explore Available Services

```bash
# List all cognitive service kinds available
az cognitiveservices account list-kinds -o table

# Common kinds for AI-102:
# - CognitiveServices (multi-service)
# - ComputerVision
# - CustomVision.Training
# - CustomVision.Prediction
# - TextAnalytics (Language)
# - SpeechServices
# - FormRecognizer (Document Intelligence)
# - OpenAI
```

---

## 🔧 Exercise 2: Secure Authentication

### Understanding Authentication Options

```
┌───────────────────────────────────────────────────────────────┐
│                  Authentication Methods                        │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Subscription Keys (API Keys)                              │
│     └── Simple, but less secure for production                │
│                                                               │
│  2. Azure Active Directory (Entra ID)                         │
│     └── OAuth tokens, RBAC, managed identity                  │
│                                                               │
│  3. Azure Key Vault                                           │
│     └── Secure key storage, rotation, audit                   │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Task 2.1: Create Key Vault for Secure Key Storage

```bash
# Create Key Vault
az keyvault create \
  --name kv-intellihealth-ai \
  --resource-group rg-ai102-learning \
  --location eastus \
  --sku standard

# Store the AI Services key in Key Vault
AI_KEY=$(az cognitiveservices account keys list \
  --name ai-intellihealth-multi \
  --resource-group rg-ai102-learning \
  --query "key1" -o tsv)

az keyvault secret set \
  --vault-name kv-intellihealth-ai \
  --name "AzureAIKey" \
  --value "$AI_KEY"

# Retrieve the key from Key Vault
az keyvault secret show \
  --vault-name kv-intellihealth-ai \
  --name "AzureAIKey" \
  --query "value" -o tsv
```

### Task 2.2: Configure Managed Identity (For Production)

```python
# Using Managed Identity with Azure AI Services
from azure.identity import DefaultAzureCredential
from azure.ai.textanalytics import TextAnalyticsClient

# DefaultAzureCredential tries multiple auth methods:
# 1. Environment variables
# 2. Managed Identity
# 3. Azure CLI
# 4. Interactive browser

credential = DefaultAzureCredential()

client = TextAnalyticsClient(
    endpoint="https://ai-intellihealth-multi.cognitiveservices.azure.com/",
    credential=credential
)

# No API keys in code!
```

### Task 2.3: Enable Diagnostic Logging

```bash
# Get the AI Services resource ID
RESOURCE_ID=$(az cognitiveservices account show \
  --name ai-intellihealth-multi \
  --resource-group rg-ai102-learning \
  --query "id" -o tsv)

# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --workspace-name law-intellihealth \
  --resource-group rg-ai102-learning \
  --location eastus

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --workspace-name law-intellihealth \
  --resource-group rg-ai102-learning \
  --query "id" -o tsv)

# Enable diagnostic logging
az monitor diagnostic-settings create \
  --name ai-diagnostics \
  --resource $RESOURCE_ID \
  --workspace $WORKSPACE_ID \
  --logs '[{"categoryGroup":"allLogs","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'
```

---

## 🔧 Exercise 3: Working with SDKs

### Task 3.1: Set Up Python Environment

```bash
# Create virtual environment
python -m venv ai102-env

# Activate (Windows)
.\ai102-env\Scripts\Activate.ps1

# Activate (Linux/Mac)
source ai102-env/bin/activate

# Install Azure AI SDKs
pip install azure-ai-textanalytics
pip install azure-ai-vision-imageanalysis
pip install azure-cognitiveservices-speech
pip install azure-ai-formrecognizer
pip install azure-identity
pip install python-dotenv
```

### Task 3.2: Create a Configuration File

```python
# config.py
import os
from dotenv import load_dotenv

load_dotenv()

class AzureAIConfig:
    """Configuration for Azure AI Services"""
    
    # Multi-service endpoint
    ENDPOINT = os.getenv("AZURE_AI_ENDPOINT")
    KEY = os.getenv("AZURE_AI_KEY")
    
    # Individual service endpoints (if using single-service resources)
    VISION_ENDPOINT = os.getenv("AZURE_VISION_ENDPOINT", ENDPOINT)
    LANGUAGE_ENDPOINT = os.getenv("AZURE_LANGUAGE_ENDPOINT", ENDPOINT)
    SPEECH_ENDPOINT = os.getenv("AZURE_SPEECH_ENDPOINT", ENDPOINT)
    
    # Speech requires region instead of full endpoint
    SPEECH_REGION = os.getenv("AZURE_SPEECH_REGION", "eastus")
```

### Task 3.3: Test Language Service Connection

```python
# test_language_connection.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
from config import AzureAIConfig

def test_language_connection():
    """Test connection to Azure AI Language service"""
    
    # Create client
    client = TextAnalyticsClient(
        endpoint=AzureAIConfig.ENDPOINT,
        credential=AzureKeyCredential(AzureAIConfig.KEY)
    )
    
    # Test with simple sentiment analysis
    documents = [
        "IntelliHealth's AI platform is amazing! It has transformed our workflow.",
        "The documentation could be better, but overall a good experience.",
        "Terrible service. Nothing works as expected."
    ]
    
    # Call the API
    response = client.analyze_sentiment(documents)
    
    # Print results
    for idx, doc in enumerate(response):
        if not doc.is_error:
            print(f"\nDocument {idx + 1}:")
            print(f"  Text: {documents[idx][:50]}...")
            print(f"  Sentiment: {doc.sentiment}")
            print(f"  Confidence: Pos={doc.confidence_scores.positive:.2f}, "
                  f"Neu={doc.confidence_scores.neutral:.2f}, "
                  f"Neg={doc.confidence_scores.negative:.2f}")
        else:
            print(f"Document {idx + 1} error: {doc.error}")

if __name__ == "__main__":
    test_language_connection()
```

### Expected Output:
```
Document 1:
  Text: IntelliHealth's AI platform is amazing! It has t...
  Sentiment: positive
  Confidence: Pos=0.98, Neu=0.01, Neg=0.01

Document 2:
  Text: The documentation could be better, but overall a...
  Sentiment: mixed
  Confidence: Pos=0.45, Neu=0.30, Neg=0.25

Document 3:
  Text: Terrible service. Nothing works as expected....
  Sentiment: negative
  Confidence: Pos=0.01, Neu=0.02, Neg=0.97
```

---

## 🔧 Exercise 4: Working with REST APIs

### Task 4.1: Direct REST API Calls

```python
# rest_api_example.py
import requests
import json
from config import AzureAIConfig

def analyze_sentiment_rest(text: str) -> dict:
    """Call Language service using REST API directly"""
    
    # Construct the endpoint URL
    url = f"{AzureAIConfig.ENDPOINT}/language/:analyze-text?api-version=2023-04-01"
    
    # Prepare headers
    headers = {
        "Ocp-Apim-Subscription-Key": AzureAIConfig.KEY,
        "Content-Type": "application/json"
    }
    
    # Prepare request body
    body = {
        "kind": "SentimentAnalysis",
        "parameters": {
            "modelVersion": "latest"
        },
        "analysisInput": {
            "documents": [
                {
                    "id": "1",
                    "language": "en",
                    "text": text
                }
            ]
        }
    }
    
    # Make the request
    response = requests.post(url, headers=headers, json=body)
    response.raise_for_status()
    
    return response.json()

# Test
if __name__ == "__main__":
    result = analyze_sentiment_rest("I love using Azure AI Services!")
    print(json.dumps(result, indent=2))
```

### Task 4.2: Handle Errors Gracefully

```python
# error_handling.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
from azure.core.exceptions import (
    HttpResponseError,
    ClientAuthenticationError,
    ResourceNotFoundError
)
from config import AzureAIConfig

def analyze_with_error_handling(documents: list) -> list:
    """Demonstrate proper error handling for AI Services"""
    
    try:
        client = TextAnalyticsClient(
            endpoint=AzureAIConfig.ENDPOINT,
            credential=AzureKeyCredential(AzureAIConfig.KEY)
        )
        
        response = client.analyze_sentiment(documents)
        
        results = []
        for doc in response:
            if doc.is_error:
                results.append({
                    "error": True,
                    "code": doc.error.code,
                    "message": doc.error.message
                })
            else:
                results.append({
                    "error": False,
                    "sentiment": doc.sentiment,
                    "scores": {
                        "positive": doc.confidence_scores.positive,
                        "neutral": doc.confidence_scores.neutral,
                        "negative": doc.confidence_scores.negative
                    }
                })
        
        return results
        
    except ClientAuthenticationError:
        print("ERROR: Invalid API key or endpoint")
        raise
    except ResourceNotFoundError:
        print("ERROR: Resource not found. Check your endpoint URL")
        raise
    except HttpResponseError as e:
        print(f"ERROR: HTTP error - {e.status_code}: {e.message}")
        raise
    except Exception as e:
        print(f"ERROR: Unexpected error - {type(e).__name__}: {e}")
        raise

# Test with various scenarios
if __name__ == "__main__":
    # Normal documents
    docs = ["This is great!", "This is terrible."]
    print("Results:", analyze_with_error_handling(docs))
```

---

## 🔧 Exercise 5: Rate Limits and Best Practices

### Understanding Rate Limits

| Tier | Transactions/Second | Notes |
|------|---------------------|-------|
| F0 (Free) | 20 TPS | Limited features |
| S0 (Standard) | 1000 TPS | Full features |
| S1 (Higher) | Custom | Enterprise needs |

### Task 5.1: Implement Retry Logic

```python
# retry_logic.py
import time
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
from azure.core.exceptions import HttpResponseError

def analyze_with_retry(client, documents, max_retries=3):
    """Call API with exponential backoff retry"""
    
    for attempt in range(max_retries):
        try:
            response = client.analyze_sentiment(documents)
            return response
            
        except HttpResponseError as e:
            if e.status_code == 429:  # Rate limited
                wait_time = 2 ** attempt  # Exponential backoff
                print(f"Rate limited. Waiting {wait_time} seconds...")
                time.sleep(wait_time)
            elif e.status_code >= 500:  # Server error
                wait_time = 2 ** attempt
                print(f"Server error. Waiting {wait_time} seconds...")
                time.sleep(wait_time)
            else:
                raise  # Don't retry client errors
    
    raise Exception(f"Failed after {max_retries} retries")
```

### Task 5.2: Batch Processing

```python
# batch_processing.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential

def process_large_dataset(client, documents, batch_size=10):
    """Process documents in batches (API limit is usually 10-25 docs)"""
    
    all_results = []
    
    for i in range(0, len(documents), batch_size):
        batch = documents[i:i + batch_size]
        print(f"Processing batch {i // batch_size + 1}...")
        
        response = client.analyze_sentiment(batch)
        all_results.extend(response)
        
        # Small delay to avoid rate limiting
        time.sleep(0.1)
    
    return all_results
```

---

## 🧹 Cleanup

```bash
# Option 1: Delete individual resources
az cognitiveservices account delete \
  --name ai-intellihealth-multi \
  --resource-group rg-ai102-learning

# Option 2: Delete entire resource group
az group delete \
  --name rg-ai102-learning \
  --yes --no-wait
```

---

## ✅ Module Checklist

Before moving on, ensure you can:

- [ ] Explain the difference between multi-service and single-service resources
- [ ] Provision Azure AI Services using CLI and Portal
- [ ] Store and retrieve API keys securely using Key Vault
- [ ] Configure managed identity for production scenarios
- [ ] Use Python SDKs to call Azure AI services
- [ ] Make direct REST API calls
- [ ] Handle errors and implement retry logic
- [ ] Enable diagnostic logging

---

## 📚 Additional Resources

- [Azure AI Services Overview](https://learn.microsoft.com/en-us/azure/ai-services/what-are-ai-services)
- [Authentication Best Practices](https://learn.microsoft.com/en-us/azure/ai-services/authentication)
- [Azure AI Services SDKs](https://learn.microsoft.com/en-us/azure/ai-services/reference/sdk-package-resources)
- [Pricing Information](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/)

---

**Next Module:** [Module 02: Document Intelligence](../02-document-intelligence/README.md)
