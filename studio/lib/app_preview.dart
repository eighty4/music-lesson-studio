import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PlayPreviewButton extends StatefulWidget {
  final bool enabled;
  final Size size;

  const PlayPreviewButton(
      {super.key, required this.enabled, required this.size});

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
              child: const Icon(
                Icons.play_arrow,
                color: Color(0xffe4e4e4),
              ),
            ),
          )),
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
          ..shader = ui.Gradient.radial(
            center,
            radius,
            [radialInnie, radialOutie],
          )
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _PlayButtonPainter oldDelegate) {
    return oldDelegate.radialInnie != radialInnie;
  }
}
