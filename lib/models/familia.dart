class Familia {
  int id;
  int esposoId;
  int esposaId;
  String fechaBoda;
  String lugarBoda;
  bool tieneDocBoda;
  bool separados;
  String fechaSeparacion;
  String lugarSeparacion;
  bool tieneDocSeparacion;

  Familia({
    this.id = 0,
    this.esposoId = 0,
    this.esposaId = 0,
    this.fechaBoda = '00000000',
    this.lugarBoda = '',
    this.tieneDocBoda = false,
    this.separados = false,
    this.fechaSeparacion = '00000000',
    this.lugarSeparacion = '',
    this.tieneDocSeparacion = false,
  });

  factory Familia.fromMap(Map<String, dynamic> map) {
    return Familia(
      id: map['ID'] ?? 0,
      esposoId: map['EsposoID'] ?? 0,
      esposaId: map['EsposaID'] ?? 0,
      fechaBoda: map['FechaBoda'] ?? '00000000',
      lugarBoda: map['LugarBoda'] ?? '',
      tieneDocBoda: (map['TieneDocBoda'] == 1),
      separados: (map['Separados'] == 1),
      fechaSeparacion: map['FechaSeparacion'] ?? '00000000',
      lugarSeparacion: map['LugarSeparacion'] ?? '',
      tieneDocSeparacion: (map['TieneDocSeparacion'] == 1),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'EsposoID': esposoId,
      'EsposaID': esposaId,
      'FechaBoda': fechaBoda,
      'LugarBoda': lugarBoda,
      'TieneDocBoda': tieneDocBoda ? 1 : 0,
      'Separados': separados ? 1 : 0,
      'FechaSeparacion': fechaSeparacion,
      'LugarSeparacion': lugarSeparacion,
      'TieneDocSeparacion': tieneDocSeparacion ? 1 : 0,
    };
  }
}
