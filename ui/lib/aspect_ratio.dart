import 'dart:async';

import 'package:flutter/material.dart';

import 'editor_data.dart';

enum FrameAspectRatio {
  sixteenTen,
  sixteenNine,
  fourThree,
}

extension FrameAspectRatioFns on FrameAspectRatio {
  String label() {
    return switch (this) {
      FrameAspectRatio.sixteenTen => '16:10',
      FrameAspectRatio.sixteenNine => '16:9',
      FrameAspectRatio.fourThree => '4:3',
    };
  }

  Offset offset() {
    return switch (this) {
      FrameAspectRatio.sixteenTen => const Offset(16, 10),
      FrameAspectRatio.sixteenNine => const Offset(16, 9),
      FrameAspectRatio.fourThree => const Offset(4, 3),
    };
  }

  double ratio() {
    return switch (this) {
      FrameAspectRatio.sixteenTen => 16 / 10,
      FrameAspectRatio.sixteenNine => 16 / 9,
      FrameAspectRatio.fourThree => 4 / 3,
    };
  }
}

typedef AspectRatioCallback = void Function(FrameAspectRatio aspectRatio);

class AspectRatioButton extends StatefulWidget {
  final FrameAspectRatio aspectRatio;
  final AspectRatioCallback onAspectRatioChanged;

  const AspectRatioButton(
      {super.key,
      required this.aspectRatio,
      required this.onAspectRatioChanged});

  @override
  State<AspectRatioButton> createState() => _AspectRatioButtonState();
}

class _AspectRatioButtonState extends State<AspectRatioButton> {
  final OverlayPortalController controller = OverlayPortalController();
  late final StreamSubscription editorInteractionSub;

  @override
  void initState() {
    super.initState();
    editorInteractionSub = EditorData.interactionState.listen((event) {
      if (event != null) {
        controller.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: controller,
      overlayChildBuilder: (context) {
        return Positioned(top: 50, right: 50, child: buildMenu());
      },
      child: buildButton(),
    );
  }

  Widget buildButton() {
    return GestureDetector(
        onTap: () {
          EditorData.clearCurrentInteraction();
          controller.show();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
              padding: const EdgeInsets.all(10),
              width: 70,
              color: Colors.white70,
              child: Center(child: Text(widget.aspectRatio.label()))),
        ));
  }

  Widget buildMenu() {
    return Container(
      color: Colors.amber,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: FrameAspectRatio.values
            .map((aspectRatio) => Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      controller.hide();
                      widget.onAspectRatioChanged(aspectRatio);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        width: 100,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  color: aspectRatio == widget.aspectRatio
                                      ? Colors.green
                                      : Colors.transparent,
                                  height: 20,
                                  width: 20),
                              const SizedBox(width: 20),
                              Expanded(child: Text(aspectRatio.label())),
                            ]),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
  }
}
