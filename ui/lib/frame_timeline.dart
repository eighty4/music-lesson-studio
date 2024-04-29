import 'dart:async';

import 'package:flutter/material.dart';

import 'frame_data.dart';

class FrameTimeline extends StatefulWidget {
  final Size size;

  const FrameTimeline({super.key, required this.size});

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
          color: Color.fromARGB(68, 240, 240, 240),
          border: Border(
              top: BorderSide(color: Color.fromARGB(255, 220, 220, 220)))),
      height: widget.size.height,
      child: frames.length == 1
          ? const AddAnotherFrameButtonRow()
          : FrameThumbnailRow(currentFrame: currentFrame, frames: frames),
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
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                border: Border.all(
                    color: mouseHovering
                        ? Colors.purpleAccent
                        : const Color.fromARGB(255, 220, 220, 220),
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

  const FrameThumbnailRow(
      {super.key, required this.currentFrame, required this.frames});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbnailWidth = constraints.maxHeight * thumbnailRatio;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: frames
                .map((frame) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FrameThumbnail(
                        current: currentFrame == frame,
                        frame: frame,
                        width: thumbnailWidth)))
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
  final double width;

  const FrameThumbnail(
      {super.key,
      required this.current,
      required this.frame,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FrameData.changeCurrentFrame(frame);
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            border: Border.all(
                color: current
                    ? Colors.purpleAccent
                    : const Color.fromARGB(255, 220, 220, 220),
                width: 1)),
        child: Center(
            child: frame.entities.isEmpty
                ? const Text("empty")
                : Text("${frame.entities.length} entities")),
      ),
    );
  }
}
