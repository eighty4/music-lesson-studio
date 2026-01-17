import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';

import 'songs.dart';

class PlaySongScreen extends StatelessWidget {
  final String songId;

  const PlaySongScreen({super.key, required this.songId});

  @override
  Widget build(BuildContext context) {
    final song = lookupSong(songId);
    return _PlayMeasureInterface(title: song.name, measures: song.measures);
  }
}

class _PlayMeasureInterface extends StatefulWidget {
  final String title;
  final List<Measure> measures;

  _PlayMeasureInterface({required this.title, required this.measures}) {
    assert(measures.isNotEmpty);
  }

  @override
  State<_PlayMeasureInterface> createState() => _PlayMeasureInterfaceState();
}

class _PlayMeasureInterfaceState extends State<_PlayMeasureInterface> {
  int currentMeasure = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    setTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): prev,
        LogicalKeySet(LogicalKeyboardKey.arrowRight): next,
      },
      child: Focus(
        autofocus: true,
        child: Center(
          child: MeasureChart.singleMeasure(
            measure: widget.measures[currentMeasure],
            size: MediaQuery.sizeOf(context) / 2.25,
            tabContext: TabContext.forBrightness(Brightness.light),
            instrument: Instrument.guitar,
            last: isLastMeasure(),
          ),
        ),
      ),
    );
  }

  bool isLastMeasure() {
    return currentMeasure == widget.measures.length - 1;
  }

  prev() {
    if (mounted) {
      setState(() {
        currentMeasure = currentMeasure == 0
            ? widget.measures.length - 1
            : currentMeasure - 1;
      });
      resetTimer();
    }
  }

  next() {
    if (mounted) {
      setState(() => currentMeasure = isLastMeasure() ? 0 : currentMeasure + 1);
      resetTimer();
    }
  }

  setTimer() {
    timer = Timer(const Duration(seconds: 8), next);
  }

  resetTimer() {
    timer.cancel();
    setTimer();
  }
}
