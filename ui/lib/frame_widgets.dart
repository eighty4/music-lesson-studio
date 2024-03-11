// am i a widget or a model?
import 'package:flutter/widgets.dart';

class FrameEntityWidget extends StatefulWidget {
  const FrameEntityWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FrameEntityWidgetState();
  }
}

class _FrameEntityWidgetState extends State<FrameEntityWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        child: Container(
      height: 100,
      width: 100,
      color: const Color.fromARGB(255, 168, 32, 98),
    ));
  }
}
