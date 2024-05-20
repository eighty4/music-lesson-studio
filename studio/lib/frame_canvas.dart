import 'package:flutter/widgets.dart';
import 'package:libtab/context.dart';
import 'package:mls_api/api_types.dart';

import 'frame_scaling.dart';
import 'frame_widget.dart';

class FrameCanvas extends StatelessWidget {
  final List<FrameEntityWidget> entityWidgets;
  final bool interactive;

  FrameCanvas(
      {super.key,
      required Frame frame,
      required FrameScaling frameScaling,
      required this.interactive,
      required TabContext tabContext})
      : entityWidgets = frame.entities
            .map((entity) => FrameEntityWidget(
                  entity,
                  interactive: interactive,
                  projection: frameScaling.projectEntity(entity),
                  scaling: frameScaling,
                  tabContext: tabContext,
                ))
            .toList();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: entityWidgets,
    );
  }
}
