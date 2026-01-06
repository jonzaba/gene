import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../database/database_helper.dart';
import 'event_section.dart';
import '../utils/date_helper.dart';

class EditPanel extends StatefulWidget {
  final Persona? currentPerson;
  final Function(Persona)? onSave;
  final VoidCallback? onDelete;
  final VoidCallback? onSearch;

  const EditPanel({
    super.key,
    this.currentPerson,
    this.onSave,
    this.onDelete,
    this.onSearch,
  });

  @override
  State<EditPanel> createState() => _EditPanelState();
}

class _EditPanelState extends State<EditPanel> {
  // Controllers
  final _idController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellido1Controller = TextEditingController();
  final _apellido2Controller = TextEditingController();
  final _obsController = TextEditingController();

  // State for gender, locations and dates
  bool _esHombre = true;
  bool _fallecido = false;
  bool _tieneDocNac = false;
  bool _tieneDocFall = false;
  String _nacFecha = '00000000';
  String _nacLugar = '';
  String _fallFecha = '00000000';
  String _fallLugar = '';
  List<String> _locations = [];

  // Track which fields have been modified
  final Set<String> _modifiedFields = {};
  // Store original values to detect changes
  String _originalNombre = '';
  String _originalApellido1 = '';
  String _originalApellido2 = '';
  String _originalNacFecha = '';
  String _originalNacLugar = '';
  String _originalFallFecha = '';
  String _originalFallLugar = '';
  String _originalObs = '';
  bool _originalEsHombre = true;
  bool _originalFallecido = false;
  bool _originalTieneDocNac = false;
  bool _originalTieneDocFall = false;
  // Flag to prevent listeners from triggering setState during initial load
  bool _isInternalLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPersonData();
    _loadLocations();

    // Add listeners to track changes
    _nombreController.addListener(_onNombreChanged);
    _apellido1Controller.addListener(_onApellido1Changed);
    _apellido2Controller.addListener(_onApellido2Changed);
    _obsController.addListener(_onObsChanged);
  }

  Future<void> _loadLocations() async {
    final locs = await DatabaseHelper.instance.getUniqueLocations();
    if (mounted) {
      setState(() {
        _locations = locs;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.removeListener(_onNombreChanged);
    _apellido1Controller.removeListener(_onApellido1Changed);
    _apellido2Controller.removeListener(_onApellido2Changed);
    _obsController.removeListener(_onObsChanged);

    _idController.dispose();
    _nombreController.dispose();
    _apellido1Controller.dispose();
    _apellido2Controller.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _onNombreChanged() {
    if (_isInternalLoading) return;
    setState(() {
      if (_nombreController.text != _originalNombre) {
        _modifiedFields.add('nombre');
      } else {
        _modifiedFields.remove('nombre');
      }
    });
  }

  void _onApellido1Changed() {
    if (_isInternalLoading) return;
    setState(() {
      if (_apellido1Controller.text != _originalApellido1) {
        _modifiedFields.add('apellido1');
      } else {
        _modifiedFields.remove('apellido1');
      }
    });
  }

  void _onApellido2Changed() {
    if (_isInternalLoading) return;
    setState(() {
      if (_apellido2Controller.text != _originalApellido2) {
        _modifiedFields.add('apellido2');
      } else {
        _modifiedFields.remove('apellido2');
      }
    });
  }

  void _onNacFechaChanged(String value) {
    if (_isInternalLoading) return;
    setState(() {
      _nacFecha = value;
      if (_nacFecha != _originalNacFecha) {
        _modifiedFields.add('nacFecha');
      } else {
        _modifiedFields.remove('nacFecha');
      }
    });
  }

  void _onNacLugarChanged(String value) {
    if (_isInternalLoading) return;
    setState(() {
      _nacLugar = value;
      if (_nacLugar != _originalNacLugar) {
        _modifiedFields.add('nacLugar');
      } else {
        _modifiedFields.remove('nacLugar');
      }
    });
  }

  void _onFallFechaChanged(String value) {
    if (_isInternalLoading) return;
    setState(() {
      _fallFecha = value;
      if (_fallFecha != _originalFallFecha) {
        _modifiedFields.add('fallFecha');
      } else {
        _modifiedFields.remove('fallFecha');
      }
    });
  }

  void _onFallLugarChanged(String value) {
    if (_isInternalLoading) return;
    setState(() {
      _fallLugar = value;
      if (_fallLugar != _originalFallLugar) {
        _modifiedFields.add('fallLugar');
      } else {
        _modifiedFields.remove('fallLugar');
      }
    });
  }

  void _onObsChanged() {
    if (_isInternalLoading) return;
    setState(() {
      if (_obsController.text != _originalObs) {
        _modifiedFields.add('observaciones');
      } else {
        _modifiedFields.remove('observaciones');
      }
    });
  }

  void _onGenderChanged(bool isMale) {
    setState(() {
      _esHombre = isMale;
      if (_esHombre != _originalEsHombre) {
        _modifiedFields.add('esHombre');
      } else {
        _modifiedFields.remove('esHombre');
      }
    });
  }

  void _onCheckboxChanged(String fieldName, bool value) {
    setState(() {
      if (fieldName == 'fallecido') {
        _fallecido = value;
        if (_fallecido != _originalFallecido) {
          _modifiedFields.add(fieldName);
        } else {
          _modifiedFields.remove(fieldName);
        }
      } else if (fieldName == 'tieneDocNac') {
        _tieneDocNac = value;
        if (_tieneDocNac != _originalTieneDocNac) {
          _modifiedFields.add(fieldName);
        } else {
          _modifiedFields.remove(fieldName);
        }
      } else if (fieldName == 'tieneDocFall') {
        _tieneDocFall = value;
        if (_tieneDocFall != _originalTieneDocFall) {
          _modifiedFields.add(fieldName);
        } else {
          _modifiedFields.remove(fieldName);
        }
      }
    });
  }

  @override
  void didUpdateWidget(EditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPerson?.id != oldWidget.currentPerson?.id) {
      _checkChangesAndLoad(oldWidget.currentPerson);
    } else if (widget.currentPerson != oldWidget.currentPerson) {
      // Same ID but different reference (e.g. after save) - reload fields
      _loadPersonData();
    }
  }

  void _checkChangesAndLoad(Persona? oldPerson) {
    if (_modifiedFields.isNotEmpty) {
      Future.microtask(() => _showUnsavedChangesDialog(oldPerson));
    } else {
      _loadPersonData();
    }
  }

  Future<void> _showUnsavedChangesDialog(Persona? oldPerson) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Modificaciones realizadas'),
        content: const Text('¿Quieres perder los cambios?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Sí'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Grabar cambios'),
          ),
        ],
      ),
    );

    if (result == 'discard') {
      _loadPersonData(); // Load new person, discarding changes
    } else if (result == 'save') {
      await _handleSave(personOverride: oldPerson);
      _loadPersonData(); // Load new person after save
    }
    // If 'cancel' or null, do nothing - stay with current text in fields
    // and don't load the new person's data yet.
  }

  void _loadPersonData() {
    if (widget.currentPerson != null) {
      _isInternalLoading = true;
      // Store original values
      _originalNombre = widget.currentPerson!.nombre;
      _originalApellido1 = widget.currentPerson!.apellido1;
      _originalApellido2 = widget.currentPerson!.apellido2;
      _originalNacFecha = widget.currentPerson!.fechaNacimiento;
      _originalNacLugar = widget.currentPerson!.lugarNacimiento;
      _originalFallFecha = widget.currentPerson!.fechaFallecimiento;
      _originalFallLugar = widget.currentPerson!.lugarFallecimiento;
      _originalObs = widget.currentPerson!.observaciones;
      _originalEsHombre = widget.currentPerson!.esHombre;
      _originalFallecido = widget.currentPerson!.fallecido;
      _originalTieneDocNac = widget.currentPerson!.tieneDocNacimiento;
      _originalTieneDocFall = widget.currentPerson!.tieneDocFallecimiento;

      // Load into controllers
      _idController.text = widget.currentPerson!.id.toString();
      _nombreController.text = _originalNombre;
      _apellido1Controller.text = _originalApellido1;
      _apellido2Controller.text = _originalApellido2;
      _nacFecha = _originalNacFecha;
      _nacLugar = _originalNacLugar;
      _fallFecha = _originalFallFecha;
      _fallLugar = _originalFallLugar;
      _obsController.text = _originalObs;
      _esHombre = _originalEsHombre;
      _fallecido = _originalFallecido;
      _tieneDocNac = _originalTieneDocNac;
      _tieneDocFall = _originalTieneDocFall;

      // Clear modified fields tracking
      _modifiedFields.clear();
      _isInternalLoading = false;
    } else {
      _clearFields();
    }
  }

  void _clearFields() {
    _idController.clear();
    _nombreController.clear();
    _apellido1Controller.clear();
    _apellido2Controller.clear();
    _nacFecha = '00000000';
    _nacLugar = '';
    _fallFecha = '00000000';
    _fallLugar = '';
    _obsController.clear();
    _esHombre = true;
    _fallecido = false;
    _tieneDocNac = false;
    _tieneDocFall = false;
  }

  bool _validateData() {
    // Check nombre is not empty
    if (_nombreController.text.trim().isEmpty) {
      _showError('Debe ingresar el nombre de la persona');
      return false;
    }
    // Check apellido1 is not empty
    if (_apellido1Controller.text.trim().isEmpty) {
      _showError('Debe ingresar el apellido1 de la persona');
      return false;
    }
    // Check length limits (50 chars for nombre, apellido1, apellido2)
    if (_nombreController.text.length > 50) {
      _showError('El nombre debe tener menos de 50 caracteres');
      return false;
    }
    if (_apellido1Controller.text.length > 50) {
      _showError('El apellido1 debe tener menos de 50 caracteres');
      return false;
    }
    if (_apellido2Controller.text.length > 50) {
      _showError('El apellido2 debe tener menos de 50 caracteres');
      return false;
    }

    // Date validation
    if (!DateHelper.isValidDate(_nacFecha)) {
      _showError('La fecha de nacimiento no es válida');
      return false;
    }
    if (!DateHelper.isValidDate(_fallFecha)) {
      _showError('La fecha de fallecimiento no es válida');
      return false;
    }

    return true;
  }

  Future<void> _handleSave({Persona? personOverride}) async {
    if (!_validateData()) return;

    final personToSave = personOverride ?? widget.currentPerson;
    if (personToSave == null) return;

    // Create updated person object
    final updatedPerson = Persona(
      id: personToSave.id,
      nombre: _nombreController.text.trim(),
      apellido1: _apellido1Controller.text.trim(),
      apellido2: _apellido2Controller.text.trim(),
      esHombre: _esHombre,
      fechaNacimiento: _nacFecha,
      lugarNacimiento: _nacLugar,
      fallecido: _fallecido,
      fechaFallecimiento: _fallFecha,
      lugarFallecimiento: _fallLugar,
      tieneDocNacimiento: _tieneDocNac,
      tieneDocFallecimiento: _tieneDocFall,
      observaciones: _obsController.text.trim(),
      // Preserve existing values for other fields
      padreId: personToSave.padreId,
      madreId: personToSave.madreId,
      familiaId: personToSave.familiaId,
      tieneFoto: personToSave.tieneFoto,
    );

    try {
      // Save to database
      final rowsAffected = await DatabaseHelper.instance.updatePersona(
        updatedPerson,
      );

      if (rowsAffected > 0) {
        _showSuccess('Registro guardado');
        // Update originals to match saved values
        _originalNombre = _nombreController.text.trim();
        _originalApellido1 = _apellido1Controller.text.trim();
        _originalApellido2 = _apellido2Controller.text.trim();
        _originalNacFecha = _nacFecha;
        _originalNacLugar = _nacLugar;
        _originalFallFecha = _fallFecha;
        _originalFallLugar = _fallLugar;
        _originalObs = _obsController.text.trim();
        _originalEsHombre = _esHombre;
        _originalFallecido = _fallecido;
        _originalTieneDocNac = _tieneDocNac;
        _originalTieneDocFall = _tieneDocFall;
        _modifiedFields.clear(); // Clear change tracking
        _loadLocations(); // Refresh autocomplete list

        // Notify parent to reload/refresh
        if (widget.onSave != null) {
          widget.onSave!(updatedPerson);
        }
      } else {
        _showError('Error al guardar el registro');
      }
    } catch (e) {
      _showError('Error al guardar: $e');
    }
  }

  void _handleCancel() {
    // Reload original data, discarding changes
    _loadPersonData();
    _showSuccess('Cambios descartados');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Increased to fit 4 buttons (approx 60px each + spacing)
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(left: BorderSide(color: Colors.grey)),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Top Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.save, 'Grabar', _handleSave),
              _buildActionButton(Icons.cancel, 'Cancelar', _handleCancel),
              _buildActionButton(Icons.delete, 'Borrar', widget.onDelete),
              _buildActionButton(Icons.search, 'Buscar', widget.onSearch),
            ],
          ),
          const Divider(),
          // Relatives Actions
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRelButton('Padre', isMale: true),
                  _buildRelButton('Madre', isMale: false),
                  _buildRelButton('Hijo', isMale: true),
                  _buildRelButton('Hija', isMale: false),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRelButton('Hermano', isMale: true),
                  _buildRelButton('Hermana', isMale: false),
                  _buildRelButton('Marido', isMale: true),
                  _buildRelButton('Mujer', isMale: false),
                ],
              ),
            ],
          ),
          const Divider(),
          // Form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            'ID',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 50,
                          child: _buildTextField(
                            '',
                            controller: _idController,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _buildGenderDropdown()),
                      ],
                    ),
                  ),
                  _buildTextField(
                    'Nombre',
                    controller: _nombreController,
                    fieldName: 'nombre',
                    horizontal: true,
                  ),
                  _buildTextField(
                    'Apellido1',
                    controller: _apellido1Controller,
                    fieldName: 'apellido1',
                    horizontal: true,
                  ),
                  _buildTextField(
                    'Apellido2',
                    controller: _apellido2Controller,
                    fieldName: 'apellido2',
                    horizontal: true,
                  ),
                  const SizedBox(height: 4),
                  EventSection(
                    title: 'Nacimiento',
                    date: _nacFecha,
                    onDateChanged: _onNacFechaChanged,
                    location: _nacLugar,
                    onLocationChanged: _onNacLugarChanged,
                    locations: _locations,
                    hasDoc: _tieneDocNac,
                    onDocChanged: (val) =>
                        _onCheckboxChanged('tieneDocNac', val),
                    docStatus: 'Imagen',
                    modifiedFields: _modifiedFields,
                    prefix: 'nac',
                  ),
                  const SizedBox(height: 4),
                  EventSection(
                    title: 'Fallecimiento',
                    isActive: _fallecido,
                    onActiveChanged: (val) =>
                        _onCheckboxChanged('fallecido', val),
                    date: _fallFecha,
                    onDateChanged: _onFallFechaChanged,
                    location: _fallLugar,
                    onLocationChanged: _onFallLugarChanged,
                    locations: _locations,
                    hasDoc: _tieneDocFall,
                    onDocChanged: (val) =>
                        _onCheckboxChanged('tieneDocFall', val),
                    docStatus: 'Vacío',
                    modifiedFields: _modifiedFields,
                    prefix: 'fall',
                  ),
                  const SizedBox(height: 4),
                  _buildTextField(
                    'Observaciones',
                    controller: _obsController,
                    fieldName: 'observaciones',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Parejas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(child: Text('Lista de parejas')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback? onPressed,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.blue),
          onPressed: onPressed,
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildRelButton(String label, {required bool isMale}) {
    return SizedBox(
      width: 60,
      height: 42,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 20,
              color: isMale ? Colors.blue : Colors.red,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    TextEditingController? controller,
    String? fieldName, // Add fieldName to track modifications
    bool readOnly = false,
    int maxLines = 1,
    bool horizontal = false,
  }) {
    final isModified = fieldName != null && _modifiedFields.contains(fieldName);

    Widget textField = SizedBox(
      height: maxLines == 1 ? 30 : null,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: isModified
              ? Colors.green[100]
              : (readOnly ? Colors.grey[300] : Colors.white),
          // Explicitly set focus and hover colors to prevent gray overlay
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
      ),
    );

    if (horizontal) {
      if (label.isEmpty) return textField;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: textField),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        textField,
      ],
    );
  }

  Widget _buildGenderDropdown() {
    final isModified = _modifiedFields.contains('esHombre');
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isModified ? Colors.green[100] : Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool>(
          value: _esHombre,
          isExpanded: true,
          items: const [
            DropdownMenuItem(
              value: true,
              child: Text('Hombre', style: TextStyle(fontSize: 12)),
            ),
            DropdownMenuItem(
              value: false,
              child: Text('Mujer', style: TextStyle(fontSize: 12)),
            ),
          ],
          onChanged: (val) {
            if (val != null) _onGenderChanged(val);
          },
        ),
      ),
    );
  }
}
