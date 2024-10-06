import 'package:flutter/material.dart';

import 'routing.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color.fromARGB(255, 16, 16, 16)),
                  child: const Center(
                      child: Icon(
                    Icons.music_note,
                    color: Colors.lightBlueAccent,
                    size: 20,
                  ))),
              const SizedBox(width: 15),
              const Text('Music Lesson Studio', style: TextStyle(fontSize: 27)),
            ],
          ),
          ElevatedButton(
              onPressed: () => context.goToLogin(),
              child: const Text('Continue to login'))
        ],
      ),
    );
  }
}
