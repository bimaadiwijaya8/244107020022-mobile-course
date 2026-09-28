import 'package:flutter/material.dart';
import 'package:latihan_flutter/camera_app.dart';

class TabGallery extends StatefulWidget {
  const TabGallery({super.key});

  @override
  State<TabGallery> createState() => _TabGalleryState();
}

class _TabGalleryState extends State<TabGallery> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(10),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity((index % 6 + 1) * 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.album, size: 60, color: Colors.white),
            ),
          );
        },
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'camera_btn',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraApp()),
          );
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Buka Kamera'),
      ),
    );
  }
}
