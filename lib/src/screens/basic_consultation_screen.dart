import 'package:flutter/material.dart';

import '../services/api_client.dart';

class BasicConsultationScreen extends StatefulWidget {
  const BasicConsultationScreen({super.key});

  @override
  State<BasicConsultationScreen> createState() => _BasicConsultationScreenState();
}

class _BasicConsultationScreenState extends State<BasicConsultationScreen> {
  final ApiClient _apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8000');
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _visitors = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadTodayVisitors();
  }

  Future<void> _loadTodayVisitors() async {
    try {
      final visitors = await _apiClient.fetchTodayVisitors();
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
                    ..._visitors.map(_VisitorTile.new),
                ],
              ),
            ),
    );
  }
}

class _VisitorTile extends StatelessWidget {
  const _VisitorTile(this.data);

  final Map<String, dynamic> data;

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
