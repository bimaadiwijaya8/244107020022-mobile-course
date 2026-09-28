import 'package:flutter/material.dart';

class TabQueue extends StatefulWidget {
  const TabQueue({super.key});

  @override
  State<TabQueue> createState() => _TabQueueState();
}

class _TabQueueState extends State<TabQueue> {
  final List<String> _upNextQueue = [
    'Story of My Life - One Direction',
    'What Makes You Beautiful - One Direction',
    'Steal My Girl - One Direction',
    'Perfect - One Direction',
    'History - One Direction'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Up Next (Tahan untuk geser urutan)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) newIndex -= 1;
                final item = _upNextQueue.removeAt(oldIndex);
                _upNextQueue.insert(newIndex, item);
              });
            },
            children: _upNextQueue.map((song) => ListTile(
              key: ValueKey(song),
              leading: const Icon(Icons.drag_handle),
              title: Text(song),
              trailing: const Icon(Icons.play_arrow_outlined),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
