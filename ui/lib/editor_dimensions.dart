import 'package:flutter/widgets.dart';

import 'aspect_ratio.dart';
import 'editor_toolbar.dart';

class EditorDimensions {
  static Size calculateFrameSize(Size size, double ratio) {
    late final double height;
    late final double width;
    if (size.width / size.height > ratio) {
      height = .8 * size.height;
      width = ratio * height;
    } else {
      width = .8 * size.width;
      height = width / ratio;
    }
    return Size(width, height);
  }

  static Offset calculateFrameOffset(Size paneSize, Size frameSize) {
    final frameOffset = Offset((paneSize.width - frameSize.width) / 2,
        (paneSize.height - frameSize.height) / 2);
    return frameOffset;
  }

  final Size editorSize;
  final Offset frameOffset;
  final Size frameSize;
  final Size paneSize;
  final Size timelineSize;

  EditorDimensions({
    required this.editorSize,
    required this.frameOffset,
    required this.frameSize,
    required this.paneSize,
    required this.timelineSize,
  });

  factory EditorDimensions.fromConstraints(BoxConstraints constraints,
      {required FrameAspectRatio aspectRatio, required bool singleFrame}) {
    final editorSize = Size(constraints.maxWidth, constraints.maxHeight);
    final timelineSize = singleFrame
        ? Size(editorSize.width, (editorSize.height * .1).clamp(50, 70))
        : Size(editorSize.width, (editorSize.height * .175).clamp(80, 120));
    final paneSize = Size(editorSize.width,
        editorSize.height - EditorToolbar.height - timelineSize.height);
    final frameSize =
        EditorDimensions.calculateFrameSize(paneSize, aspectRatio.ratio());
    final frameOffset =
        EditorDimensions.calculateFrameOffset(paneSize, frameSize);
    return EditorDimensions(
      editorSize: editorSize,
      frameOffset: frameOffset,
      frameSize: frameSize,
      paneSize: paneSize,
      timelineSize: timelineSize,
    );
  }
}
