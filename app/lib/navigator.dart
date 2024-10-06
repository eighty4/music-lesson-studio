import 'package:flutter/material.dart';

import 'routing.dart';

class NavigatorMenu extends StatefulWidget {
  const NavigatorMenu({super.key});

  @override
  State<NavigatorMenu> createState() => _NavigatorMenuState();
}

class _NavigatorMenuState extends State<NavigatorMenu> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => context.goToSongbook(),
            child: const Icon(Icons.music_note_outlined, size: 25),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => context.goToClasses(),
            child: const Icon(Icons.school_outlined, size: 25),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => context.goToProfile(),
            child: const Icon(Icons.person_outlined, size: 25),
          ),
        ),
      ],
    );
  }
}
