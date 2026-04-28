import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_styles.dart';
import 'aspect_ratio.dart';
import 'editor_interaction.dart';
import 'editor_session.dart';
import 'frame_data.dart';

class LessonHeader extends StatefulWidget {
  static const double positionFromTop = 25;

  const LessonHeader({super.key});

  @override
  State<LessonHeader> createState() => _LessonHeaderState();
}

class _LessonHeaderState extends State<LessonHeader> {
  static const double headerHeight = EditorControls._controlsHeight + 10;

  @override
  Widget build(BuildContext context) {
    final editorSession = EditorSession.of(context);
    return SizedBox(
      height: headerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 25),
          _LessonNameTextField(
            focusNodeDebugLabel: 'lesson-plan-header',
            placeholderText: 'Unnamed lesson plan',
            text: editorSession.plan?.name,
            onUpdate: onUpdateLessonPlan,
          ),
          const SizedBox(width: 25),
          _LessonNameTextField(
            focusNodeDebugLabel: 'lesson-unit-header',
            placeholderText: 'Unnamed lesson unit',
            text: editorSession.unit?.name,
            onUpdate: onUpdateLessonUnit,
          ),
        ],
      ),
    );
  }

  void onUpdateLessonPlan(String name) {
    EditorSession.of(context).updateLessonPlanName(name);
  }

  void onUpdateLessonUnit(String name) {
    EditorSession.of(context).updateLessonUnitName(name);
  }
}

class _LessonNameTextField extends StatefulWidget {
  final String focusNodeDebugLabel;
  final String placeholderText;
  final String? text;
  final Function(String) onUpdate;

  const _LessonNameTextField({
    required this.focusNodeDebugLabel,
    required this.placeholderText,
    required this.text,
    required this.onUpdate,
  });

  @override
  State<_LessonNameTextField> createState() => _LessonNameTextFieldState();
}

class _LessonNameTextFieldState extends State<_LessonNameTextField> {
  static const hoveringTextStyle = TextStyle(
    color: Color(0xcc555555),
    fontSize: 20,
  );
  static const placeholderTextStyle = TextStyle(
    color: Color(0xee555555),
    fontSize: 20,
  );
  static const double placeholderWidth = 225;

  late final TextEditingController controller;
  bool editing = false;
  late final FocusNode focusNode;
  bool mouseHovering = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
    focusNode = FocusNode(debugLabel: widget.focusNodeDebugLabel);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => mouseHovering = true),
      onExit: (_) => setState(() => mouseHovering = false),
      child: GestureDetector(
        onTap: editing ? null : onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: placeholderWidth),
          child: editing
              ? SizedBox(
                  width: placeholderWidth,
                  child: TextField(
                    focusNode: focusNode,
                    controller: controller,
                    onSubmitted: onSubmit,
                    onTapOutside: onBlur,
                  ),
                )
              : Text(displayText(), style: textStyle()),
        ),
      ),
    );
  }

  String displayText() =>
      isPlaceholder() ? widget.placeholderText : widget.text!;

  bool isPlaceholder() => widget.text == null || widget.text!.isEmpty;

  TextStyle textStyle() =>
      mouseHovering ? hoveringTextStyle : placeholderTextStyle;

  void setEditing(bool editing) => setState(() => this.editing = editing);

  void onBlur([_]) => setEditing(false);

  void onSubmit(String text) {
    onBlur();
    widget.onUpdate(text);
  }

  void onTap() {
    setEditing(true);
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    focusNode.dispose();
  }
}

class EditorControls extends StatelessWidget {
  static const double positionFromTop = 30;
  static const double _controlsHeight = 45;
  static const double _controlsWidth = 200;
  static const double _buttonWidth = _controlsHeight;
  static const double _backgroundWidth = _controlsWidth - (_buttonWidth / 2);
  static const double _aspectRatioWidth = _controlsWidth - (_buttonWidth * 2);

  final FrameAspectRatio aspectRatio;
  final bool playButtonEnabled;
  final Function(FrameAspectRatio) onAspectRatioChanged;

  const EditorControls({
    super.key,
    required this.aspectRatio,
    required this.playButtonEnabled,
    required this.onAspectRatioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _controlsHeight,
      width: _controlsWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            height: _controlsHeight,
            width: _backgroundWidth,
            child: Container(color: const Color((0xfff3f3f3))),
          ),
          Positioned(
            left: 0,
            child: PlayPreviewButton(
              enabled: playButtonEnabled,
              size: const Size(_buttonWidth, _buttonWidth),
            ),
          ),
          Positioned(
            right: _buttonWidth,
            width: _aspectRatioWidth,
            height: _controlsHeight,
            child: AspectRatioButton(
              aspectRatio: aspectRatio,
              onAspectRatioChanged: onAspectRatioChanged,
            ),
          ),
          const Positioned(
            right: 0,
            height: _buttonWidth,
            width: _buttonWidth,
            child: SaveButton(),
          ),
        ],
      ),
    );
  }
}

class PlayPreviewButton extends StatefulWidget {
  final bool enabled;
  final Size size;

  const PlayPreviewButton({
    super.key,
    required this.enabled,
    required this.size,
  });

  @override
  State<PlayPreviewButton> createState() => _PlayPreviewButtonState();
}

class _PlayPreviewButtonState extends State<PlayPreviewButton> {
  bool mouseHovering = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => mouseHovering = true),
        onExit: (_) => setState(() => mouseHovering = false),
        child: SizedBox.fromSize(
          size: widget.size,
          child: CustomPaint(
            size: widget.size,
            painter: _buildPainter(),
            child: const Icon(Icons.play_arrow, color: Color(0xffe4e4e4)),
          ),
        ),
      ),
    );
  }

  _PlayButtonPainter _buildPainter() {
    if (widget.enabled) {
      if (mouseHovering) {
        return const _PlayButtonPainter.hovering();
      } else {
        return const _PlayButtonPainter.enabled();
      }
    } else {
      return const _PlayButtonPainter.disabled();
    }
  }
}

class _PlayButtonPainter extends CustomPainter {
  final Color radialInnie;
  final Color radialOutie;

  const _PlayButtonPainter.disabled()
    : radialInnie = const Color(0xffcacaca),
      radialOutie = const Color(0xffdddddd);

  const _PlayButtonPainter.enabled()
    : radialInnie = const Color(0xff17b917),
      radialOutie = const Color(0xff10d510);

  const _PlayButtonPainter.hovering()
    : radialInnie = const Color(0xff17c917),
      radialOutie = const Color(0xff10e510);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(center.dx, center.dy);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          radialInnie,
          radialOutie,
        ])
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _PlayButtonPainter oldDelegate) {
    return oldDelegate.radialInnie != radialInnie;
  }
}

typedef AspectRatioCallback = void Function(FrameAspectRatio aspectRatio);

class AspectRatioButton extends StatefulWidget {
  static const double _menuPositionFromRight = 10;
  static const double _menuPositionFromTop =
      _menuPositionFromRight +
      EditorControls.positionFromTop +
      EditorControls._controlsHeight;
  static const List<FrameAspectRatio> _menuDisplayOrder = [
    FrameAspectRatio.fourThree,
    FrameAspectRatio.sixteenTen,
    FrameAspectRatio.sixteenNine,
  ];

  final FrameAspectRatio aspectRatio;
  final AspectRatioCallback onAspectRatioChanged;

  const AspectRatioButton({
    super.key,
    required this.aspectRatio,
    required this.onAspectRatioChanged,
  });

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
        return Positioned(
          top: AspectRatioButton._menuPositionFromTop,
          right: AspectRatioButton._menuPositionFromRight,
          child: buildMenu(),
        );
      },
      child: buildButton(),
    );
  }

  Widget buildButton() {
    return GestureDetector(
      onTap: onButtonClick,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.aspectRatio.label(),
              style: const TextStyle(
                color: Color(0xee555555),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 7),
            const Icon(Icons.aspect_ratio, color: Color(0xee555555), size: 20),
          ],
        ),
      ),
    );
  }

  void onButtonClick() {
    if (kDebugMode) {
      print('_AspectRatioButtonState.onButtonClick');
    }
    EditorData.clearCurrentInteraction();
    controller.show();
  }

  Widget buildMenu() {
    return Container(
      color: AppStyles.aspectRatioMenuBackgroundColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: AspectRatioButton._menuDisplayOrder
            .map(
              (aspectRatio) => Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () => onAspectRatioMenuOptionClick(aspectRatio),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            color: aspectRatio == widget.aspectRatio
                                ? AppStyles.aspectRatioMenuSelectedColor
                                : AppStyles.transparentColor,
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 20),
                          Expanded(child: Text(aspectRatio.label())),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void onAspectRatioMenuOptionClick(FrameAspectRatio aspectRatio) {
    if (kDebugMode) {
      print(
        '_AspectRatioButtonState.onAspectRatioMenuOptionClick $aspectRatio',
      );
    }
    controller.hide();
    widget.onAspectRatioChanged(aspectRatio);
  }

  @override
  void dispose() {
    super.dispose();
    editorInteractionSub.cancel();
  }
}

// todo sync commands to api and remove button after entity data is stored relationally (see sql/v001-init-schema.sqlL82)
class SaveButton extends StatefulWidget {
  const SaveButton({super.key});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

enum _SaveState {
  networkUnavailable,
  saving,
  saveFailed,
  saveFinished,
  saveNotNecessary,
  localStateAvailable,
}

extension on _SaveState {
  bool enabled() {
    return switch (this) {
      _SaveState.networkUnavailable ||
      _SaveState.saveNotNecessary ||
      _SaveState.saving => false,
      _ => true,
    };
  }
}

class _SaveButtonState extends State<SaveButton> {
  bool mouseHovering = false;
  _SaveState state = _SaveState.localStateAvailable;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: state.enabled() ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => mouseHovering = true),
      onExit: (_) => setState(() => mouseHovering = false),
      child: GestureDetector(
        onTap: state.enabled() ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 75),
          color: _buttonColor(),
          padding: const EdgeInsets.all(5),
          child: Center(
            child: Icon(
              _buttonIcon(),
              color: const Color(0xffe4e4e4),
              size: 25,
            ),
          ),
        ),
      ),
    );
  }

  Color _buttonColor() {
    if (state == _SaveState.saveFailed) {
      return mouseHovering ? const Color(0xffff5722) : const Color(0xffef4712);
    } else if (state.enabled()) {
      return mouseHovering ? const Color(0xff10e510) : const Color(0xff10d510);
    } else {
      return const Color(0xffcacaca);
    }
  }

  IconData _buttonIcon() {
    return switch (state) {
      _SaveState.saveFinished ||
      _SaveState.saveNotNecessary => Icons.cloud_done,
      _SaveState.localStateAvailable => Icons.cloud_upload,
      _SaveState.networkUnavailable => Icons.cloud_off,
      _SaveState.saveFailed => Icons.sync_problem,
      _SaveState.saving => Icons.cloud_sync,
    };
  }

  Future<void> onTap() async {
    _updateState(_SaveState.saving);
    late final bool success;
    try {
      await EditorSession.of(
        context,
      ).saveLessonUnitFrames(FrameData.of(context).state.frames);
      success = true;
    } catch (e) {
      success = false;
    }
    _updateState(success ? _SaveState.saveFinished : _SaveState.saveFailed);
    if (mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: success
              ? const Text('Saved changes to cloud!')
              : const Text(
                  'Error saving to cloud!',
                  style: TextStyle(color: Colors.deepOrange),
                ),
        ),
      );
    }
  }

  void _updateState(_SaveState update) {
    if (mounted) setState(() => state = update);
  }
}
