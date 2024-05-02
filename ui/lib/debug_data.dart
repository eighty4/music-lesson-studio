import 'dart:async';

import 'package:flutter/widgets.dart';

import 'editor_data.dart';

// todo dev tools extension
class DebugData extends StatefulWidget {
  const DebugData({super.key});

  @override
  State<DebugData> createState() => _DebugDataState();
}

class _DebugDataState extends State<DebugData> {
  List<EditorInteraction?> interactions = [];
  late final StreamSubscription interactionSubscription;

  @override
  void initState() {
    super.initState();
    interactionSubscription = EditorData.interactionState
        .listen((event) => setState(() => interactions.insert(0, event)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            interactions.length,
            (i) => Text(interactions[i] == null ? 'null' : label(i),
                style: TextStyle(
                    fontWeight: i == 0 ? FontWeight.bold : null,
                    color: i == 0 ? null : color(i)))));
  }

  Color color(int i) {
    final alpha = (((interactions.length - i) / interactions.length) * 255)
        .toInt()
        .clamp(50, 205);
    return Color.fromARGB(alpha, 0, 0, 0);
  }

  String label(int i) {
    String s = interactions[i].toString();
    return s.substring(s.indexOf('{') + 1, s.indexOf('}'));
  }

  @override
  void dispose() {
    super.dispose();
    interactionSubscription.cancel();
  }
}
