# Module 07: Conversational AI

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 4-5 hours](https://img.shields.io/badge/Time-4--5%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will:
- Build knowledge bases with Question Answering
- Create conversational bots with Bot Framework
- Implement multi-turn dialogs
- Deploy bots to multiple channels
- Integrate AI services into bots

---

## 📖 The IntelliHealth Scenario

IntelliHealth needs conversational AI for:

| Use Case | Capability | Value |
|----------|------------|-------|
| Patient FAQ | Question Answering | 24/7 self-service |
| Appointment booking | Bot dialogs | Automated scheduling |
| Symptom checker | Multi-turn conversation | Initial triage |
| Multi-channel support | Channel integration | Meet patients where they are |

---

## 🔧 Exercise 1: Question Answering

### Task 1.1: Create Language Resource

```bash
# Create Language resource (includes QnA)
az cognitiveservices account create \
  --name ai-intellihealth-language \
  --resource-group rg-ai102-learning \
  --kind TextAnalytics \
  --sku F0 \
  --location eastus \
  --yes
```

### Task 1.2: Create Knowledge Base

```python
# question_answering.py
from azure.ai.language.questionanswering import QuestionAnsweringClient
from azure.ai.language.questionanswering.projects import AuthoringClient
from azure.core.credentials import AzureKeyCredential
import os

def get_client():
    endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
    key = os.getenv("AZURE_LANGUAGE_KEY")
    return QuestionAnsweringClient(endpoint, AzureKeyCredential(key))

def get_authoring_client():
    endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
    key = os.getenv("AZURE_LANGUAGE_KEY")
    return AuthoringClient(endpoint, AzureKeyCredential(key))

def create_healthcare_kb():
    """Create a healthcare knowledge base"""
    
    # This would typically be done in Language Studio
    # Here's the structure for reference
    
    kb_content = {
        "projectName": "intellihealth-faq",
        "language": "en",
        "qnaList": [
            {
                "id": 1,
                "answer": "Our clinic is open Monday through Friday, 8:00 AM to 5:00 PM. "
                         "We are closed on weekends and major holidays.",
                "source": "manual",
                "questions": [
                    "What are your hours?",
                    "When is the clinic open?",
                    "What time do you open?",
                    "What time do you close?"
                ],
                "metadata": {"category": "general"}
            },
            {
                "id": 2,
                "answer": "You can schedule an appointment by calling (555) 123-4567, "
                         "visiting our website, or using the IntelliHealth mobile app.",
                "source": "manual",
                "questions": [
                    "How do I make an appointment?",
                    "How can I schedule a visit?",
                    "I need to see a doctor",
                    "Book appointment"
                ],
                "metadata": {"category": "appointments"}
            },
            {
                "id": 3,
                "answer": "To refill a prescription, call our pharmacy line at (555) 123-4568, "
                         "use the patient portal, or ask during your next visit. "
                         "Please allow 48 hours for processing.",
                "source": "manual",
                "questions": [
                    "How do I refill my prescription?",
                    "I need a medication refill",
                    "Prescription refill",
                    "How to get more medication?"
                ],
                "metadata": {"category": "prescriptions"}
            },
            {
                "id": 4,
                "answer": "If you're experiencing a medical emergency, call 911 immediately "
                         "or go to the nearest emergency room. Do not wait.",
                "source": "manual",
                "questions": [
                    "I'm having an emergency",
                    "Medical emergency",
                    "This is urgent",
                    "I need help now"
                ],
                "metadata": {"category": "emergency"}
            },
            {
                "id": 5,
                "answer": "We accept most major insurance plans including Medicare, Medicaid, "
                         "Blue Cross Blue Shield, Aetna, Cigna, and United Healthcare. "
                         "Please call our billing department to verify your coverage.",
                "source": "manual",
                "questions": [
                    "What insurance do you accept?",
                    "Do you take my insurance?",
                    "Insurance coverage",
                    "What plans are accepted?"
                ],
                "metadata": {"category": "billing"}
            }
        ]
    }
    
    return kb_content

def query_kb(project_name: str, deployment_name: str, question: str):
    """Query the knowledge base"""
    
    client = get_client()
    
    response = client.get_answers(
        project_name=project_name,
        deployment_name=deployment_name,
        question=question,
        top=3,
        confidence_threshold=0.3
    )
    
    answers = []
    for answer in response.answers:
        answers.append({
            "answer": answer.answer,
            "confidence": answer.confidence,
            "source": answer.source if hasattr(answer, 'source') else None,
            "questions": answer.questions if hasattr(answer, 'questions') else []
        })
    
    return answers

# Test
if __name__ == "__main__":
    # Show KB structure
    kb = create_healthcare_kb()
    print("Healthcare FAQ Knowledge Base")
    print("=" * 40)
    for qna in kb["qnaList"]:
        print(f"\nQ: {qna['questions'][0]}")
        print(f"A: {qna['answer'][:100]}...")
```

### Task 1.3: Multi-Turn Conversations

```python
# multi_turn_qna.py
from azure.ai.language.questionanswering import QuestionAnsweringClient
from azure.core.credentials import AzureKeyCredential
import os

class MultiTurnQnA:
    """
    Multi-turn question answering for complex queries.
    Maintains context across questions.
    """
    
    def __init__(self, project_name: str, deployment_name: str):
        endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
        key = os.getenv("AZURE_LANGUAGE_KEY")
        
        self.client = QuestionAnsweringClient(endpoint, AzureKeyCredential(key))
        self.project_name = project_name
        self.deployment_name = deployment_name
        self.context = None
    
    def ask(self, question: str) -> dict:
        """Ask a question with context"""
        
        options = {
            "project_name": self.project_name,
            "deployment_name": self.deployment_name,
            "question": question,
            "top": 1,
            "confidence_threshold": 0.3
        }
        
        # Include context if available
        if self.context:
            options["context"] = self.context
        
        response = self.client.get_answers(**options)
        
        if response.answers:
            answer = response.answers[0]
            
            # Save context for follow-up questions
            if hasattr(answer, 'dialog') and answer.dialog:
                self.context = {
                    "previousQnaId": answer.qna_id,
                    "previousQuestion": question,
                    "previousAnswer": answer.answer
                }
            
            return {
                "answer": answer.answer,
                "confidence": answer.confidence,
                "prompts": [p.display_text for p in answer.dialog.prompts] if hasattr(answer, 'dialog') and answer.dialog and answer.dialog.prompts else []
            }
        
        return {
            "answer": "I'm sorry, I don't have information about that. Would you like to speak with a staff member?",
            "confidence": 0,
            "prompts": []
        }
    
    def reset_context(self):
        """Reset conversation context"""
        self.context = None

# Example usage
if __name__ == "__main__":
    print("Multi-Turn QnA Example")
    print("=" * 40)
    print("This demonstrates follow-up questions with context.")
    print("\nExample flow:")
    print("User: How do I make an appointment?")
    print("Bot: You can schedule an appointment by...")
    print("User: What about weekends?")
    print("Bot: [Uses context to understand this is about appointments]")
```

---

## 🔧 Exercise 2: Bot Framework Basics

### Task 2.1: Bot Project Setup

```bash
# Install Bot Framework SDK
pip install botbuilder-core
pip install botbuilder-dialogs
pip install aiohttp

# For local testing
pip install botbuilder-integration-aiohttp
```

### Task 2.2: Simple Echo Bot

```python
# echo_bot.py
from botbuilder.core import ActivityHandler, TurnContext
from botbuilder.schema import ChannelAccount

class EchoBot(ActivityHandler):
    """Simple echo bot for testing"""
    
    async def on_message_activity(self, turn_context: TurnContext):
        """Handle incoming messages"""
        
        user_message = turn_context.activity.text
        response = f"You said: {user_message}"
        
        await turn_context.send_activity(response)
    
    async def on_members_added_activity(
        self, 
        members_added: list[ChannelAccount], 
        turn_context: TurnContext
    ):
        """Welcome new users"""
        
        for member in members_added:
            if member.id != turn_context.activity.recipient.id:
                await turn_context.send_activity(
                    "Welcome to IntelliHealth! How can I help you today?"
                )
```

### Task 2.3: Healthcare Bot

```python
# healthcare_bot.py
from botbuilder.core import ActivityHandler, TurnContext, ConversationState, UserState
from botbuilder.schema import ChannelAccount, Activity, ActivityTypes
from botbuilder.dialogs import Dialog, DialogSet, DialogTurnStatus

class HealthcareBot(ActivityHandler):
    """
    Healthcare chatbot with dialog management.
    """
    
    def __init__(
        self, 
        conversation_state: ConversationState,
        user_state: UserState,
        dialog: Dialog
    ):
        self.conversation_state = conversation_state
        self.user_state = user_state
        self.dialog = dialog
        self.dialog_state = conversation_state.create_property("DialogState")
    
    async def on_turn(self, turn_context: TurnContext):
        """Process each turn"""
        
        await super().on_turn(turn_context)
        
        # Save state changes
        await self.conversation_state.save_changes(turn_context)
        await self.user_state.save_changes(turn_context)
    
    async def on_message_activity(self, turn_context: TurnContext):
        """Handle messages"""
        
        # Create dialog context
        dialog_set = DialogSet(self.dialog_state)
        dialog_set.add(self.dialog)
        
        dialog_context = await dialog_set.create_context(turn_context)
        
        # Continue or start dialog
        results = await dialog_context.continue_dialog()
        
        if results.status == DialogTurnStatus.Empty:
            await dialog_context.begin_dialog(self.dialog.id)
    
    async def on_members_added_activity(
        self,
        members_added: list[ChannelAccount],
        turn_context: TurnContext
    ):
        """Welcome message"""
        
        welcome_text = """
👋 Welcome to IntelliHealth Virtual Assistant!

I can help you with:
• Scheduling appointments
• Refilling prescriptions
• General health questions
• Finding clinic information

What would you like to do today?
"""
        
        for member in members_added:
            if member.id != turn_context.activity.recipient.id:
                await turn_context.send_activity(welcome_text)
```

---

## 🔧 Exercise 3: Dialog Management

### Task 3.1: Waterfall Dialogs

```python
# appointment_dialog.py
from botbuilder.dialogs import (
    ComponentDialog, 
    WaterfallDialog, 
    WaterfallStepContext,
    DialogTurnResult
)
from botbuilder.dialogs.prompts import (
    TextPrompt, 
    ConfirmPrompt, 
    DateTimePrompt,
    ChoicePrompt,
    PromptOptions
)
from botbuilder.dialogs.choices import Choice
from botbuilder.core import MessageFactory
from datetime import datetime

class AppointmentDialog(ComponentDialog):
    """
    Multi-step dialog for scheduling appointments.
    """
    
    def __init__(self, dialog_id: str = None):
        super().__init__(dialog_id or AppointmentDialog.__name__)
        
        # Add prompts
        self.add_dialog(TextPrompt(TextPrompt.__name__))
        self.add_dialog(ConfirmPrompt(ConfirmPrompt.__name__))
        self.add_dialog(DateTimePrompt(DateTimePrompt.__name__))
        self.add_dialog(ChoicePrompt(ChoicePrompt.__name__))
        
        # Add waterfall dialog
        self.add_dialog(
            WaterfallDialog(
                "appointmentWaterfall",
                [
                    self.appointment_type_step,
                    self.doctor_step,
                    self.date_step,
                    self.time_step,
                    self.confirm_step,
                    self.final_step
                ]
            )
        )
        
        self.initial_dialog_id = "appointmentWaterfall"
    
    async def appointment_type_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Ask for appointment type"""
        
        return await step_context.prompt(
            ChoicePrompt.__name__,
            PromptOptions(
                prompt=MessageFactory.text("What type of appointment do you need?"),
                choices=[
                    Choice("General Checkup"),
                    Choice("Follow-up Visit"),
                    Choice("New Patient"),
                    Choice("Urgent Care")
                ]
            )
        )
    
    async def doctor_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Ask for preferred doctor"""
        
        step_context.values["appointment_type"] = step_context.result.value
        
        return await step_context.prompt(
            ChoicePrompt.__name__,
            PromptOptions(
                prompt=MessageFactory.text("Which doctor would you like to see?"),
                choices=[
                    Choice("Dr. Sarah Johnson"),
                    Choice("Dr. Michael Chen"),
                    Choice("Dr. Emily Williams"),
                    Choice("First Available")
                ]
            )
        )
    
    async def date_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Ask for preferred date"""
        
        step_context.values["doctor"] = step_context.result.value
        
        return await step_context.prompt(
            DateTimePrompt.__name__,
            PromptOptions(
                prompt=MessageFactory.text(
                    "What date works best for you? (e.g., 'tomorrow', 'next Monday')"
                )
            )
        )
    
    async def time_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Ask for preferred time"""
        
        step_context.values["date"] = step_context.result[0].value
        
        return await step_context.prompt(
            ChoicePrompt.__name__,
            PromptOptions(
                prompt=MessageFactory.text("What time would you prefer?"),
                choices=[
                    Choice("Morning (8 AM - 12 PM)"),
                    Choice("Afternoon (12 PM - 3 PM)"),
                    Choice("Late Afternoon (3 PM - 5 PM)")
                ]
            )
        )
    
    async def confirm_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Confirm appointment details"""
        
        step_context.values["time"] = step_context.result.value
        
        summary = f"""
📅 **Appointment Summary:**
• Type: {step_context.values['appointment_type']}
• Doctor: {step_context.values['doctor']}
• Date: {step_context.values['date']}
• Time: {step_context.values['time']}

Would you like to confirm this appointment?
"""
        
        return await step_context.prompt(
            ConfirmPrompt.__name__,
            PromptOptions(prompt=MessageFactory.text(summary))
        )
    
    async def final_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Complete the booking"""
        
        if step_context.result:
            # Book the appointment (in real system, call backend API)
            confirmation_number = f"APT-{datetime.now().strftime('%Y%m%d%H%M%S')}"
            
            await step_context.context.send_activity(
                MessageFactory.text(
                    f"✅ Your appointment has been scheduled!\n\n"
                    f"Confirmation #: {confirmation_number}\n\n"
                    f"You will receive a confirmation email shortly. "
                    f"Please arrive 15 minutes early for check-in."
                )
            )
        else:
            await step_context.context.send_activity(
                MessageFactory.text(
                    "No problem! Let me know if you'd like to schedule later."
                )
            )
        
        return await step_context.end_dialog()
```

### Task 3.2: Main Dialog Router

```python
# main_dialog.py
from botbuilder.dialogs import (
    ComponentDialog, 
    WaterfallDialog,
    WaterfallStepContext,
    DialogTurnResult
)
from botbuilder.dialogs.prompts import ChoicePrompt, PromptOptions
from botbuilder.dialogs.choices import Choice
from botbuilder.core import MessageFactory

class MainDialog(ComponentDialog):
    """
    Main dialog that routes to sub-dialogs.
    """
    
    def __init__(
        self, 
        appointment_dialog,
        prescription_dialog,
        qna_dialog
    ):
        super().__init__(MainDialog.__name__)
        
        # Add sub-dialogs
        self.add_dialog(appointment_dialog)
        self.add_dialog(prescription_dialog)
        self.add_dialog(qna_dialog)
        self.add_dialog(ChoicePrompt(ChoicePrompt.__name__))
        
        # Main waterfall
        self.add_dialog(
            WaterfallDialog(
                "mainWaterfall",
                [
                    self.intro_step,
                    self.route_step,
                    self.loop_step
                ]
            )
        )
        
        self.initial_dialog_id = "mainWaterfall"
    
    async def intro_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Present main menu"""
        
        return await step_context.prompt(
            ChoicePrompt.__name__,
            PromptOptions(
                prompt=MessageFactory.text("How can I help you today?"),
                choices=[
                    Choice("📅 Schedule Appointment"),
                    Choice("💊 Refill Prescription"),
                    Choice("❓ Ask a Question"),
                    Choice("📞 Contact Us")
                ]
            )
        )
    
    async def route_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Route to appropriate dialog"""
        
        choice = step_context.result.value
        
        if "Appointment" in choice:
            return await step_context.begin_dialog("AppointmentDialog")
        elif "Prescription" in choice:
            return await step_context.begin_dialog("PrescriptionDialog")
        elif "Question" in choice:
            return await step_context.begin_dialog("QnADialog")
        elif "Contact" in choice:
            await step_context.context.send_activity(
                MessageFactory.text(
                    "📞 **Contact Information:**\n\n"
                    "• Phone: (555) 123-4567\n"
                    "• Email: info@intellihealth.com\n"
                    "• Address: 123 Medical Center Dr\n\n"
                    "Hours: Mon-Fri, 8 AM - 5 PM"
                )
            )
            return await step_context.next(None)
        
        return await step_context.next(None)
    
    async def loop_step(
        self, 
        step_context: WaterfallStepContext
    ) -> DialogTurnResult:
        """Loop back to main menu"""
        
        return await step_context.replace_dialog(self.id)
```

---

## 🔧 Exercise 4: Bot with AI Integration

### Task 4.1: AI-Powered Bot

```python
# ai_healthcare_bot.py
from botbuilder.core import ActivityHandler, TurnContext
from botbuilder.schema import ChannelAccount
from azure.ai.textanalytics import TextAnalyticsClient
from azure.ai.language.questionanswering import QuestionAnsweringClient
from azure.core.credentials import AzureKeyCredential
import os

class AIHealthcareBot(ActivityHandler):
    """
    Healthcare bot with AI integration.
    Uses sentiment analysis and QnA for intelligent responses.
    """
    
    def __init__(self):
        # Initialize AI clients
        endpoint = os.getenv("AZURE_LANGUAGE_ENDPOINT")
        key = os.getenv("AZURE_LANGUAGE_KEY")
        credential = AzureKeyCredential(key)
        
        self.text_client = TextAnalyticsClient(endpoint, credential)
        self.qna_client = QuestionAnsweringClient(endpoint, credential)
        
        self.project_name = "intellihealth-faq"
        self.deployment_name = "production"
        
        # Emergency keywords
        self.emergency_keywords = [
            "heart attack", "can't breathe", "chest pain",
            "severe bleeding", "unconscious", "overdose",
            "suicide", "kill myself"
        ]
    
    async def on_message_activity(self, turn_context: TurnContext):
        """Process incoming message with AI"""
        
        user_message = turn_context.activity.text
        
        # Check for emergencies first
        if self._check_emergency(user_message):
            await self._handle_emergency(turn_context)
            return
        
        # Analyze sentiment
        sentiment = await self._analyze_sentiment(user_message)
        
        # Get answer from QnA
        answer = await self._get_qna_answer(user_message)
        
        # Adjust response based on sentiment
        response = self._format_response(answer, sentiment)
        
        await turn_context.send_activity(response)
    
    def _check_emergency(self, message: str) -> bool:
        """Check if message contains emergency keywords"""
        message_lower = message.lower()
        return any(keyword in message_lower for keyword in self.emergency_keywords)
    
    async def _handle_emergency(self, turn_context: TurnContext):
        """Handle emergency situations"""
        await turn_context.send_activity(
            "🚨 **EMERGENCY DETECTED**\n\n"
            "If this is a medical emergency, please:\n"
            "1. **Call 911 immediately**\n"
            "2. Go to your nearest emergency room\n\n"
            "If you're having thoughts of self-harm, please call:\n"
            "• **National Suicide Prevention Lifeline: 988**\n"
            "• **Crisis Text Line: Text HOME to 741741**\n\n"
            "Help is available 24/7."
        )
    
    async def _analyze_sentiment(self, text: str) -> str:
        """Analyze message sentiment"""
        try:
            result = self.text_client.analyze_sentiment([text])[0]
            return result.sentiment
        except:
            return "neutral"
    
    async def _get_qna_answer(self, question: str) -> dict:
        """Get answer from knowledge base"""
        try:
            response = self.qna_client.get_answers(
                project_name=self.project_name,
                deployment_name=self.deployment_name,
                question=question,
                top=1
            )
            
            if response.answers and response.answers[0].confidence > 0.3:
                return {
                    "answer": response.answers[0].answer,
                    "confidence": response.answers[0].confidence,
                    "found": True
                }
        except Exception as e:
            print(f"QnA error: {e}")
        
        return {
            "answer": "I'm not sure about that. Would you like me to connect you with our staff?",
            "confidence": 0,
            "found": False
        }
    
    def _format_response(self, answer: dict, sentiment: str) -> str:
        """Format response based on sentiment and answer confidence"""
        
        response = answer["answer"]
        
        # Add empathy for negative sentiment
        if sentiment == "negative":
            response = "I understand this might be frustrating. " + response
        
        # Add clarification option for low confidence
        if not answer["found"]:
            response += "\n\nYou can also call us at (555) 123-4567 for immediate assistance."
        
        return response
    
    async def on_members_added_activity(
        self,
        members_added: list[ChannelAccount],
        turn_context: TurnContext
    ):
        """Welcome new users"""
        for member in members_added:
            if member.id != turn_context.activity.recipient.id:
                await turn_context.send_activity(
                    "👋 Welcome to IntelliHealth!\n\n"
                    "I'm your virtual health assistant. I can help you with:\n"
                    "• Clinic hours and locations\n"
                    "• Scheduling appointments\n"
                    "• Prescription refills\n"
                    "• General health questions\n\n"
                    "How can I assist you today?"
                )
```

---

## 🔧 Exercise 5: Bot Deployment

### Task 5.1: Azure Bot Service Setup

```bash
# Create App Service Plan
az appservice plan create \
  --name asp-intellihealth-bot \
  --resource-group rg-ai102-learning \
  --sku F1 \
  --is-linux

# Create Web App for Bot
az webapp create \
  --name app-intellihealth-bot \
  --resource-group rg-ai102-learning \
  --plan asp-intellihealth-bot \
  --runtime "PYTHON:3.10"

# Create Azure Bot resource
az bot create \
  --resource-group rg-ai102-learning \
  --name bot-intellihealth \
  --kind webapp \
  --sku F0 \
  --location global
```

### Task 5.2: Bot App Entry Point

```python
# app.py
from aiohttp import web
from botbuilder.core import (
    BotFrameworkAdapter,
    BotFrameworkAdapterSettings,
    ConversationState,
    MemoryStorage,
    UserState
)
from botbuilder.schema import Activity
from ai_healthcare_bot import AIHealthcareBot
import os

# Bot settings
SETTINGS = BotFrameworkAdapterSettings(
    app_id=os.getenv("MicrosoftAppId", ""),
    app_password=os.getenv("MicrosoftAppPassword", "")
)

ADAPTER = BotFrameworkAdapter(SETTINGS)

# Error handler
async def on_error(context, error):
    print(f"Error: {error}")
    await context.send_activity("Sorry, something went wrong. Please try again.")

ADAPTER.on_turn_error = on_error

# State management
MEMORY = MemoryStorage()
CONVERSATION_STATE = ConversationState(MEMORY)
USER_STATE = UserState(MEMORY)

# Create bot
BOT = AIHealthcareBot()

# Message handler
async def messages(req: web.Request) -> web.Response:
    if "application/json" in req.headers["Content-Type"]:
        body = await req.json()
    else:
        return web.Response(status=415)
    
    activity = Activity().deserialize(body)
    auth_header = req.headers.get("Authorization", "")
    
    response = await ADAPTER.process_activity(activity, auth_header, BOT.on_turn)
    
    if response:
        return web.json_response(data=response.body, status=response.status)
    return web.Response(status=201)

# Create app
APP = web.Application()
APP.router.add_post("/api/messages", messages)

if __name__ == "__main__":
    web.run_app(APP, host="0.0.0.0", port=int(os.getenv("PORT", 3978)))
```

---

## 🧹 Cleanup

```bash
# Delete bot resources
az bot delete --name bot-intellihealth --resource-group rg-ai102-learning
az webapp delete --name app-intellihealth-bot --resource-group rg-ai102-learning
az appservice plan delete --name asp-intellihealth-bot --resource-group rg-ai102-learning --yes
```

---

## ✅ Module Checklist

Before moving on, ensure you can:

- [ ] Create and query knowledge bases
- [ ] Build simple echo bots
- [ ] Implement waterfall dialogs
- [ ] Create multi-turn conversations
- [ ] Integrate AI services into bots
- [ ] Deploy bots to Azure

---

## 📚 Additional Resources

- [Bot Framework Documentation](https://learn.microsoft.com/en-us/azure/bot-service/)
- [Question Answering](https://learn.microsoft.com/en-us/azure/ai-services/language-service/question-answering/)
- [Bot Framework Samples](https://github.com/microsoft/BotBuilder-Samples)
- [Language Studio](https://language.cognitive.azure.com/)

---

**Next Module:** [Module 08: AI Search & RAG](../08-ai-search/README.md)
