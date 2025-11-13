# AI Assistant Configuration

## Google Gemini Integration

The FoodFinder app uses Google Gemini AI to provide intelligent restaurant recommendations and assistance.

### Setup Instructions

1. **Get your Gemini API Key:**
   - Visit: https://makersuite.google.com/app/apikey
   - Sign in with your Google account
   - Create a new API key
   - Copy the API key

2. **Configure the API Key:**
   - Open (or create) the `.env` file in the project root
   - Add the following line:
     ```
     GEMINI_API_KEY=your_actual_api_key_here
     ```
   - Replace `your_actual_api_key_here` with your actual Gemini API key

3. **Example .env file:**
   ```
   # Google Gemini API Configuration
   GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

### Features

The AI assistant provides:
- **Restaurant Recommendations**: Based on your preferences and database
- **Dish Suggestions**: Find specific dishes across all restaurants
- **Contextual Answers**: Get information about ratings, locations, and more
- **Conversational Interface**: Natural language understanding

### How it Works

1. **Initialization**: When you open the chatbot, the service:
   - Loads the Gemini API key from `.env`
   - Fetches all restaurants, dishes, and ratings from local database
   - Creates a context-aware chat session

2. **Database Context**: The AI has access to:
   - All restaurants with their ratings and reviews
   - Complete menu listings with prices
   - User review history and preferences
   - Top-rated restaurants

3. **Smart Responses**: The AI:
   - Only recommends restaurants from your actual database
   - Provides accurate ratings and information
   - Suggests relevant dishes and cuisines
   - Helps users make informed decisions

### Security Notes

- Never commit your `.env` file to version control
- The `.env` file is already in `.gitignore`
- Keep your API key confidential
- Don't share your API key publicly

### Troubleshooting

**"La clé API Gemini n'est pas configurée"**
- Make sure `.env` file exists in project root
- Check that `GEMINI_API_KEY` is properly set
- Restart the app after adding the key

**"API key not valid"**
- Verify your API key is correct
- Check if the API key has necessary permissions
- Ensure you've enabled the Gemini API in Google Cloud Console

**"Service not initialized"**
- Check your internet connection
- Verify the API key format (should start with AIza...)
- Check if you have quota/rate limits on your API key

### API Limits

Google Gemini has usage limits:
- Free tier: 60 requests per minute
- Consider implementing caching for production
- Monitor your API usage in Google Cloud Console

### Development

The service is located at:
- `lib/services/AI/GeminiService.dart` - Main AI service
- `lib/Pages/AIChatbot.dart` - UI implementation

To modify the AI behavior:
- Edit the system prompt in `_buildSystemPrompt()` method
- Adjust the model parameters in `initialize()` method
- Update context data in `_getContextData()` method

