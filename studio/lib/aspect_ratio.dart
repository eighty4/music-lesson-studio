enum FrameAspectRatio {
  fourThree,
  sixteenTen,
  sixteenNine,
}

extension FrameAspectRatioFns on FrameAspectRatio {
  String label() {
    return switch (this) {
      FrameAspectRatio.fourThree => '4:3',
      FrameAspectRatio.sixteenTen => '16:10',
      FrameAspectRatio.sixteenNine => '16:9',
    };
  }

  double ratio() {
    return switch (this) {
      FrameAspectRatio.fourThree => 4 / 3,
      FrameAspectRatio.sixteenTen => 1.6,
      FrameAspectRatio.sixteenNine => 16 / 9,
    };
  }
}
