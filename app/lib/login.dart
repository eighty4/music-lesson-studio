import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mls_api/sse_client.dart';
import 'package:mls_app/env.dart';
import 'package:mls_app/routing.dart';
import 'package:mls_app/session.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DeviceActivationScreen();
  }
}

class _DeviceActivationScreen extends StatefulWidget {
  const _DeviceActivationScreen();

  @override
  State<_DeviceActivationScreen> createState() =>
      _DeviceActivationScreenState();
}

class _DeviceActivationScreenState extends State<_DeviceActivationScreen> {
  StreamSubscription? subscription;
  bool successful = false;
  String? token;

  @override
  void initState() {
    super.initState();
    connectEventStream();
  }

  connectEventStream() async {
    final uri = MlsApiUri.fromPath('/api/device/activation');
    final eventStream = await EventStream(uri).connect();
    if (!mounted) {
      return;
    }
    subscription = eventStream.listen((message) {
      if (kDebugMode) {
        print('Login $message');
      }
      switch (message.event) {
        case 'initiated':
          setState(() => token = message.data);
          break;
        case 'activated':
          setState(() => successful = true);
          MlsTokenStore.store(message.data!);
          context.goToClassListScreen();
          break;
      }
    }, onDone: () {
      if (kDebugMode) {
        print('EventStream onDone');
      }
    }, onError: (Object e) {
      if (e is EventStreamTerminated) {
      } else {
        throw e;
      }
    }, cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return const Text('Device activation is preparing!');
    } else {
      return Text('Device activation $token!');
    }
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }
}
