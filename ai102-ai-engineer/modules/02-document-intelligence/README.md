# Module 02: Document Intelligence

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will:
- Understand Azure AI Document Intelligence capabilities
- Use prebuilt models for invoices, receipts, and IDs
- Build custom extraction models
- Extract tables and complex layouts
- Handle handwritten text recognition

---

## 📖 The IntelliHealth Scenario

IntelliHealth's healthcare clients need to process thousands of documents daily:

| Document Type | Volume/Day | Current Process | Target |
|---------------|------------|-----------------|--------|
| Medical invoices | 2,000 | Manual entry (15 min each) | < 30 sec |
| Patient forms | 5,000 | Manual review (10 min each) | < 1 min |
| Insurance cards | 1,000 | Photo + manual entry | Automated |
| Lab reports | 2,000 | PDF review | Automated extraction |

Your mission: Build an intelligent document processing pipeline!

---

## 📖 Understanding Document Intelligence

### Service Capabilities

```
┌─────────────────────────────────────────────────────────────────┐
│              Azure AI Document Intelligence                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Prebuilt       │  │  Custom         │  │  Add-on         │ │
│  │  Models         │  │  Models         │  │  Features       │ │
│  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤ │
│  │ • Invoice       │  │ • Custom        │  │ • Barcodes      │ │
│  │ • Receipt       │  │   Template      │  │ • Formulas      │ │
│  │ • ID Document   │  │ • Custom        │  │ • Font styling  │ │
│  │ • Business Card │  │   Neural        │  │ • Query fields  │ │
│  │ • W-2 / 1099    │  │ • Composed      │  │ • High-res OCR  │ │
│  │ • Health Ins.   │  │   Models        │  │                 │ │
│  │ • Contract      │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  Layout Analysis: Tables, Structure, Selection Marks        ││
│  │  Read (OCR): Printed & Handwritten Text Extraction          ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Exercise 1: Setup Document Intelligence

### Task 1.1: Create Document Intelligence Resource

```bash
# Create Document Intelligence resource (Form Recognizer)
az cognitiveservices account create \
  --name ai-intellihealth-docs \
  --resource-group rg-ai102-learning \
  --kind FormRecognizer \
  --sku F0 \
  --location eastus \
  --yes

# Get endpoint and keys
az cognitiveservices account show \
  --name ai-intellihealth-docs \
  --resource-group rg-ai102-learning \
  --query "properties.endpoint" -o tsv

az cognitiveservices account keys list \
  --name ai-intellihealth-docs \
  --resource-group rg-ai102-learning
```

### Task 1.2: Install the SDK

```bash
pip install azure-ai-formrecognizer
```

### Task 1.3: Create Configuration

```python
# document_config.py
import os
from dotenv import load_dotenv

load_dotenv()

class DocumentConfig:
    ENDPOINT = os.getenv("AZURE_DOCUMENT_ENDPOINT")
    KEY = os.getenv("AZURE_DOCUMENT_KEY")
    
    # Sample document URLs for testing
    SAMPLE_INVOICE = "https://raw.githubusercontent.com/Azure-Samples/cognitive-services-REST-api-samples/master/curl/form-recognizer/sample-invoice.pdf"
    SAMPLE_RECEIPT = "https://raw.githubusercontent.com/Azure-Samples/cognitive-services-REST-api-samples/master/curl/form-recognizer/contoso-receipt.png"
```

---

## 🔧 Exercise 2: Prebuilt Models

### Task 2.1: Invoice Processing

```python
# process_invoice.py
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential
from document_config import DocumentConfig

def analyze_invoice(document_url: str) -> dict:
    """Extract data from an invoice using prebuilt model"""
    
    client = DocumentAnalysisClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    # Analyze the invoice
    poller = client.begin_analyze_document_from_url(
        "prebuilt-invoice",
        document_url
    )
    result = poller.result()
    
    invoices = []
    for invoice in result.documents:
        invoice_data = {
            "vendor_name": get_field_value(invoice.fields.get("VendorName")),
            "vendor_address": get_field_value(invoice.fields.get("VendorAddress")),
            "customer_name": get_field_value(invoice.fields.get("CustomerName")),
            "invoice_id": get_field_value(invoice.fields.get("InvoiceId")),
            "invoice_date": get_field_value(invoice.fields.get("InvoiceDate")),
            "due_date": get_field_value(invoice.fields.get("DueDate")),
            "subtotal": get_field_value(invoice.fields.get("SubTotal")),
            "tax": get_field_value(invoice.fields.get("TotalTax")),
            "total": get_field_value(invoice.fields.get("InvoiceTotal")),
            "line_items": []
        }
        
        # Extract line items
        items = invoice.fields.get("Items")
        if items and items.value:
            for item in items.value:
                line_item = {
                    "description": get_field_value(item.value.get("Description")),
                    "quantity": get_field_value(item.value.get("Quantity")),
                    "unit_price": get_field_value(item.value.get("UnitPrice")),
                    "amount": get_field_value(item.value.get("Amount"))
                }
                invoice_data["line_items"].append(line_item)
        
        invoices.append(invoice_data)
    
    return invoices

def get_field_value(field):
    """Safely extract field value"""
    if field is None:
        return None
    return field.value

# Test
if __name__ == "__main__":
    invoices = analyze_invoice(DocumentConfig.SAMPLE_INVOICE)
    for inv in invoices:
        print(f"\n{'='*50}")
        print(f"Invoice: {inv['invoice_id']}")
        print(f"Vendor: {inv['vendor_name']}")
        print(f"Customer: {inv['customer_name']}")
        print(f"Date: {inv['invoice_date']}")
        print(f"Total: {inv['total']}")
        print(f"\nLine Items:")
        for item in inv['line_items']:
            print(f"  - {item['description']}: {item['amount']}")
```

### Task 2.2: Receipt Processing

```python
# process_receipt.py
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential
from document_config import DocumentConfig

def analyze_receipt(document_url: str) -> list:
    """Extract data from receipts"""
    
    client = DocumentAnalysisClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    poller = client.begin_analyze_document_from_url(
        "prebuilt-receipt",
        document_url
    )
    result = poller.result()
    
    receipts = []
    for receipt in result.documents:
        receipt_data = {
            "merchant_name": get_field_value(receipt.fields.get("MerchantName")),
            "merchant_address": get_field_value(receipt.fields.get("MerchantAddress")),
            "merchant_phone": get_field_value(receipt.fields.get("MerchantPhoneNumber")),
            "transaction_date": get_field_value(receipt.fields.get("TransactionDate")),
            "transaction_time": get_field_value(receipt.fields.get("TransactionTime")),
            "subtotal": get_field_value(receipt.fields.get("Subtotal")),
            "tax": get_field_value(receipt.fields.get("TotalTax")),
            "tip": get_field_value(receipt.fields.get("Tip")),
            "total": get_field_value(receipt.fields.get("Total")),
            "items": []
        }
        
        items = receipt.fields.get("Items")
        if items and items.value:
            for item in items.value:
                receipt_data["items"].append({
                    "name": get_field_value(item.value.get("Name")),
                    "quantity": get_field_value(item.value.get("Quantity")),
                    "price": get_field_value(item.value.get("TotalPrice"))
                })
        
        receipts.append(receipt_data)
    
    return receipts

def get_field_value(field):
    return field.value if field else None

if __name__ == "__main__":
    receipts = analyze_receipt(DocumentConfig.SAMPLE_RECEIPT)
    for r in receipts:
        print(f"\nMerchant: {r['merchant_name']}")
        print(f"Date: {r['transaction_date']}")
        print(f"Total: {r['total']}")
```

### Task 2.3: ID Document Processing

```python
# process_id.py
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential
from document_config import DocumentConfig

def analyze_id_document(document_url: str) -> list:
    """Extract data from ID documents (driver's license, passport)"""
    
    client = DocumentAnalysisClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    poller = client.begin_analyze_document_from_url(
        "prebuilt-idDocument",
        document_url
    )
    result = poller.result()
    
    ids = []
    for doc in result.documents:
        id_data = {
            "document_type": doc.doc_type,
            "first_name": get_field_value(doc.fields.get("FirstName")),
            "last_name": get_field_value(doc.fields.get("LastName")),
            "date_of_birth": get_field_value(doc.fields.get("DateOfBirth")),
            "document_number": get_field_value(doc.fields.get("DocumentNumber")),
            "expiration_date": get_field_value(doc.fields.get("DateOfExpiration")),
            "address": get_field_value(doc.fields.get("Address")),
            "region": get_field_value(doc.fields.get("Region")),
            "country": get_field_value(doc.fields.get("CountryRegion")),
            "confidence": doc.confidence
        }
        ids.append(id_data)
    
    return ids

def get_field_value(field):
    return field.value if field else None

# Test with sample ID (use your own test image)
if __name__ == "__main__":
    # Note: Use a sample ID image URL for testing
    sample_id_url = "YOUR_ID_SAMPLE_URL"
    try:
        ids = analyze_id_document(sample_id_url)
        for id_doc in ids:
            print(f"\nDocument Type: {id_doc['document_type']}")
            print(f"Name: {id_doc['first_name']} {id_doc['last_name']}")
            print(f"DOB: {id_doc['date_of_birth']}")
            print(f"Document #: {id_doc['document_number']}")
            print(f"Confidence: {id_doc['confidence']:.2%}")
    except Exception as e:
        print(f"Error: {e}")
```

---

## 🔧 Exercise 3: Layout Analysis

### Task 3.1: Extract Tables from Documents

```python
# layout_analysis.py
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential
from document_config import DocumentConfig

def analyze_layout(document_url: str):
    """Extract layout including tables, text, and structure"""
    
    client = DocumentAnalysisClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    poller = client.begin_analyze_document_from_url(
        "prebuilt-layout",
        document_url
    )
    result = poller.result()
    
    # Extract paragraphs
    print("=" * 50)
    print("PARAGRAPHS")
    print("=" * 50)
    for para in result.paragraphs:
        print(f"- {para.content[:100]}...")
        print(f"  Role: {para.role}")
        print()
    
    # Extract tables
    print("=" * 50)
    print("TABLES")
    print("=" * 50)
    for table_idx, table in enumerate(result.tables):
        print(f"\nTable {table_idx + 1}: {table.row_count} rows x {table.column_count} columns")
        
        # Create a 2D grid
        grid = [['' for _ in range(table.column_count)] for _ in range(table.row_count)]
        
        for cell in table.cells:
            grid[cell.row_index][cell.column_index] = cell.content
        
        # Print the table
        for row in grid:
            print(" | ".join(row))
    
    # Extract selection marks (checkboxes)
    print("=" * 50)
    print("SELECTION MARKS")
    print("=" * 50)
    for page in result.pages:
        for mark in page.selection_marks:
            print(f"- Checkbox at page {page.page_number}: {mark.state}")

if __name__ == "__main__":
    analyze_layout(DocumentConfig.SAMPLE_INVOICE)
```

### Task 3.2: Process Local Files

```python
# process_local_file.py
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential
from document_config import DocumentConfig

def analyze_local_document(file_path: str, model_id: str = "prebuilt-layout"):
    """Analyze a document from local file system"""
    
    client = DocumentAnalysisClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    with open(file_path, "rb") as f:
        poller = client.begin_analyze_document(
            model_id,
            f
        )
    
    result = poller.result()
    
    print(f"Document contains {len(result.pages)} page(s)")
    
    for page in result.pages:
        print(f"\nPage {page.page_number}:")
        print(f"  Width: {page.width}, Height: {page.height}")
        print(f"  Lines: {len(page.lines)}")
        print(f"  Words: {len(page.words)}")
        
        # Print first 5 lines
        for line in page.lines[:5]:
            print(f"    - {line.content}")

if __name__ == "__main__":
    # Test with a local PDF or image
    import sys
    if len(sys.argv) > 1:
        analyze_local_document(sys.argv[1])
    else:
        print("Usage: python process_local_file.py <document_path>")
```

---

## 🔧 Exercise 4: Custom Models

### Understanding Custom Model Options

| Model Type | Best For | Training Data | Accuracy |
|------------|----------|---------------|----------|
| **Template** | Fixed-format forms | 5+ samples | High |
| **Neural** | Variable layouts | 5+ samples | Very High |
| **Composed** | Multiple form types | Multiple models | Varies |

### Task 4.1: Prepare Training Data

Create a folder structure for training:
```
training-data/
├── invoices/
│   ├── invoice1.pdf
│   ├── invoice1.pdf.labels.json
│   ├── invoice2.pdf
│   ├── invoice2.pdf.labels.json
│   └── ...
└── fields.json
```

### Task 4.2: Create Training Data Storage

```bash
# Create storage account
az storage account create \
  --name stintellihealthdocs \
  --resource-group rg-ai102-learning \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name training-data \
  --account-name stintellihealthdocs

# Get connection string
az storage account show-connection-string \
  --name stintellihealthdocs \
  --resource-group rg-ai102-learning \
  --query connectionString -o tsv

# Upload training files
az storage blob upload-batch \
  --destination training-data \
  --source ./training-data \
  --account-name stintellihealthdocs

# Generate SAS URL for training
az storage container generate-sas \
  --name training-data \
  --account-name stintellihealthdocs \
  --permissions rl \
  --expiry 2024-12-31 \
  --https-only \
  --output tsv
```

### Task 4.3: Train a Custom Model

```python
# train_custom_model.py
from azure.ai.formrecognizer import DocumentModelAdministrationClient
from azure.core.credentials import AzureKeyCredential
from document_config import DocumentConfig

def train_custom_model(training_data_url: str, model_id: str):
    """Train a custom extraction model"""
    
    client = DocumentModelAdministrationClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    # Start training
    print(f"Starting training for model: {model_id}")
    poller = client.begin_build_document_model(
        build_mode="neural",  # or "template" for fixed layouts
        blob_container_url=training_data_url,
        model_id=model_id,
        description="IntelliHealth medical invoice model"
    )
    
    # Wait for training to complete
    model = poller.result()
    
    print(f"\nModel trained successfully!")
    print(f"Model ID: {model.model_id}")
    print(f"Description: {model.description}")
    print(f"Created: {model.created_on}")
    print(f"\nFields:")
    for field_name, field in model.doc_types[model_id].field_schema.items():
        print(f"  - {field_name}: {field['type']}")
    
    return model

def list_models():
    """List all custom models"""
    
    client = DocumentModelAdministrationClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    print("Custom Models:")
    for model in client.list_document_models():
        print(f"  - {model.model_id} ({model.created_on})")

def delete_model(model_id: str):
    """Delete a custom model"""
    
    client = DocumentModelAdministrationClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    client.delete_document_model(model_id)
    print(f"Model {model_id} deleted")

if __name__ == "__main__":
    # List existing models
    list_models()
```

### Task 4.4: Use Custom Model

```python
# use_custom_model.py
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential
from document_config import DocumentConfig

def analyze_with_custom_model(document_url: str, model_id: str):
    """Analyze document using custom model"""
    
    client = DocumentAnalysisClient(
        endpoint=DocumentConfig.ENDPOINT,
        credential=AzureKeyCredential(DocumentConfig.KEY)
    )
    
    poller = client.begin_analyze_document_from_url(
        model_id,
        document_url
    )
    result = poller.result()
    
    for doc in result.documents:
        print(f"Document Type: {doc.doc_type}")
        print(f"Confidence: {doc.confidence:.2%}")
        print("\nExtracted Fields:")
        
        for field_name, field in doc.fields.items():
            if field.value is not None:
                print(f"  {field_name}: {field.value} (confidence: {field.confidence:.2%})")

if __name__ == "__main__":
    # Use your custom model
    custom_model_id = "medical-invoice-model"
    document_url = "YOUR_DOCUMENT_URL"
    
    analyze_with_custom_model(document_url, custom_model_id)
```

---

## 🔧 Exercise 5: Building a Document Processing Pipeline

### Task 5.1: Create IntelliHealth Document Processor

```python
# document_processor.py
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.core.credentials import AzureKeyCredential
from dataclasses import dataclass
from typing import Optional, List
from datetime import datetime
from document_config import DocumentConfig

@dataclass
class ProcessedDocument:
    """Standardized document result"""
    document_type: str
    confidence: float
    extracted_data: dict
    processing_time: float
    page_count: int
    warnings: List[str]

class IntelliHealthDocumentProcessor:
    """
    Unified document processing for IntelliHealth.
    Handles multiple document types with consistent output.
    """
    
    def __init__(self):
        self.client = DocumentAnalysisClient(
            endpoint=DocumentConfig.ENDPOINT,
            credential=AzureKeyCredential(DocumentConfig.KEY)
        )
        
        # Map document types to model IDs
        self.model_map = {
            "invoice": "prebuilt-invoice",
            "receipt": "prebuilt-receipt",
            "id": "prebuilt-idDocument",
            "insurance_card": "prebuilt-healthInsuranceCard.us",
            "layout": "prebuilt-layout",
            "general": "prebuilt-document"
        }
    
    def process(self, document_url: str, doc_type: str = "general") -> ProcessedDocument:
        """Process a document and return standardized result"""
        
        start_time = datetime.now()
        warnings = []
        
        model_id = self.model_map.get(doc_type, "prebuilt-document")
        
        try:
            poller = self.client.begin_analyze_document_from_url(
                model_id,
                document_url
            )
            result = poller.result()
            
            # Extract data based on document type
            extracted = self._extract_data(result, doc_type)
            
            # Calculate confidence
            confidence = 0.0
            if result.documents:
                confidence = result.documents[0].confidence
            
            processing_time = (datetime.now() - start_time).total_seconds()
            
            return ProcessedDocument(
                document_type=doc_type,
                confidence=confidence,
                extracted_data=extracted,
                processing_time=processing_time,
                page_count=len(result.pages),
                warnings=warnings
            )
            
        except Exception as e:
            processing_time = (datetime.now() - start_time).total_seconds()
            return ProcessedDocument(
                document_type=doc_type,
                confidence=0.0,
                extracted_data={"error": str(e)},
                processing_time=processing_time,
                page_count=0,
                warnings=[str(e)]
            )
    
    def _extract_data(self, result, doc_type: str) -> dict:
        """Extract relevant data based on document type"""
        
        if not result.documents:
            return {"raw_text": self._get_raw_text(result)}
        
        doc = result.documents[0]
        fields = {}
        
        for name, field in doc.fields.items():
            if field.value is not None:
                fields[name] = {
                    "value": str(field.value),
                    "confidence": field.confidence
                }
        
        return fields
    
    def _get_raw_text(self, result) -> str:
        """Get all text content from document"""
        lines = []
        for page in result.pages:
            for line in page.lines:
                lines.append(line.content)
        return "\n".join(lines)

# Example usage
if __name__ == "__main__":
    processor = IntelliHealthDocumentProcessor()
    
    # Process an invoice
    result = processor.process(
        DocumentConfig.SAMPLE_INVOICE,
        doc_type="invoice"
    )
    
    print(f"Document Type: {result.document_type}")
    print(f"Confidence: {result.confidence:.2%}")
    print(f"Processing Time: {result.processing_time:.2f}s")
    print(f"Pages: {result.page_count}")
    print(f"\nExtracted Data:")
    for key, value in result.extracted_data.items():
        if isinstance(value, dict):
            print(f"  {key}: {value['value']} ({value['confidence']:.0%})")
        else:
            print(f"  {key}: {value}")
```

---

## 🧹 Cleanup

```bash
# Delete Document Intelligence resource
az cognitiveservices account delete \
  --name ai-intellihealth-docs \
  --resource-group rg-ai102-learning

# Delete storage account (if created)
az storage account delete \
  --name stintellihealthdocs \
  --resource-group rg-ai102-learning \
  --yes
```

---

## ✅ Module Checklist

Before moving on, ensure you can:

- [ ] Create and configure Document Intelligence resources
- [ ] Use prebuilt models for invoices, receipts, and IDs
- [ ] Extract tables and structured data with layout analysis
- [ ] Prepare training data for custom models
- [ ] Train and deploy custom extraction models
- [ ] Handle both URL and local file processing
- [ ] Build production-ready document processing pipelines

---

## 📚 Additional Resources

- [Document Intelligence Documentation](https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/)
- [Prebuilt Models Reference](https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/concept-model-overview)
- [Custom Model Training](https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/concept-custom)
- [Document Intelligence Studio](https://documentintelligence.ai.azure.com/)

---

**Next Module:** [Module 03: Language & Text Analytics](../03-language-analytics/README.md)
