import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mls_ui/aspect_ratio.dart';
import 'package:mls_ui/editor_data.dart';
import 'package:mls_ui/editor_styles.dart';
import 'package:mls_ui/entity_data.dart';

typedef AspectRatioCallback = void Function(FrameAspectRatio aspectRatio);

class EditorToolbar extends StatefulWidget {
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
    return Container(
      color: EditorStyleVariables.toolbarBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                ? Colors.green
                : EditorStyleVariables.toolbarButtonBackgroundColor,
            border:
                Border.all(color: EditorStyleVariables.borderColor, width: 2)),
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
          color: EditorStyleVariables.toolbarButtonGraphicColor,
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
            color: EditorStyleVariables.toolbarButtonGraphicColor,
            size: 24.0,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: EditorStyleVariables.toolbarButtonGraphicColor)),
        ]));
}

class AspectRatioButton extends StatefulWidget {
  final FrameAspectRatio aspectRatio;
  final AspectRatioCallback onAspectRatioChanged;

  const AspectRatioButton(
      {super.key,
      required this.aspectRatio,
      required this.onAspectRatioChanged});

  @override
  State<AspectRatioButton> createState() => _AspectRatioButtonState();
}

class _AspectRatioButtonState extends State<AspectRatioButton> {
  final OverlayPortalController controller = OverlayPortalController();
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub = EditorData.interactionState.listen((event) {
      if (event != null) {
        controller.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: controller,
      overlayChildBuilder: (context) {
        return Positioned(top: 50, right: 50, child: buildMenu());
      },
      child: buildButton(),
    );
  }

  Widget buildButton() {
    return GestureDetector(
        onTap: () {
          EditorData.clearCurrentInteraction();
          controller.show();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
              padding: const EdgeInsets.all(10),
              width: 70,
              color: Colors.white70,
              child: Center(child: Text(widget.aspectRatio.label()))),
        ));
  }

  Widget buildMenu() {
    return Container(
      color: Colors.amber,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: FrameAspectRatio.values
            .map((aspectRatio) => Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      controller.hide();
                      widget.onAspectRatioChanged(aspectRatio);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        width: 100,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  color: aspectRatio == widget.aspectRatio
                                      ? Colors.green
                                      : Colors.transparent,
                                  height: 20,
                                  width: 20),
                              const SizedBox(width: 20),
                              Expanded(child: Text(aspectRatio.label())),
                            ]),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
  }
}
