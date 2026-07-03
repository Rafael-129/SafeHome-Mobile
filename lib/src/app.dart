import 'package:flutter/material.dart';

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
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authenticated = await _sessionStore.isAuthenticated();
    if (!mounted) {
      return;
    }
    setState(() {
      _isAuthenticated = authenticated;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeHome Mobile',
      theme: buildAppTheme(),
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isAuthenticated
              ? HomeScreen(onLogout: _handleLogout)
              : LoginScreen(onLogin: _handleLogin),
    );
  }
}
