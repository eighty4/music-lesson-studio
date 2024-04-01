import 'dart:ui';

enum FrameAspectRatio {
  sixteenTen,
  sixteenNine,
  fourThree,
}

extension FrameAspectRatioFns on FrameAspectRatio {
  String label() {
    return switch (this) {
      FrameAspectRatio.sixteenTen => '16:10',
      FrameAspectRatio.sixteenNine => '16:9',
      FrameAspectRatio.fourThree => '4:3',
    };
  }

  Offset offset() {
    return switch (this) {
      FrameAspectRatio.sixteenTen => const Offset(16, 10),
      FrameAspectRatio.sixteenNine => const Offset(16, 9),
      FrameAspectRatio.fourThree => const Offset(4, 3),
    };
  }

  double ratio() {
    return switch (this) {
      FrameAspectRatio.sixteenTen => 16 / 10,
      FrameAspectRatio.sixteenNine => 16 / 9,
      FrameAspectRatio.fourThree => 4 / 3,
    };
  }
}
