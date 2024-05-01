import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:libtab/context.dart';

import 'app_styles.dart';
import 'frame_canvas.dart';
import 'frame_data.dart';
import 'frame_scaling.dart';

class FrameTimeline extends StatefulWidget {
  final Size size;
  final TabContext tabContext;

  const FrameTimeline(
      {super.key, required this.size, required this.tabContext});

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
          color: AppStyles.timelineBackgroundColor,
          border:
              Border(top: BorderSide(color: AppStyles.timelineBorderColor))),
      height: widget.size.height,
      child: frames.length == 1
          ? const AddAnotherFrameButtonRow()
          : FrameThumbnailRow(
              currentFrame: currentFrame,
              frames: frames,
              tabContext: widget.tabContext,
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    framesSubscription.cancel();
  }
}

class AddAnotherFrameButtonRow extends StatelessWidget {
  const AddAnotherFrameButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [AddAnotherFrameButton()]),
    );
  }
}

class AddAnotherFrameButton extends StatefulWidget {
  const AddAnotherFrameButton({super.key});

  @override
  State<AddAnotherFrameButton> createState() => _AddAnotherFrameButtonState();
}

class _AddAnotherFrameButtonState extends State<AddAnotherFrameButton> {
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => mouseHovering = true),
      onExit: (event) => setState(() => mouseHovering = false),
      child: GestureDetector(
        onTap: () {
          FrameData.createNewFrame();
        },
        child: Container(
            decoration: BoxDecoration(
                color: AppStyles.timelineThumbnailBackgroundColor,
                borderRadius: AppStyles.timelineThumbnailBorderRadius,
                border: Border.all(
                    color: mouseHovering
                        ? AppStyles.timelineActiveColor
                        : AppStyles.timelineBorderColor,
                    width: 1)),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Center(child: Text("Add another frame"))),
      ),
    );
  }
}

class FrameThumbnailRow extends StatelessWidget {
  static const double thumbnailRatio = 4 / 3;
  final Frame currentFrame;
  final List<Frame> frames;
  final TabContext tabContext;

  const FrameThumbnailRow(
      {super.key,
      required this.currentFrame,
      required this.frames,
      required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final frameScaling = FrameScaling(
              frameOffset: Offset.zero,
              frameSize: Size(constraints.maxHeight * thumbnailRatio,
                  constraints.maxHeight));
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: frames
                .map((frame) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FrameThumbnail(
                        current: currentFrame == frame,
                        frame: frame,
                        frameScaling: frameScaling,
                        tabContext: tabContext)))
                .toList(),
          );
        },
      ),
    );
  }
}

class FrameThumbnail extends StatelessWidget {
  final bool current;
  final Frame frame;
  final FrameScaling frameScaling;
  final TabContext tabContext;

  const FrameThumbnail(
      {super.key,
      required this.current,
      required this.frame,
      required this.frameScaling,
      required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
