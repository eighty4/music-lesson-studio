import 'package:flutter/widgets.dart';

class ClassData {}

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
    return FutureBuilder(
        future: loadingClasses,
        builder: (context, snapshot) {
          return switch (snapshot.connectionState) {
            ConnectionState.done => snapshot.hasData
                ? ClassList(classes: snapshot.data!)
                : const Text('Nothing to see here.'),
            _ => const SizedBox.shrink(),
          };
        });
  }
}

class ClassList extends StatelessWidget {
  final List<String> classes;

  const ClassList({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: classes.map((e) => Text(e)).toList());
  }
}
