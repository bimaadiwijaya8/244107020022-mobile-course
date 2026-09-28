import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TabGps extends StatefulWidget {
  const TabGps({super.key});

  @override
  State<TabGps> createState() => _TabGpsState();
}

class _TabGpsState extends State<TabGps> {
  String _locationMessage = "Menunggu lokasi...";
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationMessage = "Mencari lokasi saat ini...";
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _locationMessage = 'Layanan lokasi dinonaktifkan. Aktifkan GPS Anda.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _locationMessage = 'Izin lokasi ditolak.';
        });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _locationMessage = 'Izin lokasi ditolak secara permanen. Tidak dapat meminta izin.';
      });
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _isLoading = false;
        _locationMessage = "Lokasi Anda saat ini:\n\nLatitude: ${position.latitude}\nLongitude: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _locationMessage = 'Gagal mendapatkan lokasi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 80, color: Colors.indigo),
            const SizedBox(height: 24),
            const Text(
              "Fitur GPS",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Text(
                _locationMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text("Cek Lokasi Saya"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
