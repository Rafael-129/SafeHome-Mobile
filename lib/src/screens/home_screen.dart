import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/session_store.dart';
import 'basic_consultation_screen.dart';
import 'departments_screen.dart';
import 'register_visitor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onLogout, this.baseUrl});

  final Future<void> Function() onLogout;
  final String? baseUrl;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionStore _sessionStore = SessionStore();
  String? _username;
  bool _isCheckingBackend = false;
  bool? _backendOnline;
  String? _backendMessage;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await _sessionStore.getUsername();
    if (!mounted) {
      return;
    }
    setState(() {
      _username = username;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_backendOnline == null && !_isCheckingBackend) {
      _checkBackend();
    }
  }

  Future<void> _checkBackend() async {
    final baseUrl = widget.baseUrl;
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return;
    }

    setState(() {
      _isCheckingBackend = true;
      _backendMessage = null;
    });

    try {
      final client = ApiClient(baseUrl: baseUrl);
      final response = await client.ping();
      if (!mounted) {
        return;
      }
      setState(() {
        _backendOnline = true;
        _backendMessage = response['message']?.toString() ?? 'Conectado';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _backendOnline = false;
        _backendMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingBackend = false;
        });
      }
    }
  }

  Future<void> _openRegisterVisitor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterVisitorScreen(),
      ),
    );
  }

  Future<void> _openBasicConsultation() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BasicConsultationScreen(),
      ),
    );
  }

  Future<void> _openDepartments() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DepartmentsScreen(),
      ),
    );
  }

  Future<void> _logout() async {
    await widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeHome Mobile'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Hola${_username != null ? ', $_username' : ''}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí registras visitantes desde el celular y consultas lo básico.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF64748B),
                ),
          ),
          const SizedBox(height: 16),
          _BackendStatusCard(
            baseUrl: widget.baseUrl,
            isLoading: _isCheckingBackend,
            isOnline: _backendOnline,
            message: _backendMessage,
            onRetry: _checkBackend,
          ),
          const SizedBox(height: 24),
          _ActionCard(
            icon: Icons.person_add_alt_1,
            title: 'Registrar visitante',
            description: 'Completa los datos del visitante, selecciona el departamento y adjunta una imagen.',
            onTap: _openRegisterVisitor,
          ),
          const SizedBox(height: 16),
          _ActionCard(
            icon: Icons.apartment_outlined,
            title: 'Departamentos',
            description: 'Ver los departamentos y el perfil actual de la aplicación.',
            onTap: _openDepartments,
          ),
          const SizedBox(height: 16),
          _ActionCard(
            icon: Icons.today_outlined,
            title: 'Consulta básica',
            description: 'Ver visitantes del día y refrescar datos desde el backend.',
            onTap: _openBasicConsultation,
          ),
        ],
      ),
    );
  }
}

class _BackendStatusCard extends StatelessWidget {
  const _BackendStatusCard({
    required this.baseUrl,
    required this.isLoading,
    required this.isOnline,
    required this.message,
    required this.onRetry,
  });

  final String? baseUrl;
  final bool isLoading;
  final bool? isOnline;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final color = isOnline == true
        ? const Color(0xFFDCFCE7)
        : isOnline == false
            ? const Color(0xFFFFE4E6)
            : const Color(0xFFEFF6FF);
    final icon = isOnline == true
        ? Icons.cloud_done_outlined
        : isOnline == false
            ? Icons.cloud_off_outlined
            : Icons.cloud_outlined;
    final statusText = isLoading
        ? 'Verificando backend...'
        : isOnline == true
            ? 'Backend activo'
            : isOnline == false
                ? 'Backend no disponible'
                : 'Backend sin verificar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: const Color(0xFF1F6FEB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  baseUrl != null ? 'Servidor: $baseUrl' : 'Sin servidor configurado',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF475569),
                        ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isDisabled = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: isDisabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFF1F6FEB)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
