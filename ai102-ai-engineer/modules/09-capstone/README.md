# Module 09: Capstone Project

![Difficulty: Advanced](https://img.shields.io/badge/Difficulty-Advanced-red)
![Time: 8-10 hours](https://img.shields.io/badge/Time-8--10%20hours-blue)

## 🎯 Overview

This capstone project brings together all your AI-102 learning into a comprehensive, production-ready AI solution for IntelliHealth.

---

## 📖 The Challenge

### Project: IntelliHealth AI Platform

Build a complete AI-powered healthcare assistant that:
- Processes patient documents automatically
- Answers medical questions using knowledge bases
- Provides multilingual support
- Analyzes patient sentiment
- Maintains conversation context
- Follows responsible AI principles

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                  IntelliHealth AI Platform                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐         ┌─────────────────┐               │
│  │   Web/Mobile    │         │   Voice/Phone   │               │
│  │   Interface     │         │   Interface     │               │
│  └────────┬────────┘         └────────┬────────┘               │
│           │                           │                         │
│           ▼                           ▼                         │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    Bot Framework / API                       ││
│  └─────────────────────────┬───────────────────────────────────┘│
│                            │                                    │
│     ┌──────────────────────┼──────────────────────┐            │
│     │                      │                      │            │
│     ▼                      ▼                      ▼            │
│  ┌──────────┐      ┌──────────────┐      ┌──────────────┐     │
│  │ Language │      │  Azure       │      │  Document    │     │
│  │ Service  │      │  OpenAI      │      │ Intelligence │     │
│  │          │      │              │      │              │     │
│  │• QnA     │      │• GPT-4       │      │• OCR         │     │
│  │• Sentiment│     │• Embeddings  │      │• Extraction  │     │
│  │• NER     │      │• RAG         │      │• Custom      │     │
│  └──────────┘      └──────────────┘      └──────────────┘     │
│                            │                                    │
│                            ▼                                    │
│                    ┌──────────────┐                            │
│                    │  Azure AI    │                            │
│                    │   Search     │                            │
│                    │  (Vectors)   │                            │
│                    └──────────────┘                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Requirements

### Functional Requirements

1. **Document Processing**
   - Accept medical documents (invoices, forms, prescriptions)
   - Extract structured data automatically
   - Store extracted data for search

2. **Intelligent Q&A**
   - Answer patient questions about services, policies, medications
   - Use RAG for accurate, contextual answers
   - Cite sources in responses

3. **Multilingual Support**
   - Detect incoming language
   - Respond in patient's preferred language
   - Support English, Spanish, Chinese minimum

4. **Conversation Management**
   - Maintain context across turns
   - Handle appointment scheduling
   - Route complex issues to humans

5. **Analytics & Monitoring**
   - Track sentiment of patient interactions
   - Log all AI operations
   - Measure response quality

### Non-Functional Requirements

- Response time < 3 seconds
- 99.9% uptime
- HIPAA-compliant data handling
- Graceful degradation when services unavailable

---

## 🔧 Part 1: Core AI Services

### Task 1.1: Unified AI Client

```python
# ai_platform/core/ai_client.py
from azure.ai.textanalytics import TextAnalyticsClient
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.ai.language.questionanswering import QuestionAnsweringClient
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
from openai import AzureOpenAI
import os
from typing import Optional
from dataclasses import dataclass

@dataclass
class AIConfig:
    """Centralized AI configuration"""
    language_endpoint: str
    language_key: str
    document_endpoint: str
    document_key: str
    openai_endpoint: str
    openai_key: str
    search_endpoint: str
    search_key: str
    qna_project: str
    qna_deployment: str
    search_index: str

class UnifiedAIClient:
    """
    Unified client for all Azure AI services.
    Provides a single interface for the IntelliHealth platform.
    """
    
    def __init__(self, config: Optional[AIConfig] = None):
        if config is None:
            config = self._load_from_env()
        
        self.config = config
        self._init_clients()
    
    def _load_from_env(self) -> AIConfig:
        """Load configuration from environment"""
        return AIConfig(
            language_endpoint=os.getenv("AZURE_LANGUAGE_ENDPOINT"),
            language_key=os.getenv("AZURE_LANGUAGE_KEY"),
            document_endpoint=os.getenv("AZURE_DOCUMENT_ENDPOINT"),
            document_key=os.getenv("AZURE_DOCUMENT_KEY"),
            openai_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
            openai_key=os.getenv("AZURE_OPENAI_KEY"),
            search_endpoint=os.getenv("AZURE_SEARCH_ENDPOINT"),
            search_key=os.getenv("AZURE_SEARCH_KEY"),
            qna_project=os.getenv("AZURE_QNA_PROJECT", "intellihealth-faq"),
            qna_deployment=os.getenv("AZURE_QNA_DEPLOYMENT", "production"),
            search_index=os.getenv("AZURE_SEARCH_INDEX", "medical-knowledge")
        )
    
    def _init_clients(self):
        """Initialize all AI clients"""
        
        # Language services
        self.language_client = TextAnalyticsClient(
            self.config.language_endpoint,
            AzureKeyCredential(self.config.language_key)
        )
        
        # QnA
        self.qna_client = QuestionAnsweringClient(
            self.config.language_endpoint,
            AzureKeyCredential(self.config.language_key)
        )
        
        # Document Intelligence
        self.document_client = DocumentAnalysisClient(
            self.config.document_endpoint,
            AzureKeyCredential(self.config.document_key)
        )
        
        # Azure OpenAI
        self.openai_client = AzureOpenAI(
            azure_endpoint=self.config.openai_endpoint,
            api_key=self.config.openai_key,
            api_version="2024-02-15-preview"
        )
        
        # Search
        self.search_client = SearchClient(
            self.config.search_endpoint,
            self.config.search_index,
            AzureKeyCredential(self.config.search_key)
        )
    
    # Convenience methods
    def analyze_sentiment(self, text: str) -> dict:
        """Analyze text sentiment"""
        result = self.language_client.analyze_sentiment([text])[0]
        return {
            "sentiment": result.sentiment,
            "scores": {
                "positive": result.confidence_scores.positive,
                "neutral": result.confidence_scores.neutral,
                "negative": result.confidence_scores.negative
            }
        }
    
    def detect_language(self, text: str) -> str:
        """Detect text language"""
        result = self.language_client.detect_language([text])[0]
        return result.primary_language.iso6391_name
    
    def get_embedding(self, text: str) -> list:
        """Generate text embedding"""
        response = self.openai_client.embeddings.create(
            model="text-embedding-ada-002",
            input=text
        )
        return response.data[0].embedding
    
    def chat(self, messages: list, temperature: float = 0.7) -> str:
        """Get chat completion"""
        response = self.openai_client.chat.completions.create(
            model="gpt-4",
            messages=messages,
            temperature=temperature
        )
        return response.choices[0].message.content
```

---

## 🔧 Part 2: Document Processing Pipeline

### Task 2.1: Document Processor

```python
# ai_platform/document/processor.py
from dataclasses import dataclass
from typing import List, Dict, Any, Optional
from enum import Enum
from datetime import datetime
import json

class DocumentType(Enum):
    INVOICE = "invoice"
    PRESCRIPTION = "prescription"
    PATIENT_FORM = "patient_form"
    LAB_RESULT = "lab_result"
    INSURANCE_CARD = "insurance_card"
    UNKNOWN = "unknown"

@dataclass
class ProcessedDocument:
    """Result of document processing"""
    document_id: str
    document_type: DocumentType
    extracted_data: Dict[str, Any]
    confidence: float
    processing_time: float
    raw_text: str
    page_count: int
    warnings: List[str]

class DocumentProcessor:
    """
    Document processing pipeline for IntelliHealth.
    Automatically classifies and extracts data from medical documents.
    """
    
    def __init__(self, ai_client):
        self.ai_client = ai_client
        
        # Model mappings
        self.model_map = {
            DocumentType.INVOICE: "prebuilt-invoice",
            DocumentType.PRESCRIPTION: "prebuilt-document",
            DocumentType.INSURANCE_CARD: "prebuilt-healthInsuranceCard.us",
            DocumentType.PATIENT_FORM: "prebuilt-document",
            DocumentType.LAB_RESULT: "prebuilt-document",
            DocumentType.UNKNOWN: "prebuilt-document"
        }
    
    def process(self, document_url: str, document_type: DocumentType = None) -> ProcessedDocument:
        """Process a document"""
        
        start_time = datetime.now()
        warnings = []
        
        # Auto-detect type if not provided
        if document_type is None:
            document_type = self._classify_document(document_url)
            warnings.append(f"Auto-detected document type: {document_type.value}")
        
        # Get appropriate model
        model_id = self.model_map.get(document_type, "prebuilt-document")
        
        # Process document
        poller = self.ai_client.document_client.begin_analyze_document_from_url(
            model_id,
            document_url
        )
        result = poller.result()
        
        # Extract data
        extracted_data = self._extract_data(result, document_type)
        
        # Get raw text
        raw_text = self._get_raw_text(result)
        
        # Calculate confidence
        confidence = self._calculate_confidence(result)
        
        processing_time = (datetime.now() - start_time).total_seconds()
        
        return ProcessedDocument(
            document_id=f"DOC-{datetime.now().strftime('%Y%m%d%H%M%S')}",
            document_type=document_type,
            extracted_data=extracted_data,
            confidence=confidence,
            processing_time=processing_time,
            raw_text=raw_text,
            page_count=len(result.pages),
            warnings=warnings
        )
    
    def _classify_document(self, document_url: str) -> DocumentType:
        """Classify document type using layout analysis"""
        
        poller = self.ai_client.document_client.begin_analyze_document_from_url(
            "prebuilt-layout",
            document_url
        )
        result = poller.result()
        
        # Get text content
        text = self._get_raw_text(result).lower()
        
        # Simple classification based on keywords
        if "invoice" in text or "amount due" in text or "bill to" in text:
            return DocumentType.INVOICE
        elif "prescription" in text or "rx" in text or "pharmacy" in text:
            return DocumentType.PRESCRIPTION
        elif "insurance" in text or "member id" in text or "group" in text:
            return DocumentType.INSURANCE_CARD
        elif "lab" in text or "result" in text or "specimen" in text:
            return DocumentType.LAB_RESULT
        elif "patient" in text and "form" in text:
            return DocumentType.PATIENT_FORM
        
        return DocumentType.UNKNOWN
    
    def _extract_data(self, result, doc_type: DocumentType) -> dict:
        """Extract relevant data based on document type"""
        
        data = {}
        
        if result.documents:
            doc = result.documents[0]
            for field_name, field in doc.fields.items():
                if field.value is not None:
                    data[field_name] = {
                        "value": str(field.value),
                        "confidence": field.confidence
                    }
        
        return data
    
    def _get_raw_text(self, result) -> str:
        """Extract all text from document"""
        lines = []
        for page in result.pages:
            for line in page.lines:
                lines.append(line.content)
        return "\n".join(lines)
    
    def _calculate_confidence(self, result) -> float:
        """Calculate overall confidence score"""
        if result.documents:
            return result.documents[0].confidence
        return 0.0
    
    def index_document(self, doc: ProcessedDocument):
        """Index processed document for search"""
        
        # Generate embedding for the content
        embedding = self.ai_client.get_embedding(doc.raw_text[:8000])  # Limit text length
        
        # Create search document
        search_doc = {
            "id": doc.document_id,
            "title": f"{doc.document_type.value.title()} - {doc.document_id}",
            "content": doc.raw_text,
            "contentVector": embedding,
            "category": doc.document_type.value,
            "extracted_data": json.dumps(doc.extracted_data),
            "indexed_date": datetime.now().isoformat()
        }
        
        self.ai_client.search_client.upload_documents([search_doc])
        print(f"Indexed document: {doc.document_id}")
```

---

## 🔧 Part 3: Intelligent Q&A System

### Task 3.1: RAG-Powered Q&A

```python
# ai_platform/qa/rag_system.py
from dataclasses import dataclass
from typing import List, Optional
from azure.search.documents.models import VectorizedQuery

@dataclass
class QAResult:
    """Result from Q&A system"""
    answer: str
    sources: List[dict]
    confidence: float
    method: str  # "qna", "rag", or "generative"

class IntelliHealthQA:
    """
    Intelligent Q&A system with multiple answer strategies.
    """
    
    def __init__(self, ai_client):
        self.ai_client = ai_client
        
        self.system_prompt = """You are IntelliHealth's medical information assistant.

Guidelines:
1. Provide accurate, helpful health information
2. Always cite your sources using [1], [2], etc.
3. Recommend consulting a healthcare provider for personal medical advice
4. If unsure, acknowledge uncertainty
5. For emergencies, direct to call 911

Be concise, empathetic, and professional."""
    
    def answer(self, question: str, user_language: str = "en") -> QAResult:
        """Answer a question using the best available method"""
        
        # Strategy 1: Try QnA knowledge base first
        qna_result = self._try_qna(question)
        if qna_result and qna_result.confidence > 0.7:
            return qna_result
        
        # Strategy 2: Use RAG with search
        rag_result = self._try_rag(question)
        if rag_result and rag_result.confidence > 0.5:
            return rag_result
        
        # Strategy 3: Fall back to generative (with guardrails)
        return self._generative_answer(question)
    
    def _try_qna(self, question: str) -> Optional[QAResult]:
        """Try to answer from QnA knowledge base"""
        
        try:
            response = self.ai_client.qna_client.get_answers(
                project_name=self.ai_client.config.qna_project,
                deployment_name=self.ai_client.config.qna_deployment,
                question=question,
                top=1
            )
            
            if response.answers and response.answers[0].confidence > 0.5:
                answer = response.answers[0]
                return QAResult(
                    answer=answer.answer,
                    sources=[{"type": "knowledge_base", "id": answer.qna_id}],
                    confidence=answer.confidence,
                    method="qna"
                )
        except Exception as e:
            print(f"QnA error: {e}")
        
        return None
    
    def _try_rag(self, question: str) -> Optional[QAResult]:
        """Try to answer using RAG with vector search"""
        
        try:
            # Get question embedding
            query_vector = self.ai_client.get_embedding(question)
            
            # Search for relevant documents
            vector_query = VectorizedQuery(
                vector=query_vector,
                k_nearest_neighbors=5,
                fields="contentVector"
            )
            
            results = self.ai_client.search_client.search(
                search_text=question,
                vector_queries=[vector_query],
                select=["id", "title", "content", "category"],
                top=5
            )
            
            sources = []
            context_parts = []
            
            for result in results:
                sources.append({
                    "type": "document",
                    "id": result["id"],
                    "title": result["title"],
                    "score": result["@search.score"]
                })
                context_parts.append(f"[{len(sources)}] {result['title']}\n{result['content'][:500]}")
            
            if not sources:
                return None
            
            context = "\n\n".join(context_parts)
            
            # Generate answer
            messages = [
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": f"Context:\n{context}\n\nQuestion: {question}"}
            ]
            
            answer = self.ai_client.chat(messages, temperature=0.3)
            
            avg_score = sum(s["score"] for s in sources) / len(sources)
            
            return QAResult(
                answer=answer,
                sources=sources,
                confidence=min(avg_score, 1.0),
                method="rag"
            )
            
        except Exception as e:
            print(f"RAG error: {e}")
        
        return None
    
    def _generative_answer(self, question: str) -> QAResult:
        """Fall back to generative answer with strong guardrails"""
        
        guardrail_prompt = """Important: You are answering without specific context.
        
Rules for this response:
- Be extra cautious about medical claims
- Strongly recommend consulting a healthcare provider
- Do not provide specific dosages or treatment recommendations
- Keep the response general and educational
- Clearly state this is general information only"""
        
        messages = [
            {"role": "system", "content": self.system_prompt + "\n\n" + guardrail_prompt},
            {"role": "user", "content": question}
        ]
        
        answer = self.ai_client.chat(messages, temperature=0.5)
        
        disclaimer = "\n\n⚠️ *This is general information only. Please consult a healthcare provider for personal medical advice.*"
        
        return QAResult(
            answer=answer + disclaimer,
            sources=[],
            confidence=0.3,  # Low confidence for generative
            method="generative"
        )
```

---

## 🔧 Part 4: Conversational Interface

### Task 4.1: Conversation Manager

```python
# ai_platform/conversation/manager.py
from dataclasses import dataclass, field
from typing import List, Optional, Dict
from datetime import datetime
from enum import Enum

class ConversationState(Enum):
    GREETING = "greeting"
    QUESTION_ANSWERING = "qa"
    APPOINTMENT_BOOKING = "appointment"
    PRESCRIPTION_REFILL = "prescription"
    ESCALATION = "escalation"
    CLOSING = "closing"

@dataclass
class Message:
    """Single message in conversation"""
    role: str  # "user" or "assistant"
    content: str
    timestamp: datetime
    language: str = "en"
    sentiment: Optional[str] = None

@dataclass
class Conversation:
    """Full conversation context"""
    id: str
    user_id: str
    messages: List[Message] = field(default_factory=list)
    state: ConversationState = ConversationState.GREETING
    language: str = "en"
    metadata: Dict = field(default_factory=dict)

class ConversationManager:
    """
    Manages conversation context and flow for IntelliHealth.
    """
    
    def __init__(self, ai_client, qa_system):
        self.ai_client = ai_client
        self.qa_system = qa_system
        self.conversations: Dict[str, Conversation] = {}
        
        # Emergency keywords
        self.emergency_keywords = [
            "heart attack", "can't breathe", "chest pain",
            "severe bleeding", "unconscious", "overdose",
            "suicide", "kill myself", "emergency"
        ]
    
    def process_message(self, conversation_id: str, user_id: str, message: str) -> str:
        """Process incoming message and generate response"""
        
        # Get or create conversation
        if conversation_id not in self.conversations:
            self.conversations[conversation_id] = Conversation(
                id=conversation_id,
                user_id=user_id
            )
        
        conv = self.conversations[conversation_id]
        
        # Detect language
        detected_lang = self.ai_client.detect_language(message)
        if conv.language == "en" and detected_lang != "en":
            conv.language = detected_lang
        
        # Analyze sentiment
        sentiment = self.ai_client.analyze_sentiment(message)
        
        # Add user message
        conv.messages.append(Message(
            role="user",
            content=message,
            timestamp=datetime.now(),
            language=detected_lang,
            sentiment=sentiment["sentiment"]
        ))
        
        # Check for emergency
        if self._is_emergency(message):
            return self._handle_emergency(conv)
        
        # Check for escalation triggers
        if self._should_escalate(conv, sentiment):
            return self._handle_escalation(conv)
        
        # Route based on intent
        response = self._route_message(conv, message)
        
        # Add assistant message
        conv.messages.append(Message(
            role="assistant",
            content=response,
            timestamp=datetime.now(),
            language=conv.language
        ))
        
        return response
    
    def _is_emergency(self, message: str) -> bool:
        """Check for emergency keywords"""
        message_lower = message.lower()
        return any(kw in message_lower for kw in self.emergency_keywords)
    
    def _handle_emergency(self, conv: Conversation) -> str:
        """Handle emergency situation"""
        conv.state = ConversationState.ESCALATION
        
        return """🚨 **EMERGENCY DETECTED**

If this is a medical emergency:
1. **Call 911 immediately**
2. Go to your nearest emergency room

If you're having thoughts of self-harm:
• **National Suicide Prevention Lifeline: 988**
• **Crisis Text Line: Text HOME to 741741**

Help is available 24/7. You are not alone."""
    
    def _should_escalate(self, conv: Conversation, sentiment: dict) -> bool:
        """Determine if conversation should escalate to human"""
        
        # Escalate if consistently negative
        negative_count = sum(
            1 for m in conv.messages[-5:] 
            if m.sentiment == "negative"
        )
        
        if negative_count >= 3:
            return True
        
        # Escalate if conversation is long without resolution
        if len(conv.messages) > 10 and conv.state == ConversationState.QUESTION_ANSWERING:
            return True
        
        return False
    
    def _handle_escalation(self, conv: Conversation) -> str:
        """Escalate to human support"""
        conv.state = ConversationState.ESCALATION
        
        return """I want to make sure you get the help you need.

Let me connect you with a member of our team who can assist you further.

**Options:**
1. 📞 Call us: (555) 123-4567
2. 💬 Live chat: A representative will join this conversation shortly
3. 📧 Email: support@intellihealth.com

Our team is available Mon-Fri, 8 AM - 5 PM.

Is there anything else I can help clarify in the meantime?"""
    
    def _route_message(self, conv: Conversation, message: str) -> str:
        """Route message to appropriate handler"""
        
        message_lower = message.lower()
        
        # Check for appointment-related
        if any(kw in message_lower for kw in ["appointment", "schedule", "book", "visit"]):
            conv.state = ConversationState.APPOINTMENT_BOOKING
            return self._handle_appointment(conv, message)
        
        # Check for prescription-related
        if any(kw in message_lower for kw in ["prescription", "refill", "medication", "rx"]):
            conv.state = ConversationState.PRESCRIPTION_REFILL
            return self._handle_prescription(conv, message)
        
        # Default: Q&A
        conv.state = ConversationState.QUESTION_ANSWERING
        result = self.qa_system.answer(message, conv.language)
        return result.answer
    
    def _handle_appointment(self, conv: Conversation, message: str) -> str:
        """Handle appointment-related requests"""
        return """I can help you schedule an appointment! 📅

To book your appointment, please:
1. **Online:** Visit our patient portal at portal.intellihealth.com
2. **Phone:** Call (555) 123-4567

Or tell me more about what type of appointment you need:
• General checkup
• Follow-up visit
• New patient consultation
• Specialist referral"""
    
    def _handle_prescription(self, conv: Conversation, message: str) -> str:
        """Handle prescription-related requests"""
        return """I can help with your prescription! 💊

For prescription refills:
1. **Patient Portal:** Log in and request refill online
2. **Phone:** Call our pharmacy line at (555) 123-4568
3. **App:** Use the IntelliHealth mobile app

Please allow 48 hours for processing. If you're out of medication urgently, please call us directly.

Which medication do you need refilled?"""
    
    def get_conversation_summary(self, conversation_id: str) -> dict:
        """Get conversation summary for analytics"""
        
        if conversation_id not in self.conversations:
            return {}
        
        conv = self.conversations[conversation_id]
        
        sentiments = [m.sentiment for m in conv.messages if m.sentiment]
        
        return {
            "id": conv.id,
            "user_id": conv.user_id,
            "message_count": len(conv.messages),
            "duration_seconds": (conv.messages[-1].timestamp - conv.messages[0].timestamp).total_seconds() if len(conv.messages) > 1 else 0,
            "primary_language": conv.language,
            "final_state": conv.state.value,
            "sentiment_summary": {
                "positive": sentiments.count("positive"),
                "neutral": sentiments.count("neutral"),
                "negative": sentiments.count("negative")
            }
        }
```

---

## 🔧 Part 5: API and Deployment

### Task 5.1: REST API

```python
# ai_platform/api/main.py
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import Optional, List
import uuid

# Import our modules
from ..core.ai_client import UnifiedAIClient
from ..document.processor import DocumentProcessor, DocumentType
from ..qa.rag_system import IntelliHealthQA
from ..conversation.manager import ConversationManager

app = FastAPI(title="IntelliHealth AI Platform", version="1.0.0")

# Initialize services
ai_client = UnifiedAIClient()
document_processor = DocumentProcessor(ai_client)
qa_system = IntelliHealthQA(ai_client)
conversation_manager = ConversationManager(ai_client, qa_system)

# Request/Response models
class ChatRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = None
    user_id: str

class ChatResponse(BaseModel):
    response: str
    conversation_id: str
    detected_language: str

class DocumentRequest(BaseModel):
    document_url: str
    document_type: Optional[str] = None

class QuestionRequest(BaseModel):
    question: str
    language: Optional[str] = "en"

# Endpoints
@app.post("/api/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Process chat message"""
    
    conversation_id = request.conversation_id or str(uuid.uuid4())
    
    response = conversation_manager.process_message(
        conversation_id=conversation_id,
        user_id=request.user_id,
        message=request.message
    )
    
    conv = conversation_manager.conversations.get(conversation_id)
    
    return ChatResponse(
        response=response,
        conversation_id=conversation_id,
        detected_language=conv.language if conv else "en"
    )

@app.post("/api/documents/process")
async def process_document(request: DocumentRequest, background_tasks: BackgroundTasks):
    """Process a medical document"""
    
    doc_type = None
    if request.document_type:
        try:
            doc_type = DocumentType(request.document_type)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid document type")
    
    result = document_processor.process(request.document_url, doc_type)
    
    # Index in background
    background_tasks.add_task(document_processor.index_document, result)
    
    return {
        "document_id": result.document_id,
        "document_type": result.document_type.value,
        "confidence": result.confidence,
        "extracted_data": result.extracted_data,
        "processing_time": result.processing_time,
        "page_count": result.page_count,
        "warnings": result.warnings
    }

@app.post("/api/qa")
async def ask_question(request: QuestionRequest):
    """Answer a medical question"""
    
    result = qa_system.answer(request.question, request.language)
    
    return {
        "answer": result.answer,
        "confidence": result.confidence,
        "method": result.method,
        "sources": result.sources
    }

@app.get("/api/conversations/{conversation_id}/summary")
async def get_conversation_summary(conversation_id: str):
    """Get conversation analytics"""
    
    summary = conversation_manager.get_conversation_summary(conversation_id)
    
    if not summary:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    return summary

@app.get("/api/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "version": "1.0.0"}
```

---

## 📋 Deliverables Checklist

### Core Components
- [ ] Unified AI Client with all service integrations
- [ ] Document Processing Pipeline
- [ ] RAG-powered Q&A System
- [ ] Conversation Manager with state handling
- [ ] REST API with all endpoints

### Features
- [ ] Automatic document classification
- [ ] Multi-strategy answer generation (QnA → RAG → Generative)
- [ ] Language detection and multilingual support
- [ ] Sentiment tracking and escalation
- [ ] Emergency detection and handling

### Production Readiness
- [ ] Error handling throughout
- [ ] Logging and monitoring hooks
- [ ] Graceful degradation
- [ ] API documentation (Swagger)

### Documentation
- [ ] Architecture diagram
- [ ] API documentation
- [ ] Deployment guide
- [ ] Operations runbook

---

## 🧹 Cleanup

```bash
# Delete all resources
az group delete \
  --name rg-ai102-learning \
  --yes --no-wait

echo "All resources scheduled for deletion."
```

---

## 🏆 Completion

Congratulations on completing the AI-102 Portfolio Project! 🎉

You've built a comprehensive AI platform demonstrating:
- Azure AI Service integration
- Document Intelligence processing
- Advanced NLP and language understanding
- Azure OpenAI and prompt engineering
- RAG patterns with vector search
- Conversational AI with state management
- Production API development

This project showcases skills directly relevant to the AI-102 certification and real-world AI engineering.

---

## 📚 Next Steps

1. **Deploy to Azure** - Use Azure Container Apps or App Service
2. **Add Authentication** - Integrate Azure AD B2C
3. **Enhance Monitoring** - Add Application Insights
4. **Scale** - Implement caching and optimize performance
5. **Expand** - Add more document types and capabilities

Good luck on your AI-102 exam! 🚀
