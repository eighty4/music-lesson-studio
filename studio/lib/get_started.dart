import 'package:flutter/widgets.dart';

class GetStartedLanding extends StatefulWidget {
  final VoidCallback onNavToComposeMeasure;
  final VoidCallback onNavToEditor;

  const GetStartedLanding({
    super.key,
    required this.onNavToComposeMeasure,
    required this.onNavToEditor,
  });

  @override
  State<GetStartedLanding> createState() => _GetStartedLandingState();
}

class _GetStartedLandingState extends State<GetStartedLanding> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LaunchEditorLink(
            onTap: widget.onNavToEditor,
            text: 'Create a lesson plan from scratch!',
          ),
          const SizedBox(height: 20),
          LaunchEditorLink(
            onTap: widget.onNavToComposeMeasure,
            text: 'Start designing a practice measure!',
          ),
        ],
      ),
    );
  }
}

class LaunchEditorLink extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const LaunchEditorLink({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: Text(text)),
    );
  }
}
