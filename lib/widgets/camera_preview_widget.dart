import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraService cameraService;
  final bool isBlinkDetectionEnabled;

  const CameraPreviewWidget({
    super.key,
    required this.cameraService,
    required this.isBlinkDetectionEnabled,
  });

  @override
  Widget build(BuildContext context) {
    if (!cameraService.isInitialized) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.purple),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isBlinkDetectionEnabled ? Colors.green : Colors.orange,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: double.infinity,
                height: 120,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CameraPreview(cameraService.cameraController!),
                  ),
                ),
              ),
            ),
          ),
          if (isBlinkDetectionEnabled)
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.remove_red_eye, color: Colors.green, size: 30),
            ),
        ],
      ),
    );
  }
}
