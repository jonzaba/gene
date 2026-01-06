import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as p;
import '../database/database_helper.dart';
import '../models/persona.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_menu_bar.dart';

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
    // Delay slightly to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLoadConfig();
    });
  }

  Future<void> _checkAutoLoadConfig() async {
    String? ruta;
    String? base;
    int? personaId;

    if (kIsWeb) {
      // Parse URL parameters: ?ruta=...&base=...&persona=...
      final params = Uri.base.queryParameters;
      ruta = params['ruta'];
      base = params['base'];
      if (params['persona'] != null) {
        personaId = int.tryParse(params['persona']!);
      }
    } else {
      // Check for gene.config in the executable's directory
      try {
        final configFile = File('gene.config');
        if (await configFile.exists()) {
          final lines = await configFile.readAsLines();
          for (var line in lines) {
            final parts = line.split('=');
            if (parts.length == 2) {
              final key = parts[0].trim().toLowerCase();
              final value = parts[1].trim();
              if (key == 'ruta') ruta = value;
              if (key == 'base') base = value;
              if (key == 'persona') personaId = int.tryParse(value);
            }
          }
        }
      } catch (e) {
        // Silently fail if config can't be read
      }
    }

    if (ruta != null && base != null) {
      await _autoLoadDatabase(ruta, base, initialPersonaId: personaId);
    }
  }

  Future<void> _autoLoadDatabase(
    String ruta,
    String base, {
    int? initialPersonaId,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String fullPath;
      Uint8List? bytes;

      if (kIsWeb) {
        // Construct URL
        fullPath = ruta.endsWith('/') ? '$ruta$base' : '$ruta/$base';

        // Fetch bytes via HTTP
        final response = await http.get(Uri.parse(fullPath));
        if (response.statusCode == 200) {
          bytes = response.bodyBytes;
          DatabaseHelper.instance.basePath = null;
        } else {
          throw Exception('Error descargando BD: ${response.statusCode}');
        }
      } else {
        // Construct local path
        fullPath = p.join(ruta, base);
        DatabaseHelper.instance.basePath = ruta;
      }

      await DatabaseHelper.instance.openDatabaseFile(fullPath, bytes: bytes);

      setState(() {
        _dbPath = base;
      });

      if (initialPersonaId != null) {
        await _loadPersona(initialPersonaId);
      } else {
        await _loadInitialPersona();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en carga automática: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          DatabaseHelper.instance.basePath = null; // No local FS on web
        } else {
          pathOrData = result.files.single.path!;
          bytes = null; // Native uses path directly
          // Store directory path
          // Need to import 'package:path/path.dart' as p;
          // But I can't add imports with this tool easily in one go if I don't see top.
          // I will assume path package is available or use raw string manipulation if simple,
          // but path package is safer.
          // Actually, I should add the import first.

          // Quick hack: use string manipulation for now to avoid import mess if possible,
          // or just assume '/' separator since we are on Linux.
          // But safer to add import. I'll stick to a simple split for now if I can't see imports.
          // Wait, I can see imports in lines 1-10. I need to add one.
          // I'll use multi_replace to add import and the logic.

          // Let's defer strict path logic to next step or use p.dirname

          DatabaseHelper.instance.basePath = p.dirname(pathOrData);
        }

        await DatabaseHelper.instance.openDatabaseFile(
          pathOrData,
          bytes: bytes,
        );

        setState(() {
          _dbPath = result.files.single.name;
        });
        await _loadInitialPersona();
      } catch (e) {
        // Error opening database
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
    // Only show global loader if we don't have a persona yet
    if (_currentPersona == null) {
      setState(() {
        _isLoading = true;
      });
    }

    Persona? p = await DatabaseHelper.instance.getPersona(id);

    if (mounted) {
      setState(() {
        _currentPersona = p;
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePersonSaved(Persona savedPerson) async {
    // Reload the person from database to get fresh data
    await _loadPersona(savedPerson.id);
  }

  void _closeDatabase() {
    // Ideally close DB connection in DatabaseHelper
    setState(() {
      _dbPath = null;
      _currentPersona = null;
    });
    // Re-initialize DB helper if needed or just flag as closed
    // DatabaseHelper.instance.close(); // Implement if exists
  }

  Future<void> _saveDatabase() async {
    // Placeholder for saving/exporting functionality
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Función de guardar pendiente de implementación'),
        ),
      );
    }
  }

  Future<void> _searchPerson() async {
    if (!DatabaseHelper.instance.isDatabaseOpen) return;
    showSearch(
      context: context,
      delegate: PersonaSearchDelegate(onSelect: _loadPersona),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (DatabaseHelper.instance.isDatabaseOpen) {
      return MainLayout(
        currentPerson: _currentPersona,
        onOpenDatabase: _pickDatabase,
        onSaveDatabase: _saveDatabase,
        onCloseDatabase: _closeDatabase,
        onSearchPerson: _searchPerson,
        onTestApi: _testApi,
        onPersonSelected: _loadPersona,
        onPersonSaved: _handlePersonSaved,
      );
    } else {
      // Empty State but with Menu Bar
      return Column(
        children: [
          CustomMenuBar(
            onOpen: _pickDatabase,
            onTestApi: _testApi,
            // Save/Close disabled by passing null/checks in widget?
            // Logic inside CustomMenuBar handles null callbacks as disabled.
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay base de datos abierta',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickDatabase,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Abrir Base de Datos (.sqlite)'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
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
