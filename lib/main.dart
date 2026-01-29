import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.loadSettings();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;
  String? _sharedText;

  void _handleSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;

    final textFile = files.firstWhere(
      (file) => file.type == SharedMediaType.text || file.type == SharedMediaType.url,
      orElse: () => files.first,
    );

    if (textFile.type == SharedMediaType.text || textFile.type == SharedMediaType.url) {
      setState(() {
        _sharedText = textFile.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // For sharing text while app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) {
        _handleSharedFiles(files);
        ReceiveSharingIntent.instance.reset();
      }
    });

    // For sharing text while app is running
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      if (files.isNotEmpty) {
        _handleSharedFiles(files);
      }
    }, onError: (err) {
      debugPrint("Error in sharing intent: $err");
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inworld TTS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(sharedText: _sharedText),
    );
  }
}
