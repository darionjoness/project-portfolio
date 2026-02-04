# Module 06: Speech Services

![Difficulty: Intermediate](https://img.shields.io/badge/Difficulty-Intermediate-yellow)
![Time: 3-4 hours](https://img.shields.io/badge/Time-3--4%20hours-blue)

## 🎯 Learning Objectives

By the end of this module, you will:
- Convert speech to text and text to speech
- Implement real-time transcription
- Translate speech between languages
- Customize pronunciation and voices
- Build voice-enabled healthcare applications

---

## 📖 The IntelliHealth Scenario

IntelliHealth needs speech capabilities for:

| Use Case | Capability | Value |
|----------|------------|-------|
| Doctor dictation | Speech-to-Text | Faster documentation |
| Patient instructions | Text-to-Speech | Accessibility |
| Multilingual support | Translation | Diverse patient care |
| Voice commands | Real-time recognition | Hands-free operation |

---

## 🔧 Exercise 1: Setup Speech Services

### Task 1.1: Create Speech Resource

```bash
# Create Speech resource
az cognitiveservices account create \
  --name ai-intellihealth-speech \
  --resource-group rg-ai102-learning \
  --kind SpeechServices \
  --sku F0 \
  --location eastus \
  --yes

# Get key and region
az cognitiveservices account keys list \
  --name ai-intellihealth-speech \
  --resource-group rg-ai102-learning

# Note: Speech uses region, not full endpoint
# Region: eastus
```

### Task 1.2: Install SDK

```bash
pip install azure-cognitiveservices-speech
```

### Task 1.3: Configuration

```python
# speech_config.py
import os
import azure.cognitiveservices.speech as speechsdk

def get_speech_config():
    """Create Speech SDK configuration"""
    
    key = os.getenv("AZURE_SPEECH_KEY")
    region = os.getenv("AZURE_SPEECH_REGION", "eastus")
    
    speech_config = speechsdk.SpeechConfig(
        subscription=key,
        region=region
    )
    
    return speech_config
```

---

## 🔧 Exercise 2: Speech-to-Text

### Task 2.1: Basic Speech Recognition

```python
# speech_to_text.py
import azure.cognitiveservices.speech as speechsdk
from speech_config import get_speech_config

def recognize_from_microphone():
    """Recognize speech from microphone"""
    
    speech_config = get_speech_config()
    speech_config.speech_recognition_language = "en-US"
    
    # Use default microphone
    audio_config = speechsdk.AudioConfig(use_default_microphone=True)
    
    recognizer = speechsdk.SpeechRecognizer(
        speech_config=speech_config,
        audio_config=audio_config
    )
    
    print("Speak into your microphone...")
    result = recognizer.recognize_once()
    
    if result.reason == speechsdk.ResultReason.RecognizedSpeech:
        return {
            "success": True,
            "text": result.text,
            "confidence": "high"  # Detailed confidence requires detailed results
        }
    elif result.reason == speechsdk.ResultReason.NoMatch:
        return {
            "success": False,
            "error": "No speech could be recognized"
        }
    elif result.reason == speechsdk.ResultReason.Canceled:
        cancellation = result.cancellation_details
        return {
            "success": False,
            "error": f"Recognition canceled: {cancellation.reason}"
        }

def recognize_from_file(audio_file: str):
    """Recognize speech from audio file"""
    
    speech_config = get_speech_config()
    speech_config.speech_recognition_language = "en-US"
    
    audio_config = speechsdk.AudioConfig(filename=audio_file)
    
    recognizer = speechsdk.SpeechRecognizer(
        speech_config=speech_config,
        audio_config=audio_config
    )
    
    result = recognizer.recognize_once()
    
    if result.reason == speechsdk.ResultReason.RecognizedSpeech:
        return {"success": True, "text": result.text}
    else:
        return {"success": False, "error": str(result.reason)}

# Test
if __name__ == "__main__":
    print("Testing microphone recognition...")
    result = recognize_from_microphone()
    print(result)
```

### Task 2.2: Continuous Recognition

```python
# continuous_recognition.py
import azure.cognitiveservices.speech as speechsdk
from speech_config import get_speech_config
import threading

class ContinuousSpeechRecognizer:
    """Continuous speech recognition for medical dictation"""
    
    def __init__(self, language: str = "en-US"):
        self.speech_config = get_speech_config()
        self.speech_config.speech_recognition_language = language
        
        # Enable detailed output
        self.speech_config.output_format = speechsdk.OutputFormat.Detailed
        
        # Use microphone
        self.audio_config = speechsdk.AudioConfig(use_default_microphone=True)
        
        self.recognizer = speechsdk.SpeechRecognizer(
            speech_config=self.speech_config,
            audio_config=self.audio_config
        )
        
        self.transcript = []
        self.is_running = False
        self._done = threading.Event()
    
    def start(self):
        """Start continuous recognition"""
        
        # Set up event handlers
        self.recognizer.recognizing.connect(self._on_recognizing)
        self.recognizer.recognized.connect(self._on_recognized)
        self.recognizer.session_stopped.connect(self._on_stopped)
        self.recognizer.canceled.connect(self._on_canceled)
        
        self.is_running = True
        self.recognizer.start_continuous_recognition()
        
        print("Continuous recognition started. Speak now...")
    
    def stop(self):
        """Stop continuous recognition"""
        
        self.recognizer.stop_continuous_recognition()
        self.is_running = False
        self._done.wait()
        
        return self.get_transcript()
    
    def get_transcript(self) -> str:
        """Get full transcript"""
        return " ".join(self.transcript)
    
    def _on_recognizing(self, evt):
        """Handle interim results"""
        print(f"  [Recognizing]: {evt.result.text}")
    
    def _on_recognized(self, evt):
        """Handle final results"""
        if evt.result.reason == speechsdk.ResultReason.RecognizedSpeech:
            self.transcript.append(evt.result.text)
            print(f"  [Recognized]: {evt.result.text}")
    
    def _on_stopped(self, evt):
        """Handle session stopped"""
        print("Session stopped")
        self._done.set()
    
    def _on_canceled(self, evt):
        """Handle cancellation"""
        print(f"Canceled: {evt.cancellation_details}")
        self._done.set()

# Test
if __name__ == "__main__":
    recognizer = ContinuousSpeechRecognizer()
    recognizer.start()
    
    import time
    print("\nSpeak for 10 seconds...")
    time.sleep(10)
    
    transcript = recognizer.stop()
    print(f"\n\nFull transcript:\n{transcript}")
```

### Task 2.3: Medical Dictation System

```python
# medical_dictation.py
import azure.cognitiveservices.speech as speechsdk
from speech_config import get_speech_config
import re

class MedicalDictationSystem:
    """
    Medical dictation with vocabulary optimization.
    Handles medical terms and structured formatting.
    """
    
    def __init__(self):
        self.speech_config = get_speech_config()
        self.speech_config.speech_recognition_language = "en-US"
        
        # Add custom phrases for better medical recognition
        self.phrase_list = speechsdk.PhraseListGrammar.from_recognizer(
            speechsdk.SpeechRecognizer(
                speech_config=self.speech_config,
                audio_config=speechsdk.AudioConfig(use_default_microphone=True)
            )
        )
        
        # Common medical terms that might be misrecognized
        medical_terms = [
            "hypertension", "hyperlipidemia", "hyperglycemia",
            "metformin", "lisinopril", "atorvastatin",
            "myocardial infarction", "cerebrovascular accident",
            "COPD", "CHF", "DM2", "HTN", "CAD",
            "systolic", "diastolic", "tachycardia", "bradycardia"
        ]
        
        for term in medical_terms:
            self.phrase_list.addPhrase(term)
        
        # Dictation commands
        self.commands = {
            "new paragraph": "\n\n",
            "new line": "\n",
            "period": ".",
            "comma": ",",
            "colon": ":",
            "semicolon": ";",
            "open parenthesis": "(",
            "close parenthesis": ")",
            "question mark": "?"
        }
    
    def dictate(self, timeout_seconds: int = 30) -> str:
        """
        Start dictation session.
        Automatically formats medical dictation.
        """
        
        audio_config = speechsdk.AudioConfig(use_default_microphone=True)
        recognizer = speechsdk.SpeechRecognizer(
            speech_config=self.speech_config,
            audio_config=audio_config
        )
        
        transcript_parts = []
        
        def on_recognized(evt):
            if evt.result.reason == speechsdk.ResultReason.RecognizedSpeech:
                text = self._process_commands(evt.result.text)
                transcript_parts.append(text)
                print(f"[Dictated]: {text}")
        
        recognizer.recognized.connect(on_recognized)
        
        recognizer.start_continuous_recognition()
        
        import time
        print(f"Dictating for {timeout_seconds} seconds...")
        print("Say 'new paragraph' or 'new line' for formatting.")
        print("-" * 40)
        
        time.sleep(timeout_seconds)
        
        recognizer.stop_continuous_recognition()
        
        raw_transcript = " ".join(transcript_parts)
        formatted = self._format_transcript(raw_transcript)
        
        return formatted
    
    def _process_commands(self, text: str) -> str:
        """Process dictation commands"""
        
        result = text.lower()
        for command, replacement in self.commands.items():
            result = result.replace(command, replacement)
        
        return result
    
    def _format_transcript(self, text: str) -> str:
        """Apply medical note formatting"""
        
        # Capitalize sentences
        sentences = text.split('. ')
        sentences = [s.strip().capitalize() for s in sentences if s.strip()]
        formatted = '. '.join(sentences)
        
        if not formatted.endswith('.'):
            formatted += '.'
        
        return formatted

# Test
if __name__ == "__main__":
    dictation = MedicalDictationSystem()
    
    print("Medical Dictation System")
    print("=" * 40)
    
    result = dictation.dictate(timeout_seconds=15)
    
    print("\n" + "=" * 40)
    print("Final Transcript:")
    print(result)
```

---

## 🔧 Exercise 3: Text-to-Speech

### Task 3.1: Basic Speech Synthesis

```python
# text_to_speech.py
import azure.cognitiveservices.speech as speechsdk
from speech_config import get_speech_config

def speak_text(text: str, voice: str = "en-US-JennyNeural"):
    """Convert text to speech and play through speaker"""
    
    speech_config = get_speech_config()
    speech_config.speech_synthesis_voice_name = voice
    
    # Use default speaker
    audio_config = speechsdk.AudioConfig(use_default_speaker=True)
    
    synthesizer = speechsdk.SpeechSynthesizer(
        speech_config=speech_config,
        audio_config=audio_config
    )
    
    result = synthesizer.speak_text(text)
    
    if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
        return {"success": True, "message": "Audio played successfully"}
    else:
        return {"success": False, "error": str(result.reason)}

def save_speech_to_file(text: str, output_file: str, voice: str = "en-US-JennyNeural"):
    """Save synthesized speech to audio file"""
    
    speech_config = get_speech_config()
    speech_config.speech_synthesis_voice_name = voice
    
    audio_config = speechsdk.AudioConfig(filename=output_file)
    
    synthesizer = speechsdk.SpeechSynthesizer(
        speech_config=speech_config,
        audio_config=audio_config
    )
    
    result = synthesizer.speak_text(text)
    
    if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
        return {"success": True, "file": output_file}
    else:
        return {"success": False, "error": str(result.reason)}

# Test
if __name__ == "__main__":
    # Play through speaker
    message = "Welcome to IntelliHealth. How can I help you today?"
    result = speak_text(message)
    print(result)
```

### Task 3.2: SSML for Natural Speech

```python
# ssml_speech.py
import azure.cognitiveservices.speech as speechsdk
from speech_config import get_speech_config

def speak_ssml(ssml: str):
    """Synthesize speech from SSML for better control"""
    
    speech_config = get_speech_config()
    
    synthesizer = speechsdk.SpeechSynthesizer(
        speech_config=speech_config,
        audio_config=speechsdk.AudioConfig(use_default_speaker=True)
    )
    
    result = synthesizer.speak_ssml(ssml)
    
    return result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted

def generate_patient_instructions(instructions: dict) -> str:
    """Generate SSML for patient instructions"""
    
    ssml = f"""
    <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" 
           xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="en-US">
        <voice name="en-US-JennyNeural">
            <mstts:express-as style="friendly">
                <prosody rate="slow">
                    Hello {instructions.get('patient_name', 'there')}.
                </prosody>
            </mstts:express-as>
            
            <break time="500ms"/>
            
            <prosody rate="medium">
                Here are your instructions for today.
            </prosody>
            
            <break time="300ms"/>
            
            <emphasis level="moderate">
                Medication: Take {instructions.get('medication', 'your medication')} 
                {instructions.get('dosage', '')} {instructions.get('frequency', '')}.
            </emphasis>
            
            <break time="500ms"/>
            
            <prosody rate="slow">
                {instructions.get('special_instructions', '')}
            </prosody>
            
            <break time="500ms"/>
            
            <mstts:express-as style="friendly">
                If you have any questions, please call us at 
                <say-as interpret-as="telephone">{instructions.get('phone', '555-1234')}</say-as>.
            </mstts:express-as>
        </voice>
    </speak>
    """
    
    return ssml

# Test
if __name__ == "__main__":
    instructions = {
        "patient_name": "John",
        "medication": "Metformin",
        "dosage": "500 milligrams",
        "frequency": "twice daily with meals",
        "special_instructions": "Monitor your blood sugar levels and record them in your log.",
        "phone": "555-123-4567"
    }
    
    ssml = generate_patient_instructions(instructions)
    print("Speaking patient instructions...")
    speak_ssml(ssml)
```

### Task 3.3: Voice Selection

```python
# voice_catalog.py
import azure.cognitiveservices.speech as speechsdk
from speech_config import get_speech_config

def list_available_voices(language: str = None):
    """List available neural voices"""
    
    speech_config = get_speech_config()
    synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config)
    
    result = synthesizer.get_voices_async().get()
    
    voices = []
    for voice in result.voices:
        if language is None or voice.locale.startswith(language):
            voices.append({
                "name": voice.short_name,
                "locale": voice.locale,
                "gender": str(voice.gender),
                "voice_type": voice.voice_type.name
            })
    
    return voices

# Healthcare-appropriate voices
RECOMMENDED_VOICES = {
    "en-US": {
        "professional_female": "en-US-JennyNeural",
        "professional_male": "en-US-GuyNeural",
        "warm_female": "en-US-AriaNeural",
        "warm_male": "en-US-DavisNeural"
    },
    "es-ES": {
        "female": "es-ES-ElviraNeural",
        "male": "es-ES-AlvaroNeural"
    },
    "zh-CN": {
        "female": "zh-CN-XiaoxiaoNeural",
        "male": "zh-CN-YunxiNeural"
    }
}

# Test
if __name__ == "__main__":
    print("Available English voices:")
    voices = list_available_voices("en-US")
    for v in voices[:10]:
        print(f"  {v['name']} ({v['gender']})")
```

---

## 🔧 Exercise 4: Speech Translation

### Task 4.1: Real-Time Translation

```python
# speech_translation.py
import azure.cognitiveservices.speech as speechsdk
from speech_config import get_speech_config
import os

def create_translation_config(source_language: str, target_languages: list):
    """Create translation configuration"""
    
    key = os.getenv("AZURE_SPEECH_KEY")
    region = os.getenv("AZURE_SPEECH_REGION", "eastus")
    
    translation_config = speechsdk.translation.SpeechTranslationConfig(
        subscription=key,
        region=region
    )
    
    translation_config.speech_recognition_language = source_language
    
    for lang in target_languages:
        translation_config.add_target_language(lang)
    
    return translation_config

def translate_speech(source_language: str = "en-US", target_languages: list = ["es", "zh-Hans"]):
    """Translate speech in real-time"""
    
    translation_config = create_translation_config(source_language, target_languages)
    
    audio_config = speechsdk.AudioConfig(use_default_microphone=True)
    
    recognizer = speechsdk.translation.TranslationRecognizer(
        translation_config=translation_config,
        audio_config=audio_config
    )
    
    print(f"Speak in {source_language}...")
    result = recognizer.recognize_once()
    
    if result.reason == speechsdk.ResultReason.TranslatedSpeech:
        translations = {
            "original": result.text,
            "translations": {}
        }
        
        for lang in target_languages:
            translations["translations"][lang] = result.translations[lang]
        
        return translations
    else:
        return {"error": str(result.reason)}

def translate_and_speak(source_language: str = "en-US", 
                        target_language: str = "es",
                        voice: str = "es-ES-ElviraNeural"):
    """Translate speech and synthesize in target language"""
    
    translation_config = create_translation_config(source_language, [target_language])
    translation_config.voice_name = voice
    
    audio_config = speechsdk.AudioConfig(use_default_microphone=True)
    
    recognizer = speechsdk.translation.TranslationRecognizer(
        translation_config=translation_config,
        audio_config=audio_config
    )
    
    print(f"Speak in {source_language}...")
    result = recognizer.recognize_once()
    
    if result.reason == speechsdk.ResultReason.TranslatedSpeech:
        translated_text = result.translations[target_language]
        
        # Synthesize the translation
        speech_config = get_speech_config()
        speech_config.speech_synthesis_voice_name = voice
        
        synthesizer = speechsdk.SpeechSynthesizer(
            speech_config=speech_config,
            audio_config=speechsdk.AudioConfig(use_default_speaker=True)
        )
        
        synthesizer.speak_text(translated_text)
        
        return {
            "original": result.text,
            "translated": translated_text,
            "target_language": target_language
        }
    
    return {"error": str(result.reason)}

# Test
if __name__ == "__main__":
    print("Speech Translation")
    print("=" * 40)
    
    result = translate_speech()
    print(f"\nOriginal: {result.get('original')}")
    
    for lang, translation in result.get('translations', {}).items():
        print(f"{lang}: {translation}")
```

---

## 🔧 Exercise 5: Healthcare Voice Assistant

### Complete Voice System

```python
# healthcare_voice_assistant.py
import azure.cognitiveservices.speech as speechsdk
from speech_config import get_speech_config
from typing import Optional, Callable
import threading
import time

class HealthcareVoiceAssistant:
    """
    Voice-enabled healthcare assistant.
    Supports dictation, commands, and multilingual interaction.
    """
    
    def __init__(self, language: str = "en-US"):
        self.speech_config = get_speech_config()
        self.speech_config.speech_recognition_language = language
        self.language = language
        
        # Voice for responses
        self.voices = {
            "en-US": "en-US-JennyNeural",
            "es-ES": "es-ES-ElviraNeural",
            "es-MX": "es-MX-DaliaNeural",
            "zh-CN": "zh-CN-XiaoxiaoNeural"
        }
        
        # Command handlers
        self.commands = {
            "help": self._handle_help,
            "schedule appointment": self._handle_appointment,
            "refill prescription": self._handle_refill,
            "speak to nurse": self._handle_nurse,
            "translate": self._handle_translate
        }
    
    def listen(self) -> Optional[str]:
        """Listen for voice input"""
        
        audio_config = speechsdk.AudioConfig(use_default_microphone=True)
        recognizer = speechsdk.SpeechRecognizer(
            speech_config=self.speech_config,
            audio_config=audio_config
        )
        
        print("Listening...")
        result = recognizer.recognize_once()
        
        if result.reason == speechsdk.ResultReason.RecognizedSpeech:
            return result.text
        return None
    
    def speak(self, text: str, voice: str = None):
        """Speak response"""
        
        self.speech_config.speech_synthesis_voice_name = voice or self.voices.get(self.language, "en-US-JennyNeural")
        
        synthesizer = speechsdk.SpeechSynthesizer(
            speech_config=self.speech_config,
            audio_config=speechsdk.AudioConfig(use_default_speaker=True)
        )
        
        synthesizer.speak_text(text)
    
    def process(self, text: str) -> str:
        """Process voice input and return response"""
        
        text_lower = text.lower()
        
        # Check for commands
        for command, handler in self.commands.items():
            if command in text_lower:
                return handler(text)
        
        # Default response
        return self._default_response(text)
    
    def run_interactive(self):
        """Run interactive voice assistant session"""
        
        self.speak("Hello! I'm your IntelliHealth voice assistant. How can I help you today?")
        
        while True:
            user_input = self.listen()
            
            if user_input:
                print(f"You said: {user_input}")
                
                if "goodbye" in user_input.lower() or "exit" in user_input.lower():
                    self.speak("Goodbye! Take care and stay healthy.")
                    break
                
                response = self.process(user_input)
                print(f"Assistant: {response}")
                self.speak(response)
            else:
                self.speak("I didn't catch that. Could you please repeat?")
    
    def _handle_help(self, text: str) -> str:
        return """I can help you with the following:
        Schedule an appointment.
        Refill a prescription.
        Speak to a nurse.
        Translate information.
        Just tell me what you need."""
    
    def _handle_appointment(self, text: str) -> str:
        return "I can help you schedule an appointment. What day works best for you?"
    
    def _handle_refill(self, text: str) -> str:
        return "I'll help you refill your prescription. Which medication do you need refilled?"
    
    def _handle_nurse(self, text: str) -> str:
        return "I'm connecting you with a nurse. Please hold for a moment."
    
    def _handle_translate(self, text: str) -> str:
        return "I can translate for you. What language do you need?"
    
    def _default_response(self, text: str) -> str:
        return f"I heard: {text}. Would you like me to help you schedule an appointment, refill a prescription, or speak to a nurse?"

# Test
if __name__ == "__main__":
    print("Healthcare Voice Assistant")
    print("=" * 40)
    print("Commands: 'help', 'schedule appointment', 'refill prescription', 'speak to nurse'")
    print("Say 'goodbye' to exit.")
    print()
    
    assistant = HealthcareVoiceAssistant()
    assistant.run_interactive()
```

---

## 🧹 Cleanup

```bash
# Delete Speech resource
az cognitiveservices account delete \
  --name ai-intellihealth-speech \
  --resource-group rg-ai102-learning
```

---

## ✅ Module Checklist

Before moving on, ensure you can:

- [ ] Implement speech-to-text with microphone and files
- [ ] Use continuous recognition for dictation
- [ ] Add custom phrases for medical terminology
- [ ] Synthesize speech with neural voices
- [ ] Use SSML for natural speech control
- [ ] Translate speech in real-time
- [ ] Build voice-enabled applications

---

## 📚 Additional Resources

- [Speech Service Documentation](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/)
- [Speech SDK Samples](https://github.com/Azure-Samples/cognitive-services-speech-sdk)
- [SSML Reference](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-synthesis-markup)
- [Voice Gallery](https://speech.microsoft.com/portal/voicegallery)

---

**Next Module:** [Module 07: Conversational AI](../07-conversational-ai/README.md)
