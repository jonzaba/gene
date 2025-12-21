import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/persona.dart';
import '../models/familia.dart';

class PersonDetailsScreen extends StatefulWidget {
  final Persona persona;
  final Function(int) onPersonaSelected;

  const PersonDetailsScreen({
    super.key,
    required this.persona,
    required this.onPersonaSelected,
  });

  @override
  State<PersonDetailsScreen> createState() => _PersonDetailsScreenState();
}

class _PersonDetailsScreenState extends State<PersonDetailsScreen> {
  Persona? _father;
  Persona? _mother;
  List<FamilyData> _families = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelatedData();
  }

  @override
  void didUpdateWidget(PersonDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.persona.id != widget.persona.id) {
      _loadRelatedData();
    }
  }

  Future<void> _loadRelatedData() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper.instance;
    final p = widget.persona;

    // Load Parents
    Persona? father;
    if (p.padreId > 0) {
      father = await db.getPersona(p.padreId);
    }

    Persona? mother;
    if (p.madreId > 0) {
      mother = await db.getPersona(p.madreId);
    }

    // Load Families where this person is a spouse
    List<Familia> families = [];
    if (p.esHombre) {
      families = await db.getFamiliasWhereEsposo(p.id);
    } else {
      families = await db.getFamiliasWhereEsposa(p.id);
    }

    List<FamilyData> familyDataList = [];
    for (var f in families) {
      int spouseId = p.esHombre ? f.esposaId : f.esposoId;
      Persona? spouse;
      if (spouseId > 0) {
        spouse = await db.getPersona(spouseId);
      }
      List<Persona> children = await db.getHijos(f.id);
      familyDataList.add(
        FamilyData(family: f, spouse: spouse, children: children),
      );
    }

    if (mounted) {
      setState(() {
        _father = father;
        _mother = mother;
        _families = familyDataList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final p = widget.persona;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            color: p.esHombre ? Colors.blue[50] : Colors.pink[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.person, size: 64, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    p.nombreCompleto,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Text('ID: ${p.id}'),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Nacimiento:',
                    '${p.fechaNacimiento} en ${p.lugarNacimiento}',
                  ),
                  if (p.fallecido)
                    _buildInfoRow(
                      'Fallecimiento:',
                      '${p.fechaFallecimiento} en ${p.lugarFallecimiento}',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Parents
          Text('Padres', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          Row(
            children: [
              Expanded(child: _buildPersonCard('Padre', _father)),
              const SizedBox(width: 8),
              Expanded(child: _buildPersonCard('Madre', _mother)),
            ],
          ),
          const SizedBox(height: 16),

          // Families
          Text('Familias', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          if (_families.isEmpty) const Text('Sin familias registradas.'),
          ..._families.map((f) => _buildFamilyCard(f)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPersonCard(String title, Persona? p) {
    return Card(
      child: InkWell(
        onTap: p != null ? () => widget.onPersonaSelected(p.id) : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              if (p != null) ...[
                Text(p.nombreCompleto, textAlign: TextAlign.center),
                Text('(${p.fechaNacimiento.substring(0, 4)})'),
              ] else
                const Text(
                  'Desconocido',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyCard(FamilyData data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matrimonio: ${data.family.fechaBoda}'),
            const SizedBox(height: 8),
            const Text(
              'Cónyuge:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildPersonCard('Pareja', data.spouse),
            const SizedBox(height: 8),
            const Text('Hijos:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (data.children.isEmpty) const Text('Sin hijos registrados.'),
            Wrap(
              spacing: 8,
              children: data.children
                  .map(
                    (child) => SizedBox(
                      width: 150,
                      child: _buildPersonCard('Hijo/a', child),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class FamilyData {
  final Familia family;
  final Persona? spouse;
  final List<Persona> children;

  FamilyData({required this.family, this.spouse, required this.children});
}
