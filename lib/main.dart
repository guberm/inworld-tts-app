import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SettingsService.instance.loadSettings();
    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error during initialization: $e');
    debugPrint(stackTrace.toString());
    runApp(const MyApp());
  }
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
    try {
      if (files.isEmpty) return;

      final textFile = files.firstWhere(
        (file) =>
            file.type == SharedMediaType.text ||
            file.type == SharedMediaType.url,
        orElse: () => files.first,
      );

      if (textFile.type == SharedMediaType.text ||
          textFile.type == SharedMediaType.url) {
        if (mounted) {
          setState(() {
            _sharedText = textFile.path;
            debugPrint('Shared text received: $_sharedText');
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error handling shared files: $e');
      debugPrint(stackTrace.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    try {
      // For sharing text while app is closed
      ReceiveSharingIntent.instance.getInitialMedia().then((files) {
        try {
          if (files.isNotEmpty) {
            _handleSharedFiles(files);
            ReceiveSharingIntent.instance.reset();
          }
        } catch (e) {
          debugPrint("Error processing initial media: $e");
        }
      }).catchError((err) {
        debugPrint("Error getting initial media: $err");
      });

      // For sharing text while app is running
      _intentDataStreamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen((files) {
        try {
          if (files.isNotEmpty) {
            _handleSharedFiles(files);
            ReceiveSharingIntent.instance.reset();
          }
        } catch (e) {
          debugPrint("Error processing media stream: $e");
        }
      }, onError: (err) {
        debugPrint("Error in sharing intent: $err");
      });
    } catch (e, stackTrace) {
      debugPrint("Error setting up sharing intent: $e");
      debugPrint(stackTrace.toString());
      // Create an empty subscription to avoid null errors
      _intentDataStreamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen((_) {});
    }
  }

  @override
  void dispose() {
    try {
      _intentDataStreamSubscription.cancel();
    } catch (e) {
      debugPrint('Error canceling subscription: $e');
    }
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
