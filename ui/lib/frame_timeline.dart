import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/context.dart';

import 'app_styles.dart';
import 'frame_canvas.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';

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
    return _FrameThumbnailRow(
      currentFrame: currentFrame,
      frames: frames,
      height: widget.height / 2,
      tabContext: widget.tabContext,
    );
  }

  @override
  void dispose() {
    super.dispose();
    currentFrameSubscription.cancel();
    framesSubscription.cancel();
  }
}

class _AddAnotherFrameButton extends StatefulWidget {
  const _AddAnotherFrameButton();

  @override
  State<_AddAnotherFrameButton> createState() => _AddAnotherFrameButtonState();
}

class _AddAnotherFrameButtonState extends State<_AddAnotherFrameButton> {
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: const Size(50, 40),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => setState(() => mouseHovering = true),
        onExit: (event) => setState(() => mouseHovering = false),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
              decoration: BoxDecoration(
                  color: AppStyles.timelineThumbnailBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: mouseHovering
                          ? AppStyles.timelineActiveColor
                          : AppStyles.timelineBorderColor,
                      width: 1)),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: const Center(
                  child: Text('+',
                      style:
                          TextStyle(color: AppStyles.timelineAddFrameColor)))),
        ),
      ),
    );
  }

  void onTap() {
    if (kDebugMode) {
      print('_AddAnotherFrameButtonState.onTap');
    }
    FrameData.createNewFrame();
  }
}

class _FrameThumbnailRow extends StatelessWidget {
  static const double thumbnailRatio = 4 / 3;
  final Frame currentFrame;
  final List<Frame> frames;
  final double height;
  final TabContext tabContext;

  const _FrameThumbnailRow(
      {required this.currentFrame,
      required this.frames,
      required this.height,
      required this.tabContext});

  @override
  Widget build(BuildContext context) {
    final frameScaling = FrameScaling(
        frameOffset: Offset.zero,
        frameSize: Size(height * thumbnailRatio, height));
    return SizedBox(
        height: height,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...frames.map((frame) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _FrameThumbnail(
                      current: currentFrame == frame,
                      frame: frame,
                      frameScaling: frameScaling,
                      tabContext: tabContext))),
              const _AddAnotherFrameButton()
            ]));
  }
}

class _FrameThumbnail extends StatelessWidget {
  final bool current;
  final Frame frame;
  final FrameScaling frameScaling;
  final TabContext tabContext;

  const _FrameThumbnail(
      {required this.current,
      required this.frame,
      required this.frameScaling,
      required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }

  onTap() {
    FrameData.changeCurrentFrame(frame);
  }
}
