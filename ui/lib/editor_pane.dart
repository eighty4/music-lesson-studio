import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';

import 'app_styles.dart';
import 'editor_data.dart';
import 'editor_shortcuts.dart';
import 'entity_data.dart';
import 'frame_canvas.dart';
import 'frame_data.dart';
import 'frame_menu.dart';
import 'frame_scaling.dart';
import 'frame_widget.dart';

enum _CanvasMenuOption { paste }

final _canvasMenuOptions =
    _CanvasMenuOption.values.map((v) => FrameMenuOption(v.name, v)).toList();

class EditorPane extends StatefulWidget {
  final FrameScaling frameScaling;
  final Offset globalCursorPosition;
  final TabContext tabContext;

  const EditorPane(
      {super.key,
      required this.frameScaling,
      required this.globalCursorPosition,
      required this.tabContext});

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  EntityType? addingEntityType;
  FocusNode focusNode = FocusNode(debugLabel: "editor-pane");
  UniqueKey? selectedEntityKey;
  Frame frame = Frame();
  late final StreamSubscription editorInteractionSub;
  late final StreamSubscription frameDataSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub =
        EditorData.interactionState.listen((editorInteraction) => setState(() {
              addingEntityType = editorInteraction?.addingEntity?.entityType;
              selectedEntityKey = editorInteraction?.selectedEntity?.entityKey;
            }));
    frameDataSub = FrameData.currentFrameStream
        .listen((frame) => setState(() => this.frame = frame));
  }

  @override
  Widget build(BuildContext context) {
    return buildInteractionWidgets(buildFrameCanvas());
  }

  Widget buildInteractionWidgets(Widget child) {
    return Actions(
        actions: <Type, Action<Intent>>{
          if (addingEntityType != null) CancelIntent: CancelAction(),
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
                  callback: _onMenuOption,
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
            border: Border.all(color: AppStyles.frameCanvasBorderColor)),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            FrameCanvas(
                frame: frame,
                frameScaling: widget.frameScaling,
                interactive: true,
                tabContext: widget.tabContext),
            if (addingEntityType != null) buildAddingEntity()
          ],
        ),
      ),
    );
  }

  Widget buildAddingEntity() {
    final entitySize = addingEntityType!.defaultSize();
    final canvasSize = widget.frameScaling.projectSize(entitySize);
    final canvasOffset = widget.frameScaling
        .clampPanePosition(widget.globalCursorPosition, entitySize: canvasSize);
    return FrameEntityWidget(
      Entity(type: addingEntityType!, offset: Offset.zero, size: Size.zero),
      projection: EntityProjection(canvasOffset, canvasSize),
      interactive: false,
      scaling: widget.frameScaling,
      tabContext: widget.tabContext,
    );
  }

  void _onMenuOption(_CanvasMenuOption option) {
    if (kDebugMode) {
      print(option);
    }
  }

  void onLeftClick() {
    if (kDebugMode) {
      print('EditorPane.onLeftClick');
    }
    EditorData.clearCurrentInteraction();
    if (addingEntityType != null) {
      final entitySize = addingEntityType!.defaultSize();
      final canvasSize = widget.frameScaling.projectSize(entitySize);
      final canvasOffset = widget.frameScaling.clampPanePosition(
          widget.globalCursorPosition,
          entitySize: canvasSize);
      FrameData.addEntity(Entity(
        type: addingEntityType!,
        offset: widget.frameScaling
            .reverseOffsetProjection(EntityProjection.fromOffset(canvasOffset)),
        size: entitySize,
      ));
    }
  }

  void onRightClick() {
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
    frameDataSub.cancel();
  }
}
