import 'package:flutter/widgets.dart';

import 'aspect_ratio.dart';

class EditorDimensions {
  static const _frameMaxHeightRatio = .7;

  static Size _calculateFrameSize(
      double editorWidth, double maxFrameHeight, double ratio) {
    late final double height;
    late final double width;
    if ((editorWidth * .8) / maxFrameHeight > ratio) {
      height = maxFrameHeight;
      width = ratio * height;
    } else {
      width = .8 * editorWidth;
      height = width / ratio;
    }
    return Size(width, height);
  }

  final Size editorSize;
  final Offset frameOffset;
  final Size frameSize;
  final Offset headerOffset;
  final Size headerSize;
  final Size paneSize;
  final Offset timelineOffset;
  final Size timelineSize;
  final Offset toolbarOffset;
  final Size toolbarSize;

  EditorDimensions({
    required this.editorSize,
    required this.frameOffset,
    required this.frameSize,
    required this.headerOffset,
    required this.headerSize,
    required this.paneSize,
    required this.timelineOffset,
    required this.timelineSize,
    required this.toolbarOffset,
    required this.toolbarSize,
  });

  factory EditorDimensions.fromConstraints(BoxConstraints constraints,
      {required FrameAspectRatio aspectRatio, required double headerHeight}) {
    return EditorDimensions.fromEditorSize(
        Size(constraints.maxWidth, constraints.maxHeight),
        aspectRatio: aspectRatio,
        headerHeight: headerHeight);
  }

  factory EditorDimensions.fromEditorSize(Size editorSize,
      {required FrameAspectRatio aspectRatio, required double headerHeight}) {
    final paneSize = Size(editorSize.width, editorSize.height - headerHeight);
    final frameSize = _calculateFrameSize(editorSize.width,
        paneSize.height * _frameMaxHeightRatio, aspectRatio.ratio());
    final frameOffset = Offset((paneSize.width - frameSize.width) / 2,
        headerHeight + ((paneSize.height - frameSize.height) / 2));
    final toolbarSize =
        Size(editorSize.width, (paneSize.height - frameSize.height) / 2);
    return EditorDimensions(
        editorSize: editorSize,
        frameOffset: frameOffset,
        frameSize: frameSize,
        headerOffset: Offset.zero,
        headerSize: Size(editorSize.width, headerHeight),
        paneSize: paneSize,
        timelineOffset: Offset(0, frameOffset.dy + frameSize.height),
        timelineSize: Size(editorSize.width, toolbarSize.height),
        toolbarOffset: Offset(0, headerHeight),
        toolbarSize: toolbarSize);
  }
}
