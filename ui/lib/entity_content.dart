import 'package:flutter/widgets.dart';
import 'package:libtab/libtab.dart';
import 'package:mls_ui/entity_data.dart';
import 'package:mls_ui/studio_editor.dart';

class DefaultEntityContent extends StatelessWidget {
  final EntityType entityType;
  final Offset offset;

  const DefaultEntityContent(this.entityType, this.offset, {super.key});

  @override
  Widget build(BuildContext context) {
    return EntityContent(Entity(
      type: entityType,
      x: offset.dx,
      y: offset.dy,
    ));
  }
}

class EntityContent extends StatelessWidget {
  final Entity entity;
  final Size size;

  EntityContent(this.entity, {super.key, Size? size})
      : size = size ?? entity.size;

  @override
  Widget build(BuildContext context) {
    return switch (entity.type) {
      EntityType.chordChart => ChordChartEntityContent(entity, size: size),
      EntityType.measureChart => MeasureChartEntityContent(entity, size: size),
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

  ChordChartEntityContent(this.entity, {super.key, Size? size})
      : size = size ?? entity.size;

  @override
  Widget build(BuildContext context) {
    return ChordChartDisplay(
        chord: ChordNoteSet(Instrument.banjo, Chord.c),
        tabContext: StudioEditor.tabContext,
        // todo scale for aspect ratio
        size: size);
  }
}

class MeasureChartEntityContent extends StatelessWidget {
  final Entity entity;
  final Size size;

  MeasureChartEntityContent(this.entity, {super.key, Size? size})
      : size = size ?? entity.size;

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
        tabContext: StudioEditor.tabContext,
        // todo scale for aspect ratio
        size: size);
  }
}
