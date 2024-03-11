import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mls_ui/editor_data.dart';
import 'package:mls_ui/editor_styles.dart';
import 'package:mls_ui/frame_data.dart';

class EditorToolbar extends StatefulWidget {
  const EditorToolbar({super.key});

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  EntityType? addingEntityType;
  late final StreamSubscription addingEntityTypeSub;

  @override
  void initState() {
    super.initState();
    addingEntityTypeSub = EditorData.interactionState.listen(
        (editorInteraction) => setState(() =>
            addingEntityType = editorInteraction?.addingEntity?.entityType));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EditorStyleVariables.toolbarBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ToolbarButton(
                icon: Icons.image,
                active: addingEntityType == EntityType.imageUpload,
                semanticLabel: 'Add image file',
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.imageUpload)),
            const SizedBox(width: 2),
            ToolbarButton(
                icon: Icons.text_fields,
                active: addingEntityType == EntityType.paragraphText,
                semanticLabel: 'Add paragraph text',
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.paragraphText)),
            const SizedBox(width: 2),
            ToolbarButton(
                icon: Icons.videocam,
                active: addingEntityType == EntityType.videoRecord,
                semanticLabel: 'Add webcam video',
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.videoRecord)),
            const SizedBox(width: 2),
            ToolbarButton(
                icon: Icons.music_note,
                active: addingEntityType == EntityType.measureChart,
                semanticLabel: 'Add music chart',
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.measureChart)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    addingEntityTypeSub.cancel();
  }
}

class ToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String? semanticLabel;
  final VoidCallback onActivate;

  const ToolbarButton(
      {super.key,
      required this.icon,
      required this.active,
      required this.onActivate,
      this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActivate,
      child: Container(
        decoration: BoxDecoration(
            color: active
                ? Colors.green
                : EditorStyleVariables.toolbarButtonBackgroundColor,
            border:
                Border.all(color: EditorStyleVariables.borderColor, width: 2)),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: EditorStyleVariables.toolbarButtonGraphicColor,
          size: 24.0,
          semanticLabel: 'Add text entity',
        ),
      ),
    );
  }
}
