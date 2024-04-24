import 'package:flutter/material.dart';

import 'studio_editor.dart';

void main() {
  runApp(const StudioEditorApp());
}

class StudioEditorApp extends StatelessWidget {
  const StudioEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Lesson Studio UI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(body: StudioEditor()),
    );
  }
}
