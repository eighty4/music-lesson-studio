import 'package:flutter/material.dart';

import 'api_client.dart';
import 'app_styles.dart';
import 'aspect_ratio.dart';
import 'editor_session.dart';
import 'frame_data.dart';

// todo replace Material font icons
class EditorHeader extends StatelessWidget {
  static const double height = 60;
  static const TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.w500, fontSize: 18, color: Color(0xFFEEFFEE));

  final FrameAspectRatio aspectRatio;
  final String lessonPlanName;
  final String lessonUnitName;
  final AspectRatioCallback onAspectRatioChanged;

  const EditorHeader(
      {super.key,
      required this.aspectRatio,
      required this.lessonPlanName,
      required this.lessonUnitName,
      required this.onAspectRatioChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyles.toolbarBackgroundColor,
      height: EditorHeader.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(lessonPlanName, style: textStyle),
            const SizedBox(width: 10),
            const Text(':', style: textStyle),
            const SizedBox(width: 10),
            Text(lessonUnitName, style: textStyle),
            const Spacer(),
            const SaveButton(),
            const SizedBox(width: 10),
            AspectRatioButton(
                aspectRatio: aspectRatio,
                onAspectRatioChanged: onAspectRatioChanged),
          ],
        ),
      ),
    );
  }
}

class SaveButton extends StatefulWidget {
  const SaveButton({super.key});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    const size = EditorHeader.height * .75;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: saving ? null : onTap,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 75),
            decoration: BoxDecoration(
              color: saving ? Colors.grey : Colors.pinkAccent,
              border: Border.all(color: Colors.greenAccent, width: 3),
              borderRadius: BorderRadius.circular(4),
            ),
            height: size,
            width: size,
            child: const Center(
                child: Icon(
              Icons.save,
              color: Colors.greenAccent,
              size: size * .75,
            ))),
      ),
    );
  }

  onTap() async {
    setState(() => saving = true);
    late final bool success;
    try {
      await ApiClient.saveLessonUnitFrames(
          EditorSession.of(context), FrameData.frames);
      success = true;
    } catch (_) {
      success = false;
    } finally {
      setState(() => saving = false);
    }
    if (mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(SnackBar(
        content: success
            ? const Text('Saved changes to cloud!')
            : const Text('Error saving to cloud!',
                style: TextStyle(color: Colors.deepOrange)),
      ));
    }
  }
}
