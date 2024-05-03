import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/context.dart';

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
  final double height;
  final TabContext tabContext;

  const FrameTimeline(
      {super.key, required this.height, required this.tabContext});

  @override
  State<FrameTimeline> createState() => _FrameTimelineState();
}

class _FrameTimelineState extends State<FrameTimeline> {
  Frame currentFrame = FrameData.currentFrame;
  List<Frame> frames = FrameData.frames;
  bool mouseHovering = false;
  late final StreamSubscription currentFrameSubscription;
  late final StreamSubscription framesSubscription;

  @override
  void initState() {
    super.initState();
    currentFrameSubscription = FrameData.currentFrameStream.listen(
        (currentFrame) => setState(() => this.currentFrame = currentFrame));
    framesSubscription = FrameData.allFramesStream
        .listen((frames) => setState(() => this.frames = frames));
  }

  @override
  Widget build(BuildContext context) {
    const thumbnailRatio = 4 / 3;
    final frameScaling = FrameScaling(
        frameOffset: Offset.zero,
        frameSize: Size(widget.height * thumbnailRatio, widget.height));
    return Center(
      child: SizedBox(
        height: widget.height,
        child: MouseRegion(
          onEnter: (_) => setState(() => mouseHovering = true),
          onExit: (_) => setState(() => mouseHovering = false),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildThumbnails(frameScaling)),
        ),
      ),
    );
  }

  List<Widget> _buildThumbnails(frameScaling) {
    final buttonMaxHeight = widget.height * .75;
    final maxed = frames.length == 5;
    return List.generate((frames.length * 2) + 1, (i) {
      if (i == 0 || i % 2 == 0) {
        return _AddFrameButton(
            enabled: !maxed,
            insertFrameIndex: i ~/ 2,
            maxHeight: buttonMaxHeight);
      } else {
        return _buildThumbnail((i - 1) ~/ 2, frameScaling);
      }
    });
  }

  _FrameThumbnail _buildThumbnail(int frameIndex, frameScaling) {
    return _FrameThumbnail(
        current: currentFrame == frames[frameIndex],
        frame: frames[frameIndex],
        frameIndex: frameIndex,
        frameScaling: frameScaling,
        tabContext: widget.tabContext);
  }

  @override
  void dispose() {
    super.dispose();
    currentFrameSubscription.cancel();
    framesSubscription.cancel();
  }
}

class _FrameThumbnail extends StatelessWidget {
  final bool current;
  final Frame frame;
  final int frameIndex;
  final FrameScaling frameScaling;
  final TabContext tabContext;

  const _FrameThumbnail(
      {required this.current,
      required this.frame,
      required this.frameIndex,
      required this.frameScaling,
      required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _onLeftClick,
        onSecondaryTap: _onRightClick,
        child: FrameMenu(
          predicate: (interaction) =>
              interaction.openThumbnailMenu?.frameIndex == frameIndex,
          disabled: FrameData.frames.length == 1
              ? const [_ThumbnailMenuOption.delete]
              : List<_ThumbnailMenuOption>.empty(),
          options: _thumbnailMenuOptions,
          callback: _onMenuOption,
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

  _onLeftClick() {
    EditorData.clearCurrentInteraction();
    FrameData.changeCurrentFrame(frame);
  }

  _onRightClick() {
    FrameData.changeCurrentFrame(frame);
    EditorData.openThumbnailMenu(frameIndex);
  }

  _onMenuOption(_ThumbnailMenuOption option) {
    EditorData.clearCurrentInteraction();
    FrameData.deleteFrame(frameIndex);
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
    FrameData.createNewFrame(insertFrameIndex: widget.insertFrameIndex);
  }
}
