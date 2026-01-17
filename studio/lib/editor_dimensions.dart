import 'package:flutter/widgets.dart';

import 'aspect_ratio.dart';

class EditorDimensions {
  static const _frameMaxHeightRatio = .7;

  static Size _calculateFrameSize(
    double editorWidth,
    double maxFrameHeight,
    double ratio,
  ) {
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

  final Rect frame;
  final Rect timeline;
  final Rect toolbar;

  EditorDimensions({
    required this.frame,
    required this.timeline,
    required this.toolbar,
  });

  factory EditorDimensions.fromConstraints(
    BoxConstraints constraints, {
    required FrameAspectRatio aspectRatio,
    required double headerHeight,
  }) {
    return EditorDimensions.fromEditorSize(
      Size(constraints.maxWidth, constraints.maxHeight),
      aspectRatio: aspectRatio,
      headerHeight: headerHeight,
    );
  }

  factory EditorDimensions.fromEditorSize(
    Size editorSize, {
    required FrameAspectRatio aspectRatio,
    required double headerHeight,
  }) {
    final paneSize = Size(editorSize.width, editorSize.height - headerHeight);
    final frameSize = _calculateFrameSize(
      editorSize.width,
      paneSize.height * _frameMaxHeightRatio,
      aspectRatio.ratio(),
    );
    final frameOffset = Offset(
      (paneSize.width - frameSize.width) / 2,
      headerHeight + ((paneSize.height - frameSize.height) / 2),
    );
    final toolbarSize = Size(
      editorSize.width,
      (paneSize.height - frameSize.height) / 2,
    );
    return EditorDimensions(
      frame: Rect.fromLTWH(
        frameOffset.dx,
        frameOffset.dy,
        frameSize.width,
        frameSize.height,
      ),
      timeline: Rect.fromLTWH(
        0,
        frameOffset.dy + frameSize.height,
        editorSize.width,
        toolbarSize.height,
      ),
      toolbar: Rect.fromLTWH(
        0,
        headerHeight,
        editorSize.width,
        (paneSize.height - frameSize.height) / 2,
      ),
    );
  }
}
