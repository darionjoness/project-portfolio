# Module 08: AI Search & RAG

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will:
- Create and configure Azure AI Search indexes
- Implement indexers and skillsets
- Build semantic search solutions
- Create vector search with embeddings
- Implement production RAG patterns

---

## 📖 The IntelliHealth Scenario

IntelliHealth needs intelligent search for:

| Use Case | Capability | Value |
|----------|------------|-------|
| Medical literature | Semantic search | Research acceleration |
| Patient records | Full-text search | Quick information access |
| Drug information | Vector search | Similarity matching |
| Knowledge base | RAG | Intelligent Q&A |

---

## 🔧 Exercise 1: Azure AI Search Setup

### Task 1.1: Create Search Service

```bash
# Create Azure AI Search service
az search service create \
  --name srch-intellihealth \
  --resource-group rg-ai102-learning \
  --sku free \
  --location eastus

# Get admin key
az search admin-key show \
  --service-name srch-intellihealth \
  --resource-group rg-ai102-learning

# Get query key
az search query-key list \
  --service-name srch-intellihealth \
  --resource-group rg-ai102-learning
```

### Task 1.2: Install SDK

```bash
pip install azure-search-documents
```

### Task 1.3: Create Index

```python
# create_index.py
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (
    SearchIndex,
    SearchField,
    SearchFieldDataType,
    SimpleField,
    SearchableField,
    ComplexField
)
from azure.core.credentials import AzureKeyCredential
import os

def get_index_client():
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_ADMIN_KEY")
    return SearchIndexClient(endpoint, AzureKeyCredential(key))

def create_medical_index():
    """Create index for medical documents"""
    
    client = get_index_client()
    
    # Define index schema
    index = SearchIndex(
        name="medical-documents",
        fields=[
            SimpleField(name="id", type=SearchFieldDataType.String, key=True),
            SearchableField(name="title", type=SearchFieldDataType.String, 
                          analyzer_name="en.microsoft"),
            SearchableField(name="content", type=SearchFieldDataType.String,
                          analyzer_name="en.microsoft"),
            SearchableField(name="summary", type=SearchFieldDataType.String),
            SimpleField(name="category", type=SearchFieldDataType.String, 
                       filterable=True, facetable=True),
            SimpleField(name="department", type=SearchFieldDataType.String,
                       filterable=True, facetable=True),
            SimpleField(name="publishDate", type=SearchFieldDataType.DateTimeOffset,
                       filterable=True, sortable=True),
            SearchableField(name="keywords", type=SearchFieldDataType.Collection(SearchFieldDataType.String)),
            SimpleField(name="sourceUrl", type=SearchFieldDataType.String)
        ]
    )
    
    result = client.create_or_update_index(index)
    print(f"Created index: {result.name}")
    return result

def list_indexes():
    """List all indexes"""
    client = get_index_client()
    for index in client.list_indexes():
        print(f"  - {index.name}")

# Test
if __name__ == "__main__":
    create_medical_index()
    print("\nAll indexes:")
    list_indexes()
```

---

## 🔧 Exercise 2: Indexing Documents

### Task 2.1: Upload Documents

```python
# index_documents.py
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
import os
from datetime import datetime

def get_search_client(index_name: str):
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_ADMIN_KEY")
    return SearchClient(endpoint, index_name, AzureKeyCredential(key))

def upload_medical_documents():
    """Upload sample medical documents"""
    
    client = get_search_client("medical-documents")
    
    documents = [
        {
            "id": "1",
            "title": "Understanding Type 2 Diabetes",
            "content": """Type 2 diabetes is a chronic condition that affects how your body 
            metabolizes sugar (glucose). With type 2 diabetes, your body either resists the 
            effects of insulin or doesn't produce enough insulin to maintain normal glucose levels.
            
            Common symptoms include increased thirst, frequent urination, increased hunger,
            unintended weight loss, fatigue, blurred vision, slow-healing sores, and frequent
            infections. Risk factors include being overweight, fat distribution, inactivity,
            family history, and age.""",
            "summary": "Overview of Type 2 Diabetes symptoms, causes, and risk factors",
            "category": "Endocrinology",
            "department": "Internal Medicine",
            "publishDate": datetime(2024, 1, 15),
            "keywords": ["diabetes", "blood sugar", "insulin", "glucose", "metabolism"]
        },
        {
            "id": "2",
            "title": "Hypertension Management Guidelines",
            "content": """Hypertension, or high blood pressure, is a common condition where the 
            long-term force of blood against artery walls is high enough to cause health problems.
            
            Blood pressure is measured in millimeters of mercury (mm Hg) and has two numbers:
            systolic (top number) and diastolic (bottom number). Normal blood pressure is below
            120/80 mm Hg. Stage 1 hypertension is 130-139/80-89 mm Hg.
            
            Treatment includes lifestyle changes (diet, exercise, weight loss) and medications
            such as ACE inhibitors, ARBs, calcium channel blockers, and diuretics.""",
            "summary": "Guidelines for managing high blood pressure",
            "category": "Cardiology",
            "department": "Cardiovascular",
            "publishDate": datetime(2024, 2, 1),
            "keywords": ["hypertension", "blood pressure", "cardiovascular", "heart health"]
        },
        {
            "id": "3",
            "title": "COVID-19 Vaccination Protocol",
            "content": """COVID-19 vaccines are safe and effective at preventing severe illness,
            hospitalization, and death. The CDC recommends staying up to date with COVID-19 
            vaccines for everyone 6 months and older.
            
            Primary series and booster doses are recommended based on age and health status.
            Common side effects include pain at injection site, fatigue, headache, muscle pain,
            chills, and fever. These are normal signs that the body is building protection.""",
            "summary": "Current COVID-19 vaccination guidelines and protocols",
            "category": "Infectious Disease",
            "department": "Public Health",
            "publishDate": datetime(2024, 3, 1),
            "keywords": ["covid", "vaccination", "vaccine", "immunization", "coronavirus"]
        },
        {
            "id": "4",
            "title": "Managing Chronic Pain",
            "content": """Chronic pain is pain that lasts more than three months. It can affect
            your physical and emotional health, relationships, and ability to work and enjoy life.
            
            Treatment approaches include medications (NSAIDs, acetaminophen, antidepressants),
            physical therapy, cognitive behavioral therapy, and in some cases, interventional
            procedures. A multidisciplinary approach often works best.
            
            Opioid medications should be used cautiously due to risk of dependency.""",
            "summary": "Comprehensive approach to chronic pain management",
            "category": "Pain Management",
            "department": "Anesthesiology",
            "publishDate": datetime(2024, 1, 20),
            "keywords": ["pain", "chronic pain", "pain management", "therapy"]
        },
        {
            "id": "5",
            "title": "Preventive Health Screenings by Age",
            "content": """Regular health screenings can help detect problems early when they're
            easier to treat. Recommended screenings vary by age, sex, and risk factors.
            
            Ages 18-39: Blood pressure, cholesterol, diabetes screening, STI testing.
            Ages 40-49: All above plus mammogram (women), colonoscopy discussion.
            Ages 50-64: Colonoscopy, bone density (women), prostate discussion (men).
            Ages 65+: All above plus lung cancer screening (if smoking history).
            
            Discuss your personal risk factors with your healthcare provider.""",
            "summary": "Age-appropriate preventive health screening recommendations",
            "category": "Preventive Care",
            "department": "Primary Care",
            "publishDate": datetime(2024, 2, 15),
            "keywords": ["screening", "preventive care", "wellness", "health check"]
        }
    ]
    
    result = client.upload_documents(documents)
    
    print(f"Uploaded {len(documents)} documents")
    for r in result:
        print(f"  - {r.key}: {r.succeeded}")
    
    return result

# Test
if __name__ == "__main__":
    upload_medical_documents()
```

### Task 2.2: Search Documents

```python
# search_documents.py
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
import os

def get_search_client(index_name: str):
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_QUERY_KEY")  # Use query key for search
    return SearchClient(endpoint, index_name, AzureKeyCredential(key))

def simple_search(query: str, top: int = 5):
    """Perform simple full-text search"""
    
    client = get_search_client("medical-documents")
    
    results = client.search(
        search_text=query,
        top=top,
        include_total_count=True
    )
    
    print(f"Found {results.get_count()} results for '{query}'")
    
    for result in results:
        print(f"\n  Title: {result['title']}")
        print(f"  Category: {result['category']}")
        print(f"  Score: {result['@search.score']:.4f}")
        print(f"  Summary: {result['summary'][:100]}...")

def filtered_search(query: str, category: str = None, department: str = None):
    """Search with filters"""
    
    client = get_search_client("medical-documents")
    
    # Build filter
    filters = []
    if category:
        filters.append(f"category eq '{category}'")
    if department:
        filters.append(f"department eq '{department}'")
    
    filter_string = " and ".join(filters) if filters else None
    
    results = client.search(
        search_text=query,
        filter=filter_string,
        top=5
    )
    
    for result in results:
        print(f"  - {result['title']} ({result['category']})")

def faceted_search(query: str):
    """Search with facets for navigation"""
    
    client = get_search_client("medical-documents")
    
    results = client.search(
        search_text=query,
        facets=["category", "department"],
        include_total_count=True
    )
    
    # Get facets
    facets = results.get_facets()
    
    print(f"\nCategories:")
    for facet in facets.get("category", []):
        print(f"  - {facet['value']}: {facet['count']}")
    
    print(f"\nDepartments:")
    for facet in facets.get("department", []):
        print(f"  - {facet['value']}: {facet['count']}")

# Test
if __name__ == "__main__":
    print("Simple Search:")
    simple_search("diabetes blood sugar")
    
    print("\n" + "=" * 50)
    print("Filtered Search (Cardiology only):")
    filtered_search("treatment", category="Cardiology")
    
    print("\n" + "=" * 50)
    print("Faceted Search:")
    faceted_search("health")
```

---

## 🔧 Exercise 3: Semantic Search

### Task 3.1: Enable Semantic Search

```python
# semantic_search.py
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (
    SearchIndex,
    SearchField,
    SearchFieldDataType,
    SemanticConfiguration,
    SemanticField,
    SemanticPrioritizedFields,
    SemanticSearch
)
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
import os

def create_semantic_index():
    """Create index with semantic configuration"""
    
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_ADMIN_KEY")
    client = SearchIndexClient(endpoint, AzureKeyCredential(key))
    
    # Define semantic configuration
    semantic_config = SemanticConfiguration(
        name="medical-semantic-config",
        prioritized_fields=SemanticPrioritizedFields(
            title_field=SemanticField(field_name="title"),
            content_fields=[SemanticField(field_name="content")],
            keywords_fields=[SemanticField(field_name="keywords")]
        )
    )
    
    index = SearchIndex(
        name="medical-documents-semantic",
        fields=[
            SearchField(name="id", type=SearchFieldDataType.String, key=True),
            SearchField(name="title", type=SearchFieldDataType.String, searchable=True),
            SearchField(name="content", type=SearchFieldDataType.String, searchable=True),
            SearchField(name="summary", type=SearchFieldDataType.String, searchable=True),
            SearchField(name="category", type=SearchFieldDataType.String, 
                       filterable=True, facetable=True),
            SearchField(name="keywords", type=SearchFieldDataType.Collection(SearchFieldDataType.String),
                       searchable=True)
        ],
        semantic_search=SemanticSearch(configurations=[semantic_config])
    )
    
    result = client.create_or_update_index(index)
    print(f"Created semantic index: {result.name}")

def semantic_search(query: str):
    """Perform semantic search"""
    
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_QUERY_KEY")
    client = SearchClient(endpoint, "medical-documents-semantic", AzureKeyCredential(key))
    
    results = client.search(
        search_text=query,
        query_type="semantic",
        semantic_configuration_name="medical-semantic-config",
        query_caption="extractive",
        query_answer="extractive",
        top=3
    )
    
    # Check for semantic answers
    answers = results.get_answers()
    if answers:
        print("Semantic Answers:")
        for answer in answers:
            print(f"  {answer.text}")
            print(f"  Confidence: {answer.score:.2f}")
    
    print("\nSearch Results:")
    for result in results:
        print(f"\n  Title: {result['title']}")
        
        # Show captions if available
        captions = result.get("@search.captions")
        if captions:
            for caption in captions:
                print(f"  Caption: {caption.text}")

# Test
if __name__ == "__main__":
    # Note: Semantic search requires a paid tier (Basic+)
    print("Semantic Search Example")
    print("=" * 50)
    print("Note: Semantic search requires Basic tier or higher")
```

---

## 🔧 Exercise 4: Vector Search

### Task 4.1: Create Vector Index

```python
# vector_index.py
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (
    SearchIndex,
    SearchField,
    SearchFieldDataType,
    VectorSearch,
    HnswAlgorithmConfiguration,
    VectorSearchProfile,
    SearchableField,
    SimpleField
)
from azure.core.credentials import AzureKeyCredential
import os

def create_vector_index():
    """Create index with vector search capability"""
    
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_ADMIN_KEY")
    client = SearchIndexClient(endpoint, AzureKeyCredential(key))
    
    # Configure vector search
    vector_search = VectorSearch(
        algorithms=[
            HnswAlgorithmConfiguration(
                name="hnsw-config",
                parameters={
                    "m": 4,
                    "efConstruction": 400,
                    "efSearch": 500,
                    "metric": "cosine"
                }
            )
        ],
        profiles=[
            VectorSearchProfile(
                name="vector-profile",
                algorithm_configuration_name="hnsw-config"
            )
        ]
    )
    
    index = SearchIndex(
        name="medical-vectors",
        fields=[
            SimpleField(name="id", type=SearchFieldDataType.String, key=True),
            SearchableField(name="title", type=SearchFieldDataType.String),
            SearchableField(name="content", type=SearchFieldDataType.String),
            SimpleField(name="category", type=SearchFieldDataType.String, 
                       filterable=True),
            SearchField(
                name="contentVector",
                type=SearchFieldDataType.Collection(SearchFieldDataType.Single),
                searchable=True,
                vector_search_dimensions=1536,  # OpenAI ada-002 dimensions
                vector_search_profile_name="vector-profile"
            )
        ],
        vector_search=vector_search
    )
    
    result = client.create_or_update_index(index)
    print(f"Created vector index: {result.name}")

# Test
if __name__ == "__main__":
    create_vector_index()
```

### Task 4.2: Index with Embeddings

```python
# index_with_embeddings.py
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
from openai import AzureOpenAI
import os

def get_embedding(text: str) -> list:
    """Generate embedding using Azure OpenAI"""
    
    client = AzureOpenAI(
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
        api_key=os.getenv("AZURE_OPENAI_KEY"),
        api_version="2024-02-15-preview"
    )
    
    response = client.embeddings.create(
        model="text-embedding-ada-002",
        input=text
    )
    
    return response.data[0].embedding

def index_documents_with_vectors():
    """Index documents with embeddings"""
    
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_ADMIN_KEY")
    client = SearchClient(endpoint, "medical-vectors", AzureKeyCredential(key))
    
    documents = [
        {
            "id": "1",
            "title": "Diabetes Management",
            "content": "Type 2 diabetes is managed through diet, exercise, and medications like metformin.",
            "category": "Endocrinology"
        },
        {
            "id": "2",
            "title": "Heart Disease Prevention",
            "content": "Preventing heart disease involves maintaining healthy blood pressure, cholesterol, and weight.",
            "category": "Cardiology"
        },
        {
            "id": "3",
            "title": "Anxiety Treatment",
            "content": "Anxiety disorders can be treated with therapy, medication, or a combination of both approaches.",
            "category": "Psychiatry"
        }
    ]
    
    # Add embeddings
    for doc in documents:
        doc["contentVector"] = get_embedding(doc["content"])
        print(f"Generated embedding for: {doc['title']}")
    
    result = client.upload_documents(documents)
    print(f"\nIndexed {len(documents)} documents with vectors")

# Test
if __name__ == "__main__":
    index_documents_with_vectors()
```

### Task 4.3: Vector Search

```python
# vector_search.py
from azure.search.documents import SearchClient
from azure.search.documents.models import VectorizedQuery
from azure.core.credentials import AzureKeyCredential
from openai import AzureOpenAI
import os

def get_embedding(text: str) -> list:
    """Generate embedding"""
    client = AzureOpenAI(
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
        api_key=os.getenv("AZURE_OPENAI_KEY"),
        api_version="2024-02-15-preview"
    )
    response = client.embeddings.create(model="text-embedding-ada-002", input=text)
    return response.data[0].embedding

def vector_search(query: str, top_k: int = 3):
    """Perform vector similarity search"""
    
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_QUERY_KEY")
    client = SearchClient(endpoint, "medical-vectors", AzureKeyCredential(key))
    
    # Generate query embedding
    query_vector = get_embedding(query)
    
    # Create vector query
    vector_query = VectorizedQuery(
        vector=query_vector,
        k_nearest_neighbors=top_k,
        fields="contentVector"
    )
    
    results = client.search(
        search_text=None,  # Pure vector search
        vector_queries=[vector_query],
        select=["id", "title", "content", "category"]
    )
    
    print(f"Vector search for: '{query}'")
    print("=" * 50)
    
    for result in results:
        print(f"\nTitle: {result['title']}")
        print(f"Category: {result['category']}")
        print(f"Score: {result['@search.score']:.4f}")
        print(f"Content: {result['content'][:100]}...")

def hybrid_search(query: str, top_k: int = 3):
    """Combine keyword and vector search"""
    
    endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
    key = os.getenv("AZURE_SEARCH_QUERY_KEY")
    client = SearchClient(endpoint, "medical-vectors", AzureKeyCredential(key))
    
    # Generate query embedding
    query_vector = get_embedding(query)
    
    vector_query = VectorizedQuery(
        vector=query_vector,
        k_nearest_neighbors=top_k,
        fields="contentVector"
    )
    
    results = client.search(
        search_text=query,  # Also do keyword search
        vector_queries=[vector_query],
        select=["id", "title", "content", "category"]
    )
    
    print(f"Hybrid search for: '{query}'")
    print("=" * 50)
    
    for result in results:
        print(f"\nTitle: {result['title']}")
        print(f"Score: {result['@search.score']:.4f}")

# Test
if __name__ == "__main__":
    vector_search("How do I manage my blood sugar levels?")
    print("\n")
    hybrid_search("heart health tips")
```

---

## 🔧 Exercise 5: Production RAG System

### Task 5.1: Complete RAG Implementation

```python
# production_rag.py
from azure.search.documents import SearchClient
from azure.search.documents.models import VectorizedQuery
from azure.core.credentials import AzureKeyCredential
from openai import AzureOpenAI
from dataclasses import dataclass
from typing import List, Optional
import os

@dataclass
class SearchResult:
    """Single search result"""
    id: str
    title: str
    content: str
    score: float
    category: Optional[str] = None

@dataclass
class RAGResponse:
    """RAG system response"""
    answer: str
    sources: List[SearchResult]
    confidence: float

class MedicalRAGSystem:
    """
    Production RAG system for medical Q&A.
    Combines Azure AI Search with Azure OpenAI.
    """
    
    def __init__(self):
        # Search client
        self.search_client = SearchClient(
            os.getenv("AZURE_SEARCH_ENDPOINT"),
            "medical-vectors",
            AzureKeyCredential(os.getenv("AZURE_SEARCH_ADMIN_KEY"))
        )
        
        # OpenAI client
        self.openai_client = AzureOpenAI(
            azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
            api_key=os.getenv("AZURE_OPENAI_KEY"),
            api_version="2024-02-15-preview"
        )
        
        self.embedding_model = "text-embedding-ada-002"
        self.chat_model = "gpt-4"
    
    def query(self, question: str, top_k: int = 5) -> RAGResponse:
        """Answer a question using RAG"""
        
        # Step 1: Retrieve relevant documents
        sources = self._retrieve(question, top_k)
        
        if not sources:
            return RAGResponse(
                answer="I couldn't find relevant information to answer your question.",
                sources=[],
                confidence=0.0
            )
        
        # Step 2: Generate answer
        answer = self._generate(question, sources)
        
        # Calculate confidence based on search scores
        avg_score = sum(s.score for s in sources) / len(sources)
        
        return RAGResponse(
            answer=answer,
            sources=sources,
            confidence=min(avg_score, 1.0)
        )
    
    def _retrieve(self, query: str, top_k: int) -> List[SearchResult]:
        """Retrieve relevant documents using hybrid search"""
        
        # Get query embedding
        embedding = self._get_embedding(query)
        
        # Hybrid search (vector + keyword)
        vector_query = VectorizedQuery(
            vector=embedding,
            k_nearest_neighbors=top_k,
            fields="contentVector"
        )
        
        results = self.search_client.search(
            search_text=query,
            vector_queries=[vector_query],
            select=["id", "title", "content", "category"],
            top=top_k
        )
        
        sources = []
        for result in results:
            sources.append(SearchResult(
                id=result["id"],
                title=result["title"],
                content=result["content"],
                score=result["@search.score"],
                category=result.get("category")
            ))
        
        return sources
    
    def _generate(self, question: str, sources: List[SearchResult]) -> str:
        """Generate answer from retrieved context"""
        
        # Build context from sources
        context_parts = []
        for i, source in enumerate(sources, 1):
            context_parts.append(f"[{i}] {source.title}\n{source.content}")
        
        context = "\n\n".join(context_parts)
        
        # Build prompt
        system_prompt = """You are a helpful medical information assistant. 
Answer questions based on the provided context. Follow these rules:
1. Only use information from the provided context
2. If the context doesn't contain the answer, say so
3. Always recommend consulting a healthcare provider for personal medical advice
4. Cite sources using [1], [2], etc.
5. Be concise but thorough"""

        user_prompt = f"""Context:
{context}

Question: {question}

Answer based on the context above:"""
        
        response = self.openai_client.chat.completions.create(
            model=self.chat_model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.3,
            max_tokens=500
        )
        
        return response.choices[0].message.content
    
    def _get_embedding(self, text: str) -> list:
        """Generate embedding"""
        response = self.openai_client.embeddings.create(
            model=self.embedding_model,
            input=text
        )
        return response.data[0].embedding

# Test
if __name__ == "__main__":
    rag = MedicalRAGSystem()
    
    questions = [
        "How can I manage my blood sugar levels?",
        "What are the symptoms of high blood pressure?",
        "What vaccines do I need as an adult?"
    ]
    
    for question in questions:
        print(f"\n{'='*60}")
        print(f"Question: {question}")
        
        response = rag.query(question)
        
        print(f"\nAnswer: {response.answer}")
        print(f"\nConfidence: {response.confidence:.2%}")
        print(f"\nSources:")
        for source in response.sources:
            print(f"  - {source.title} (score: {source.score:.4f})")
```

---

## 🧹 Cleanup

```bash
# Delete search service
az search service delete \
  --name srch-intellihealth \
  --resource-group rg-ai102-learning \
  --yes
```

---

## ✅ Module Checklist

Before moving on, ensure you can:

- [ ] Create and configure search indexes
- [ ] Upload and index documents
- [ ] Perform full-text searches with filters
- [ ] Use facets for navigation
- [ ] Implement semantic search
- [ ] Create vector search indexes
- [ ] Generate and use embeddings
- [ ] Build production RAG systems

---

## 📚 Additional Resources

- [Azure AI Search Documentation](https://learn.microsoft.com/en-us/azure/search/)
- [Vector Search](https://learn.microsoft.com/en-us/azure/search/vector-search-overview)
- [Semantic Search](https://learn.microsoft.com/en-us/azure/search/semantic-search-overview)
- [RAG Patterns](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview)

---

**Next Module:** [Module 09: Capstone Project](../09-capstone/README.md)
