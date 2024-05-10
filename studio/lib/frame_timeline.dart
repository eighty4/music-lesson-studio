import 'dart:async';

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
  static const thumbnailRatio = 4 / 3;

  final Stream<FrameDataState> frameDataStream;
  final double height;
  final TabContext tabContext;
  final FrameScaling thumbnailFrameScaling;

  FrameTimeline(
      {super.key,
      required this.frameDataStream,
      required this.height,
      required this.tabContext})
      : thumbnailFrameScaling = FrameScaling(
            frameOffset: Offset.zero,
            frameSize: Size(height * thumbnailRatio, height));

  @override
  State<FrameTimeline> createState() => _FrameTimelineState();
}

class _FrameTimelineState extends State<FrameTimeline> {
  Frame currentFrame = Frame();
  int? dragFrameIndex;
  int? dragHoverI;
  List<Frame> frames = [];
  bool mouseHovering = false;
  late final StreamSubscription frameDataSubscription;

  @override
  void initState() {
    super.initState();
    frameDataSubscription =
        widget.frameDataStream.listen((event) => setState(() {
              currentFrame = event.currentFrame;
              frames = event.frames;
            }));
  }

  @override
  Widget build(BuildContext context) {
    // final frameData = FrameData.of(context);
    return Center(
      child: SizedBox(
        height: widget.height,
        child: MouseRegion(
          onEnter: (_) => setState(() => mouseHovering = true),
          onExit: (_) => setState(() => mouseHovering = false),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildThumbnails()),
        ),
      ),
    );
  }

  List<Widget> _buildThumbnails() {
    final buttonMaxHeight = widget.height * .75;
    final maxed = frames.length == 5;
    final reorderable = frames.length > 1;
    return List.generate((frames.length * 2) + 1, (i) {
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
        final thumbnail =
            _buildThumbnail(frameIndex, widget.thumbnailFrameScaling);
        if (reorderable) {
          return Draggable(
              data: frameIndex,
              maxSimultaneousDrags: 1,
              onDragStarted: () => setState(() => dragFrameIndex = frameIndex),
              onDraggableCanceled: (_, __) =>
                  {if (mounted) setState(() => dragFrameIndex = null)},
              onDragCompleted: () =>
                  {if (mounted) setState(() => dragFrameIndex = null)},
              feedback:
                  _buildThumbnail(frameIndex, widget.thumbnailFrameScaling),
              childWhenDragging: Container(),
              child: _buildThumbnail(frameIndex, widget.thumbnailFrameScaling));
        } else {
          return thumbnail;
        }
      }
    });
  }

  _FrameThumbnail _buildThumbnail(int frameIndex, frameScaling) {
    return _FrameThumbnail(
        current: currentFrame == frames[frameIndex],
        frame: frames[frameIndex],
        frameIndex: frameIndex,
        frameScaling: frameScaling,
        tabContext: widget.tabContext,
        unitHasMultiplePanes: frames.length > 1);
  }

  @override
  void dispose() {
    super.dispose();
    frameDataSubscription.cancel();
  }
}

class _FrameThumbnail extends StatelessWidget {
  final bool current;
  final Frame frame;
  final int frameIndex;
  final FrameScaling frameScaling;
  final TabContext tabContext;
  final bool unitHasMultiplePanes;

  const _FrameThumbnail(
      {required this.current,
      required this.frame,
      required this.frameIndex,
      required this.frameScaling,
      required this.tabContext,
      required this.unitHasMultiplePanes});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _onLeftClick(context),
        onSecondaryTap: () => _onRightClick(context),
        child: FrameMenu(
          predicate: (interaction) =>
              interaction.openThumbnailMenu?.frameIndex == frameIndex,
          disabled: unitHasMultiplePanes
              ? const [_ThumbnailMenuOption.delete]
              : List<_ThumbnailMenuOption>.empty(),
          options: _thumbnailMenuOptions,
          callback: (option) => _onMenuOption(context, option),
          child: Container(
            height: frameScaling.frameSize.height,
            width: frameScaling.frameSize.width,
            decoration: BoxDecoration(
                color: AppStyles.timelineThumbnailBackgroundColor,
                borderRadius: AppStyles.timelineThumbnailBorderRadius,
                border: Border.all(
                    color: current
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

  _onLeftClick(BuildContext context) {
    EditorData.clearCurrentInteraction();
    FrameData.of(context).changeCurrentFrame(frame);
  }

  _onRightClick(BuildContext context) {
    FrameData.of(context).changeCurrentFrame(frame);
    EditorData.openThumbnailMenu(frameIndex);
  }

  _onMenuOption(BuildContext context, _ThumbnailMenuOption option) {
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
        onTap: _onTap,
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

  void _onTap() {
    if (kDebugMode) {
      print('_AddAnotherFrameButtonState.onTap');
    }
    EditorData.clearCurrentInteraction();
    FrameData.of(context)
        .createNewFrame(insertFrameIndex: widget.insertFrameIndex);
  }
}
