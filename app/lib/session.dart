import 'package:flutter/widgets.dart';
import 'package:mls_api/http_client.dart';
import 'package:mls_app/routing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MlsTokenStore {
  static const _key = 'mls-token';
  static final _sharedPrefs = SharedPreferencesAsync();

  static Future<void> clear() => _sharedPrefs.remove(_key);

  static Future<String?> retrieve() => _sharedPrefs.getString(_key);

  static Future<void> store(String token) =>
      _sharedPrefs.setString(_key, token);
}

class SessionLookupResult {
  final String? authToken;
  final MlsTokenHttpClient? _httpClient;

  MlsTokenHttpClient get httpClient => _httpClient!;

  SessionLookupResult({this.authToken})
      : _httpClient = authToken == null ? null : MlsTokenHttpClient(authToken);
}

class SessionLookup extends StatefulWidget {
  static SessionLookupResult of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedSessionLookup>();
    assert(inherited != null);
    return inherited!.result;
  }

  final Widget child;

  const SessionLookup({super.key, required this.child});

  @override
  State<SessionLookup> createState() => _SessionLookupState();
}

class _SessionLookupState extends State<SessionLookup> {
  late final String? authToken;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    MlsTokenStore.retrieve().then((authToken) {
      if (mounted) {
        setState(() {
          loading = false;
          this.authToken = authToken;
        });
        if (context.currentRoutePath == MlsAppRoutes.splash &&
            authToken != null) {
          context.goToClassListScreen();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox.shrink();
    } else {
      return _InheritedSessionLookup(authToken: authToken, child: widget.child);
    }
  }
}

class _InheritedSessionLookup extends InheritedWidget {
  final SessionLookupResult result;

  _InheritedSessionLookup({required String? authToken, required super.child})
      : result = SessionLookupResult(authToken: authToken);

  @override
  bool updateShouldNotify(covariant _InheritedSessionLookup oldWidget) {
    return oldWidget.result.authToken != result.authToken;
  }
}
