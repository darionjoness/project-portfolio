# Module 03: Language & Text Analytics

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will:
- Analyze sentiment and opinions in text
- Extract key phrases and entities
- Detect and translate languages
- Build custom text classification models
- Implement entity linking and recognition

---

## 📖 The IntelliHealth Scenario

IntelliHealth needs to analyze patient feedback and medical notes:

| Use Case | Service | Value |
|----------|---------|-------|
| Patient satisfaction | Sentiment Analysis | Track experience trends |
| Chief complaints | Key Phrase Extraction | Quick triage support |
| Medical coding | Entity Recognition | Automated ICD-10 suggestions |
| Multi-language support | Translation | Serve diverse patients |

---

## 🔧 Exercise 1: Sentiment Analysis

### Task 1.1: Basic Sentiment Analysis

```python
# sentiment_analysis.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
import os

def get_client():
    endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
    key = os.getenv("AZURE_LANGUAGE_KEY")
    return TextAnalyticsClient(endpoint, AzureKeyCredential(key))

def analyze_patient_feedback(feedback_list: list):
    """Analyze patient feedback for sentiment"""
    
    client = get_client()
    response = client.analyze_sentiment(feedback_list, show_opinion_mining=True)
    
    results = []
    for idx, doc in enumerate(response):
        if doc.is_error:
            results.append({"error": doc.error.message})
            continue
            
        result = {
            "text": feedback_list[idx][:50] + "...",
            "sentiment": doc.sentiment,
            "confidence": {
                "positive": doc.confidence_scores.positive,
                "neutral": doc.confidence_scores.neutral,
                "negative": doc.confidence_scores.negative
            },
            "sentences": [],
            "opinions": []
        }
        
        for sentence in doc.sentences:
            sentence_info = {
                "text": sentence.text,
                "sentiment": sentence.sentiment
            }
            result["sentences"].append(sentence_info)
            
            # Opinion mining (aspect-based sentiment)
            for mined_opinion in sentence.mined_opinions:
                target = mined_opinion.target
                for assessment in mined_opinion.assessments:
                    result["opinions"].append({
                        "target": target.text,
                        "assessment": assessment.text,
                        "sentiment": assessment.sentiment
                    })
        
        results.append(result)
    
    return results

# Test with patient feedback
if __name__ == "__main__":
    feedback = [
        "The doctor was very friendly and explained everything clearly. Wait time was long though.",
        "Terrible experience. Rude staff, dirty waiting room, and they lost my paperwork.",
        "Standard visit. Got my prescription renewed without issues.",
        "Dr. Smith is amazing! She really listens and takes time with each patient."
    ]
    
    results = analyze_patient_feedback(feedback)
    
    for r in results:
        print(f"\n{'='*60}")
        print(f"Text: {r.get('text', 'N/A')}")
        print(f"Overall Sentiment: {r.get('sentiment', 'N/A')}")
        
        if 'opinions' in r and r['opinions']:
            print("Opinions:")
            for op in r['opinions']:
                print(f"  - {op['target']}: {op['assessment']} ({op['sentiment']})")
```

### Expected Output:
```
============================================================
Text: The doctor was very friendly and explained everythi...
Overall Sentiment: mixed

Opinions:
  - doctor: friendly (positive)
  - Wait time: long (negative)

============================================================
Text: Terrible experience. Rude staff, dirty waiting room...
Overall Sentiment: negative

Opinions:
  - experience: Terrible (negative)
  - staff: Rude (negative)
  - waiting room: dirty (negative)
```

---

## 🔧 Exercise 2: Entity Recognition

### Task 2.1: Named Entity Recognition (NER)

```python
# entity_recognition.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
import os

def get_client():
    endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
    key = os.getenv("AZURE_LANGUAGE_KEY")
    return TextAnalyticsClient(endpoint, AzureKeyCredential(key))

def extract_entities(documents: list):
    """Extract named entities from text"""
    
    client = get_client()
    response = client.recognize_entities(documents)
    
    results = []
    for doc in response:
        if doc.is_error:
            results.append({"error": doc.error.message})
            continue
        
        entities = []
        for entity in doc.entities:
            entities.append({
                "text": entity.text,
                "category": entity.category,
                "subcategory": entity.subcategory,
                "confidence": entity.confidence_score
            })
        
        results.append({"entities": entities})
    
    return results

# Test with medical notes
if __name__ == "__main__":
    notes = [
        "Patient John Smith, DOB 03/15/1985, visited Dr. Sarah Johnson at City Hospital on January 15, 2024. "
        "Prescribed Metformin 500mg for Type 2 Diabetes. Follow-up scheduled in 3 months.",
        
        "Mary Wilson presented with chest pain radiating to left arm. ECG performed showed normal sinus rhythm. "
        "Troponin levels were within normal range. Patient advised to follow up with cardiologist Dr. Chen."
    ]
    
    results = extract_entities(notes)
    
    for idx, result in enumerate(results):
        print(f"\n{'='*60}")
        print(f"Document {idx + 1} Entities:")
        
        # Group by category
        by_category = {}
        for entity in result.get("entities", []):
            cat = entity["category"]
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(entity)
        
        for category, entities in by_category.items():
            print(f"\n  {category}:")
            for e in entities:
                subcat = f" ({e['subcategory']})" if e['subcategory'] else ""
                print(f"    - {e['text']}{subcat}: {e['confidence']:.0%}")
```

### Task 2.2: Healthcare Entity Recognition

```python
# healthcare_entities.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
import os

def analyze_healthcare_entities(documents: list):
    """Extract healthcare-specific entities from medical text"""
    
    endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
    key = os.getenv("AZURE_LANGUAGE_KEY")
    client = TextAnalyticsClient(endpoint, AzureKeyCredential(key))
    
    # Use healthcare-specific analysis
    poller = client.begin_analyze_healthcare_entities(documents)
    result = poller.result()
    
    for doc in result:
        if doc.is_error:
            print(f"Error: {doc.error}")
            continue
        
        print(f"\n{'='*60}")
        print("Healthcare Entities:")
        
        for entity in doc.entities:
            print(f"\n  Entity: {entity.text}")
            print(f"  Category: {entity.category}")
            if entity.normalized_text:
                print(f"  Normalized: {entity.normalized_text}")
            if entity.data_sources:
                for source in entity.data_sources:
                    print(f"  Code: {source.name} - {source.entity_id}")
        
        # Show relationships between entities
        if doc.entity_relations:
            print("\n  Relationships:")
            for relation in doc.entity_relations:
                print(f"  - {relation.relation_type}:")
                for role in relation.roles:
                    print(f"      {role.name}: {role.entity.text}")

# Test
if __name__ == "__main__":
    medical_notes = [
        "Patient diagnosed with Type 2 Diabetes Mellitus. Started on Metformin 500mg twice daily. "
        "Blood glucose levels were 180 mg/dL. A1C was 8.5%. Patient also has hypertension controlled "
        "with Lisinopril 10mg daily. Blood pressure today 132/84 mmHg."
    ]
    
    analyze_healthcare_entities(medical_notes)
```

---

## 🔧 Exercise 3: Key Phrase Extraction

### Task 3.1: Extract Key Phrases from Clinical Notes

```python
# key_phrases.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
import os

def extract_key_phrases(documents: list):
    """Extract key phrases from documents"""
    
    endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
    key = os.getenv("AZURE_LANGUAGE_KEY")
    client = TextAnalyticsClient(endpoint, AzureKeyCredential(key))
    
    response = client.extract_key_phrases(documents)
    
    results = []
    for doc in response:
        if doc.is_error:
            results.append({"error": doc.error.message})
        else:
            results.append({"key_phrases": doc.key_phrases})
    
    return results

# Example: Patient chief complaints triage
if __name__ == "__main__":
    chief_complaints = [
        "I've had this terrible headache for 3 days now, with nausea and sensitivity to light. "
        "The pain is throbbing and mostly on the right side of my head.",
        
        "My knee has been swelling since I fell playing basketball last week. "
        "It's hard to bend and hurts when I put weight on it.",
        
        "I've been feeling really tired lately, even after sleeping 8 hours. "
        "Also noticed I'm always thirsty and going to the bathroom frequently."
    ]
    
    results = extract_key_phrases(chief_complaints)
    
    for idx, result in enumerate(results):
        print(f"\n{'='*60}")
        print(f"Chief Complaint {idx + 1}:")
        print(f"  Key Phrases: {', '.join(result.get('key_phrases', []))}")
        
        # In real system, could trigger triage rules:
        phrases = result.get('key_phrases', [])
        if any('headache' in p.lower() for p in phrases):
            print("  ⚠️  Suggested: Neurology consult")
        if any('swelling' in p.lower() or 'knee' in p.lower() for p in phrases):
            print("  ⚠️  Suggested: Orthopedic evaluation")
        if any('thirsty' in p.lower() or 'tired' in p.lower() for p in phrases):
            print("  ⚠️  Suggested: Blood glucose screening")
```

---

## 🔧 Exercise 4: Language Detection and Translation

### Task 4.1: Detect Patient Communication Language

```python
# language_detection.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
import os

def detect_language(documents: list):
    """Detect the language of incoming text"""
    
    endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
    key = os.getenv("AZURE_LANGUAGE_KEY")
    client = TextAnalyticsClient(endpoint, AzureKeyCredential(key))
    
    response = client.detect_language(documents)
    
    results = []
    for doc in response:
        if doc.is_error:
            results.append({"error": doc.error.message})
        else:
            results.append({
                "language": doc.primary_language.name,
                "iso_code": doc.primary_language.iso6391_name,
                "confidence": doc.primary_language.confidence_score
            })
    
    return results

# Test
if __name__ == "__main__":
    messages = [
        "I need to schedule an appointment with Dr. Johnson.",
        "Necesito programar una cita con el médico lo antes posible.",
        "我想预约看医生，明天有空吗？",
        "J'ai besoin de renouveler mon ordonnance pour le diabète."
    ]
    
    results = detect_language(messages)
    
    for idx, result in enumerate(results):
        print(f"Message {idx + 1}: {result}")
```

### Task 4.2: Translation with Translator Service

```python
# translation.py
import os
import requests
import uuid

def translate_text(text: str, target_language: str, source_language: str = None):
    """Translate text using Azure Translator"""
    
    key = os.getenv("AZURE_TRANSLATOR_KEY")
    endpoint = os.getenv("AZURE_TRANSLATOR_ENDPOINT", "https://api.cognitive.microsofttranslator.com")
    region = os.getenv("AZURE_TRANSLATOR_REGION", "eastus")
    
    path = '/translate'
    url = endpoint + path
    
    params = {
        'api-version': '3.0',
        'to': target_language
    }
    if source_language:
        params['from'] = source_language
    
    headers = {
        'Ocp-Apim-Subscription-Key': key,
        'Ocp-Apim-Subscription-Region': region,
        'Content-type': 'application/json',
        'X-ClientTraceId': str(uuid.uuid4())
    }
    
    body = [{'text': text}]
    
    response = requests.post(url, params=params, headers=headers, json=body)
    response.raise_for_status()
    
    result = response.json()
    
    return {
        'detected_language': result[0].get('detectedLanguage', {}).get('language'),
        'translations': [
            {
                'language': t['to'],
                'text': t['text']
            }
            for t in result[0]['translations']
        ]
    }

# Example: Multilingual patient communication
if __name__ == "__main__":
    # Translate patient message to English
    spanish_message = "Tengo dolor de cabeza muy fuerte desde hace dos días."
    result = translate_text(spanish_message, target_language="en")
    
    print(f"Original: {spanish_message}")
    print(f"Detected: {result['detected_language']}")
    print(f"English: {result['translations'][0]['text']}")
    
    # Translate response back to patient's language
    english_response = "Please come to the emergency room if the headache persists or worsens."
    result = translate_text(english_response, target_language="es")
    
    print(f"\nResponse: {english_response}")
    print(f"Spanish: {result['translations'][0]['text']}")
```

---

## 🔧 Exercise 5: Custom Text Classification

### Task 5.1: Create Classification Project

```python
# custom_classification.py
"""
Custom text classification for medical document routing.

Before running this code, you need to:
1. Create a Language resource in Azure Portal
2. Go to Language Studio: https://language.cognitive.azure.com
3. Create a Custom Text Classification project
4. Label your training data
5. Train and deploy the model
"""

from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
import os

def classify_medical_documents(documents: list, project_name: str, deployment_name: str):
    """Classify documents using custom trained model"""
    
    endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
    key = os.getenv("AZURE_LANGUAGE_KEY")
    client = TextAnalyticsClient(endpoint, AzureKeyCredential(key))
    
    # Single-label classification
    poller = client.begin_single_label_classify(
        documents,
        project_name=project_name,
        deployment_name=deployment_name
    )
    
    results = []
    for doc in poller.result():
        if doc.is_error:
            results.append({"error": doc.error.message})
        else:
            results.append({
                "classification": doc.classifications[0].category,
                "confidence": doc.classifications[0].confidence_score
            })
    
    return results

# Example document routing categories:
# - LAB_RESULTS
# - PRESCRIPTION
# - REFERRAL
# - BILLING
# - PATIENT_CORRESPONDENCE

if __name__ == "__main__":
    # These would be classified by your custom model
    test_docs = [
        "Lab results for patient John Smith. CBC shows elevated WBC count of 12,500.",
        "Please refill Lisinopril 10mg, 90 day supply, 1 tablet daily.",
        "Referring patient to cardiology for chest pain evaluation.",
        "Invoice #12345 for office visit on 01/15/2024. Amount due: $125.00"
    ]
    
    # Uncomment when you have a trained model:
    # results = classify_medical_documents(
    #     test_docs,
    #     project_name="medical-doc-classifier",
    #     deployment_name="production"
    # )
    # print(results)
    
    print("Custom classification requires a trained model.")
    print("Visit Language Studio to create and train your model.")
```

---

## 🔧 Exercise 6: Building a Patient Communication Analyzer

### Complete Solution

```python
# patient_communication_analyzer.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
from dataclasses import dataclass
from typing import List, Optional
import os

@dataclass
class CommunicationAnalysis:
    """Analysis result for patient communication"""
    original_text: str
    detected_language: str
    translated_text: Optional[str]
    sentiment: str
    sentiment_scores: dict
    key_phrases: List[str]
    entities: List[dict]
    suggested_actions: List[str]

class PatientCommunicationAnalyzer:
    """
    Comprehensive analyzer for patient communications.
    Handles multilingual input, sentiment, entity extraction, and routing.
    """
    
    def __init__(self):
        endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
        key = os.getenv("AZURE_LANGUAGE_KEY")
        self.client = TextAnalyticsClient(endpoint, AzureKeyCredential(key))
        
        # Priority keywords for triage
        self.urgent_keywords = [
            "chest pain", "difficulty breathing", "severe pain",
            "bleeding", "unconscious", "allergic reaction"
        ]
        
        self.appointment_keywords = [
            "schedule", "appointment", "reschedule", "cancel",
            "available", "book"
        ]
        
        self.prescription_keywords = [
            "refill", "prescription", "medication", "pharmacy",
            "out of", "need more"
        ]
    
    def analyze(self, text: str, translate_to: str = "en") -> CommunicationAnalysis:
        """Perform comprehensive analysis of patient communication"""
        
        # Step 1: Detect language
        lang_result = self.client.detect_language([text])[0]
        detected_lang = lang_result.primary_language.iso6391_name
        
        # Step 2: Translate if needed
        translated = None
        analysis_text = text
        if detected_lang != translate_to:
            # Would use Translator API here
            translated = f"[Translation would be performed here]"
            # For analysis, we'll use original if English, otherwise skip some features
        
        # Step 3: Sentiment analysis
        sentiment_result = self.client.analyze_sentiment(
            [text], 
            show_opinion_mining=True
        )[0]
        
        # Step 4: Key phrase extraction
        phrases_result = self.client.extract_key_phrases([text])[0]
        key_phrases = phrases_result.key_phrases if not phrases_result.is_error else []
        
        # Step 5: Entity recognition
        entities_result = self.client.recognize_entities([text])[0]
        entities = []
        if not entities_result.is_error:
            for entity in entities_result.entities:
                entities.append({
                    "text": entity.text,
                    "category": entity.category,
                    "confidence": entity.confidence_score
                })
        
        # Step 6: Determine suggested actions
        suggested_actions = self._suggest_actions(text, key_phrases, sentiment_result.sentiment)
        
        return CommunicationAnalysis(
            original_text=text,
            detected_language=detected_lang,
            translated_text=translated,
            sentiment=sentiment_result.sentiment,
            sentiment_scores={
                "positive": sentiment_result.confidence_scores.positive,
                "neutral": sentiment_result.confidence_scores.neutral,
                "negative": sentiment_result.confidence_scores.negative
            },
            key_phrases=key_phrases,
            entities=entities,
            suggested_actions=suggested_actions
        )
    
    def _suggest_actions(self, text: str, phrases: list, sentiment: str) -> List[str]:
        """Suggest actions based on analysis"""
        
        actions = []
        text_lower = text.lower()
        phrases_lower = [p.lower() for p in phrases]
        
        # Check for urgent keywords
        for keyword in self.urgent_keywords:
            if keyword in text_lower or any(keyword in p for p in phrases_lower):
                actions.append("⚠️ URGENT: Route to triage nurse immediately")
                break
        
        # Check for appointment requests
        for keyword in self.appointment_keywords:
            if keyword in text_lower:
                actions.append("📅 Route to scheduling")
                break
        
        # Check for prescription requests
        for keyword in self.prescription_keywords:
            if keyword in text_lower:
                actions.append("💊 Route to pharmacy/prescriptions")
                break
        
        # Handle negative sentiment
        if sentiment == "negative":
            actions.append("😟 Patient may be frustrated - prioritize response")
        
        if not actions:
            actions.append("📋 Route to general inbox")
        
        return actions

# Test
if __name__ == "__main__":
    analyzer = PatientCommunicationAnalyzer()
    
    test_messages = [
        "I need to refill my blood pressure medication. I'm almost out.",
        "This is ridiculous! I've been waiting 2 hours and no one has called me back!",
        "I'm having severe chest pain and difficulty breathing.",
        "Can I schedule a follow-up appointment for next week?"
    ]
    
    for msg in test_messages:
        print(f"\n{'='*70}")
        result = analyzer.analyze(msg)
        
        print(f"Message: {result.original_text[:60]}...")
        print(f"Language: {result.detected_language}")
        print(f"Sentiment: {result.sentiment}")
        print(f"Key Phrases: {', '.join(result.key_phrases[:5])}")
        print(f"Actions:")
        for action in result.suggested_actions:
            print(f"  {action}")
```

---

## 🧹 Cleanup

```bash
# Delete Language resource
az cognitiveservices account delete \
  --name ai-intellihealth-language \
  --resource-group rg-ai102-learning
```

---

## ✅ Module Checklist

Before moving on, ensure you can:

- [ ] Analyze sentiment with opinion mining
- [ ] Extract named entities from text
- [ ] Use healthcare-specific entity recognition
- [ ] Extract key phrases for summarization
- [ ] Detect document language
- [ ] Translate text between languages
- [ ] Build custom text classification models
- [ ] Create comprehensive text analysis pipelines

---

## 📚 Additional Resources

- [Azure AI Language Documentation](https://learn.microsoft.com/en-us/azure/ai-services/language-service/)
- [Text Analytics API Reference](https://learn.microsoft.com/en-us/azure/ai-services/language-service/sentiment-opinion-mining/)
- [Language Studio](https://language.cognitive.azure.com/)
- [Healthcare NLP](https://learn.microsoft.com/en-us/azure/ai-services/language-service/text-analytics-for-health/)

---

**Next Module:** [Module 04: Azure OpenAI Service](../04-azure-openai/README.md)
