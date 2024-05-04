import 'package:flutter/material.dart';

import 'app_styles.dart';
import 'aspect_ratio.dart';

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
            AspectRatioButton(
                aspectRatio: aspectRatio,
                onAspectRatioChanged: onAspectRatioChanged),
          ],
        ),
      ),
    );
  }
}
