import 'dart:async';

import 'package:flutter/material.dart';

import 'app_styles.dart';
import 'aspect_ratio.dart';
import 'editor_data.dart';
import 'entity_data.dart';

// todo replace Material font icons
class EditorToolbar extends StatefulWidget {
  static const double height = 80;
  final FrameAspectRatio aspectRatio;
  final AspectRatioCallback onAspectRatioChanged;

  const EditorToolbar(
      {super.key,
      required this.aspectRatio,
      required this.onAspectRatioChanged});

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
    return GestureDetector(
      onTap: () => {
        if (addingEntityType == null) {EditorData.clearCurrentInteraction()}
      },
      child: Container(
        color: AppStyles.toolbarBackgroundColor,
        height: EditorToolbar.height,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconToolbarButton(
                  icon: Icons.text_fields,
                  active: addingEntityType == EntityType.paragraphText,
                  onActivate: createActivateCallback(EntityType.paragraphText)),
              const SizedBox(width: 2),
              IconToolbarButton(
                  icon: Icons.image,
                  active: addingEntityType == EntityType.imageUpload,
                  onActivate: createActivateCallback(EntityType.imageUpload)),
              const SizedBox(width: 2),
              IconToolbarButton(
                  icon: Icons.videocam,
                  active: addingEntityType == EntityType.videoRecord,
                  onActivate: createActivateCallback(EntityType.videoRecord)),
              const SizedBox(width: 2),
              LabeledIconToolbarButton(
                  icon: Icons.music_note,
                  label: 'Measure',
                  active: addingEntityType == EntityType.measureChart,
                  onActivate: createActivateCallback(EntityType.measureChart)),
              const SizedBox(width: 2),
              LabeledIconToolbarButton(
                  icon: Icons.music_note,
                  label: 'Chord',
                  active: addingEntityType == EntityType.chordChart,
                  onActivate: createActivateCallback(EntityType.chordChart)),
              const SizedBox(width: 2),
              AspectRatioButton(
                  aspectRatio: widget.aspectRatio,
                  onAspectRatioChanged: widget.onAspectRatioChanged),
            ],
          ),
        ),
      ),
    );
  }

  ActivateCallback createActivateCallback(EntityType entityType) {
    return (isActivated) {
      if (isActivated) {
        EditorData.startAddEntityInteraction(entityType);
      } else {
        EditorData.clearCurrentInteraction();
      }
    };
  }

  @override
  void dispose() {
    super.dispose();
    addingEntityTypeSub.cancel();
  }
}

typedef ActivateCallback = Function(bool);

class ToolbarButton extends StatelessWidget {
  final Widget child;
  final bool active;
  final ActivateCallback onActivate;

  const ToolbarButton(
      {super.key,
      required this.child,
      required this.active,
      required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onActivate(!active),
      child: Container(
        decoration: BoxDecoration(
            color: active
                ? AppStyles.toolbarButtonActiveBackgroundColor
                : AppStyles.toolbarButtonBackgroundColor,
            border: Border.all(color: AppStyles.toolbarBorderColor, width: 2)),
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}

class IconToolbarButton extends ToolbarButton {
  IconToolbarButton(
      {super.key,
      required IconData icon,
      required super.active,
      required super.onActivate})
      : super(
            child: Icon(
          icon,
          color: AppStyles.toolbarButtonGraphicColor,
          size: 24.0,
        ));
}

class LabeledIconToolbarButton extends ToolbarButton {
  LabeledIconToolbarButton(
      {super.key,
      required IconData icon,
      required String label,
      required super.active,
      required super.onActivate})
      : super(
            child: Row(children: [
          Icon(
            icon,
            color: AppStyles.toolbarButtonGraphicColor,
            size: 24.0,
          ),
          const SizedBox(width: 8),
          Text(label,
              style:
                  const TextStyle(color: AppStyles.toolbarButtonGraphicColor)),
        ]));
}
