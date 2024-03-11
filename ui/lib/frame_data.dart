enum EntityType {
  measureChart,
  chordChart,
  paragraphText,
  hypermediaLink,
  imageUpload,
  videoUpload,
  videoRecord,
  youTubeEmbed
}

class Entity {
  final EntityType type;
  final int x;
  final int y;
  final int w;
  final int h;

  Entity(
      {required this.type,
      required this.x,
      required this.y,
      required this.w,
      required this.h});
}

class Frame {
  final List<Entity> entities = [];
}

class FrameData {
  final List<Frame> frames = [Frame()];
  int currentFrame = 0;

  // todo currentFrame observable

  addEntity(int frameIndex, Entity entity) {}
}
