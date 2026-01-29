import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../models/tts_settings.dart';
import '../services/tts_service.dart';
import '../services/settings_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? sharedText;

  const HomeScreen({super.key, this.sharedText});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final TTSService _ttsService = TTSService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isGenerating = false;
  bool _isPlaying = false;
  File? _currentAudioFile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.sharedText != null) {
      _textController.text = widget.sharedText!;
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sharedText != null &&
        widget.sharedText != oldWidget.sharedText) {
      _textController.text = widget.sharedText!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _generateTTS() async {
    if (_textController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter some text';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final settings = SettingsService.instance.settings;
      final audioFile = await _ttsService.generateTTS(
        _textController.text,
        settings,
      );

      setState(() {
        _currentAudioFile = audioFile;
        _isGenerating = false;
      });

      // Auto-play the generated audio
      await _playAudio();
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _playAudio() async {
    if (_currentAudioFile == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_currentAudioFile!.path));
    }
  }

  Future<void> _updateSetting() async {
    await SettingsService.instance.saveSettings(
      SettingsService.instance.settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inworld TTS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              setState(() {}); // Refresh to reflect settings changes
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language and Voice Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButton<String>(
                        value: settings.languageCode,
                        isExpanded: true,
                        items: TTSSettings.availableLanguageCodes.map((code) {
                          return DropdownMenuItem(
                            value: code,
                            child: Text(
                              TTSSettings.languageNames[code] ?? code,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              settings.languageCode = value;
                            });
                            _updateSetting();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButton<String>(
                        value: settings.voiceId,
                        isExpanded: true,
                        items: TTSSettings.availableVoices.map((voice) {
                          return DropdownMenuItem(
                            value: voice,
                            child: Text(
                              voice,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              settings.voiceId = value;
                            });
                            _updateSetting();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Text input
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Enter text to convert to speech...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),

            // Generate button
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateTTS,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.mic),
              label: Text(_isGenerating ? 'Generating...' : 'Generate Speech'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            // Play button
            if (_currentAudioFile != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _playAudio,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(_isPlaying ? 'Pause' : 'Play Audio'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            // Settings info
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Settings:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Model: ${settings.modelId}',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                  Text(
                    'API Key: ${settings.apiKey.isEmpty ? "Not set" : "Set"}',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
