import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';

import 'adding_entity.dart';
import 'app_styles.dart';
import 'editor_interaction.dart';
import 'editor_shortcuts.dart';
import 'frame_canvas.dart';
import 'frame_menu.dart';
import 'frame_scaling.dart';

enum _CanvasMenuOption { paste }

final _canvasMenuOptions =
    _CanvasMenuOption.values.map((v) => FrameMenuOption(v.name, v)).toList();

class EditorPane extends StatefulWidget {
  final Frame currentFrame;
  final FrameScaling frameScaling;
  final TabContext tabContext;

  const EditorPane(
      {super.key,
      required this.currentFrame,
      required this.frameScaling,
      required this.tabContext});

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  FocusNode focusNode = FocusNode(debugLabel: 'editor-pane');
  UniqueKey? selectedEntityKey;
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) => setState(() {
              selectedEntityKey = editorInteraction?.selectedEntity?.entityKey;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return buildInteractionWidgets(buildFrameCanvas());
  }

  Widget buildInteractionWidgets(Widget child) {
    return Actions(
        actions: <Type, Action<Intent>>{
          RedoIntent: RedoAction(),
          UndoIntent: UndoAction(),
        },
        child: Focus(
            focusNode: focusNode,
            autofocus: true,
            child: GestureDetector(
                onTap: onLeftClick,
                child: FrameMenu(
                  predicate: (interaction) =>
                      interaction.openCanvasMenu != null,
                  disabled: const [_CanvasMenuOption.paste],
                  options: _canvasMenuOptions,
                  callback: onMenuOption,
                  child: GestureDetector(
                    onSecondaryTap: onRightClick,
                    child: child,
                  ),
                ))));
  }

  Widget buildFrameCanvas() {
    return Center(
      child: Container(
        width: widget.frameScaling.frameSize.width,
        height: widget.frameScaling.frameSize.height,
        decoration: BoxDecoration(
            border: Border.all(color: AppStyles.frameCanvasBorderColor),
            color: AppStyles.frameCanvasBackgroundColor),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            FrameCanvas(
                frame: widget.currentFrame,
                frameScaling: widget.frameScaling,
                interactive: true,
                tabContext: widget.tabContext),
            AddingEntity(
                frameScaling: widget.frameScaling,
                tabContext: widget.tabContext),
          ],
        ),
      ),
    );
  }

  onMenuOption(_CanvasMenuOption option) {
    if (kDebugMode) {
      print(option);
    }
  }

  onLeftClick() {
    if (kDebugMode) {
      print('EditorPane.onLeftClick');
    }
    EditorData.clearCurrentInteraction();
  }

  onRightClick() {
    if (kDebugMode) {
      print('EditorPane.onRightClick');
    }
    EditorData.openCanvasMenu();
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
    focusNode.dispose();
  }
}
