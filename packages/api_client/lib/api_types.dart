import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:libtab/libtab.dart';

extension on Note {
  Map<String, dynamic> toJson() {
    return {'f': fret, 'm': melody, 's': string, 't': timing.toSixteenthNth()};
  }
}

extension type UniqueId(String id) {}

class LessonPlan {
  final UniqueId? id;
  final String? name;
  final List<LessonUnit> units;

  LessonPlan({this.id, this.name, List<LessonUnit>? units})
    : units = units ?? const [];

  factory LessonPlan.fromJson(String json) {
    return LessonPlan.fromDecodedJson(jsonDecode(json));
  }

  factory LessonPlan.fromDecodedJson(Map<String, dynamic> decoded) {
    return LessonPlan(
      id: decoded['id'],
      name: decoded['name'],
      units: decoded['units'] == null
          ? null
          : List<LessonUnit>.from(
              decoded['units'].map((unit) => LessonUnit.fromDecodedJson(unit)),
            ),
    );
  }
}

class LessonUnit {
  final UniqueId? id;
  final String? name;
  final List<Frame> frames;

  LessonUnit({this.id, this.name, List<Frame>? frames})
    : frames = frames ?? const [];

  factory LessonUnit.fromDecodedJson(Map<String, dynamic> decoded) {
    return LessonUnit(
      id: decoded['id'],
      name: decoded['name'],
      frames: decoded['frames'] == null
          ? null
          : List<Frame>.from(
              decoded['frames'].map((frame) => Frame.fromDecodedJson(frame)),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'frames': frames};
  }
}

class Frame {
  final UniqueKey key;
  final List<Entity> entities;

  Frame({Iterable<Entity>? entities, UniqueKey? key})
    : key = key ?? UniqueKey(),
      entities = List.of(entities ?? [], growable: false);

  factory Frame.fromDecodedJson(Map<String, dynamic> decoded) {
    assert(decoded['entities'] != null);
    return Frame(
      entities: List<Entity>.from(
        decoded['entities'].map((entity) => Entity.fromDecodedJson(entity)),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Frame && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;

  Map<String, dynamic> toJson() {
    return {'entities': entities};
  }
}

enum EntityType {
  measureChart,
  chordChart,
  paragraphText,
  hypermediaLink,
  imageUpload,
  videoUpload,
  videoRecord,
  youTubeEmbed,
}

extension EntityTypeFns on EntityType {
  EntityData defaultData() {
    return switch (this) {
      EntityType.chordChart => ChordChartData(
        chord: Chord.c,
        instrument: Instrument.banjo,
      ),
      EntityType.measureChart => MeasureChartData(
        instrument: Instrument.banjo,
        notes: [
          Note(2, 1, melody: true, timing: Timing(NoteType.eighth, 1)),
          Note(5, 6, slideTo: 7, timing: Timing(NoteType.eighth, 2)),
          Note(3, 3, timing: Timing(NoteType.eighth, 3)),
          Note(4, 4, timing: Timing(NoteType.eighth, 4)),
        ],
      ),
      EntityType.paragraphText => throw UnimplementedError(),
      EntityType.hypermediaLink => throw UnimplementedError(),
      EntityType.imageUpload => throw UnimplementedError(),
      EntityType.videoUpload => throw UnimplementedError(),
      EntityType.videoRecord => throw UnimplementedError(),
      EntityType.youTubeEmbed => throw UnimplementedError(),
    };
  }

  Size defaultSize() {
    return switch (this) {
      EntityType.chordChart => const Size(.15, .25),
      EntityType.measureChart => const Size(.4, .3),
      EntityType.paragraphText => throw UnimplementedError(),
      EntityType.hypermediaLink => throw UnimplementedError(),
      EntityType.imageUpload => throw UnimplementedError(),
      EntityType.videoUpload => throw UnimplementedError(),
      EntityType.videoRecord => throw UnimplementedError(),
      EntityType.youTubeEmbed => throw UnimplementedError(),
    };
  }

  String identifier() {
    return switch (this) {
      EntityType.chordChart => 'chord',
      EntityType.measureChart => 'measure',
      EntityType.paragraphText => throw UnimplementedError(),
      EntityType.hypermediaLink => throw UnimplementedError(),
      EntityType.imageUpload => throw UnimplementedError(),
      EntityType.videoUpload => throw UnimplementedError(),
      EntityType.videoRecord => throw UnimplementedError(),
      EntityType.youTubeEmbed => throw UnimplementedError(),
    };
  }
}

abstract class EntityData {
  Map<String, dynamic> toJson();
}

class ChordChartData extends EntityData {
  Instrument instrument;
  Chord chord;

  ChordChartData({required this.instrument, required this.chord});

  factory ChordChartData.fromDecodedJson(Map<String, dynamic> decoded) {
    assert(decoded['chord'] != null);
    assert(decoded['instrument'] != null);
    return ChordChartData(
      chord: Chord.values.byName(decoded['chord']),
      instrument: Instrument.values.byName(decoded['instrument']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'chord': chord.name, 'instrument': instrument.name};
  }
}

class MeasureChartData extends EntityData {
  Instrument instrument;
  List<Note> notes;

  MeasureChartData({required this.instrument, required this.notes});

  factory MeasureChartData.fromDecodedJson(Map<String, dynamic> decoded) {
    assert(decoded['instrument'] != null);
    assert(decoded['notes'] != null);
    return MeasureChartData(
      instrument: Instrument.values.byName(decoded['instrument']),
      notes: [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'instrument': instrument.name,
      'notes': notes.map((note) => note.toJson()).toList(growable: false),
    };
  }
}

class Entity<T extends EntityData> {
  final UniqueKey key;
  final EntityType type;
  final Offset offset;
  final Size size;
  final T data;

  Entity({
    required this.type,
    required this.offset,
    required this.data,
    Size? size,
    UniqueKey? key,
  }) : key = key ?? UniqueKey(),
       size = size ?? type.defaultSize() {
    assert(
      data.runtimeType ==
          switch (type) {
            EntityType.chordChart => ChordChartData,
            EntityType.measureChart => MeasureChartData,
            _ => throw UnimplementedError(),
          },
    );
  }

  factory Entity.chordChart({
    required Chord chord,
    required Instrument instrument,
    required Offset offset,
    Size? size,
  }) {
    return Entity(
      type: EntityType.chordChart,
      data: ChordChartData(chord: chord, instrument: instrument) as T,
      offset: offset,
      size: size,
    );
  }

  factory Entity.measureChart({
    required Instrument instrument,
    required List<Note> notes,
    required Offset offset,
    Size? size,
  }) {
    return Entity(
      type: EntityType.measureChart,
      data: MeasureChartData(instrument: instrument, notes: notes) as T,
      offset: offset,
      size: size,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;

  factory Entity.fromDecodedJson(Map<String, dynamic> decoded) {
    final entityType = _entityTypeFromIdentifier(decoded['type']);
    return Entity(
      type: _entityTypeFromIdentifier(decoded['type']),
      data:
          switch (entityType) {
                EntityType.chordChart => ChordChartData.fromDecodedJson(
                  decoded['data'],
                ),
                EntityType.measureChart => MeasureChartData.fromDecodedJson(
                  decoded['data'],
                ),
                _ => throw UnimplementedError(),
              }
              as T,
      offset: _rectToOffset(decoded['rect']),
      size: _rectToSize(decoded['rect']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.identifier(),
      'rect': {
        'x': offset.dx,
        'y': offset.dy,
        'w': size.width,
        'h': size.height,
      },
      'data': data.toJson(),
    };
  }
}

EntityType _entityTypeFromIdentifier(String entityTypeIdentifier) =>
    switch (entityTypeIdentifier) {
      'chord' => EntityType.chordChart,
      'measure' => EntityType.measureChart,
      _ => throw Error(),
    };

Offset _rectToOffset(Map<String, dynamic> decoded) {
  assert(decoded['x'] != null && decoded['y'] != null);
  return Offset(_numberToDouble(decoded['x']), _numberToDouble(decoded['y']));
}

Size _rectToSize(Map<String, dynamic> decoded) {
  assert(decoded['w'] != null && decoded['h'] != null);
  return Size(_numberToDouble(decoded['w']), _numberToDouble(decoded['h']));
}

double _numberToDouble(dynamic number) {
  if (number is int) {
    return number.toDouble();
  } else if (number is double) {
    return number;
  } else {
    throw Error();
  }
}
