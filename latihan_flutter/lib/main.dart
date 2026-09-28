import 'package:flutter/material.dart';
import 'package:latihan_flutter/tab_now_playing.dart';
import 'package:latihan_flutter/tab_queue.dart';
import 'package:latihan_flutter/tab_gallery.dart';
import 'package:latihan_flutter/tab_details.dart';
import 'package:latihan_flutter/tab_gps.dart';
import 'package:camera/camera.dart';
import 'package:latihan_flutter/camera_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const NightChangesApp());
}

class NightChangesApp extends StatelessWidget {
  const NightChangesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Night Changes',
      theme: ThemeData(

        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MainSongScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainSongScreen extends StatefulWidget {
  const MainSongScreen({super.key});

  @override
  State<MainSongScreen> createState() => _MainSongScreenState();
}

class _MainSongScreenState extends State<MainSongScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Night Changes - 1D'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _showMessage(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Share Song', child: Text('Share')),
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: const [
          TabNowPlaying(),
          TabQueue(),
          TabGallery(),
          TabDetails(),
          TabGps(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: 'Player'),
          BottomNavigationBarItem(icon: Icon(Icons.queue_music), label: 'Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: 'Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Details'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'GPS'),
        ],
      ),
    );
  }
}
