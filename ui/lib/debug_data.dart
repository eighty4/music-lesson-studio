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
    interactionSubscription =
        EditorData.interactionState.listen((event) => setState(() {
              interactions = [event, ...interactions];
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            interactions.length,
            (i) => Text(
                interactions[i] == null ? 'null' : interactions[i].toString(),
                style: TextStyle(
                    fontWeight: i == 0 ? FontWeight.bold : null,
                    color: i == 0
                        ? null
                        : Color.fromARGB(
                            (((interactions.length - i) / interactions.length) *
                                    255)
                                .toInt()
                                .clamp(50, 205),
                            0,
                            0,
                            0)))));
  }

  @override
  void dispose() {
    super.dispose();
    interactionSubscription.cancel();
  }
}
