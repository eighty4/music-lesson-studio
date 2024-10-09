import 'package:flutter/widgets.dart';

class PlaySongScreen extends StatefulWidget {
  final String songId;

  const PlaySongScreen({super.key, required this.songId});

  @override
  State<PlaySongScreen> createState() => _PlaySongScreenState();
}

class _PlaySongScreenState extends State<PlaySongScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Your song: ${widget.songId}'));
  }
}
