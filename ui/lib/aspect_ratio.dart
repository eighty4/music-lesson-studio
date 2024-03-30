enum AspectRatioSetting {
  sixteenTen,
  sixteenNine,
  fourThree,
}

extension AspectRatioSettingFns on AspectRatioSetting {
  String label() {
    return switch (this) {
      AspectRatioSetting.sixteenTen => '16:10',
      AspectRatioSetting.sixteenNine => '16:9',
      AspectRatioSetting.fourThree => '4:3',
    };
  }

  double ratio() {
    return switch (this) {
      AspectRatioSetting.sixteenTen => 16 / 10,
      AspectRatioSetting.sixteenNine => 16 / 9,
      AspectRatioSetting.fourThree => 4 / 3,
    };
  }
}
