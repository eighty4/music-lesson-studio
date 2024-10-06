import 'package:flutter/widgets.dart';

const songs = [
  ("Black Mountain Rag",),
  ("I've Been All Around This World",),
  ("Little Maggie",),
  ("Nine Pound Hammer",),
  ("Reuben's Train",),
  ("Wayfaring Stranger",),
  ("Will the Circle Be Unbroken",),
];

class SongbookScreen extends StatelessWidget {
  const SongbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Songbook',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) => Text(songs[index].$1),
              itemCount: songs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
