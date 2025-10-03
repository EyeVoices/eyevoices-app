import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';
import 'config/app_theme.dart';

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Standardmäßig im Light Mode
      home: HomeScreen(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
} 
