import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';

import 'api_types.dart';
import 'app_styles.dart';

class EntityContent extends StatelessWidget {
  final Entity entity;
  final Size size;
  final TabContext tabContext;

  EntityContent(this.entity, {super.key, Size? size, required this.tabContext})
      : size = size ?? entity.size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyles.entityBackgroundColor,
      child: switch (entity.type) {
        EntityType.chordChart =>
          _ChordChartEntityContent(entity, size, tabContext: tabContext),
        EntityType.measureChart =>
          _MeasureChartEntityContent(entity, size, tabContext: tabContext),
        EntityType.paragraphText => throw UnimplementedError(),
        EntityType.hypermediaLink => throw UnimplementedError(),
        EntityType.imageUpload => throw UnimplementedError(),
        EntityType.videoUpload => throw UnimplementedError(),
        EntityType.videoRecord => throw UnimplementedError(),
        EntityType.youTubeEmbed => throw UnimplementedError(),
      },
    );
  }
}

class _ChordChartEntityContent extends StatelessWidget {
  final Entity entity;
  final Size size;
  final TabContext tabContext;

  const _ChordChartEntityContent(this.entity, this.size,
      {required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return ChordChartDisplay(
        chord: ChordNoteSet(Instrument.banjo, Chord.c),
        tabContext: tabContext,
        // todo scale for aspect ratio
        size: size);
  }
}

class _MeasureChartEntityContent extends StatelessWidget {
  final Entity entity;
  final Size size;
  final TabContext tabContext;

  const _MeasureChartEntityContent(this.entity, this.size,
      {required this.tabContext});

  @override
  Widget build(BuildContext context) {
    return MeasureDisplay(
        Measure.fromNoteList([
          Note(2, 1, melody: true),
          Note(5, 6, slideTo: 7),
          Note(3, 3),
          Note(4, 4),
          null,
          null,
          null,
          null,
        ]),
        // todo configurable instrument
        instrument: Instrument.banjo,
        tabContext: tabContext,
        size: size);
  }
}
