import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppConfig _appConfig = AppConfig();
  final TextEditingController _baseUrlController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTesting = false;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final baseUrl = await _appConfig.getBaseUrl();
    if (!mounted) {
      return;
    }
    setState(() {
      _baseUrlController.text = baseUrl;
      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    final value = _baseUrlController.text.trim();
    if (value.isEmpty) {
      setState(() {
        _errorMessage = 'Ingresa una URL válida.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      await _appConfig.setBaseUrl(value);
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Configuración guardada.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _testConnection() async {
    final value = _baseUrlController.text.trim();
    if (value.isEmpty) {
      setState(() {
        _errorMessage = 'Ingresa una URL válida.';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final client = ApiClient(baseUrl: value);
      final result = await client.ping();
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = result['message']?.toString() ?? 'Conexión correcta.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Backend',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajusta la dirección del servidor según el dispositivo donde ejecutes la app.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL del backend',
                    hintText: 'http://192.168.1.50:8000',
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _saveConfig,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Guardar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.2),
                            )
                          : const Icon(Icons.wifi_tethering_outlined),
                      label: const Text('Probar conexión'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_statusMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(_statusMessage!),
                  ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFF9F1239)),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
