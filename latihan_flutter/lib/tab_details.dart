import 'package:flutter/material.dart';

class TabDetails extends StatelessWidget {
  const TabDetails({super.key});

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tags & Genre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Pop')),
              Chip(label: Text('Boyband')),
              Chip(label: Text('2014')),
              Chip(label: Text('Acoustic')),
              Chip(label: Text('One Direction')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Aksi Lainnya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => _showMessage(context, 'Membuka album penuh...'),
                child: const Text('Play Album'),
              ),
              OutlinedButton(
                onPressed: () => _showMessage(context, 'Mengunduh lagu...'),
                child: const Text('Download'),
              ),
              TextButton(
                onPressed: () => _showMessage(context, 'Menampilkan profil 1D...'),
                child: const Text('View Artist'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Komentar Fans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Directioner ${index + 1}'),
                subtitle: const Text('Lagu ini mengingatkanku pada masa lalu! 💖😭'),
              );
            },
          ),
        ],
      ),
    );
  }
}
