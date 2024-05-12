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

  final Frame currentFrame;
  final List<Frame> frames;
  final double height;
  final TabContext tabContext;
  final FrameScaling thumbnailFrameScaling;

  FrameTimeline(
      {super.key,
      required this.currentFrame,
      required this.frames,
      required this.height,
      required this.tabContext})
      : thumbnailFrameScaling = FrameScaling(
            frameOffset: Offset.zero,
            frameSize: Size(height * _thumbnailRatio, height));

  @override
  State<FrameTimeline> createState() => _FrameTimelineState();
}

class _FrameTimelineState extends State<FrameTimeline> {
  int? dragFrameIndex;
  int? dragHoverI;
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: widget.height,
        child: MouseRegion(
          onEnter: (_) => setState(() => mouseHovering = true),
          onExit: (_) => setState(() => mouseHovering = false),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: buildThumbnails(context)),
        ),
      ),
    );
  }

  List<Widget> buildThumbnails(BuildContext context) {
    final buttonMaxHeight = widget.height * .75;
    final maxed = widget.frames.length == 5;
    final reorderable = widget.frames.length > 1;
    return List.generate((widget.frames.length * 2) + 1, (i) {
      if (i == 0 || i % 2 == 0) {
        if (dragFrameIndex != null) {
          final draggingFrameI = (dragFrameIndex! * 2) + 1;
          if (draggingFrameI + 1 == i || draggingFrameI - 1 == i) {
            return Container(width: 20);
          }
          late final int reorderFrameIndex;
          if (draggingFrameI < i) {
            reorderFrameIndex = (i ~/ 2) - 1;
          } else {
            reorderFrameIndex = (i ~/ 2);
          }
          return DragTarget<int>(
            onMove: (_) => setState(() => dragHoverI = i),
            onLeave: (_) => setState(() => dragHoverI = null),
            onAcceptWithDetails: (details) {
              setState(() {
                dragHoverI = null;
                FrameData.of(context)
                    .reorderFrame(details.data, reorderFrameIndex);
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 20,
                color: dragHoverI == i
                    ? const Color(0xFF20AA20)
                    : AppStyles.transparentColor,
              );
            },
          );
        } else {
          final insertFrameIndex = i ~/ 2;
          return _AddFrameButton(
              enabled: !maxed,
              insertFrameIndex: insertFrameIndex,
              maxHeight: buttonMaxHeight);
        }
      } else {
        final frameIndex = (i - 1) ~/ 2;
        final thumbnail = buildThumbnail(frameIndex: frameIndex);
        if (reorderable) {
          return Draggable(
              data: frameIndex,
              maxSimultaneousDrags: 1,
              onDragStarted: () => setState(() => dragFrameIndex = frameIndex),
              onDraggableCanceled: (_, __) =>
                  {if (mounted) setState(() => dragFrameIndex = null)},
              onDragCompleted: () =>
                  {if (mounted) setState(() => dragFrameIndex = null)},
              feedback: thumbnail,
              childWhenDragging: Container(),
              child: thumbnail);
        } else {
          return thumbnail;
        }
      }
    });
  }

  _FrameThumbnail buildThumbnail({required int frameIndex}) {
    final frame = widget.frames[frameIndex];
    return _FrameThumbnail(
      frame: frame,
      frameIndex: frameIndex,
      frameScaling: widget.thumbnailFrameScaling,
      isCurrentFrame: frame == widget.currentFrame,
      tabContext: widget.tabContext,
      unitHasMultipleFrames: widget.frames.length > 1,
    );
  }
}

class _FrameThumbnail extends StatelessWidget {
  final Frame frame;
  final int frameIndex;
  final FrameScaling frameScaling;
  final bool isCurrentFrame;
  final TabContext tabContext;
  final bool unitHasMultipleFrames;

  const _FrameThumbnail(
      {required this.frame,
      required this.frameIndex,
      required this.frameScaling,
      required this.isCurrentFrame,
      required this.tabContext,
      required this.unitHasMultipleFrames});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onLeftClick(context),
        onSecondaryTap: () => onRightClick(context),
        child: FrameMenu(
          predicate: (interaction) =>
              interaction.openThumbnailMenu?.frameIndex == frameIndex,
          disabled: unitHasMultipleFrames
              ? const [_ThumbnailMenuOption.delete]
              : List<_ThumbnailMenuOption>.empty(),
          options: _thumbnailMenuOptions,
          callback: (option) => onMenuOption(context, option),
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
    EditorData.openThumbnailMenu(frameIndex);
  }

  onMenuOption(BuildContext context, _ThumbnailMenuOption option) {
    EditorData.clearCurrentInteraction();
    FrameData.of(context).deleteFrame(frameIndex);
  }
}

class _AddFrameButton extends StatefulWidget {
  final bool enabled;
  final int insertFrameIndex;
  final double maxHeight;

  const _AddFrameButton(
      {required this.enabled,
      required this.insertFrameIndex,
      required this.maxHeight});

  @override
  State<_AddFrameButton> createState() => _AddFrameButtonState();
}

class _AddFrameButtonState extends State<_AddFrameButton> {
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return const SizedBox(width: 20);
    }
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
    FrameData.of(context)
        .createNewFrame(insertFrameIndex: widget.insertFrameIndex);
  }
}
