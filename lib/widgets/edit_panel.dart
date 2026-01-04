import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../database/database_helper.dart';

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
  // ... add date controllers etc.

  @override
  void initState() {
    super.initState();
    _loadPersonData();
  }

  @override
  void didUpdateWidget(EditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPerson != oldWidget.currentPerson) {
      _loadPersonData();
    }
  }

  void _loadPersonData() {
    if (widget.currentPerson != null) {
      _idController.text = widget.currentPerson!.id.toString();
      _nombreController.text = widget.currentPerson!.nombre;
      _apellido1Controller.text = widget.currentPerson!.apellido1;
      _apellido2Controller.text = widget.currentPerson!.apellido2;
    } else {
      _clearFields();
    }
  }

  void _clearFields() {
    _idController.clear();
    _nombreController.clear();
    _apellido1Controller.clear();
    _apellido2Controller.clear();
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
    return true;
  }

  Future<void> _handleSave() async {
    if (!_validateData()) return;

    if (widget.currentPerson == null) return;

    // Create updated person object
    final updatedPerson = Persona(
      id: widget.currentPerson!.id,
      nombre: _nombreController.text.trim(),
      apellido1: _apellido1Controller.text.trim(),
      apellido2: _apellido2Controller.text.trim(),
      // Preserve existing values for other fields
      esHombre: widget.currentPerson!.esHombre,
      fechaNacimiento: widget.currentPerson!.fechaNacimiento,
      lugarNacimiento: widget.currentPerson!.lugarNacimiento,
      fechaFallecimiento: widget.currentPerson!.fechaFallecimiento,
      lugarFallecimiento: widget.currentPerson!.lugarFallecimiento,
      observaciones: widget.currentPerson!.observaciones,
      padreId: widget.currentPerson!.padreId,
      madreId: widget.currentPerson!.madreId,
      familiaId: widget.currentPerson!.familiaId,
      tieneFoto: widget.currentPerson!.tieneFoto,
      tieneDocNacimiento: widget.currentPerson!.tieneDocNacimiento,
      tieneDocFallecimiento: widget.currentPerson!.tieneDocFallecimiento,
      fallecido: widget.currentPerson!.fallecido,
    );

    try {
      // Save to database
      final rowsAffected = await DatabaseHelper.instance.updatePersona(
        updatedPerson,
      );

      if (rowsAffected > 0) {
        _showSuccess('Registro guardado');
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
              _buildActionButton(Icons.cancel, 'Cancelar', () {}),
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
                  _buildTextField(
                    'ID',
                    controller: _idController,
                    readOnly: true,
                  ), // Show ID
                  _buildTextField('Nombre', controller: _nombreController),
                  _buildTextField(
                    'Apellido1',
                    controller: _apellido1Controller,
                  ),
                  _buildTextField(
                    'Apellido2',
                    controller: _apellido2Controller,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nacimiento',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Fecha')),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_today, size: 16),
                    ],
                  ),
                  _buildTextField('Lugar'),
                  const SizedBox(height: 8),
                  const Text(
                    'Fallecimiento',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Fecha')),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_today, size: 16),
                    ],
                  ),
                  _buildTextField('Lugar'),
                  const SizedBox(height: 8),
                  _buildTextField('Observaciones', maxLines: 3),

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
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        SizedBox(
          height: maxLines == 1 ? 30 : null,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
