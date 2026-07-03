import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/department.dart';
import '../models/visitor_payload.dart';

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Department>> fetchDepartments() async {
    final response = await _client.get(_uri('/api/departamentos/'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('No se pudieron cargar los departamentos');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List ? decoded : (decoded['results'] as List<dynamic>? ?? <dynamic>[]);

    return items.map((dynamic item) {
      return Department(
        code: item['codigo']?.toString() ?? '',
        displayName: _buildDepartmentLabel(item),
      );
    }).where((department) => department.code.isNotEmpty).toList();
  }

  Future<void> createVisitor(VisitorPayload payload) async {
    final response = await _client.post(
      _uri('/api/visitantes/'),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'No se pudo registrar el visitante';
      try {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          message = decoded.values.map((value) => value.toString()).join(' ');
        }
      } catch (_) {
        // Keep default message.
      }
      throw ApiException(message);
    }
  }

  Future<List<Map<String, dynamic>>> fetchTodayVisitors() async {
    final response = await _client.get(_uri('/api/visitantes/hoy/'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('No se pudieron cargar los visitantes de hoy');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List ? decoded : (decoded['results'] as List<dynamic>? ?? <dynamic>[]);

    return items
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  String _buildDepartmentLabel(Map<String, dynamic> item) {
    final torre = item['torre']?.toString() ?? '';
    final piso = item['piso']?.toString() ?? '';
    final numero = item['numero']?.toString() ?? '';
    final codigo = item['codigo']?.toString() ?? '';
    final label = [
      if (torre.isNotEmpty) 'Torre $torre',
      if (piso.isNotEmpty) 'Piso $piso',
      if (numero.isNotEmpty) 'Dpto. $numero',
    ].join(' · ');
    return label.isNotEmpty ? '$label ($codigo)' : codigo;
  }
}

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
