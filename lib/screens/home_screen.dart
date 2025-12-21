import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';
import '../models/persona.dart';
import 'person_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  Persona? _currentPersona;
  String? _dbPath;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Seleccionar Base de Datos SQLite',
      type: FileType.any,
      withData: kIsWeb, // Only load data into memory on Web
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String pathOrData;
        Uint8List? bytes;

        if (kIsWeb) {
          pathOrData = 'uploaded.db'; // Virtual path for Web
          bytes = result.files.single.bytes;
        } else {
          pathOrData = result.files.single.path!;
          bytes = null; // Native uses path directly
        }

        await DatabaseHelper.instance.openDatabaseFile(
          pathOrData,
          bytes: bytes,
        );

        setState(() {
          _dbPath = result.files.single.name;
        });
        await _loadInitialPersona();
      } catch (e, stackTrace) {
        print('Error opening database: $e');
        print(stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error abriendo base de datos: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadInitialPersona() async {
    // Try to load ID 1, or the first one found
    Persona? p = await DatabaseHelper.instance.getPersona(1);
    if (p == null) {
      List<Persona> all = await DatabaseHelper.instance.getAllPersonas();
      if (all.isNotEmpty) {
        p = all.first;
      }
    }

    if (mounted) {
      setState(() {
        _currentPersona = p;
      });
    }
  }

  Future<void> _loadPersona(int id) async {
    setState(() {
      _isLoading = true;
    });
    Persona? p = await DatabaseHelper.instance.getPersona(id);
    setState(() {
      _currentPersona = p;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Arbol Genealogico'),
            if (_dbPath != null)
              Text(_dbPath!, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        actions: [
          if (DatabaseHelper.instance.isDatabaseOpen)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: PersonaSearchDelegate(onSelect: _loadPersona),
                );
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Abrir Base de Datos'),
              onTap: () {
                Navigator.pop(context);
                _pickDatabase();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Probar API'),
              onTap: () async {
                Navigator.pop(context);
                await _testApi();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Salir'),
              onTap: () {
                // Exit app
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('https://jonzaba.github.io/'));
      if (response.statusCode == 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Respuesta API'),
              content: Text(response.body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error API: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!DatabaseHelper.instance.isDatabaseOpen) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No hay base de datos abierta.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDatabase,
              child: const Text('Abrir Base de Datos'),
            ),
          ],
        ),
      );
    }

    if (_currentPersona == null) {
      return const Center(
        child: Text('No se ha seleccionado ninguna persona.'),
      );
    }

    return PersonDetailsScreen(
      persona: _currentPersona!,
      onPersonaSelected: _loadPersona,
    );
  }
}

class PersonaSearchDelegate extends SearchDelegate<int?> {
  final Function(int) onSelect;

  PersonaSearchDelegate({required this.onSelect});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Escriba un nombre para buscar.'));
    }

    return FutureBuilder<List<Persona>>(
      future: DatabaseHelper.instance.searchPersonas(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron resultados.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final p = snapshot.data![index];
            return ListTile(
              title: Text(p.nombreCompleto),
              subtitle: Text('ID: ${p.id} - ${p.fechaNacimiento}'),
              onTap: () {
                onSelect(p.id);
                close(context, p.id);
              },
            );
          },
        );
      },
    );
  }
}
