import 'package:flutter/material.dart';

import '../services/session_store.dart';
import 'basic_consultation_screen.dart';
import 'register_visitor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionStore _sessionStore = SessionStore();
  String? _username;

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
            title: 'Consulta básica',
            description: 'Ver visitantes del día y refrescar datos desde el backend.',
            onTap: _openBasicConsultation,
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
