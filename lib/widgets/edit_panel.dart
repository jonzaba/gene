import 'package:flutter/material.dart';
import '../models/persona.dart';

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
      _nombreController.text = widget.currentPerson!.nombre;
      _apellido1Controller.text = widget.currentPerson!.apellido1;
      _apellido2Controller.text = widget.currentPerson!.apellido2;
    } else {
      _clearFields();
    }
  }

  void _clearFields() {
    _nombreController.clear();
    _apellido1Controller.clear();
    _apellido2Controller.clear();
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
              _buildActionButton(Icons.save, 'Grabar', () {}),
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
                  _buildTextField('ID', readOnly: true), // Show ID
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
