class VisitorPayload {
  VisitorPayload({
    required this.firstName,
    required this.lastName,
    required this.documentNumber,
    required this.visitDate,
    required this.visitTime,
    required this.departmentCode,
    required this.acceptTerms,
    required this.acceptPhoto,
    this.reason,
    this.privacyNote,
    this.photoBase64,
  });

  final String firstName;
  final String lastName;
  final String documentNumber;
  final String visitDate;
  final String visitTime;
  final String departmentCode;
  final bool acceptTerms;
  final bool acceptPhoto;
  final String? reason;
  final String? privacyNote;
  final String? photoBase64;

  Map<String, dynamic> toJson() {
    return {
      'nombre': firstName,
      'apellido': lastName,
      'dni': documentNumber,
      'fecha_visita': visitDate,
      'hora_visita': visitTime,
      'depart_visita': departmentCode,
      'acepta_terminos': acceptTerms,
      'acepta_foto': acceptPhoto,
      if (reason != null && reason!.trim().isNotEmpty) 'motivo': reason!.trim(),
      if (privacyNote != null && privacyNote!.trim().isNotEmpty) 'observacion_privacidad': privacyNote!.trim(),
      if (photoBase64 != null && photoBase64!.trim().isNotEmpty) 'foto': photoBase64!.trim(),
    };
  }
}
