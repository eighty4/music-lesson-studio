import 'package:flutter/material.dart';
import 'package:mls_ui/editor_pane.dart';
import 'package:mls_ui/editor_toolbar.dart';

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
      home: const StudioEditor(),
    );
  }
}

class StudioEditor extends StatelessWidget {
  const StudioEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(children: [
        EditorToolbar(),
        EditorPane(),
      ]),
    );
  }
}
