import 'package:libtab/libtab.dart';

class Song {
  String name;
  List<Measure> measures;

  Song({required this.name, required this.measures});
}

Song lookupSong(String songId) {
  return switch (songId) {
    "Black Mountain Rag" => blackMountainRag(),
    "I've Been All Around This World" => iveBeenAllAroundThisWorld(),
    "Little Maggie" => littleMaggie(),
    "Nine Pound Hammer" => ninePoundHammer(),
    "Reuben's Train" => reubensTrain(),
    "Wayfaring Stranger" => wayfaringStrange(),
    "Will the Circle Be Unbroken" => willTheCircleBeUnbroken(),
    _ => throw Error()
  };
}

Song blackMountainRag() =>
    Song(name: 'Black Mountain Rag', measures: _fallbackMeasures);

Song iveBeenAllAroundThisWorld() =>
    Song(name: "I've Been All Around This World", measures: _fallbackMeasures);

Song littleMaggie() => Song(name: "Little Maggie", measures: _fallbackMeasures);

Song ninePoundHammer() =>
    Song(name: "Nine Pound Hammer", measures: _fallbackMeasures);

Song reubensTrain() =>
    Song(name: "Reuben's Train", measures: _fallbackMeasures);

Song wayfaringStrange() =>
    Song(name: "Wayfaring Stranger", measures: _fallbackMeasures);

Song willTheCircleBeUnbroken() =>
    Song(name: "Will the Circle Be Unbroken", measures: _fallbackMeasures);

final List<Measure> _fallbackMeasures = [
  Measure.fromNoteList([
    Note(2, 0),
    Note(1, 0),
    Note(5, 0),
    Note(2, 0),
    Note(1, 0),
    Note(5, 0),
    Note(2, 0),
    Note(1, 0),
  ]),
  Measure.fromNoteList([
    Note(1, 0),
    Note(2, 0),
    Note(5, 0),
    Note(1, 0),
    Note(2, 0),
    Note(5, 0),
    Note(1, 0),
    Note(2, 0)
  ]),
  Measure.fromNoteList([
    Note(3, 0),
    Note(2, 0),
    Note(1, 0),
    Note(5, 0),
    Note(1, 0),
    Note(2, 0),
    Note(3, 0),
    Note(1, 0),
  ]),
  Measure.fromNoteList([
    Note(3, 0),
    Note(2, 0),
    Note(5, 0),
    Note(1, 0),
    Note(4, 0),
    Note(2, 0),
    Note(5, 0),
    Note(1, 0),
  ]),
];
