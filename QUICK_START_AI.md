# 🚀 Quick Start - AI Assistant

## What You Need to Do Before Testing

### 1. Install Dependencies (5 seconds)
```bash
cd /Users/achraf/Desktop/esprit/mobile/MobileAppProject
flutter pub get
```

### 2. Get Gemini API Key (2 minutes)
1. Visit: **https://makersuite.google.com/app/apikey**
2. Sign in with Google
3. Click "Create API Key"
4. Copy the key (starts with `AIza...`)

### 3. Add API Key to .env File (1 minute)
Create/edit `.env` file in project root:
```
GEMINI_API_KEY=paste_your_key_here
```

### 4. Run and Test (1 minute)
```bash
flutter run
```

Then:
- Open the app
- Tap the AI button (floating button with message icon)
- Try: "Quels sont les meilleurs restaurants ?"

---

## Example .env File

Create a file named `.env` in your project root:
```bash
# Example .env file
GEMINI_API_KEY=AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Important**: Replace with YOUR actual API key!

---

## Quick Test Queries

Once the chatbot opens, try:

1. **"Quels restaurants sont disponibles ?"**
2. **"Recommande-moi un bon restaurant"**
3. **"Je cherche des sushis"**
4. **"Quel est le restaurant le mieux noté ?"**

---

## If Something Goes Wrong

### "API key not configured"
→ Check `.env` file exists and has `GEMINI_API_KEY=your_key`

### "API key not valid"  
→ Get new key from https://makersuite.google.com/app/apikey

### Loading forever
→ Check internet connection

### No restaurants found
→ Add some restaurants to your database first

---

## Files Changed

✅ **pubspec.yaml** - Added google_generative_ai package  
✅ **lib/services/AI/GeminiService.dart** - NEW: AI service  
✅ **lib/Pages/AIChatbot.dart** - Updated with real AI  

---

## That's It!

The AI assistant will:
- Know ALL your restaurants from the database
- Provide accurate ratings and reviews
- Recommend based on real data
- Answer in French naturally
- NEVER make up fake restaurants

**Full documentation**: See `AI_ASSISTANT_IMPLEMENTATION.md`

---

**Ready to test! 🎉**

