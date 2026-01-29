class TTSSettings {
  String apiKey;
  String voiceId;
  String modelId;
  String audioEncoding;
  int sampleRateHertz;
  bool useStreaming;
  String languageCode;

  TTSSettings({
    this.apiKey = '',
    this.voiceId = 'Ashley',
    this.modelId = 'inworld-tts-1.5-max',
    this.audioEncoding = 'MP3',
    this.sampleRateHertz = 48000,
    this.useStreaming = false,
    this.languageCode = 'EN_US',
  });

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'voiceId': voiceId,
      'modelId': modelId,
      'audioEncoding': audioEncoding,
      'sampleRateHertz': sampleRateHertz,
      'useStreaming': useStreaming,
      'languageCode': languageCode,
    };
  }

  factory TTSSettings.fromJson(Map<String, dynamic> json) {
    return TTSSettings(
      apiKey: json['apiKey'] ?? '',
      voiceId: json['voiceId'] ?? 'Ashley',
      modelId: json['modelId'] ?? 'inworld-tts-1.5-max',
      audioEncoding: json['audioEncoding'] ?? 'MP3',
      sampleRateHertz: json['sampleRateHertz'] ?? 48000,
      useStreaming: json['useStreaming'] ?? false,
      languageCode: json['languageCode'] ?? 'EN_US',
    );
  }

  // Available voices based on documentation
  static const List<String> availableVoices = [
    'Alex',
    'Ashley',
    'Craig',
    'Deborah',
    'Dennis',
    'Dominus',
    'Edward',
    'Elizabeth',
    'Hades',
    'Heitor',
    'Julia',
    'Maitê',
    'Mark',
    'Olivia',
    'Pixie',
    'Priya',
    'Ronald',
    'Sarah',
    'Shaun',
    'Theodore',
    'Timothy',
    'Wendy',
  ];

  // Available models
  static const List<String> availableModels = [
    'inworld-tts-1.5-max',
    'inworld-tts-1.5-mini',
  ];

  // Audio encoding options
  static const List<String> availableEncodings = [
    'MP3',
    'LINEAR16',
  ];

  // Sample rate options
  static const List<int> availableSampleRates = [
    16000,
    22050,
    24000,
    44100,
    48000,
  ];

  // Language codes from Inworld API
  static const List<String> availableLanguageCodes = [
    'EN_US',
    'ZH_CN',
    'KO_KR',
    'JA_JP',
    'RU_RU',
    'IT_IT',
    'ES_ES',
    'PT_BR',
    'DE_DE',
    'FR_FR',
    'AR_SA',
    'PL_PL',
    'NL_NL',
    'HI_IN',
    'HE_IL',
  ];

  // Language display names
  static const Map<String, String> languageNames = {
    'EN_US': 'English (US)',
    'ZH_CN': 'Chinese (Simplified)',
    'KO_KR': 'Korean',
    'JA_JP': 'Japanese',
    'RU_RU': 'Russian',
    'IT_IT': 'Italian',
    'ES_ES': 'Spanish',
    'PT_BR': 'Portuguese (Brazil)',
    'DE_DE': 'German',
    'FR_FR': 'French',
    'AR_SA': 'Arabic',
    'PL_PL': 'Polish',
    'NL_NL': 'Dutch',
    'HI_IN': 'Hindi',
    'HE_IL': 'Hebrew',
  };
}
