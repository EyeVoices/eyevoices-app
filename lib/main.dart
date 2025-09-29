import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(EyeVoicesApp(cameras: cameras));
}

class EyeVoicesApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const EyeVoicesApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EyeVoices',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}
