class Persona {
  int id;
  String nombre;
  String apellido1;
  String apellido2;
  bool esHombre;
  String fechaNacimiento;
  String lugarNacimiento;
  bool tieneDocNacimiento;
  bool fallecido;
  String fechaFallecimiento;
  String lugarFallecimiento;
  bool tieneDocFallecimiento;
  bool tieneFoto;
  int padreId;
  int madreId;
  int familiaId;
  String observaciones;

  Persona({
    this.id = 0,
    this.nombre = '',
    this.apellido1 = '',
    this.apellido2 = '',
    this.esHombre = true,
    this.fechaNacimiento = '00000000',
    this.lugarNacimiento = '',
    this.tieneDocNacimiento = false,
    this.fallecido = false,
    this.fechaFallecimiento = '00000000',
    this.lugarFallecimiento = '',
    this.tieneDocFallecimiento = false,
    this.tieneFoto = false,
    this.padreId = 0,
    this.madreId = 0,
    this.familiaId = 0,
    this.observaciones = '',
  });

  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      id: map['ID'] ?? 0,
      nombre: map['Nombre'] ?? '',
      apellido1: map['Apellido1'] ?? '',
      apellido2: map['Apellido2'] ?? '',
      esHombre: (map['Varon'] == 1 || map['Varon'] == true),
      fechaNacimiento: map['FechaNacimiento'] ?? '00000000',
      lugarNacimiento: map['LugarNacimiento'] ?? '',
      tieneDocNacimiento: (map['TieneDocNacimiento'] == 1),
      fallecido: (map['Fallecido'] == 1),
      fechaFallecimiento: map['FechaFallecimiento'] ?? '00000000',
      lugarFallecimiento: map['LugarFallecimiento'] ?? '',
      tieneDocFallecimiento: (map['TieneDocFallecimiento'] == 1),
      tieneFoto: (map['TieneFoto'] == 1),
      padreId: map['PadreID'] ?? 0,
      madreId: map['MadreID'] ?? 0,
      familiaId: map['FamiliaID'] ?? 0,
      observaciones: map['Observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'Nombre': nombre,
      'Apellido1': apellido1,
      'Apellido2': apellido2,
      'Varon': esHombre ? 1 : 0,
      'FechaNacimiento': fechaNacimiento,
      'LugarNacimiento': lugarNacimiento,
      'TieneDocNacimiento': tieneDocNacimiento ? 1 : 0,
      'Fallecido': fallecido ? 1 : 0,
      'FechaFallecimiento': fechaFallecimiento,
      'LugarFallecimiento': lugarFallecimiento,
      'TieneDocFallecimiento': tieneDocFallecimiento ? 1 : 0,
      'TieneFoto': tieneFoto ? 1 : 0,
      'PadreID': padreId,
      'MadreID': madreId,
      'FamiliaID': familiaId,
      'Observaciones': observaciones,
    };
  }

  String get nombreCompleto {
    return '$nombre $apellido1 $apellido2'.trim();
  }
}
