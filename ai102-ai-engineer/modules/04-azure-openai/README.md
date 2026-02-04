# Module 04: Azure OpenAI Service

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 5-6 hours](https://img.shields.io/badge/Time-5--6%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will:
- Deploy and configure Azure OpenAI models
- Master prompt engineering techniques
- Implement RAG (Retrieval Augmented Generation)
- Apply responsible AI practices
- Build production-ready GPT applications

---

## 📖 The IntelliHealth Scenario

IntelliHealth wants to leverage generative AI for:

| Use Case | Model | Value |
|----------|-------|-------|
| Medical Q&A assistant | GPT-4 | Patient education |
| Clinical note summarization | GPT-4 | Time savings |
| Document drafting | GPT-4 | Administrative efficiency |
| Medical literature search | Embeddings | Research acceleration |

---

## ⚠️ Prerequisites

**Azure OpenAI requires approval!**
1. Apply at: https://aka.ms/oai/access
2. Approval typically takes 1-2 business days
3. Requires a valid business use case

---

## 🔧 Exercise 1: Setting Up Azure OpenAI

### Task 1.1: Create Azure OpenAI Resource

```bash
# Create Azure OpenAI resource (requires approval)
az cognitiveservices account create \
  --name ai-intellihealth-openai \
  --resource-group rg-ai102-learning \
  --kind OpenAI \
  --sku S0 \
  --location eastus \
  --yes

# Get endpoint
az cognitiveservices account show \
  --name ai-intellihealth-openai \
  --resource-group rg-ai102-learning \
  --query "properties.endpoint" -o tsv

# Get key
az cognitiveservices account keys list \
  --name ai-intellihealth-openai \
  --resource-group rg-ai102-learning
```

### Task 1.2: Deploy a Model

```bash
# Deploy GPT-4 model
az cognitiveservices account deployment create \
  --name ai-intellihealth-openai \
  --resource-group rg-ai102-learning \
  --deployment-name gpt-4 \
  --model-name gpt-4 \
  --model-version "0613" \
  --model-format OpenAI \
  --sku-name Standard \
  --sku-capacity 10

# Deploy embedding model
az cognitiveservices account deployment create \
  --name ai-intellihealth-openai \
  --resource-group rg-ai102-learning \
  --deployment-name text-embedding-ada-002 \
  --model-name text-embedding-ada-002 \
  --model-version "2" \
  --model-format OpenAI \
  --sku-name Standard \
  --sku-capacity 10
```

### Task 1.3: Install SDK

```bash
pip install openai
pip install tiktoken  # For token counting
```

### Task 1.4: Basic Configuration

```python
# openai_config.py
import os
from openai import AzureOpenAI

def get_openai_client():
    """Create Azure OpenAI client"""
    return AzureOpenAI(
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
        api_key=os.getenv("AZURE_OPENAI_KEY"),
        api_version="2024-02-15-preview"
    )

# Model deployment names
GPT4_DEPLOYMENT = "gpt-4"
EMBEDDING_DEPLOYMENT = "text-embedding-ada-002"
```

---

## 🔧 Exercise 2: Basic Chat Completions

### Task 2.1: Simple Chat

```python
# basic_chat.py
from openai_config import get_openai_client, GPT4_DEPLOYMENT

def chat(user_message: str, system_prompt: str = None):
    """Simple chat completion"""
    
    client = get_openai_client()
    
    messages = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
    messages.append({"role": "user", "content": user_message})
    
    response = client.chat.completions.create(
        model=GPT4_DEPLOYMENT,
        messages=messages,
        temperature=0.7,
        max_tokens=500
    )
    
    return response.choices[0].message.content

# Test
if __name__ == "__main__":
    # Simple question
    response = chat("What are the symptoms of Type 2 Diabetes?")
    print(response)
```

### Task 2.2: Conversation with History

```python
# conversation.py
from openai_config import get_openai_client, GPT4_DEPLOYMENT

class ConversationManager:
    """Manage multi-turn conversations"""
    
    def __init__(self, system_prompt: str = None):
        self.client = get_openai_client()
        self.messages = []
        
        if system_prompt:
            self.messages.append({
                "role": "system",
                "content": system_prompt
            })
    
    def chat(self, user_message: str) -> str:
        """Send message and get response"""
        
        self.messages.append({
            "role": "user",
            "content": user_message
        })
        
        response = self.client.chat.completions.create(
            model=GPT4_DEPLOYMENT,
            messages=self.messages,
            temperature=0.7,
            max_tokens=500
        )
        
        assistant_message = response.choices[0].message.content
        
        self.messages.append({
            "role": "assistant",
            "content": assistant_message
        })
        
        return assistant_message
    
    def clear_history(self):
        """Clear conversation history (keep system prompt)"""
        if self.messages and self.messages[0]["role"] == "system":
            self.messages = [self.messages[0]]
        else:
            self.messages = []

# Test
if __name__ == "__main__":
    conv = ConversationManager(
        system_prompt="You are a helpful medical information assistant. "
                      "Always recommend consulting a healthcare provider."
    )
    
    print("Assistant:", conv.chat("What is hypertension?"))
    print("\n---\n")
    print("Assistant:", conv.chat("What are the treatment options?"))
    print("\n---\n")
    print("Assistant:", conv.chat("Can lifestyle changes help?"))
```

---

## 🔧 Exercise 3: Prompt Engineering

### Task 3.1: System Prompts for Healthcare

```python
# healthcare_prompts.py

# Medical Information Assistant
MEDICAL_INFO_PROMPT = """
You are IntelliHealth's Medical Information Assistant. Your role is to provide 
accurate, helpful health information while being appropriately cautious.

Guidelines:
1. Provide evidence-based information when available
2. Always recommend consulting a healthcare provider for personal medical advice
3. Never diagnose conditions or prescribe treatments
4. Be empathetic and supportive
5. If unsure, acknowledge uncertainty
6. For emergencies, direct to call 911 or go to the nearest ER

Format responses clearly with:
- Brief explanation
- Key points as bullet points when helpful
- Appropriate disclaimers
"""

# Clinical Note Summarizer
CLINICAL_SUMMARIZER_PROMPT = """
You are a clinical documentation specialist. Summarize medical notes following 
this structure:

1. **Chief Complaint**: Primary reason for visit
2. **Key Findings**: Relevant examination/test results  
3. **Assessment**: Working diagnosis or differential
4. **Plan**: Treatment and follow-up recommendations

Rules:
- Use standard medical terminology
- Be concise but complete
- Preserve all clinically relevant information
- Flag any critical values or urgent findings
"""

# Patient Communication Writer
PATIENT_COMM_PROMPT = """
You are a healthcare communication specialist. Write patient-friendly 
communications that are:

1. Written at a 6th-grade reading level
2. Free of medical jargon (or explain terms when necessary)
3. Empathetic and supportive in tone
4. Clear about next steps
5. Culturally sensitive
"""
```

### Task 3.2: Few-Shot Prompting

```python
# few_shot_prompting.py
from openai_config import get_openai_client, GPT4_DEPLOYMENT

def extract_medication_info(text: str) -> str:
    """Extract medication information using few-shot learning"""
    
    client = get_openai_client()
    
    messages = [
        {
            "role": "system",
            "content": "Extract medication information from clinical notes. "
                       "Return structured JSON for each medication found."
        },
        {
            "role": "user",
            "content": "Patient started on Metformin 500mg twice daily with meals."
        },
        {
            "role": "assistant",
            "content": """```json
{
    "medications": [
        {
            "name": "Metformin",
            "dose": "500mg",
            "frequency": "twice daily",
            "instructions": "with meals",
            "action": "started"
        }
    ]
}
```"""
        },
        {
            "role": "user",
            "content": "Increased Lisinopril from 10mg to 20mg daily. Discontinued Amlodipine 5mg."
        },
        {
            "role": "assistant",
            "content": """```json
{
    "medications": [
        {
            "name": "Lisinopril",
            "dose": "20mg",
            "frequency": "daily",
            "instructions": null,
            "action": "increased",
            "previous_dose": "10mg"
        },
        {
            "name": "Amlodipine",
            "dose": "5mg",
            "frequency": null,
            "instructions": null,
            "action": "discontinued"
        }
    ]
}
```"""
        },
        {
            "role": "user",
            "content": text
        }
    ]
    
    response = client.chat.completions.create(
        model=GPT4_DEPLOYMENT,
        messages=messages,
        temperature=0,  # Lower temperature for structured output
        max_tokens=500
    )
    
    return response.choices[0].message.content

# Test
if __name__ == "__main__":
    note = """
    Patient's blood pressure still elevated. 
    Adding Hydrochlorothiazide 25mg once daily in the morning.
    Continue current Metoprolol 50mg twice daily.
    Will recheck BP in 2 weeks.
    """
    
    result = extract_medication_info(note)
    print(result)
```

### Task 3.3: Chain of Thought Prompting

```python
# chain_of_thought.py
from openai_config import get_openai_client, GPT4_DEPLOYMENT

def clinical_reasoning(symptoms: str) -> str:
    """Use chain-of-thought for clinical reasoning"""
    
    client = get_openai_client()
    
    system_prompt = """
You are a clinical decision support system. When given symptoms, think through 
the differential diagnosis step by step.

IMPORTANT: This is for educational purposes only. Always recommend professional 
medical evaluation.

Structure your response as:
1. **Initial Assessment**: Summarize the key symptoms
2. **Reasoning**: Think through each symptom and what it might indicate
3. **Differential Diagnosis**: List possible conditions from most to least likely
4. **Recommended Workup**: Suggest tests or evaluations
5. **Red Flags**: Identify any urgent/emergent concerns
"""
    
    response = client.chat.completions.create(
        model=GPT4_DEPLOYMENT,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Patient presents with: {symptoms}"}
        ],
        temperature=0.3,
        max_tokens=1000
    )
    
    return response.choices[0].message.content

# Test
if __name__ == "__main__":
    symptoms = """
    45-year-old male presenting with:
    - Substernal chest pressure for 2 hours
    - Radiating to left arm
    - Associated with shortness of breath
    - Diaphoresis (sweating)
    - History of hypertension and diabetes
    """
    
    print(clinical_reasoning(symptoms))
```

---

## 🔧 Exercise 4: RAG (Retrieval Augmented Generation)

### Task 4.1: Create Embeddings

```python
# embeddings.py
from openai_config import get_openai_client, EMBEDDING_DEPLOYMENT
import numpy as np

def get_embedding(text: str) -> list:
    """Generate embedding for text"""
    
    client = get_openai_client()
    
    response = client.embeddings.create(
        model=EMBEDDING_DEPLOYMENT,
        input=text
    )
    
    return response.data[0].embedding

def cosine_similarity(vec1: list, vec2: list) -> float:
    """Calculate cosine similarity between two vectors"""
    
    a = np.array(vec1)
    b = np.array(vec2)
    
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

# Test
if __name__ == "__main__":
    # Create embeddings for medical concepts
    concepts = [
        "high blood pressure treatment options",
        "hypertension management guidelines",
        "diabetes blood sugar control",
        "heart attack symptoms"
    ]
    
    embeddings = [get_embedding(c) for c in concepts]
    
    # Find most similar to query
    query = "How to manage high blood pressure?"
    query_embedding = get_embedding(query)
    
    similarities = [cosine_similarity(query_embedding, e) for e in embeddings]
    
    print(f"Query: {query}\n")
    for concept, sim in zip(concepts, similarities):
        print(f"  {sim:.4f} - {concept}")
```

### Task 4.2: Simple RAG Implementation

```python
# simple_rag.py
from openai_config import get_openai_client, GPT4_DEPLOYMENT, EMBEDDING_DEPLOYMENT
import numpy as np

class SimpleRAG:
    """
    Simple RAG implementation for IntelliHealth knowledge base.
    In production, use Azure AI Search or a vector database.
    """
    
    def __init__(self):
        self.client = get_openai_client()
        self.documents = []
        self.embeddings = []
    
    def add_documents(self, documents: list):
        """Add documents to the knowledge base"""
        
        for doc in documents:
            embedding = self._get_embedding(doc)
            self.documents.append(doc)
            self.embeddings.append(embedding)
    
    def _get_embedding(self, text: str) -> list:
        """Get embedding for text"""
        
        response = self.client.embeddings.create(
            model=EMBEDDING_DEPLOYMENT,
            input=text
        )
        return response.data[0].embedding
    
    def _find_relevant_docs(self, query: str, top_k: int = 3) -> list:
        """Find most relevant documents for query"""
        
        query_embedding = self._get_embedding(query)
        
        similarities = []
        for i, doc_embedding in enumerate(self.embeddings):
            sim = np.dot(query_embedding, doc_embedding) / (
                np.linalg.norm(query_embedding) * np.linalg.norm(doc_embedding)
            )
            similarities.append((i, sim))
        
        # Sort by similarity (descending)
        similarities.sort(key=lambda x: x[1], reverse=True)
        
        # Return top_k documents
        return [self.documents[i] for i, _ in similarities[:top_k]]
    
    def query(self, question: str) -> str:
        """Answer question using RAG"""
        
        # Retrieve relevant documents
        relevant_docs = self._find_relevant_docs(question)
        
        # Build context
        context = "\n\n".join([f"Document {i+1}:\n{doc}" 
                               for i, doc in enumerate(relevant_docs)])
        
        # Generate answer
        system_prompt = """
You are a medical information assistant. Answer questions based on the 
provided context documents. If the answer isn't in the context, say so.
Always recommend consulting a healthcare provider for personal medical advice.
"""
        
        user_message = f"""
Context:
{context}

Question: {question}

Answer based on the context above:
"""
        
        response = self.client.chat.completions.create(
            model=GPT4_DEPLOYMENT,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            temperature=0.3,
            max_tokens=500
        )
        
        return response.choices[0].message.content

# Test
if __name__ == "__main__":
    rag = SimpleRAG()
    
    # Add medical knowledge base documents
    documents = [
        """
        Hypertension Treatment Guidelines:
        - Lifestyle modifications: diet, exercise, weight loss, sodium reduction
        - First-line medications: ACE inhibitors, ARBs, calcium channel blockers, thiazides
        - Target BP: <130/80 for most adults
        - Monitor every 3-6 months once controlled
        """,
        """
        Type 2 Diabetes Management:
        - A1C target: <7% for most adults
        - First-line medication: Metformin
        - Lifestyle: diet, exercise, weight management
        - Monitor: quarterly A1C, annual eye/foot exams
        - Consider GLP-1 or SGLT2 for cardiovascular benefit
        """,
        """
        Heart Attack Warning Signs:
        - Chest discomfort (pressure, squeezing, pain)
        - Discomfort in arms, back, neck, jaw, stomach
        - Shortness of breath
        - Cold sweat, nausea, lightheadedness
        - CALL 911 IMMEDIATELY if suspected
        """
    ]
    
    rag.add_documents(documents)
    
    # Query the knowledge base
    questions = [
        "What medications are used for high blood pressure?",
        "What is the A1C target for diabetics?",
        "What should I do if I think I'm having a heart attack?"
    ]
    
    for q in questions:
        print(f"\n{'='*60}")
        print(f"Q: {q}")
        print(f"\nA: {rag.query(q)}")
```

---

## 🔧 Exercise 5: Responsible AI

### Task 5.1: Content Filtering

```python
# content_safety.py
from openai_config import get_openai_client, GPT4_DEPLOYMENT

def safe_chat(user_message: str, system_prompt: str = None):
    """
    Chat with content filtering.
    Azure OpenAI has built-in content filters for:
    - Hate speech
    - Violence
    - Self-harm
    - Sexual content
    """
    
    client = get_openai_client()
    
    messages = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
    messages.append({"role": "user", "content": user_message})
    
    try:
        response = client.chat.completions.create(
            model=GPT4_DEPLOYMENT,
            messages=messages,
            temperature=0.7,
            max_tokens=500
        )
        
        # Check for content filter results
        choice = response.choices[0]
        
        if choice.finish_reason == "content_filter":
            return {
                "success": False,
                "message": "Response filtered due to content policy.",
                "filter_results": choice.content_filter_results
            }
        
        return {
            "success": True,
            "message": choice.message.content
        }
        
    except Exception as e:
        if "content_filter" in str(e).lower():
            return {
                "success": False,
                "message": "Request filtered due to content policy.",
                "error": str(e)
            }
        raise

# Test
if __name__ == "__main__":
    # Normal request
    result = safe_chat("What are healthy eating habits?")
    print(f"Success: {result['success']}")
    print(f"Message: {result['message'][:200]}...")
```

### Task 5.2: Guardrails for Healthcare AI

```python
# healthcare_guardrails.py
from openai_config import get_openai_client, GPT4_DEPLOYMENT

class HealthcareAIGuardrails:
    """
    Guardrails for responsible healthcare AI.
    """
    
    def __init__(self):
        self.client = get_openai_client()
        
        # Topics that require special handling
        self.emergency_keywords = [
            "suicide", "kill myself", "end my life",
            "heart attack", "can't breathe", "overdose",
            "severe bleeding", "unconscious"
        ]
        
        self.out_of_scope = [
            "prescribe", "diagnose me", "what medication should I take",
            "is this cancer", "am I going to die"
        ]
    
    def check_input(self, user_input: str) -> dict:
        """Check input for safety concerns"""
        
        input_lower = user_input.lower()
        
        # Check for emergencies
        for keyword in self.emergency_keywords:
            if keyword in input_lower:
                return {
                    "allow": False,
                    "reason": "emergency",
                    "response": self._emergency_response(keyword)
                }
        
        # Check for out-of-scope requests
        for phrase in self.out_of_scope:
            if phrase in input_lower:
                return {
                    "allow": False,
                    "reason": "out_of_scope",
                    "response": self._scope_response()
                }
        
        return {"allow": True}
    
    def _emergency_response(self, keyword: str) -> str:
        """Response for emergency situations"""
        
        if any(k in keyword for k in ["suicide", "kill myself", "end my life"]):
            return """
🚨 **If you're having thoughts of suicide, please reach out for help immediately:**

- **National Suicide Prevention Lifeline:** 988 (call or text)
- **Crisis Text Line:** Text HOME to 741741
- **International Association for Suicide Prevention:** https://www.iasp.info/resources/Crisis_Centres/

You don't have to face this alone. These services are free, confidential, and available 24/7.
"""
        
        return """
🚨 **This sounds like a medical emergency.**

**Please call 911 or go to your nearest emergency room immediately.**

If you're not sure if it's an emergency, call 911 and let the dispatcher help you decide.
"""
    
    def _scope_response(self) -> str:
        """Response for out-of-scope requests"""
        
        return """
I'm an AI assistant designed to provide general health information, but I'm not able to:
- Diagnose medical conditions
- Prescribe medications
- Provide specific medical advice for your situation

**Please consult with a qualified healthcare provider** who can:
- Review your complete medical history
- Perform a proper examination
- Order appropriate tests
- Provide personalized treatment recommendations

Would you like general information about a health topic instead?
"""
    
    def process(self, user_input: str, system_prompt: str = None) -> str:
        """Process input with guardrails"""
        
        # Check input
        check_result = self.check_input(user_input)
        
        if not check_result["allow"]:
            return check_result["response"]
        
        # Add safety system prompt
        safety_prompt = """
You are a helpful medical information assistant. Important rules:
1. NEVER diagnose conditions or prescribe treatments
2. ALWAYS recommend consulting a healthcare provider for personal medical advice
3. If someone mentions an emergency, direct them to call 911
4. Be empathetic but maintain appropriate boundaries
5. Provide general, evidence-based health information only
"""
        
        full_prompt = f"{safety_prompt}\n\n{system_prompt}" if system_prompt else safety_prompt
        
        # Make the API call
        messages = [
            {"role": "system", "content": full_prompt},
            {"role": "user", "content": user_input}
        ]
        
        response = self.client.chat.completions.create(
            model=GPT4_DEPLOYMENT,
            messages=messages,
            temperature=0.5,
            max_tokens=500
        )
        
        return response.choices[0].message.content

# Test
if __name__ == "__main__":
    guardrails = HealthcareAIGuardrails()
    
    test_inputs = [
        "What are some ways to reduce stress?",
        "I'm having chest pain and can't breathe",
        "Can you prescribe me something for my headache?",
        "What are the symptoms of the flu?"
    ]
    
    for input_text in test_inputs:
        print(f"\n{'='*60}")
        print(f"Input: {input_text}")
        print(f"\nResponse:\n{guardrails.process(input_text)}")
```

---

## 🧹 Cleanup

```bash
# Delete Azure OpenAI deployments
az cognitiveservices account deployment delete \
  --name ai-intellihealth-openai \
  --resource-group rg-ai102-learning \
  --deployment-name gpt-4

az cognitiveservices account deployment delete \
  --name ai-intellihealth-openai \
  --resource-group rg-ai102-learning \
  --deployment-name text-embedding-ada-002

# Delete Azure OpenAI resource
az cognitiveservices account delete \
  --name ai-intellihealth-openai \
  --resource-group rg-ai102-learning
```

---

## ✅ Module Checklist

Before moving on, ensure you can:

- [ ] Deploy Azure OpenAI models (GPT-4, embeddings)
- [ ] Implement chat completions with conversation history
- [ ] Write effective system prompts for different use cases
- [ ] Use few-shot and chain-of-thought prompting
- [ ] Generate and use embeddings for similarity search
- [ ] Build a simple RAG implementation
- [ ] Implement responsible AI guardrails
- [ ] Handle content filtering appropriately

---

## 📚 Additional Resources

- [Azure OpenAI Documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [Prompt Engineering Guide](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/prompt-engineering)
- [RAG with Azure OpenAI](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/use-your-data)
- [Responsible AI Practices](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/content-filter)

---

**Next Module:** [Module 05: Computer Vision](../05-computer-vision/README.md)
