import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    if (cameras.isNotEmpty) {
      controller = CameraController(cameras[0], ResolutionPreset.max);
      controller
          .initialize()
          .then((_) {
            if (!mounted) {
              return;
            }
            setState(() {});
          })
          .catchError((Object e) {
            if (e is CameraException) {
              switch (e.code) {
                case 'CameraAccessDenied':
                  // Handle access errors here.
                  break;
                default:
                  // Handle other errors here.
                  break;
              }
            }
          });
    }
  }

  @override
  void dispose() {
    if (cameras.isNotEmpty) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera App')),
        body: const Center(child: Text('Tidak ada kamera ditemukan')),
      );
    }
    if (!controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Diubah dari MaterialApp(home: CameraPreview) menjadi Scaffold agar tombol Back berfungsi
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
      ),
      body: Center(
        child: CameraPreview(controller),
      ),
    );
  }
}
