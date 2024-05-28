import 'package:flutter/widgets.dart';

class GetStartedLanding extends StatefulWidget {
  final VoidCallback onNavToEditor;

  const GetStartedLanding({super.key, required this.onNavToEditor});

  @override
  State<GetStartedLanding> createState() => _GetStartedLandingState();
}

class _GetStartedLandingState extends State<GetStartedLanding> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: widget.onNavToEditor,
            child: const Text('Click here to start designing a lesson!')),
      ),
    );
  }
}
