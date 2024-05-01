import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';

import 'entity_data.dart';

class EntityContent extends StatelessWidget {
  final Entity entity;
  final Size size;
  final TabContext tabContext;

  EntityContent(this.entity, {super.key, Size? size, required this.tabContext})
      : size = size ?? entity.size;

  @override
  Widget build(BuildContext context) {
    return switch (entity.type) {
      EntityType.chordChart =>
        ChordChartEntityContent(entity, size, tabContext: tabContext),
      EntityType.measureChart =>
        MeasureChartEntityContent(entity, size, tabContext: tabContext),
      EntityType.paragraphText => throw UnimplementedError(),
      EntityType.hypermediaLink => throw UnimplementedError(),
      EntityType.imageUpload => throw UnimplementedError(),
      EntityType.videoUpload => throw UnimplementedError(),
      EntityType.videoRecord => throw UnimplementedError(),
      EntityType.youTubeEmbed => throw UnimplementedError(),
    };
  }
}

class ChordChartEntityContent extends StatelessWidget {
  final Entity entity;
  final Size size;
  final TabContext tabContext;

  const ChordChartEntityContent(this.entity, this.size,
      {super.key, required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return ChordChartDisplay(
        chord: ChordNoteSet(Instrument.banjo, Chord.c),
        tabContext: tabContext,
        // todo scale for aspect ratio
        size: size);
  }
}

class MeasureChartEntityContent extends StatelessWidget {
  final Entity entity;
  final Size size;
  final TabContext tabContext;

  const MeasureChartEntityContent(this.entity, this.size,
      {super.key, required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return MeasureDisplay(
        Measure.fromNoteList([
          Note(2, 1),
          Note(5, 0),
          Note(1, 2),
          Note(5, 0),
          Note(1, 0),
          null,
          Note(5, 0),
          Note(1, 0),
        ]),
        instrument: Instrument.banjo,
        tabContext: tabContext,
        // todo scale for aspect ratio
        size: size);
  }
}
