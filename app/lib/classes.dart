import 'package:flutter/material.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  late final Future<List<String>> loadingClasses;

  @override
  void initState() {
    super.initState();
    loadingClasses = Future.delayed(const Duration(seconds: 1))
        .then((_) => List.of(['Banjo 101', 'Banjo 201']));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Classes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded(
              child: FutureBuilder(
                  future: loadingClasses,
                  builder: (context, snapshot) {
                    return switch (snapshot.connectionState) {
                      ConnectionState.done => snapshot.hasData
                          ? _ClassList(classes: snapshot.data!)
                          : const Center(child: Text('Nothing to see here.')),
                      ConnectionState.waiting => const Center(
                          child: Text('loading...',
                              style: TextStyle(color: Colors.black45))),
                      _ => const SizedBox.shrink(),
                    };
                  })),
        ],
      ),
    );
  }
}

class _ClassList extends StatelessWidget {
  final List<String> classes;

  const _ClassList({required this.classes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => Text(classes[index]),
      itemCount: classes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      shrinkWrap: true,
    );
  }
}
