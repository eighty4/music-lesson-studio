import 'dart:async';

import 'package:flutter/material.dart';

import 'editor_toolbar.dart';
import 'entity_content.dart';
import 'entity_data.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';
import 'frame_widget.dart';
import 'studio_editor.dart';

class FrameCanvas extends StatefulWidget {
  final EntityType? addingEntityType;
  final FrameScaling scaling;

  const FrameCanvas(
      {super.key, required this.addingEntityType, required this.scaling});

  @override
  State<FrameCanvas> createState() => _FrameCanvasState();
}

class _FrameCanvasState extends State<FrameCanvas> {
  Frame frame = Frame();
  late final StreamSubscription frameDataSub;

  @override
  void initState() {
    super.initState();
    frameDataSub = FrameData.currentFrame
        .listen((frame) => setState(() => this.frame = frame));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // todo scale for aspect ratio
        width: widget.scaling.frameSize.width,
        // todo scale for aspect ratio
        height: widget.scaling.frameSize.height,
        decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            ...frame.entities.map((entity) => FrameEntityWidget(
                  entity,
                  scaling: widget.scaling,
                  tabContext: StudioEditor.tabContext,
                )),
            if (widget.addingEntityType != null) buildAddingEntity()
          ],
        ),
      ),
    );
  }

  // todo center adding entity on cursor
  buildAddingEntity() {
    // todo scale for aspect ratio
    final size = widget.addingEntityType!.defaultSize();
    // todo scale for aspect ratio
    final offset = widget.scaling.clampFramePosition(
        // todo scale for aspect ratio
        widget.scaling.cursor.position -
            widget.scaling.frameOffset -
            const Offset(0, EditorToolbar.height),
        // todo scale for aspect ratio
        entitySize: size);
    return Positioned(
        // todo scale for aspect ratio
        left: offset.dx,
        // todo scale for aspect ratio
        top: offset.dy,
        child: EntityContent(Entity(
            type: widget.addingEntityType!, offset: offset, size: size)));
  }

  @override
  void dispose() {
    super.dispose();
    frameDataSub.cancel();
  }
}
