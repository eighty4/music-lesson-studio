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
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.paragraphText)),
            const SizedBox(width: 2),
            IconToolbarButton(
                icon: Icons.image,
                active: addingEntityType == EntityType.imageUpload,
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.imageUpload)),
            const SizedBox(width: 2),
            IconToolbarButton(
                icon: Icons.videocam,
                active: addingEntityType == EntityType.videoRecord,
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.videoRecord)),
            const SizedBox(width: 2),
            LabeledIconToolbarButton(
                icon: Icons.music_note,
                label: 'Measure',
                active: addingEntityType == EntityType.measureChart,
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.measureChart)),
            const SizedBox(width: 2),
            LabeledIconToolbarButton(
                icon: Icons.music_note,
                label: 'Chord',
                active: addingEntityType == EntityType.chordChart,
                onActivate: () => EditorData.startAddEntityInteraction(
                    EntityType.chordChart)),
            const SizedBox(width: 2),
            AspectRatioButton(
                aspectRatio: widget.aspectRatio,
                onAspectRatioChanged: widget.onAspectRatioChanged),
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
  final Widget child;
  final bool active;
  final VoidCallback onActivate;

  const ToolbarButton(
      {super.key,
      required this.child,
      required this.active,
      required this.onActivate});

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

class AspectRatioButton extends StatelessWidget {
  final FrameAspectRatio aspectRatio;
  final AspectRatioCallback onAspectRatioChanged;
  final OverlayPortalController controller = OverlayPortalController();

  AspectRatioButton(
      {super.key,
      required this.aspectRatio,
      required this.onAspectRatioChanged});

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
        onTap: () => controller.toggle(),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
              padding: const EdgeInsets.all(10),
              width: 70,
              color: Colors.white70,
              child: Center(child: Text(aspectRatio.label()))),
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
                      onAspectRatioChanged(aspectRatio);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        width: 100,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  color: aspectRatio == this.aspectRatio
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
}
