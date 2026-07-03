import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/app_config.dart';

class BasicConsultationScreen extends StatefulWidget {
  const BasicConsultationScreen({super.key});

  @override
  State<BasicConsultationScreen> createState() => _BasicConsultationScreenState();
}

class _BasicConsultationScreenState extends State<BasicConsultationScreen> {
  final AppConfig _appConfig = AppConfig();
  ApiClient? _apiClient;
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _visitors = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadTodayVisitors();
  }

  Future<void> _loadTodayVisitors() async {
    try {
      final client = _apiClient ??= ApiClient(baseUrl: await _appConfig.getBaseUrl());
      final visitors = await client.fetchTodayVisitors();
      if (!mounted) {
        return;
      }
      setState(() {
        _visitors = visitors;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _finalizeVisitor(int visitorId) async {
    setState(() {
      _isActionLoading = true;
      _errorMessage = null;
    });

    try {
      final client = _apiClient ??= ApiClient(baseUrl: await _appConfig.getBaseUrl());
      await client.finalizeVisitor(visitorId);
      await _loadTodayVisitors();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita finalizada')),
      );
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
          _isActionLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta básica'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodayVisitors,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Visitantes de hoy',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Listado básico consumido desde el backend.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
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
                    )
                  else if (_visitors.isEmpty)
                    const _EmptyState()
                  else
                    ..._visitors.map(
                      (visitor) => _VisitorTile(
                        visitor,
                        onFinalize: _isActionLoading
                            ? null
                            : () {
                                final id = visitor['idvisitante'];
                                if (id is int) {
                                  _finalizeVisitor(id);
                                } else if (id is String) {
                                  final parsed = int.tryParse(id);
                                  if (parsed != null) {
                                    _finalizeVisitor(parsed);
                                  }
                                }
                              },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _VisitorTile extends StatelessWidget {
  const _VisitorTile(this.data, {this.onFinalize});

  final Map<String, dynamic> data;
  final VoidCallback? onFinalize;

  @override
  Widget build(BuildContext context) {
    final nombre = '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim();
    final dni = data['dni']?.toString() ?? 'Sin DNI';
    final motivo = data['motivo']?.toString() ?? 'Sin motivo';
    final departamento = data['iddepartamento']?.toString() ?? data['depart_visita']?.toString() ?? 'Sin departamento';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0F2FE),
          child: Icon(Icons.badge_outlined, color: Color(0xFF1F6FEB)),
        ),
        title: Text(nombre.isEmpty ? 'Visitante' : nombre),
        subtitle: Text('$dni · $motivo · Dep: $departamento'),
        trailing: onFinalize == null
            ? null
            : TextButton(
                onPressed: onFinalize,
                child: const Text('Finalizar'),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy_outlined, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            'No hay visitantes cargados hoy.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
