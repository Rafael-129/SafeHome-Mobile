import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/app_config.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  final AppConfig _appConfig = AppConfig();
  ApiClient? _apiClient;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _profile = <String, dynamic>{};
  List<Map<String, dynamic>> _departments = <Map<String, dynamic>>[];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final client = _apiClient ??= ApiClient(baseUrl: await _appConfig.getBaseUrl());
      final profile = await client.fetchAppProfile();
      final departments = await client.fetchDepartments();
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
        _departments = departments
            .map(
              (department) => <String, dynamic>{
                'codigo': department.code,
                'displayName': department.displayName,
              },
            )
            .toList();
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
    final nombreAplicacion = _profile['nombre_aplicacion']?.toString() ?? 'SafeHome';
    final descripcion = _profile['descripcion']?.toString() ?? 'Sistema de control de acceso';
    final version = _profile['version']?.toString() ?? '1.0.0';
    final permitirSinFoto = _profile['permitir_registro_sin_foto'] == true;
    final fotoRequerida = _profile['politica_foto_requerida'] == true;
    final filteredDepartments = _departments.where((department) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      final displayName = department['displayName']?.toString().toLowerCase() ?? '';
      final codigo = department['codigo']?.toString().toLowerCase() ?? '';
      return displayName.contains(query) || codigo.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    nombreAplicacion,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descripcion,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar departamento',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                });
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoChip(label: 'Versión', value: version),
                      _InfoChip(label: 'Sin foto', value: permitirSinFoto ? 'Sí' : 'No'),
                      _InfoChip(label: 'Foto requerida', value: fotoRequerida ? 'Sí' : 'No'),
                    ],
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
                  else if (filteredDepartments.isEmpty)
                    const _EmptyState()
                  else
                    ...filteredDepartments.map(
                      (department) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE0F2FE),
                            child: Icon(Icons.apartment_outlined, color: Color(0xFF1F6FEB)),
                          ),
                          title: Text(department['displayName']?.toString() ?? 'Departamento'),
                          subtitle: Text('Código: ${department['codigo'] ?? ''}'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: const Color(0xFFEFF6FF),
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
          const Icon(Icons.apartment_outlined, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            'No hay departamentos disponibles.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
