import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tts_settings.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TTSSettings _settings;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _settings = TTSSettings.fromJson(
      SettingsService.instance.settings.toJson(),
    );
    _apiKeyController = TextEditingController(text: _settings.apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    _settings.apiKey = _apiKeyController.text;
    await SettingsService.instance.saveSettings(_settings);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  Future<void> _openApiKeyUrl() async {
    final Uri url = Uri.parse('https://studio.inworld.ai/workspaces');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Key Section
          const Text(
            'API Key',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your Inworld API Key (Base64)',
                    border: OutlineInputBorder(),
                    helperText: 'Get your API key from Inworld Portal',
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Get API Key',
                onPressed: _openApiKeyUrl,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Language Selection
          const Text(
            'Language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _settings.languageCode,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              helperText: 'Select pronunciation language',
            ),
            items: TTSSettings.availableLanguageCodes.map((code) {
              return DropdownMenuItem(
                value: code,
                child: Text(TTSSettings.languageNames[code] ?? code),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _settings.languageCode = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          // Voice Selection
          const Text(
            'Voice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _settings.voiceId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              helperText: 'Select a voice for text-to-speech',
            ),
            items: TTSSettings.availableVoices.map((voice) {
              return DropdownMenuItem(
                value: voice,
                child: Text(voice),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _settings.voiceId = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          // Model Selection
          const Text(
            'Model',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _settings.modelId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              helperText: 'Max: Best quality | Mini: Fastest',
            ),
            items: TTSSettings.availableModels.map((model) {
              return DropdownMenuItem(
                value: model,
                child: Text(model),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _settings.modelId = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          // Audio Encoding
          const Text(
            'Audio Encoding',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _settings.audioEncoding,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              helperText: 'MP3: Compressed | LINEAR16: Uncompressed WAV',
            ),
            items: TTSSettings.availableEncodings.map((encoding) {
              return DropdownMenuItem(
                value: encoding,
                child: Text(encoding),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _settings.audioEncoding = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          // Sample Rate
          const Text(
            'Sample Rate (Hz)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _settings.sampleRateHertz,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              helperText: 'Higher = Better quality but larger file',
            ),
            items: TTSSettings.availableSampleRates.map((rate) {
              return DropdownMenuItem(
                value: rate,
                child: Text('$rate Hz'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _settings.sampleRateHertz = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          // Streaming Option
          const Text(
            'Streaming',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SwitchListTile(
            title: const Text('Use Streaming Mode'),
            subtitle: const Text('Lower latency for real-time applications'),
            value: _settings.useStreaming,
            onChanged: (value) {
              setState(() {
                _settings.useStreaming = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade900),
                    const SizedBox(width: 8),
                    Text(
                      'About Inworld TTS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ' TTS-1.5-Max: Best quality, 200ms latency\n'
                  ' TTS-1.5-Mini: Fastest, 120ms latency\n'
                  ' Supports 15 languages\n'
                  ' Pricing: \$10/1M chars (Max), \$5/1M chars (Mini)',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
