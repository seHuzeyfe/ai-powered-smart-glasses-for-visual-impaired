import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32-CAM Stream',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const VideoStreamPage(),
    );
  }
}

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({Key? key}) : super(key: key);

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  late VlcPlayerController _vlcPlayerController;

  @override
  void initState() {
    super.initState();
    _vlcPlayerController = VlcPlayerController.network(
      'http://192.168.1.50/mjpeg/1', // Make sure this is the correct IP
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(3000),
          '--verbose=2', // High verbosity for debugging
          '--log-verbose=2', // Set the verbosity of the log
          '--file-logging', // Enable file logging
          '--logfile=vlc-log.txt' // Specify the log file location
        ]),
        http: VlcHttpOptions([
          '--http-reconnect', // Enable HTTP reconnect
          '--http-forward-cookies', // Forward cookies
          '--no-http-referrer', // Do not send HTTP referrer
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32-CAM Stream'),
      ),
      body: Center(
        child: VlcPlayer(
          controller: _vlcPlayerController,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _vlcPlayerController.dispose();
    super.dispose();
  }
}
