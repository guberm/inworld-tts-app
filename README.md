# Inworld TTS App

Flutter Android application that uses Inworld AI TTS API to generate speech from text with full configuration support.

## Features

-  **Text Sharing**: Receive text via Android Share Intent (share text from any app)
-  **TTS Generation**: Convert text to speech using Inworld AI API
-  **Multi-Language**: Support for 15 languages (English, Chinese, Korean, Japanese, Russian, Italian, Spanish, Portuguese, German, French, Arabic, Polish, Dutch, Hindi, Hebrew)
-  **Full API Configuration**:
  - Voice selection (22 voices)
  - Model selection (TTS-1.5-Max or TTS-1.5-Mini)
  - Audio encoding (MP3 or LINEAR16)
  - Sample rate (16000-48000 Hz)
  - Streaming mode
-  **Secure Storage**: API key saved locally
-  **Built-in Player**: Audio playback with play/pause controls

## Installation

### Prerequisites
- Flutter SDK >= 3.0.0
- Android SDK 21+
- Inworld API Key

### Setup

1. Verify Flutter installation:
```bash
flutter doctor
```

2. Install dependencies:
```bash
flutter pub get
```

3. Build APK:
```bash
flutter build apk --release
```

## Usage

### 1. Get API Key
- Sign up at [Inworld Studio](https://studio.inworld.ai/)
- Navigate to Settings > API Keys
- Copy your Base64 credentials

### 2. Configure App
- Open Settings ( icon)
- Paste your API key in the "API Key" field
- Select your preferred voice and model
- Click "Save Settings"

### 3. Generate Speech
- Enter text manually or share text from another app
- Select language and voice
- Click "Generate Speech"
- Audio will automatically play when ready

## Configuration Options

### Languages (15)
English (US), Chinese, Korean, Japanese, Russian, Italian, Spanish, Portuguese, German, French, Arabic, Polish, Dutch, Hindi, Hebrew

### Voices (22)
Ashley, Alex, Craig, Deborah, Dennis, Edward, Elizabeth, Julia, Mark, Olivia, Sarah, and more

### Models
- **inworld-tts-1.5-max**: Best quality, 200ms latency
- **inworld-tts-1.5-mini**: Fastest, 120ms latency

### Audio Format
- **MP3**: Compressed, smaller file size
- **LINEAR16**: Uncompressed WAV, best quality

### Sample Rates
16000, 22050, 24000, 44100, or 48000 Hz

## Dependencies

- `http` - API requests
- `shared_preferences` - Settings persistence
- `receive_sharing_intent` - Text sharing from other apps
- `audioplayers` - Audio playback
- `path_provider` - File system access
- `permission_handler` - Android permissions
- `url_launcher` - Open API key portal

## API Pricing

- TTS-1.5-Max: $10 per 1M characters
- TTS-1.5-Mini: $5 per 1M characters

## Project Structure

```
lib/
 main.dart                    # App entry point
 models/
    tts_settings.dart        # Settings data model
 services/
    tts_service.dart         # Inworld API integration
    settings_service.dart    # Persistent storage
 screens/
     home_screen.dart         # Main UI
     settings_screen.dart     # Configuration panel
```

## License

MIT

## Author

Michael Guber (guberm@gmail.com)

## Links

- [Inworld AI Documentation](https://platform.inworld.ai/v2/documentation/docs/quickstart-tts)
- [Inworld Studio](https://studio.inworld.ai/)
