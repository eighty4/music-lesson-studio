abstract class FrameCommand {
  exec();

  undo();
}

class CreateEntity implements FrameCommand {
  @override
  exec() {
    // TODO: implement exec
    throw UnimplementedError();
  }

  @override
  undo() {
    // TODO: implement undo
    throw UnimplementedError();
  }
}

class MoveEntity implements FrameCommand {
  @override
  exec() {
    // TODO: implement exec
    throw UnimplementedError();
  }

  @override
  undo() {
    // TODO: implement undo
    throw UnimplementedError();
  }
}

class ResizeEntity implements FrameCommand {
  @override
  exec() {
    // TODO: implement exec
    throw UnimplementedError();
  }

  @override
  undo() {
    // TODO: implement undo
    throw UnimplementedError();
  }
}

class DeleteEntity implements FrameCommand {
  @override
  exec() {
    // TODO: implement exec
    throw UnimplementedError();
  }

  @override
  undo() {
    // TODO: implement undo
    throw UnimplementedError();
  }
}
