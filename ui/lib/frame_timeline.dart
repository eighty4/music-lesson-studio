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
    return Center(
      child: SizedBox(
        height: widget.height,
        child: _FrameThumbnailRow(
          currentFrame: currentFrame,
          frames: frames,
          height: widget.height,
          tabContext: widget.tabContext,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    currentFrameSubscription.cancel();
    framesSubscription.cancel();
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
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildChildren(frameScaling));
  }

  List<Widget> _buildChildren(frameScaling) {
    return List.generate(frames.length + 1, (i) {
      if (i == frames.length) {
        return const _AddAnotherFrameButton();
      } else {
        return _FrameThumbnail(
            current: currentFrame == frames[i],
            frame: frames[i],
            frameIndex: i,
            frameScaling: frameScaling,
            tabContext: tabContext);
      }
    });
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

class _AddAnotherFrameButton extends StatefulWidget {
  const _AddAnotherFrameButton();

  @override
  State<_AddAnotherFrameButton> createState() => _AddAnotherFrameButtonState();
}

class _AddAnotherFrameButtonState extends State<_AddAnotherFrameButton> {
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => mouseHovering = true),
      onExit: (event) => setState(() => mouseHovering = false),
      child: GestureDetector(
        onTap: _onTap,
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
                    style: TextStyle(color: AppStyles.timelineAddFrameColor)))),
      ),
    );
  }

  void _onTap() {
    if (kDebugMode) {
      print('_AddAnotherFrameButtonState.onTap');
    }
    EditorData.clearCurrentInteraction();
    FrameData.createNewFrame();
  }
}
