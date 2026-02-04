# AI-102 Troubleshooting Guide

## Common Issues and Solutions

### Authentication Errors

#### Issue: "InvalidAuthenticationTokenTenant"
```
InvalidAuthenticationTokenTenant: The access token is from the wrong issuer
```

**Solution:**
1. Ensure you're logged into the correct Azure tenant
2. Re-authenticate: `az login --tenant <tenant-id>`
3. Clear cached tokens: `az account clear`

#### Issue: "AuthenticationFailed"
**Solution:**
```bash
# Verify your credentials
az account show

# Re-login if needed
az login

# Set correct subscription
az account set --subscription <subscription-id>
```

---

### Resource Provisioning

#### Issue: "QuotaExceeded"
**Solution:**
- Free tier limits reached
- Upgrade to paid tier or delete unused resources
- Request quota increase in Azure Portal

#### Issue: "ResourceNotFound"
**Solution:**
```bash
# Verify resource exists
az cognitiveservices account show \
  --name <resource-name> \
  --resource-group <rg-name>

# Check you're in correct region
az cognitiveservices account list-skus --location eastus
```

#### Issue: "SkuNotAvailable"
**Solution:**
- Not all SKUs available in all regions
- Try different region
- Check: https://azure.microsoft.com/regions/services/

---

### Azure OpenAI Issues

#### Issue: "Access Denied" to Azure OpenAI
**Solution:**
1. Verify you've been approved: https://aka.ms/oai/access
2. Check approval email
3. Approval takes 1-2 business days

#### Issue: "DeploymentNotFound"
```bash
# List deployments
az cognitiveservices account deployment list \
  --name <resource-name> \
  --resource-group <rg-name>

# Create deployment
az cognitiveservices account deployment create \
  --name <resource-name> \
  --resource-group <rg-name> \
  --deployment-name gpt-4 \
  --model-name gpt-4 \
  --model-version "0613" \
  --model-format OpenAI \
  --sku-name Standard \
  --sku-capacity 10
```

#### Issue: "Rate Limit Exceeded"
**Solution:**
- Implement exponential backoff
- Reduce request frequency
- Increase capacity (costs more)

```python
import time

def call_with_retry(func, max_retries=3):
    for i in range(max_retries):
        try:
            return func()
        except Exception as e:
            if "rate limit" in str(e).lower():
                wait = 2 ** i
                time.sleep(wait)
            else:
                raise
```

---

### Document Intelligence Issues

#### Issue: "UnsupportedMediaType"
**Solution:**
- Supported formats: PDF, JPEG, PNG, BMP, TIFF
- Check file isn't corrupted
- Ensure URL is accessible

#### Issue: "InvalidRequest" with custom model
**Solution:**
1. Verify training completed successfully
2. Check model is published
3. Use correct model ID

```bash
# List trained models
az cognitiveservices account deployment list \
  --name <form-recognizer-name> \
  --resource-group <rg-name>
```

---

### Language Service Issues

#### Issue: "InvalidDocumentBatch"
**Solution:**
- Maximum 10 documents per batch
- Maximum 5,120 characters per document
- Check for empty documents

```python
# Split large batches
def batch_documents(docs, batch_size=10):
    for i in range(0, len(docs), batch_size):
        yield docs[i:i + batch_size]
```

#### Issue: "UnsupportedLanguage"
**Solution:**
- Check language is supported
- List: https://learn.microsoft.com/en-us/azure/ai-services/language-service/language-support

---

### Speech Service Issues

#### Issue: "Audio not recognized"
**Solution:**
1. Check microphone permissions
2. Verify audio format (16kHz, 16-bit, mono recommended)
3. Ensure clear audio input

```python
# Test microphone
import azure.cognitiveservices.speech as speechsdk

config = speechsdk.SpeechConfig(subscription=key, region=region)
recognizer = speechsdk.SpeechRecognizer(speech_config=config)
result = recognizer.recognize_once()
print(f"Status: {result.reason}")
```

#### Issue: "SynthesizingAudioFailed"
**Solution:**
- Check voice name is valid
- Verify SSML syntax if using SSML
- Check output audio configuration

---

### Search Service Issues

#### Issue: "IndexNotFound"
**Solution:**
```python
# List indexes
client = SearchIndexClient(endpoint, credential)
for index in client.list_indexes():
    print(index.name)
```

#### Issue: "Vector search not working"
**Solution:**
1. Verify vector field dimensions match embedding model
2. Check vector search profile is configured
3. Ensure embeddings are proper float arrays

```python
# Verify embedding dimensions
embedding = get_embedding("test")
print(f"Dimensions: {len(embedding)}")  # Should be 1536 for ada-002
```

---

### SDK Issues

#### Issue: "ModuleNotFoundError"
**Solution:**
```bash
# Install all required packages
pip install azure-ai-textanalytics
pip install azure-ai-formrecognizer
pip install azure-ai-vision-imageanalysis
pip install azure-cognitiveservices-speech
pip install azure-search-documents
pip install openai
```

#### Issue: "ImportError: cannot import name"
**Solution:**
- SDK version mismatch
- Update to latest versions

```bash
pip install --upgrade azure-ai-textanalytics
pip install --upgrade azure-ai-formrecognizer
pip install --upgrade openai
```

---

### Environment Variable Issues

#### Issue: "NoneType has no attribute"
**Solution:**
- Environment variable not set

```python
import os

# Check if variables are set
required_vars = [
    "AZURE_AI_ENDPOINT",
    "AZURE_AI_KEY",
    "AZURE_OPENAI_ENDPOINT",
    "AZURE_OPENAI_KEY"
]

for var in required_vars:
    value = os.getenv(var)
    if value:
        print(f"✓ {var} is set")
    else:
        print(f"✗ {var} is NOT set")
```

---

### Common Error Patterns

| Error | Likely Cause | Solution |
|-------|-------------|----------|
| 401 Unauthorized | Bad API key | Check/regenerate key |
| 403 Forbidden | Wrong permissions | Check RBAC roles |
| 404 Not Found | Wrong endpoint/resource | Verify URL |
| 429 Too Many Requests | Rate limited | Add retry logic |
| 500 Server Error | Azure issue | Retry, check status |

---

### Getting Help

1. **Azure Status**: https://status.azure.com/
2. **Documentation**: https://learn.microsoft.com/azure/ai-services/
3. **Stack Overflow**: Tag questions with `azure-cognitive-services`
4. **Azure Support**: Create support ticket in Portal

---

### Debug Logging

Enable detailed logging:

```python
import logging
import sys

# Enable debug logging
logging.basicConfig(
    level=logging.DEBUG,
    stream=sys.stdout,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# For Azure SDK
logger = logging.getLogger('azure')
logger.setLevel(logging.DEBUG)
```

---

Remember: When in doubt, check the official documentation and verify your credentials are correct!
