import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_api/api_types.dart';

const green = Color(0xff27ae60);

extension on NoteType {
  String label() {
    switch (this) {
      case NoteType.sixteenth:
        return '16th';
      case NoteType.eighth:
        return '8th';
      case NoteType.quarter:
        return 'quarter';
      case NoteType.half:
        return 'half';
      case NoteType.whole:
        return 'whole';
    }
  }
}

typedef ComposeCallback = void Function(List<Note>);

class ComposeChart extends StatelessWidget {
  final ComposeCallback callback;
  final Instrument instrument;

  const ComposeChart({
    super.key,
    required this.callback,
    required this.instrument,
  });

  @override
  Widget build(BuildContext context) {
    final measureRatio = EntityType.measureChart.defaultSize();
    final appSize = MediaQuery.sizeOf(context);
    final chartSize = Size(
      appSize.width * measureRatio.width * 1.1,
      appSize.height * measureRatio.height * 1.1,
    );
    final chartPositioning = ChartPositioning.calculate(chartSize, instrument);
    return Center(
      child: _ComposeChart(
        callback: callback,
        chartPositioning: chartPositioning,
        chartSize: chartSize,
        instrument: instrument,
        notePositions: calculateNotePositions(instrument, chartPositioning),
      ),
    );
  }

  List<(Note, Offset)> calculateNotePositions(
    Instrument instrument,
    ChartPositioning chartPositioning,
  ) {
    const noteType = NoteType.eighth;
    final List<(Note, Offset)> result = [];
    for (var string = 1; string <= instrument.stringCount(); string++) {
      for (var nth = 1; nth <= noteType.notesPerMeasure(); nth++) {
        final note = Note(string, 0, timing: Timing(noteType, nth));
        result.add((note, chartPositioning.position(note)));
      }
    }
    return result;
  }
}

class _ComposeChart extends StatefulWidget {
  final ChartPositioning chartPositioning;
  final Size chartSize;
  final Instrument instrument;
  final List<(Note, Offset)> notePositions;
  final ComposeCallback callback;

  const _ComposeChart({
    required this.callback,
    required this.chartPositioning,
    required this.chartSize,
    required this.instrument,
    required this.notePositions,
  });

  @override
  State<_ComposeChart> createState() => _ComposeChartState();
}

class _ComposeChartState extends State<_ComposeChart> {
  final FocusScopeNode focusScopeNode = FocusScopeNode(
    debugLabel: 'compose-chart',
  );
  Note? cursor;
  Map<int, Map<Timing, (Note, bool)>> notes = {};

  @override
  void initState() {
    super.initState();
    for (var i = 1; i <= widget.instrument.stringCount(); i++) {
      notes[i] = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final chartRect = Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2),
      width: widget.chartSize.width,
      height: widget.chartSize.height,
    );
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): cancelCursor,
        const SingleActivator(LogicalKeyboardKey.space): toggleNote,
      },
      child: FocusTraversalGroup(
        child: FocusScope(
          node: focusScopeNode,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fromRect(
                rect: chartRect,
                child: MeasureDisplay(
                  Measure(notes: []),
                  size: widget.chartSize,
                  tabContext: TabContext.forBrightness(Brightness.dark),
                  instrument: widget.instrument,
                ),
              ),
              ...buildNotePositions(chartRect),
              Positioned.fromRect(
                rect: Rect.fromPoints(
                  chartRect.topLeft.translate(0, -70),
                  chartRect.topRight.translate(0, -20),
                ),
                child: _ComposeChartMenu(
                  onFinished: closeComposing,
                  width: widget.chartSize.width,
                ),
              ),
              if (cursor != null)
                Positioned.fromRect(
                  rect: Rect.fromPoints(
                    chartRect.bottomLeft.translate(0, 20),
                    chartRect.bottomRight.translate(0, 70),
                  ),
                  child: _NotePositionMenu(
                    note: cursor!,
                    width: widget.chartSize.width,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildNotePositions(Rect chartRect) {
    const size = Size.square(_NotePlacement.size);
    return widget.notePositions.map((notePosition) {
      final noteRect = Rect.fromCenter(
        center: chartRect.topLeft.translate(
          notePosition.$2.dx,
          notePosition.$2.dy,
        ),
        width: size.width,
        height: size.height,
      );
      final note = notePosition.$1;
      return Positioned.fromRect(
        rect: noteRect,
        child: _NotePlacement(
          included: notes[note.string]?[note.timing]?.$2 == true,
          note: note,
          onSelectNote: changeCursor,
        ),
      );
    }).toList();
  }

  void cancelCursor() {
    if (cursor != null) {
      setState(() => cursor = null);
    }
    focusScopeNode.unfocus();
  }

  void changeCursor(Note note) {
    setState(() => cursor = note);
  }

  void closeComposing() {
    final List<Note> result = [];
    for (final notesByTiming in notes.values) {
      for (final note in notesByTiming.values) {
        if (note.$2) {
          result.add(note.$1);
        }
      }
    }
    widget.callback(result);
  }

  void toggleNote() {
    if (cursor != null) {
      setState(() {
        final note = cursor!;
        var lookup = notes[note.string]![note.timing];
        if (lookup == null) {
          notes[note.string]![note.timing] = (note, true);
        } else {
          notes[note.string]![note.timing] = (lookup.$1, !lookup.$2);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    focusScopeNode.dispose();
  }
}

typedef _NoteCallback = void Function(Note);

class _NotePlacement extends StatefulWidget {
  static const double size = 40;
  final bool included;
  final Note note;
  final _NoteCallback onSelectNote;

  const _NotePlacement({
    required this.included,
    required this.note,
    required this.onSelectNote,
  });

  @override
  State<StatefulWidget> createState() {
    return _NotePlacementState();
  }
}

class _NotePlacementState extends State<_NotePlacement> {
  late final FocusNode focusNode;
  bool focused = false;
  bool mouseHovering = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(
      debugLabel:
          'note-placement-${widget.note.timing.toSixteenthNth()}x${widget.note.string}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: false,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => mouseHovering = true),
        onExit: (_) => setState(() => mouseHovering = false),
        child: GestureDetector(
          onTap: onTap,
          child: Center(child: container()),
        ),
      ),
    );
  }

  AnimatedContainer container() {
    final size = containerSize();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 75),
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        color: containerColor(),
        border: Border.all(color: borderColor(), width: 2),
      ),
    );
  }

  Color borderColor() {
    if (focused) {
      return green;
    } else if (widget.included) {
      return const Color(0xffdddddd);
    } else if (mouseHovering) {
      return Colors.transparent;
    } else {
      return Colors.transparent;
    }
  }

  Color containerColor() {
    if (widget.included) {
      return const Color(0xffeeeeee);
    } else if (focused) {
      return green;
    } else if (mouseHovering) {
      return Colors.purple;
    } else {
      return Colors.transparent;
    }
  }

  double containerSize() {
    if (widget.included) {
      return _NotePlacement.size;
    } else if (focused) {
      return _NotePlacement.size * .25;
    } else if (mouseHovering) {
      return _NotePlacement.size * .4;
    } else {
      return 0;
    }
  }

  void onFocusChange(bool focused) {
    setState(() => this.focused = focused);
    if (focused) {
      widget.onSelectNote(widget.note);
    }
  }

  void onTap() {
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }
}

class _ComposeChartMenu extends StatelessWidget {
  final VoidCallback onFinished;
  final double width;

  const _ComposeChartMenu({required this.onFinished, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: width,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: const Color(0xffd9d9d9)),
        borderRadius: BorderRadius.circular(2),
        color: const Color(0xffe1e1e1),
      ),
      child: Row(
        children: [
          _NotePositionMenuButton(
            onTap: onFinished,
            child: const Icon(Icons.done, color: green),
          ),
        ],
      ),
    );
  }
}

class _NotePositionMenu extends StatelessWidget {
  final Note note;
  final double width;

  const _NotePositionMenu({required this.note, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: width,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: const Color(0xffd9d9d9)),
        borderRadius: BorderRadius.circular(2),
        color: const Color(0xffe1e1e1),
      ),
      child: Row(
        children: [
          _NotePositionMenuButton.slide(
            onTap: () {
              if (kDebugMode) {
                print('slide');
              }
            },
          ),
          _NotePositionMenuButton.hammerOn(
            onTap: () {
              if (kDebugMode) {
                print('hammer on');
              }
            },
          ),
          _NotePositionMenuButton.pullOff(
            onTap: () {
              if (kDebugMode) {
                print('pull off');
              }
            },
          ),
          const Spacer(),
          Text(
            '${note.timing.nth}${stOrRdOrTh(note.timing.nth)} ${note.timing.type.label()} note',
          ),
        ],
      ),
    );
  }

  String stOrRdOrTh(int num) {
    return switch (num) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }
}

class _NotePositionMenuButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _NotePositionMenuButton({required this.child, required this.onTap});

  _NotePositionMenuButton.hammerOn({required this.onTap})
    : child = CustomPaint(
        size: const Size.square(40),
        painter: _HammerOnButtonPainter(),
      );

  _NotePositionMenuButton.slide({required this.onTap})
    : child = CustomPaint(
        size: const Size.square(40),
        painter: _SlideButtonPainter(),
      );

  _NotePositionMenuButton.pullOff({required this.onTap})
    : child = CustomPaint(
        size: const Size.square(40),
        painter: _PullOffButtonPainter(),
      );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffcecece)),
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xffd9d9d9),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _HammerOnButtonPainter extends _NotePositionMenuButtonPainter {
  @override
  Path createPath(Size size) {
    return Path()
      ..moveTo(0, size.height * .65)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * .2,
        size.width,
        size.height * .65,
      );
  }
}

class _SlideButtonPainter extends _NotePositionMenuButtonPainter {
  @override
  Path createPath(Size size) {
    return Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);
  }
}

class _PullOffButtonPainter extends _NotePositionMenuButtonPainter {
  @override
  Path createPath(Size size) {
    return Path()
      ..moveTo(0, size.height * .35)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * .8,
        size.width,
        size.height * .35,
      );
  }
}

abstract class _NotePositionMenuButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(createPath(size), createPaint(size));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  Path createPath(Size size);

  Paint createPaint(Size size) {
    return Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0x00444444), Color(0xff444444)],
            stops: [0, .5],
          ).createShader(
            Rect.fromPoints(
              const Offset(0, 0),
              Offset(size.width, size.height),
            ),
          )
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
  }
}
