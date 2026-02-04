# Module 05: Computer Vision

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will:
- Analyze images for objects, faces, and content
- Extract text from images using OCR
- Train custom image classification models
- Implement object detection solutions
- Apply computer vision in healthcare scenarios

---

## 📖 The IntelliHealth Scenario

IntelliHealth needs computer vision for:

| Use Case | Capability | Value |
|----------|------------|-------|
| Medical image analysis | Image classification | Preliminary screening |
| Document digitization | OCR | Legacy record conversion |
| Pill identification | Object detection | Medication safety |
| Patient check-in | Face recognition | Contactless identification |

---

## 🔧 Exercise 1: Azure AI Vision Basics

### Task 1.1: Setup Vision Resource

```bash
# Create Computer Vision resource
az cognitiveservices account create \
  --name ai-intellihealth-vision \
  --resource-group rg-ai102-learning \
  --kind ComputerVision \
  --sku F0 \
  --location eastus \
  --yes

# Get endpoint and key
az cognitiveservices account show \
  --name ai-intellihealth-vision \
  --resource-group rg-ai102-learning \
  --query "properties.endpoint" -o tsv

az cognitiveservices account keys list \
  --name ai-intellihealth-vision \
  --resource-group rg-ai102-learning
```

### Task 1.2: Install SDK

```bash
pip install azure-ai-vision-imageanalysis
```

### Task 1.3: Basic Image Analysis

```python
# image_analysis.py
from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential
import os

def get_client():
    endpoint = os.getenv("AZURE_VISION_ENDPOINT")
    key = os.getenv("AZURE_VISION_KEY")
    return ImageAnalysisClient(endpoint, AzureKeyCredential(key))

def analyze_image(image_url: str):
    """Analyze an image for multiple visual features"""
    
    client = get_client()
    
    result = client.analyze_from_url(
        image_url,
        visual_features=[
            VisualFeatures.CAPTION,
            VisualFeatures.DENSE_CAPTIONS,
            VisualFeatures.TAGS,
            VisualFeatures.OBJECTS,
            VisualFeatures.PEOPLE
        ]
    )
    
    analysis = {
        "caption": None,
        "dense_captions": [],
        "tags": [],
        "objects": [],
        "people": []
    }
    
    # Main caption
    if result.caption:
        analysis["caption"] = {
            "text": result.caption.text,
            "confidence": result.caption.confidence
        }
    
    # Dense captions (multiple region descriptions)
    if result.dense_captions:
        for caption in result.dense_captions.list:
            analysis["dense_captions"].append({
                "text": caption.text,
                "confidence": caption.confidence,
                "bounding_box": caption.bounding_box
            })
    
    # Tags
    if result.tags:
        for tag in result.tags.list:
            analysis["tags"].append({
                "name": tag.name,
                "confidence": tag.confidence
            })
    
    # Objects
    if result.objects:
        for obj in result.objects.list:
            analysis["objects"].append({
                "name": obj.tags[0].name if obj.tags else "unknown",
                "confidence": obj.tags[0].confidence if obj.tags else 0,
                "bounding_box": obj.bounding_box
            })
    
    # People detection
    if result.people:
        for person in result.people.list:
            analysis["people"].append({
                "bounding_box": person.bounding_box,
                "confidence": person.confidence
            })
    
    return analysis

# Test
if __name__ == "__main__":
    # Use a sample image URL
    sample_url = "https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/images/windows-kitchen.jpg"
    
    result = analyze_image(sample_url)
    
    print("Image Analysis Results:")
    print(f"\nCaption: {result['caption']['text']} ({result['caption']['confidence']:.0%})")
    
    print("\nTags:")
    for tag in result['tags'][:10]:
        print(f"  - {tag['name']}: {tag['confidence']:.0%}")
    
    print(f"\nObjects detected: {len(result['objects'])}")
    for obj in result['objects']:
        print(f"  - {obj['name']}: {obj['confidence']:.0%}")
    
    print(f"\nPeople detected: {len(result['people'])}")
```

---

## 🔧 Exercise 2: OCR - Text Extraction

### Task 2.1: Extract Text from Images

```python
# ocr_extraction.py
from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential
import os

def get_client():
    endpoint = os.getenv("AZURE_VISION_ENDPOINT")
    key = os.getenv("AZURE_VISION_KEY")
    return ImageAnalysisClient(endpoint, AzureKeyCredential(key))

def extract_text(image_url: str) -> dict:
    """Extract text from an image using OCR"""
    
    client = get_client()
    
    result = client.analyze_from_url(
        image_url,
        visual_features=[VisualFeatures.READ]
    )
    
    text_content = {
        "full_text": "",
        "lines": [],
        "words": []
    }
    
    if result.read:
        for block in result.read.blocks:
            for line in block.lines:
                text_content["lines"].append({
                    "text": line.text,
                    "bounding_polygon": line.bounding_polygon
                })
                text_content["full_text"] += line.text + "\n"
                
                for word in line.words:
                    text_content["words"].append({
                        "text": word.text,
                        "confidence": word.confidence
                    })
    
    return text_content

def extract_text_from_file(image_path: str) -> dict:
    """Extract text from a local image file"""
    
    client = get_client()
    
    with open(image_path, "rb") as f:
        image_data = f.read()
    
    result = client.analyze(
        image_data,
        visual_features=[VisualFeatures.READ]
    )
    
    text_content = {
        "full_text": "",
        "lines": []
    }
    
    if result.read:
        for block in result.read.blocks:
            for line in block.lines:
                text_content["lines"].append(line.text)
                text_content["full_text"] += line.text + "\n"
    
    return text_content

# Test
if __name__ == "__main__":
    # Sample image with text
    sample_url = "https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/images/handwritten-text.png"
    
    result = extract_text(sample_url)
    
    print("Extracted Text:")
    print("-" * 40)
    print(result["full_text"])
    print("-" * 40)
    print(f"\nTotal lines: {len(result['lines'])}")
    print(f"Total words: {len(result['words'])}")
```

### Task 2.2: Medical Document OCR Pipeline

```python
# medical_document_ocr.py
from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential
import re
import os

class MedicalDocumentOCR:
    """
    OCR pipeline for medical documents.
    Extracts structured data from scanned medical forms.
    """
    
    def __init__(self):
        endpoint = os.getenv("AZURE_VISION_ENDPOINT")
        key = os.getenv("AZURE_VISION_KEY")
        self.client = ImageAnalysisClient(endpoint, AzureKeyCredential(key))
        
        # Patterns for medical data extraction
        self.patterns = {
            "date": r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}',
            "phone": r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}',
            "ssn": r'\d{3}-\d{2}-\d{4}',
            "dob": r'(?:DOB|Date of Birth|Born)[:\s]*(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})',
            "mrn": r'(?:MRN|Medical Record)[:\s#]*(\w+)',
            "allergies": r'(?:Allergies|Allergy)[:\s]*([^\n]+)',
            "medications": r'(?:Medications?|Meds|Rx)[:\s]*([^\n]+)'
        }
    
    def process(self, image_url: str) -> dict:
        """Process a medical document image"""
        
        # Extract raw text
        result = self.client.analyze_from_url(
            image_url,
            visual_features=[VisualFeatures.READ]
        )
        
        full_text = ""
        if result.read:
            for block in result.read.blocks:
                for line in block.lines:
                    full_text += line.text + "\n"
        
        # Extract structured data
        extracted = {
            "raw_text": full_text,
            "dates": self._find_pattern("date", full_text),
            "phone_numbers": self._find_pattern("phone", full_text),
            "dob": self._find_pattern("dob", full_text),
            "mrn": self._find_pattern("mrn", full_text),
            "allergies": self._find_pattern("allergies", full_text),
            "medications": self._find_pattern("medications", full_text)
        }
        
        return extracted
    
    def _find_pattern(self, pattern_name: str, text: str) -> list:
        """Find all matches for a pattern"""
        
        pattern = self.patterns.get(pattern_name)
        if not pattern:
            return []
        
        matches = re.findall(pattern, text, re.IGNORECASE)
        return matches

# Test
if __name__ == "__main__":
    ocr = MedicalDocumentOCR()
    
    # Would use a real medical form image
    print("Medical Document OCR ready.")
    print("Provide an image URL to process.")
```

---

## 🔧 Exercise 3: Custom Vision

### Task 3.1: Setup Custom Vision

```bash
# Create Custom Vision training resource
az cognitiveservices account create \
  --name ai-intellihealth-customvision-train \
  --resource-group rg-ai102-learning \
  --kind CustomVision.Training \
  --sku F0 \
  --location eastus \
  --yes

# Create Custom Vision prediction resource
az cognitiveservices account create \
  --name ai-intellihealth-customvision-predict \
  --resource-group rg-ai102-learning \
  --kind CustomVision.Prediction \
  --sku F0 \
  --location eastus \
  --yes
```

### Task 3.2: Train Image Classifier

```python
# custom_vision_train.py
from azure.cognitiveservices.vision.customvision.training import CustomVisionTrainingClient
from azure.cognitiveservices.vision.customvision.training.models import ImageFileCreateBatch, ImageFileCreateEntry
from msrest.authentication import ApiKeyCredentials
import os
import time

def get_training_client():
    endpoint = os.getenv("CUSTOM_VISION_TRAINING_ENDPOINT")
    key = os.getenv("CUSTOM_VISION_TRAINING_KEY")
    credentials = ApiKeyCredentials(in_headers={"Training-key": key})
    return CustomVisionTrainingClient(endpoint, credentials)

def create_project(project_name: str, classification_type: str = "Multiclass"):
    """Create a Custom Vision project"""
    
    client = get_training_client()
    
    # Get domain for image classification
    domains = client.get_domains()
    general_domain = next(d for d in domains if d.name == "General" and d.type == "Classification")
    
    project = client.create_project(
        name=project_name,
        domain_id=general_domain.id,
        classification_type=classification_type
    )
    
    print(f"Created project: {project.name} ({project.id})")
    return project

def add_training_images(project_id: str, tag_name: str, image_urls: list):
    """Add training images for a tag"""
    
    client = get_training_client()
    
    # Create or get tag
    tags = client.get_tags(project_id)
    tag = next((t for t in tags if t.name == tag_name), None)
    
    if not tag:
        tag = client.create_tag(project_id, tag_name)
        print(f"Created tag: {tag.name}")
    
    # Add images
    for url in image_urls:
        client.create_images_from_urls(
            project_id,
            images=[{"url": url, "tag_ids": [tag.id]}]
        )
    
    print(f"Added {len(image_urls)} images for tag: {tag_name}")

def train_project(project_id: str):
    """Train the Custom Vision model"""
    
    client = get_training_client()
    
    print("Starting training...")
    iteration = client.train_project(project_id)
    
    while iteration.status == "Training":
        print("Training in progress...")
        time.sleep(5)
        iteration = client.get_iteration(project_id, iteration.id)
    
    print(f"Training complete! Status: {iteration.status}")
    return iteration

def publish_iteration(project_id: str, iteration_id: str, publish_name: str):
    """Publish trained model for predictions"""
    
    client = get_training_client()
    prediction_resource_id = os.getenv("CUSTOM_VISION_PREDICTION_RESOURCE_ID")
    
    client.publish_iteration(
        project_id,
        iteration_id,
        publish_name,
        prediction_resource_id
    )
    
    print(f"Published model: {publish_name}")

# Example workflow
if __name__ == "__main__":
    print("Custom Vision Training")
    print("=" * 40)
    print("1. Create project: create_project('medical-image-classifier')")
    print("2. Add images: add_training_images(project_id, 'xray-normal', urls)")
    print("3. Train: train_project(project_id)")
    print("4. Publish: publish_iteration(project_id, iteration_id, 'production')")
```

### Task 3.3: Use Custom Vision Model

```python
# custom_vision_predict.py
from azure.cognitiveservices.vision.customvision.prediction import CustomVisionPredictionClient
from msrest.authentication import ApiKeyCredentials
import os

def get_prediction_client():
    endpoint = os.getenv("CUSTOM_VISION_PREDICTION_ENDPOINT")
    key = os.getenv("CUSTOM_VISION_PREDICTION_KEY")
    credentials = ApiKeyCredentials(in_headers={"Prediction-key": key})
    return CustomVisionPredictionClient(endpoint, credentials)

def classify_image(project_id: str, publish_name: str, image_url: str):
    """Classify an image using trained model"""
    
    client = get_prediction_client()
    
    result = client.classify_image_url(
        project_id,
        publish_name,
        {"url": image_url}
    )
    
    predictions = []
    for prediction in result.predictions:
        predictions.append({
            "tag": prediction.tag_name,
            "probability": prediction.probability
        })
    
    return sorted(predictions, key=lambda x: x["probability"], reverse=True)

def classify_local_image(project_id: str, publish_name: str, image_path: str):
    """Classify a local image file"""
    
    client = get_prediction_client()
    
    with open(image_path, "rb") as f:
        result = client.classify_image(
            project_id,
            publish_name,
            f
        )
    
    predictions = []
    for prediction in result.predictions:
        predictions.append({
            "tag": prediction.tag_name,
            "probability": prediction.probability
        })
    
    return sorted(predictions, key=lambda x: x["probability"], reverse=True)

# Test
if __name__ == "__main__":
    print("Custom Vision Prediction")
    print("Use classify_image() or classify_local_image() with your trained model.")
```

---

## 🔧 Exercise 4: Healthcare Vision Application

### Complete Medical Image Analysis System

```python
# medical_vision_system.py
from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential
from dataclasses import dataclass
from typing import List, Optional
import os

@dataclass
class ImageAnalysisResult:
    """Result from medical image analysis"""
    image_type: str
    description: str
    objects_detected: List[dict]
    text_extracted: Optional[str]
    metadata: dict
    confidence: float

class MedicalVisionSystem:
    """
    Complete vision system for IntelliHealth.
    Handles multiple types of medical image analysis.
    """
    
    def __init__(self):
        endpoint = os.getenv("AZURE_VISION_ENDPOINT")
        key = os.getenv("AZURE_VISION_KEY")
        self.client = ImageAnalysisClient(endpoint, AzureKeyCredential(key))
        
        # Medical image classification rules
        self.image_types = {
            "xray": ["x-ray", "radiograph", "bone", "skeleton", "chest", "lung"],
            "document": ["text", "form", "paper", "document", "handwriting"],
            "medication": ["pill", "medicine", "bottle", "prescription", "tablet"],
            "patient_photo": ["person", "face", "portrait"],
            "lab_equipment": ["microscope", "test", "tube", "laboratory"]
        }
    
    def analyze(self, image_url: str) -> ImageAnalysisResult:
        """Perform comprehensive image analysis"""
        
        # Full analysis
        result = self.client.analyze_from_url(
            image_url,
            visual_features=[
                VisualFeatures.CAPTION,
                VisualFeatures.TAGS,
                VisualFeatures.OBJECTS,
                VisualFeatures.PEOPLE,
                VisualFeatures.READ
            ]
        )
        
        # Determine image type
        tags = [t.name.lower() for t in result.tags.list] if result.tags else []
        image_type = self._classify_image_type(tags)
        
        # Get description
        description = result.caption.text if result.caption else "No description available"
        confidence = result.caption.confidence if result.caption else 0.0
        
        # Extract objects
        objects = []
        if result.objects:
            for obj in result.objects.list:
                if obj.tags:
                    objects.append({
                        "name": obj.tags[0].name,
                        "confidence": obj.tags[0].confidence,
                        "location": {
                            "x": obj.bounding_box["x"],
                            "y": obj.bounding_box["y"],
                            "width": obj.bounding_box["w"],
                            "height": obj.bounding_box["h"]
                        }
                    })
        
        # Extract text if present
        text_content = None
        if result.read:
            lines = []
            for block in result.read.blocks:
                for line in block.lines:
                    lines.append(line.text)
            text_content = "\n".join(lines) if lines else None
        
        # Build metadata
        metadata = {
            "tags": tags[:10],
            "people_count": len(result.people.list) if result.people else 0,
            "has_text": text_content is not None
        }
        
        return ImageAnalysisResult(
            image_type=image_type,
            description=description,
            objects_detected=objects,
            text_extracted=text_content,
            metadata=metadata,
            confidence=confidence
        )
    
    def _classify_image_type(self, tags: List[str]) -> str:
        """Classify image type based on tags"""
        
        tag_set = set(tags)
        
        for image_type, keywords in self.image_types.items():
            if tag_set.intersection(keywords):
                return image_type
        
        return "unknown"
    
    def analyze_for_phi(self, image_url: str) -> dict:
        """
        Analyze image for Protected Health Information (PHI).
        Returns warnings if PHI might be present.
        """
        
        result = self.analyze(image_url)
        
        phi_warnings = []
        
        # Check for faces (patient photos)
        if result.metadata.get("people_count", 0) > 0:
            phi_warnings.append("Image contains faces - may require consent")
        
        # Check extracted text for PHI patterns
        if result.text_extracted:
            text = result.text_extracted.lower()
            
            phi_patterns = [
                ("SSN", r'\d{3}-\d{2}-\d{4}'),
                ("Date of Birth", "dob"),
                ("Date of Birth", "date of birth"),
                ("Medical Record Number", "mrn"),
                ("Phone Number", r'\d{3}[-.\s]?\d{3}[-.\s]?\d{4}')
            ]
            
            import re
            for name, pattern in phi_patterns:
                if isinstance(pattern, str):
                    if pattern in text:
                        phi_warnings.append(f"Potential {name} detected in text")
                else:
                    if re.search(pattern, text):
                        phi_warnings.append(f"Potential {name} detected in text")
        
        return {
            "analysis": result,
            "phi_warnings": phi_warnings,
            "contains_phi": len(phi_warnings) > 0
        }

# Test
if __name__ == "__main__":
    system = MedicalVisionSystem()
    
    # Test with sample image
    sample_url = "https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/images/windows-kitchen.jpg"
    
    result = system.analyze(sample_url)
    
    print("Medical Vision Analysis")
    print("=" * 50)
    print(f"Image Type: {result.image_type}")
    print(f"Description: {result.description}")
    print(f"Confidence: {result.confidence:.0%}")
    print(f"\nObjects: {len(result.objects_detected)}")
    for obj in result.objects_detected:
        print(f"  - {obj['name']}: {obj['confidence']:.0%}")
    print(f"\nMetadata: {result.metadata}")
    
    if result.text_extracted:
        print(f"\nExtracted Text:\n{result.text_extracted[:200]}")
```

---

## 🧹 Cleanup

```bash
# Delete Vision resources
az cognitiveservices account delete \
  --name ai-intellihealth-vision \
  --resource-group rg-ai102-learning

az cognitiveservices account delete \
  --name ai-intellihealth-customvision-train \
  --resource-group rg-ai102-learning

az cognitiveservices account delete \
  --name ai-intellihealth-customvision-predict \
  --resource-group rg-ai102-learning
```

---

## ✅ Module Checklist

Before moving on, ensure you can:

- [ ] Analyze images for captions, tags, and objects
- [ ] Extract text from images using OCR
- [ ] Process local files and URLs
- [ ] Create Custom Vision projects
- [ ] Train and publish custom image classifiers
- [ ] Implement object detection solutions
- [ ] Build production vision applications

---

## 📚 Additional Resources

- [Azure AI Vision Documentation](https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/)
- [Custom Vision Portal](https://www.customvision.ai/)
- [Image Analysis API Reference](https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/concept-analyzing-images)
- [OCR Documentation](https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/concept-ocr)

---

**Next Module:** [Module 06: Speech Services](../06-speech-services/README.md)
