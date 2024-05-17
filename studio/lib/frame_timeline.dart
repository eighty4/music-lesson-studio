import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/context.dart';

import 'api_types.dart';
import 'app_styles.dart';
import 'editor_data.dart';
import 'frame_canvas.dart';
import 'frame_data.dart';
import 'frame_menu.dart';
import 'frame_scaling.dart';

enum _ThumbnailMenuOption { delete }

final _thumbnailMenuOptions =
    _ThumbnailMenuOption.values.map((v) => FrameMenuOption(v.name, v)).toList();

class FrameTimeline extends StatefulWidget {
  static const _thumbnailRatio = 4 / 3;

  final double buttonMaxHeight;
  final Frame currentFrame;
  final List<Frame> frames;
  final List<UniqueKey> frameKeys;
  final bool isFrameCountMaxed;
  final bool isReorderable;
  final double height;
  final TabContext tabContext;
  final FrameScaling thumbnailFrameScaling;

  FrameTimeline(
      {super.key,
      required this.currentFrame,
      required this.frames,
      required this.height,
      required this.tabContext})
      : buttonMaxHeight = height * .75,
        frameKeys = frames.map((frame) => frame.key).toList(growable: false),
        isFrameCountMaxed = frames.length == FrameData.maxFrames,
        isReorderable = frames.length > 1,
        thumbnailFrameScaling = FrameScaling(
            frameOffset: Offset.zero,
            frameSize: Size(height * _thumbnailRatio, height));

  @override
  State<FrameTimeline> createState() => _FrameTimelineState();
}

class _FrameTimelineState extends State<FrameTimeline> {
  UniqueKey? draggingFrame;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: widget.height,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buildContent(context)),
      ),
    );
  }

  List<Widget> buildContent(BuildContext context) {
    List<Widget> result = [];
    for (var i = 0; i < widget.frames.length; i++) {
      final frame = widget.frames[i];
      result.add(buildSpacer(
          beforeFrame: frame.key,
          excludeReorderDragTarget: i == 0 ? null : widget.frames[i - 1].key));
      result.add(buildThumbnail(frame));
    }
    result.add(buildSpacer(afterFrame: widget.frames.last.key));
    return result;
  }

  Widget buildSpacer(
      {UniqueKey? afterFrame,
      UniqueKey? beforeFrame,
      UniqueKey? excludeReorderDragTarget}) {
    assert([afterFrame, beforeFrame].where((v) => v != null).length == 1);
    if (draggingFrame != null) {
      if (draggingFrame == (afterFrame ?? beforeFrame) ||
          draggingFrame == excludeReorderDragTarget) {
        return buildNonInteractiveSpacer();
      } else {
        return FrameReorderDragTarget(
          afterFrame: afterFrame,
          beforeFrame: beforeFrame,
        );
      }
    } else if (widget.isFrameCountMaxed) {
      return buildNonInteractiveSpacer();
    } else {
      return AddFrameButton(
          afterFrame: afterFrame,
          beforeFrame: beforeFrame,
          maxHeight: widget.buttonMaxHeight);
    }
  }

  Widget buildNonInteractiveSpacer() => const SizedBox(width: 20);

  Widget buildThumbnail(Frame frame) {
    final thumbnail = FrameThumbnail(
        frame: frame,
        frameScaling: widget.thumbnailFrameScaling,
        isCurrentFrame: frame == widget.currentFrame,
        tabContext: widget.tabContext,
        unitHasMultipleFrames: widget.frames.length > 1);
    if (draggingFrame != null) {
      return thumbnail;
    }
    return Draggable<UniqueKey>(
        data: frame.key,
        maxSimultaneousDrags: 1,
        onDragStarted: () => setState(() => draggingFrame = frame.key),
        onDraggableCanceled: (_, __) =>
            {if (mounted) setState(() => draggingFrame = null)},
        onDragCompleted: () =>
            {if (mounted) setState(() => draggingFrame = null)},
        feedback: thumbnail,
        childWhenDragging: Container(),
        child: thumbnail);
  }
}

class FrameThumbnail extends StatelessWidget {
  final Frame frame;
  final FrameScaling frameScaling;
  final bool isCurrentFrame;
  final TabContext tabContext;
  final bool unitHasMultipleFrames;

  const FrameThumbnail(
      {super.key,
      required this.frame,
      required this.frameScaling,
      required this.isCurrentFrame,
      required this.tabContext,
      required this.unitHasMultipleFrames});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onLeftClick(context),
        onSecondaryTap: () => onRightClick(context),
        child: FrameMenu<_ThumbnailMenuOption>(
          predicate: (interaction) =>
              interaction.openThumbnailMenu?.frameKey == frame.key,
          disabled: unitHasMultipleFrames
              ? List.empty()
              : const [_ThumbnailMenuOption.delete],
          options: _thumbnailMenuOptions,
          callback: (option) => _onMenuOption(context, option),
          child: Container(
            height: frameScaling.frameSize.height,
            width: frameScaling.frameSize.width,
            decoration: BoxDecoration(
                color: AppStyles.timelineThumbnailBackgroundColor,
                borderRadius: AppStyles.timelineThumbnailBorderRadius,
                border: Border.all(
                    color: isCurrentFrame
                        ? AppStyles.timelineActiveColor
                        : AppStyles.timelineBorderColor,
                    width: 1)),
            child: FrameCanvas(
              frame: frame,
              frameScaling: frameScaling,
              interactive: false,
              tabContext: tabContext,
            ),
          ),
        ));
  }

  onLeftClick(BuildContext context) {
    EditorData.clearCurrentInteraction();
    FrameData.of(context).changeCurrentFrame(frame);
  }

  onRightClick(BuildContext context) {
    FrameData.of(context).changeCurrentFrame(frame);
    EditorData.openThumbnailMenu(frame.key);
  }

  _onMenuOption(BuildContext context, _ThumbnailMenuOption option) {
    EditorData.clearCurrentInteraction();
    FrameData.of(context).deleteFrame(frame.key);
  }
}

class AddFrameButton extends StatefulWidget {
  final UniqueKey? afterFrame;
  final UniqueKey? beforeFrame;
  final double maxHeight;

  const AddFrameButton(
      {super.key,
      required this.beforeFrame,
      required this.afterFrame,
      required this.maxHeight});

  @override
  State<AddFrameButton> createState() => _AddFrameButtonState();
}

class _AddFrameButtonState extends State<AddFrameButton> {
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => mouseHovering = true),
      onExit: (_) => setState(() => mouseHovering = false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          width: mouseHovering ? 30 : 20,
          padding: mouseHovering
              ? const EdgeInsets.symmetric(horizontal: 12)
              : const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                height: mouseHovering ? widget.maxHeight : 10,
                width: mouseHovering ? 6 : 4,
                decoration: BoxDecoration(
                    color: mouseHovering
                        ? AppStyles.timelineActiveColor
                        : AppStyles.timelineBorderColor,
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  onTap() {
    if (kDebugMode) {
      print('_AddAnotherFrameButtonState.onTap');
    }
    EditorData.clearCurrentInteraction();
    FrameData.of(context).addFrame(
        afterFrame: widget.afterFrame, beforeFrame: widget.beforeFrame);
    setState(() => mouseHovering = false);
  }
}

class FrameReorderDragTarget extends StatefulWidget {
  final UniqueKey? afterFrame;
  final UniqueKey? beforeFrame;

  const FrameReorderDragTarget(
      {super.key, required this.afterFrame, required this.beforeFrame});

  @override
  State<FrameReorderDragTarget> createState() => _FrameReorderDragTargetState();
}

class _FrameReorderDragTargetState extends State<FrameReorderDragTarget> {
  bool dragHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<UniqueKey>(
      onMove: onMove,
      onLeave: onLeave,
      onAcceptWithDetails: onAcceptWithDetails,
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 20,
          color: dragHovering
              ? const Color(0xFF20AA20)
              : AppStyles.transparentColor,
        );
      },
    );
  }

  onMove(_) {
    if (kDebugMode) {
      print('_FrameReorderDragTargetState.onMove');
    }
    setState(() => dragHovering = true);
  }

  onLeave(_) {
    if (kDebugMode) {
      print('_FrameReorderDragTargetState.onLeave');
    }
    setState(() => dragHovering = false);
  }

  onAcceptWithDetails(DragTargetDetails<UniqueKey> details) {
    if (kDebugMode) {
      print('_FrameReorderDragTargetState.onAcceptWithDetails');
    }
    setState(() => dragHovering = false);
    FrameData.of(context).reorderFrame(details.data,
        afterFrame: widget.afterFrame, beforeFrame: widget.beforeFrame);
  }
}
