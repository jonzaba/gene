import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../database/database_helper.dart';

class TreePanel extends StatefulWidget {
  final Persona? currentPerson;
  final Function(int) onPersonSelected;

  const TreePanel({
    super.key,
    required this.currentPerson,
    required this.onPersonSelected,
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

  // View options
  bool verParejas = true; // Toggle between Siblings (false) and Partners (true)

  @override
  void didUpdateWidget(TreePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPerson?.id != widget.currentPerson?.id) {
      _loadTreeData();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentPerson != null) {
      _loadTreeData();
    }
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
      // Note: Java code allows up to 13 children
      List<Persona> hijos = await db.getHijosOf(p.id);
      if (hijos.length > 13) hijos = hijos.sublist(0, 13);
      nodo[0] = hijos;

      // 4. Siblings or Partners (Row 5)
      List<Persona> others;
      if (verParejas) {
        others = await db.getParejasOf(p.id);
      } else {
        others = await db.getHermanosOf(p.id);
      }
      if (others.length > 12) others = others.sublist(0, 12);
      nodo[5] = others;
    } catch (e) {
      print('Error loading tree: $e');
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
    // Ensure list is large enough
    while (nodo[row]!.length <= index) {
      nodo[row]!.add(null);
    }
    nodo[row]![index] = p;
  }

  void _toggleViewMode() {
    setState(() {
      verParejas = !verParejas;
    });
    _loadTreeData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (widget.currentPerson == null) {
      return const Center(child: Text("Seleccione una persona"));
    }

    return Column(
      children: [
        // Optional toolbar for tree view
        Container(
          height: 30,
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _toggleViewMode,
                child: Text(verParejas ? "Ver Hermanos" : "Ver Parejas"),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapUp: (details) {
                  _handleTap(
                    details.localPosition,
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                },
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: TreePainter(
                    nodo: nodo,
                    config: TreeConfig(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      verParejas: verParejas,
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

  void _handleTap(Offset position, double width, double height) {
    // Re-calculate layout to find hit
    // This is a bit inefficient (duplicating layout logic), but accurate.
    // Ideally, the Painter should return hit regions, or we share a LayoutCalculator.
    // For now, I'll implement a simple hit test loop similar to Painter.

    final config = TreeConfig(
      width: width,
      height: height,
      verParejas: verParejas,
    );
    final calculator = TreeLayoutCalculator(config: config, nodo: nodo);

    final hitPerson = calculator.hitTest(position);
    if (hitPerson != null && hitPerson.id != widget.currentPerson?.id) {
      widget.onPersonSelected(hitPerson.id);
    }
  }
}

class TreeConfig {
  final double width;
  final double height;
  final bool verParejas;

  // Constants from Java code approx
  final int dy = 40;

  TreeConfig({
    required this.width,
    required this.height,
    required this.verParejas,
  });

  double get alto => ((height - 50) / 5) - dy;
  double get ancho => (width / 8) - 15;
}

class TreeLayoutCalculator {
  final TreeConfig config;
  final Map<int, List<Persona?>> nodo;

  TreeLayoutCalculator({required this.config, required this.nodo});

  Persona? hitTest(Offset pos) {
    // Check Children (Row 0)
    if (nodo.containsKey(0)) {
      int count = nodo[0]!.where((e) => e != null).length;
      double w = (count > 7) ? config.width / count - 2 : config.ancho;
      for (int j = 0; j < count; j++) {
        var p = nodo[0]![j];
        if (p == null) continue;
        double x = j * config.width / count + config.width / count / 2 - w / 2;
        double y = config.dy.toDouble();
        if (_rectContains(x, y, w, config.alto, pos)) return p;
      }
    }

    // Check Ancestors (+ Focus) Rows 1-4
    for (int i = 1; i <= 4; i++) {
      if (!nodo.containsKey(i)) continue;
      int maxJ = (1 << (i - 1)); // 2^(i-1)
      for (int j = 0; j < maxJ; j++) {
        if (j >= nodo[i]!.length) break;
        var p = nodo[i]![j];
        if (p == null) continue;

        double w = config.ancho;
        // Adjust width for level 1 if needed (logic from Java)
        // Skipping complex adjustment for now

        double x =
            j * config.width / (1 << (i - 1)) + config.width / (1 << i) - w / 2;
        double y = i * (config.alto + config.dy) + config.dy;

        if (_rectContains(x, y, w, config.alto, pos)) return p;
      }
    }

    // Check Others (Row 5)
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
        if (_rectContains(x, y, w, config.alto, pos)) return p;
      }
    }

    return null;
  }

  bool _rectContains(double x, double y, double w, double h, Offset p) {
    return p.dx >= x && p.dx <= x + w && p.dy >= y && p.dy <= y + h;
  }
}

class TreePainter extends CustomPainter {
  final Map<int, List<Persona?>> nodo;
  final TreeConfig config;

  TreePainter({required this.nodo, required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    if (config.width == 0 || config.height == 0) return;

    // Draw Title? (Maybe skip for now)

    // 1. Draw Children
    if (nodo.containsKey(0)) {
      int count = nodo[0]!.where((e) => e != null).length;
      double w = (count > 7) ? config.width / count - 2 : config.ancho;

      for (int j = 0; j < count; j++) {
        var p = nodo[0]![j];
        if (p == null) continue;

        double x = j * config.width / count + config.width / count / 2 - w / 2;
        double y = config.dy.toDouble();

        _drawNode(canvas, x, y, w, config.alto, p);

        // Lines
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

    // 2. Draw Ancestors (1-4)
    for (int i = 1; i <= 4; i++) {
      if (!nodo.containsKey(i)) continue;
      int maxJ = (1 << (i - 1));
      for (int j = 0; j < maxJ; j++) {
        if (j >= nodo[i]!.length) break;
        var p = nodo[i]![j];
        if (p == null) continue; // Sparse array

        double w = config.ancho;
        double x =
            j * config.width / (1 << (i - 1)) + config.width / (1 << i) - w / 2;
        double y = i * (config.alto + config.dy) + config.dy;

        _drawNode(canvas, x, y, w, config.alto, p);

        // Lines to parent (if any)
        if (i > 1) {
          double x1 = x + w / 2;
          double x2 = 0;

          if (j % 2 == 0) {
            x2 =
                (x1 +
                    (j + 1) * config.width / (1 << (i - 1)) +
                    config.width / (1 << i)) /
                2;
          } else {
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

    // 3. Draw Siblings/Partners (Row 5)
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

        _drawNode(canvas, x, y, w, config.alto, p);

        double x1 = x + w / 2;
        double x2 = config.width / 2;

        final paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1;

        // Lines are different for partners vs siblings
        if (!config.verParejas) {
          // Siblings: Connect to top
          double y1 = y + config.alto;
          double y2 = y + config.alto + config.dy / 2;
          canvas.drawLine(Offset(x1, y1), Offset(x1, y2), paint);
          canvas.drawLine(Offset(x1, y2), Offset(x2, y2), paint);
          if (j == 0) {
            // Check logic for vertical line?
            // buffer.drawLine(x2, y1, x2, y2);
          }
        } else {
          // Partners: Connect to top ??
          double y1 = y;
          double y2 = y - config.dy / 2;
          canvas.drawLine(Offset(x1, y1), Offset(x1, y2), paint);
          canvas.drawLine(Offset(x1, y2), Offset(x2, y2), paint);
        }
      }
    }
  }

  void _drawNode(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Persona p,
  ) {
    final paint = Paint()
      ..color = p.esHombre ? const Color(0xFF5FF5FF) : const Color(0xFFFFEBEB)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Box
    final rect = Rect.fromLTWH(x, y, w, h);

    // 3D Effect simple
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Text
    final textSpan = TextSpan(
      text: "${p.nombre}\n${p.apellido1}\n${p.fechaNacimiento}",
      style: TextStyle(
        color: Colors.black,
        fontSize: h / 8 < 6 ? 6 : h / 8,
        fontFamily: 'Arial', // Fallback
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: w);

    // Center Text
    textPainter.paint(
      canvas,
      Offset(x + (w - textPainter.width) / 2, y + (h - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
