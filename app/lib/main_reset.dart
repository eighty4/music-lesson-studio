import 'package:flutter/widgets.dart';

import 'main.dart' as app_main;
import 'session.dart';

void main() {
  runApp(const ClearTokenStore());
}

class ClearTokenStore extends StatefulWidget {
  const ClearTokenStore({super.key});

  @override
  State<ClearTokenStore> createState() => _ClearTokenStoreState();
}

class _ClearTokenStoreState extends State<ClearTokenStore> {
  bool cleared = false;

  @override
  void initState() {
    super.initState();
    MlsTokenStore.clear().then((_) => setState(() => cleared = true));
  }

  @override
  Widget build(BuildContext context) {
    return const app_main.MlsApp();
  }
}
