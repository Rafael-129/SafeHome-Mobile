import 'package:flutter/material.dart';

import 'services/app_config.dart';
import 'screens/settings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_store.dart';
import 'theme/app_theme.dart';

class SafeHomeMobileApp extends StatefulWidget {
  const SafeHomeMobileApp({super.key});

  @override
  State<SafeHomeMobileApp> createState() => _SafeHomeMobileAppState();
}

class _SafeHomeMobileAppState extends State<SafeHomeMobileApp> {
  final SessionStore _sessionStore = SessionStore();
  final AppConfig _appConfig = AppConfig();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _baseUrl;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authenticated = await _sessionStore.isAuthenticated();
    final baseUrl = await _appConfig.getBaseUrl();
    if (!mounted) {
      return;
    }
    setState(() {
      _isAuthenticated = authenticated;
      _baseUrl = baseUrl;
      _isLoading = false;
    });
  }

  Future<void> _handleLogin(String username, String password) async {
    final success = await _sessionStore.login(username: username, password: password);
    if (!mounted) {
      return;
    }
    setState(() {
      _isAuthenticated = success;
    });
  }

  Future<void> _handleLogout() async {
    await _sessionStore.logout();
    if (!mounted) {
      return;
    }
    setState(() {
      _isAuthenticated = false;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onSaved: _refreshConfig,
        ),
      ),
    );
  }

  Future<void> _refreshConfig() async {
    final baseUrl = await _appConfig.getBaseUrl();
    if (!mounted) {
      return;
    }
    setState(() {
      _baseUrl = baseUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeHome Mobile',
      theme: buildAppTheme(),
      builder: (context, child) {
        return Scaffold(
          body: child,
          floatingActionButton: _isLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Config'),
                ),
        );
      },
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isAuthenticated
              ? HomeScreen(
                  onLogout: _handleLogout,
                  baseUrl: _baseUrl,
                )
              : LoginScreen(onLogin: _handleLogin),
    );
  }
}
