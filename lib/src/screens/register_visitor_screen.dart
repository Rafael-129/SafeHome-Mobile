import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/department.dart';
import '../models/visitor_payload.dart';
import '../services/api_client.dart';
import '../services/app_config.dart';
import '../widgets/photo_picker_tile.dart';

class RegisterVisitorScreen extends StatefulWidget {
  const RegisterVisitorScreen({super.key});

  @override
  State<RegisterVisitorScreen> createState() => _RegisterVisitorScreenState();
}

class _RegisterVisitorScreenState extends State<RegisterVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _documentController = TextEditingController();
  final _reasonController = TextEditingController();
  final _privacyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final AppConfig _appConfig = AppConfig();
  ApiClient? _apiClient;

  List<Department> _departments = <Department>[];
  Department? _selectedDepartment;
  bool _acceptTerms = false;
  bool _acceptPhoto = true;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _photoPath;
  String? _photoBase64;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _documentController.dispose();
    _reasonController.dispose();
    _privacyController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final client = _apiClient ??= ApiClient(baseUrl: await _appConfig.getBaseUrl());
      final departments = await client.fetchDepartments();
      if (!mounted) {
        return;
      }
      setState(() {
        _departments = departments;
        _selectedDepartment = departments.isNotEmpty ? departments.first : null;
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

  Future<void> _pickPhoto(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 75);
    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _photoPath = image.path;
      _photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedTime = picked;
    });
  }

  Future<void> _saveVisitor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDepartment == null) {
      setState(() {
        _errorMessage = 'Selecciona un departamento.';
      });
      return;
    }
    if (!_acceptTerms) {
      setState(() {
        _errorMessage = 'Debes aceptar los términos para registrar al visitante.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final payload = VisitorPayload(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      documentNumber: _documentController.text,
      visitDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      visitTime: _formatTimeForBackend(_selectedTime),
      departmentCode: _selectedDepartment!.code,
      acceptTerms: _acceptTerms,
      acceptPhoto: _acceptPhoto,
      reason: _reasonController.text,
      privacyNote: _privacyController.text,
      photoBase64: _acceptPhoto ? _photoBase64 : null,
    );

    try {
      await _apiClient.createVisitor(payload);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitante registrado correctamente')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _firstNameController.clear();
        _lastNameController.clear();
        _documentController.clear();
        _reasonController.clear();
        _privacyController.clear();
        _photoPath = null;
        _photoBase64 = null;
        _acceptTerms = false;
        _acceptPhoto = true;
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
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
          _isSaving = false;
        });
      }
    }
  }

  String _formatTimeForBackend(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar visitante'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null) ...[
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
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'Datos del visitante',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: 320,
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(labelText: 'Nombres'),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa los nombres' : null,
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(labelText: 'Apellidos'),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa los apellidos' : null,
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: TextFormField(
                                controller: _documentController,
                                decoration: const InputDecoration(labelText: 'DNI'),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa el DNI' : null,
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: TextFormField(
                                controller: _reasonController,
                                decoration: const InputDecoration(labelText: 'Motivo de visita'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: 320,
                              child: DropdownButtonFormField<Department>(
                                value: _selectedDepartment,
                                decoration: const InputDecoration(labelText: 'Departamento'),
                                items: _departments
                                    .map(
                                      (department) => DropdownMenuItem<Department>(
                                        value: department,
                                        child: Text(department.displayName),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDepartment = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: InkWell(
                                onTap: _selectDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Fecha de visita'),
                                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: InkWell(
                                onTap: _selectTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Hora de visita'),
                                  child: Text(_selectedTime.format(context)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SwitchListTile(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value;
                            });
                          },
                          title: const Text('Acepta términos y condiciones'),
                          subtitle: const Text('Obligatorio para registrar al visitante.'),
                        ),
                        SwitchListTile(
                          value: _acceptPhoto,
                          onChanged: (value) {
                            setState(() {
                              _acceptPhoto = value;
                            });
                          },
                          title: const Text('Autoriza captura de foto'),
                          subtitle: const Text('Si no acepta, la imagen no se enviará.'),
                        ),
                        const SizedBox(height: 16),
                        PhotoPickerTile(
                          label: 'Imagen del visitante',
                          subtitle: 'Selecciona una foto desde la cámara o la galería.',
                          imagePath: _photoPath,
                          onPickFromCamera: () => _pickPhoto(ImageSource.camera),
                          onPickFromGallery: () => _pickPhoto(ImageSource.gallery),
                          onClear: () {
                            setState(() {
                              _photoPath = null;
                              _photoBase64 = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _privacyController,
                          decoration: const InputDecoration(labelText: 'Observación de privacidad'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _saveVisitor,
                          icon: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.4),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(_isSaving ? 'Guardando...' : 'Registrar visitante'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'La app envía la foto como base64 dentro del JSON, alineada con el backend actual.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
