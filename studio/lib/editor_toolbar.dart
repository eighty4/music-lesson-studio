import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mls_api/api_types.dart';

import 'app_styles.dart';
import 'editor_data.dart';

// todo replace Material font icons
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // _IconToolbarButton(
        //     icon: Icons.text_fields,
        //     active: addingEntityType == EntityType.paragraphText,
        //     onActivate: createActivateCallback(EntityType.paragraphText)),
        // const SizedBox(width: 3),
        // _IconToolbarButton(
        //     icon: Icons.image,
        //     active: addingEntityType == EntityType.imageUpload,
        //     onActivate: createActivateCallback(EntityType.imageUpload)),
        // const SizedBox(width: 3),
        // _IconToolbarButton(
        //     icon: Icons.videocam,
        //     active: addingEntityType == EntityType.videoRecord,
        //     onActivate: createActivateCallback(EntityType.videoRecord)),
        // const SizedBox(width: 3),
        _LabeledIconToolbarButton(
            icon: Icons.music_note,
            label: 'Measure',
            active: addingEntityType == EntityType.measureChart,
            onActivate: createActivateCallback(EntityType.measureChart)),
        const SizedBox(width: 3),
        _LabeledIconToolbarButton(
            icon: Icons.music_note,
            label: 'Chord',
            active: addingEntityType == EntityType.chordChart,
            onActivate: createActivateCallback(EntityType.chordChart)),
      ],
    );
  }

  _ActivateCallback createActivateCallback(EntityType entityType) {
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

typedef _ActivateCallback = Function(bool);

class _ToolbarButton extends StatelessWidget {
  final Widget child;
  final bool active;
  final _ActivateCallback onActivate;

  const _ToolbarButton(
      {required this.child, required this.active, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

  onTap() {
    if (kDebugMode) {
      print('ToolbarButton.onTap');
    }
    onActivate(!active);
  }
}

// class _IconToolbarButton extends _ToolbarButton {
//   _IconToolbarButton(
//       {required IconData icon,
//       required super.active,
//       required super.onActivate})
//       : super(
//             child: Icon(
//           icon,
//           color: AppStyles.toolbarButtonGraphicColor,
//           size: 24.0,
//         ));
// }

class _LabeledIconToolbarButton extends _ToolbarButton {
  _LabeledIconToolbarButton(
      {required IconData icon,
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
