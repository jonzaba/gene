import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/persona.dart';
import '../database/database_helper.dart';
import 'nodo_familia.dart';

class TreeNodeLayout {
  final Persona persona;
  final Rect rect;
  TreeNodeLayout(this.persona, this.rect);
}

class TreeConfig {
  final double width;
  final double height;
  final bool verParejas;

  final ui.Image? imgFotoMasc;
  final ui.Image? imgFotoFem;
  final ui.Image? imgDocNac;
  final ui.Image? imgDocFall;
  final ui.Image? imgDocBoda;
  final ui.Image? imgDocSep;

  // Constants from Java code approx
  final int dy = 40;

  TreeConfig({
    required this.width,
    required this.height,
    required this.verParejas,
    this.imgFotoMasc,
    this.imgFotoFem,
    this.imgDocNac,
    this.imgDocFall,
    this.imgDocBoda,
    this.imgDocSep,
  });

  double get alto => ((height - 50) / 5) - dy;
  double get ancho => (width / 8) - 15;
}

class TreePanel extends StatefulWidget {
  final Persona? currentPerson;
  final Function(int) onPersonSelected;
  final bool verParejas;

  const TreePanel({
    super.key,
    required this.currentPerson,
    required this.onPersonSelected,
    this.verParejas = true,
  });

  @override
  State<TreePanel> createState() => _TreePanelState();
}

class _TreePanelState extends State<TreePanel> {
  // Grid structure matching PanelFamilia.java
  // 0: Children
  // 1-4: Ancestors (1=Focus, 2=Parents, 3=Grandparents...)
  // 5: Siblings/Partners
  // Using Map for sparse storage: row -> [list of personas]
  Map<int, List<Persona?>> nodo = {};
  bool isLoading = false;

  // Images
  ui.Image? imgFotoMasc;
  ui.Image? imgFotoFem;
  ui.Image? imgDocNac;
  ui.Image? imgDocFall;
  ui.Image? imgDocBoda;
  ui.Image? imgDocSep;

  @override
  void didUpdateWidget(TreePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if ID changes, reference changes (e.g. after save), or view mode changes
    if (oldWidget.currentPerson?.id != widget.currentPerson?.id ||
        oldWidget.currentPerson != widget.currentPerson ||
        oldWidget.verParejas != widget.verParejas) {
      _loadTreeData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAssets();
    if (widget.currentPerson != null) {
      _loadTreeData();
    }
  }

  Future<void> _loadAssets() async {
    try {
      imgFotoMasc = await _loadImage('assets/images/foto_m.png');
      imgFotoFem = await _loadImage('assets/images/foto_f.png');
      imgDocNac = await _loadImage('assets/images/doc_Nacimiento.png');
      imgDocFall = await _loadImage('assets/images/doc_Fallecimiento.png');
      imgDocBoda = await _loadImage('assets/images/doc_Boda.png');
      imgDocSep = await _loadImage('assets/images/doc_Separacion.png');
      if (mounted) setState(() {});
    } catch (e) {
      // Error loading assets
    }
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _loadTreeData() async {
    if (widget.currentPerson == null) return;

    setState(() {
      isLoading = true;
      nodo.clear();
    });

    try {
      final p = widget.currentPerson!;
      final db = DatabaseHelper.instance;

      // 1. Focus Person (Row 1, Index 0)
      nodo[1] = [p];

      // 2. Ancestors (Rows 2-4)
      await _loadAncestors(p, 1, 0);

      // 3. Children (Row 0)
      List<Persona> hijos = await db.getHijosOf(p.id);
      if (hijos.length > 13) hijos = hijos.sublist(0, 13);
      nodo[0] = hijos;

      // 4. Siblings or Partners (Row 5)
      List<Persona> others;
      if (widget.verParejas) {
        others = await db.getParejasOf(p.id);
      } else {
        others = await db.getHermanosOf(p.id);
      }
      if (others.length > 12) others = others.sublist(0, 12);
      nodo[5] = others;

      // Batch fetch family docs
      List<Persona> allVisible = [];
      for (var list in nodo.values) {
        for (var item in list) {
          if (item != null) allVisible.add(item);
        }
      }
      await db.checkFamilyDocs(allVisible);
    } catch (e) {
      // Error loading tree
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAncestors(Persona p, int level, int index) async {
    if (level >= 4) return;

    // Load Father
    if (p.padreId > 0) {
      Persona? father = await DatabaseHelper.instance.getPersona(p.padreId);
      if (father != null) {
        _addToGrid(level + 1, 2 * index, father);
        await _loadAncestors(father, level + 1, 2 * index);
      }
    }

    // Load Mother
    if (p.madreId > 0) {
      Persona? mother = await DatabaseHelper.instance.getPersona(p.madreId);
      if (mother != null) {
        _addToGrid(level + 1, 2 * index + 1, mother);
        await _loadAncestors(mother, level + 1, 2 * index + 1);
      }
    }
  }

  void _addToGrid(int row, int index, Persona p) {
    if (nodo[row] == null) nodo[row] = [];
    while (nodo[row]!.length <= index) {
      nodo[row]!.add(null);
    }
    nodo[row]![index] = p;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (widget.currentPerson == null) {
      return const Center(child: Text("Seleccione una persona"));
    }

    return Column(
      children: [
        // Title Bar
        Container(
          height: 40,
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(
            "Arbol Genealógico de ${widget.currentPerson?.nombreCompleto ?? ''}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final config = TreeConfig(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                verParejas: widget.verParejas,
                imgFotoMasc: imgFotoMasc,
                imgFotoFem: imgFotoFem,
                imgDocNac: imgDocNac,
                imgDocFall: imgDocFall,
                imgDocBoda: imgDocBoda,
                imgDocSep: imgDocSep,
              );
              final layoutCalc = TreeLayoutCalculator(
                config: config,
                nodo: nodo,
              );
              final positions = layoutCalc.getLayout();

              return InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.1,
                maxScale: 4.0,
                child: GestureDetector(
                  onTapUp: (details) {
                    for (var node in positions) {
                      if (node.rect.contains(details.localPosition)) {
                        if (node.persona.id != widget.currentPerson?.id) {
                          widget.onPersonSelected(node.persona.id);
                        }
                        return;
                      }
                    }
                  },
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: Colors.white, // Background for hits
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: TreePainter(nodo: nodo, config: config),
                        ),
                        ...positions.map(
                          (node) => Positioned(
                            left: node.rect.left,
                            top: node.rect.top,
                            width: node.rect.width,
                            height: node.rect.height,
                            child: NodoFamilia(
                              persona: node.persona,
                              width: node.rect.width,
                              height: node.rect.height,
                              isActive:
                                  node.persona.id ==
                                  widget.currentPerson?.id, // Highlight active
                              hasDocBoda: node.persona.hasDocBoda,
                              hasDocSeparacion: node.persona.hasDocSeparacion,
                              imgFotoMasc: imgFotoMasc,
                              imgFotoFem: imgFotoFem,
                              imgDocNac: imgDocNac,
                              imgDocFall: imgDocFall,
                              imgDocBoda: imgDocBoda,
                              imgDocSep: imgDocSep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TreeLayoutCalculator {
  final TreeConfig config;
  final Map<int, List<Persona?>> nodo;

  TreeLayoutCalculator({required this.config, required this.nodo});

  List<TreeNodeLayout> getLayout() {
    List<TreeNodeLayout> layout = [];

    // Children (Row 0)
    if (nodo.containsKey(0)) {
      int count = nodo[0]!.where((e) => e != null).length;
      double w = (count > 7) ? config.width / count - 2 : config.ancho;
      for (int j = 0; j < count; j++) {
        var p = nodo[0]![j];
        if (p == null) continue;
        double x = j * config.width / count + config.width / count / 2 - w / 2;
        double y = config.dy.toDouble();
        layout.add(TreeNodeLayout(p, Rect.fromLTWH(x, y, w, config.alto)));
      }
    }

    // Ancestors (Rows 1-4)
    for (int i = 1; i <= 4; i++) {
      if (!nodo.containsKey(i)) continue;
      int maxJ = (1 << (i - 1));
      for (int j = 0; j < maxJ; j++) {
        if (j >= nodo[i]!.length) break;
        var p = nodo[i]![j];
        if (p == null) continue;

        double w = config.ancho;
        double x =
            j * config.width / (1 << (i - 1)) + config.width / (1 << i) - w / 2;
        double y = i * (config.alto + config.dy) + config.dy;
        layout.add(TreeNodeLayout(p, Rect.fromLTWH(x, y, w, config.alto)));
      }
    }

    // Others (Row 5)
    if (nodo.containsKey(5)) {
      int count = nodo[5]!.where((e) => e != null).length;
      double w = (count > 6)
          ? config.width / (count + 1 + (count % 2)) - 2
          : config.ancho;
      int par = count + count % 2;
      double spc = (count > 6) ? 2.0 : 50.0;

      for (int j = 0; j < count; j++) {
        var p = nodo[5]![j];
        if (p == null) continue;

        double x =
            j * (config.width - w - spc) / par +
            (config.width - w - spc) / par / 2 -
            w / 2;
        if (j >= par / 2) x += w + spc;

        double y = 1 * (config.alto + config.dy) + config.dy;
        layout.add(TreeNodeLayout(p, Rect.fromLTWH(x, y, w, config.alto)));
      }
    }
    return layout;
  }
}

class TreePainter extends CustomPainter {
  final Map<int, List<Persona?>> nodo;
  final TreeConfig config;

  TreePainter({required this.nodo, required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    if (config.width == 0 || config.height == 0) return;

    // 1. Draw Children Lines
    if (nodo.containsKey(0)) {
      int count = nodo[0]!.where((e) => e != null).length;
      double w = (count > 7) ? config.width / count - 2 : config.ancho;

      for (int j = 0; j < count; j++) {
        var p = nodo[0]![j];
        if (p == null) continue;

        double x = j * config.width / count + config.width / count / 2 - w / 2;
        double y = config.dy.toDouble();

        double x1 = x + w / 2;
        double x2 = config.width / 2;
        double y1 = y + config.alto;
        double y2 = y + config.alto + config.dy / 2;
        double y3 = y + config.alto + config.dy;

        final paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1;
        canvas.drawLine(Offset(x1, y1), Offset(x1, y2), paint);
        canvas.drawLine(Offset(x1, y2), Offset(x2, y2), paint);
        canvas.drawLine(Offset(x2, y2), Offset(x2, y3), paint);
      }
    }

    // 2. Draw Ancestors Lines (Rows 1-4)
    for (int i = 1; i <= 4; i++) {
      if (!nodo.containsKey(i)) continue;
      int maxJ = (1 << (i - 1));
      for (int j = 0; j < maxJ; j++) {
        if (j >= nodo[i]!.length) break;
        var p = nodo[i]![j];
        if (p == null) continue;

        double w = config.ancho;
        double x =
            j * config.width / (1 << (i - 1)) + config.width / (1 << i) - w / 2;
        double y = i * (config.alto + config.dy) + config.dy;

        // Lines to parent (if not root)
        if (i > 1) {
          double x1 = x + w / 2;
          double x2 = 0;

          if (j % 2 == 0) {
            // Right child of parent
            x2 =
                (x1 +
                    (j + 1) * config.width / (1 << (i - 1)) +
                    config.width / (1 << i)) /
                2;
          } else {
            // Left child of parent
            x2 =
                (x1 +
                    (j - 1) * config.width / (1 << (i - 1)) +
                    config.width / (1 << i)) /
                2;
          }

          double y1 = y;
          double y2 = y - config.dy / 2;
          double y3 = y - config.dy;

          final paint = Paint()
            ..color = Colors.black
            ..strokeWidth = 1;
          canvas.drawLine(Offset(x1, y1), Offset(x1, y2), paint);
          canvas.drawLine(Offset(x1, y2), Offset(x2, y2), paint);
          canvas.drawLine(Offset(x2, y2), Offset(x2, y3), paint);
        }
      }
    }

    // 3. Draw Siblings/Partners Lines (Row 5)
    if (nodo.containsKey(5)) {
      int count = nodo[5]!.where((e) => e != null).length;
      double w = (count > 6)
          ? config.width / (count + 1 + (count % 2)) - 2
          : config.ancho;
      int par = count + count % 2;
      double spc = (count > 6) ? 2.0 : 50.0;

      for (int j = 0; j < count; j++) {
        var p = nodo[5]![j];
        if (p == null) continue;

        double x =
            j * (config.width - w - spc) / par +
            (config.width - w - spc) / par / 2 -
            w / 2;
        if (j >= par / 2) x += w + spc;

        double y = 1 * (config.alto + config.dy) + config.dy;

        double x1 = x + w / 2;
        double x2 = config.width / 2;

        final paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1;

        if (!config.verParejas) {
          // Siblings
          double y1 = y + config.alto;
          double y2 = y + config.alto + config.dy / 2;
          canvas.drawLine(Offset(x1, y1), Offset(x1, y2), paint);
          canvas.drawLine(Offset(x1, y2), Offset(x2, y2), paint);
        } else {
          // Partners
          double y1 = y;
          double y2 = y - config.dy / 2;
          canvas.drawLine(Offset(x1, y1), Offset(x1, y2), paint);
          canvas.drawLine(Offset(x1, y2), Offset(x2, y2), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.nodo != nodo ||
        oldDelegate.config.width != config.width ||
        oldDelegate.config.height != config.height ||
        oldDelegate.config.verParejas != config.verParejas;
  }
}
