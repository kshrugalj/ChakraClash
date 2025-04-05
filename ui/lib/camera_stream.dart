import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'websocket_client.dart';

class CameraStreamPage extends StatefulWidget {
  const CameraStreamPage({super.key});

  @override
  _CameraStreamPageState createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  CameraController? controller;
  Timer? captureTimer;

  @override
  void initState() {
    super.initState();
    initCamera();
//    WebSocketClient.connect();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final cam = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    controller = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();

    setState(() {});

    // Periodically take a picture and send it
    captureTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!controller!.value.isInitialized || controller!.value.isTakingPicture) return;

      try {
        final XFile picture = await controller!.takePicture();
        final bytes = await picture.readAsBytes();
        final base64Image = base64Encode(bytes);
        WebSocketClient.sendImage(base64Image);
      } catch (e) {
        print("Capture error: $e");
      }
    });
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    controller?.dispose();
    WebSocketClient.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Pose Estimation')),
      body: controller?.value.isInitialized ?? false
          ? CameraPreview(controller!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
