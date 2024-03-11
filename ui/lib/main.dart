import 'package:flutter/material.dart';
import 'package:mls_ui/editor_pane.dart';
import 'package:mls_ui/editor_toolbar.dart';
import 'package:mls_ui/frame_widgets.dart';

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

class StudioEditor extends StatefulWidget {
  const StudioEditor({super.key});

  @override
  State<StudioEditor> createState() => _StudioEditorState();
}

class _StudioEditorState extends State<StudioEditor> {
  List<FrameEntityWidget> frameEntityWidgets = const [FrameEntityWidget()];

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
