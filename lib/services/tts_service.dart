import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/tts_settings.dart';

class TTSService {
  static const String baseUrl = 'https://api.inworld.ai/tts/v1/voice';
  static const String streamUrl = 'https://api.inworld.ai/tts/v1/voice:stream';

  Future<File> generateTTS(String text, TTSSettings settings) async {
    if (settings.apiKey.isEmpty) {
      throw Exception('API Key is not set. Please add it in Settings.');
    }

    if (settings.useStreaming) {
      return await _generateStreamingTTS(text, settings);
    } else {
      return await _generateSimpleTTS(text, settings);
    }
  }

  Future<File> _generateSimpleTTS(String text, TTSSettings settings) async {
    final headers = {
      'Authorization': 'Basic ${settings.apiKey}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> payload = {
      'text': text,
      'voiceId': settings.voiceId,
      'modelId': settings.modelId,
    };

    // Add audio_config if not MP3
    if (settings.audioEncoding != 'MP3') {
      payload['audio_config'] = {
        'audio_encoding': settings.audioEncoding,
        'sample_rate_hertz': settings.sampleRateHertz,
      };
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate TTS: ${response.statusCode} - ${response.body}');
    }

    final result = jsonDecode(response.body);
    final audioContent = base64Decode(result['audioContent']);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileExtension = settings.audioEncoding == 'MP3' ? 'mp3' : 'wav';
    final file = File('${directory.path}/output_${DateTime.now().millisecondsSinceEpoch}.$fileExtension');
    await file.writeAsBytes(audioContent);

    return file;
  }

  Future<File> _generateStreamingTTS(String text, TTSSettings settings) async {
    final headers = {
      'Authorization': 'Basic ${settings.apiKey}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> payload = {
      'text': text,
      'voiceId': settings.voiceId,
      'modelId': settings.modelId,
      'audio_config': {
        'audio_encoding': settings.audioEncoding,
        'sample_rate_hertz': settings.sampleRateHertz,
      },
    };

    final request = http.Request('POST', Uri.parse(streamUrl));
    request.headers.addAll(headers);
    request.body = jsonEncode(payload);

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      throw Exception('Failed to generate streaming TTS: ${streamedResponse.statusCode} - $errorBody');
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileExtension = settings.audioEncoding == 'LINEAR16' ? 'wav' : 'mp3';
    final file = File('${directory.path}/output_stream_${DateTime.now().millisecondsSinceEpoch}.$fileExtension');
    
    final audioData = <int>[];
    bool firstChunk = true;

    await for (var line in streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.isNotEmpty) {
        final chunk = jsonDecode(line);
        final audioChunk = base64Decode(chunk['result']['audioContent']);
        
        // Skip WAV header for subsequent chunks
        if (firstChunk) {
          audioData.addAll(audioChunk);
          firstChunk = false;
        } else if (audioChunk.length > 44) {
          audioData.addAll(audioChunk.sublist(44));
        }
      }
    }

    await file.writeAsBytes(audioData);
    return file;
  }
}
