import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/persona.dart';
import 'dart:math';

class SurnamesPanel extends StatefulWidget {
  final Persona? currentPerson;
  final double width;
  final Function(double) onWidthChanged;
  final int numApellidos;
  final Function(int) onNumApellidosChanged;

  const SurnamesPanel({
    super.key,
    this.currentPerson,
    required this.width,
    required this.onWidthChanged,
    required this.numApellidos,
    required this.onNumApellidosChanged,
  });

  @override
  State<SurnamesPanel> createState() => _SurnamesPanelState();
}

class _SurnamesPanelState extends State<SurnamesPanel> {
  List<String> _surnames = [];
  bool _isLoading = false;

  // Resizing state
  double _baseWidth = 180.0;
  final double _minWidth = 150.0;
  final double _maxWidth = 600.0;

  @override
  void initState() {
    super.initState();
    _loadSurnames();
  }

  @override
  void didUpdateWidget(SurnamesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPerson?.id != oldWidget.currentPerson?.id ||
        widget.numApellidos != oldWidget.numApellidos) {
      _loadSurnames();
    }
  }

  Future<void> _loadSurnames() async {
    if (widget.currentPerson == null) {
      setState(() {
        _surnames = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final int levels = (log(widget.numApellidos) / log(2)).floor();
      final ancestors = await DatabaseHelper.instance.getAncestors(
        widget.currentPerson!.id,
        levels + 1,
      );

      List<String> result = List.filled(widget.numApellidos + 1, "");

      // Initial state for recursive calculation
      List<Persona?> currentLevel = [widget.currentPerson];

      // Level 1 special case
      if (widget.numApellidos >= 1) {
        result[1] = widget.currentPerson!.apellido1;
      }

      int cont = 2;
      for (int niv = 1; niv <= levels; niv++) {
        List<Persona?> nextLevel = List.filled(pow(2, niv).toInt(), null);
        int adicMadre = pow(2, niv - 1).toInt();

        for (int i = 0; i < currentLevel.length; i++) {
          final p = currentLevel[i];
          if (p != null) {
            if (cont + i <= widget.numApellidos) {
              result[cont + i] = p.apellido2;
            }

            if (p.padreId > 0) {
              nextLevel[i] = ancestors[p.padreId];
            }
            if (p.madreId > 0) {
              nextLevel[i + adicMadre] = ancestors[p.madreId];
            }
          }
        }
        currentLevel = nextLevel;
        cont = 1 + pow(2, niv).toInt();
      }

      setState(() {
        _surnames = result.sublist(1);
        _isLoading = false;
      });
    } catch (e) {
      // Error loading surnames
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    String text = "";
    for (int i = 0; i < _surnames.length; i++) {
      text += "${i + 1}\t${_surnames[i]}\n";
    }
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
  }

  @override
  Widget build(BuildContext context) {
    // Scaling factor based on default width 180
    final double scale = widget.width / 180.0;
    final double fontSize = (11 * scale).clamp(8.0, 32.0);
    final double headerFontSize = (10 * scale).clamp(7.0, 24.0);
    final double rowHeight = (25 * scale).clamp(18.0, 80.0);
    final double numWidth = (30 * scale).clamp(20.0, 100.0);

    return GestureDetector(
      onScaleStart: (details) {
        _baseWidth = widget.width;
      },
      onScaleUpdate: (details) {
        final newWidth = (_baseWidth * details.scale).clamp(
          _minWidth,
          _maxWidth,
        );
        widget.onWidthChanged(newWidth);
      },
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: const Border(left: BorderSide(color: Colors.grey)),
        ),
        child: Column(
          children: [
            // 1. Controls (Dropdown)
            Padding(
              padding: EdgeInsets.all(8.0 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Num. Apellidos:',
                      style: TextStyle(fontSize: 11 * scale.clamp(0.8, 2.0)),
                    ),
                  ),
                  SizedBox(
                    height: 30 * scale.clamp(0.8, 2.0),
                    width: 60 * scale.clamp(1.0, 3.0),
                    child: DropdownButtonHideUnderline(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.white,
                        ),
                        child: DropdownButton<int>(
                          value: widget.numApellidos,
                          isExpanded: true,
                          style: TextStyle(
                            fontSize: 12 * scale.clamp(0.8, 1.5),
                            color: Colors.black,
                          ),
                          items: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024].map(
                            (int val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(val.toString()),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              widget.onNumApellidosChanged(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 2. Table Header
            Container(
              color: Colors.grey[400],
              padding: EdgeInsets.symmetric(vertical: 2 * scale),
              child: Row(
                children: [
                  SizedBox(
                    width: numWidth,
                    child: Text(
                      'Nu...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Apellido',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 3. Main List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: widget.numApellidos,
                      itemBuilder: (context, index) {
                        final String surname = index < _surnames.length
                            ? _surnames[index]
                            : "";
                        return Container(
                          height: rowHeight,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                            color: index % 2 == 0
                                ? Colors.white
                                : Colors.grey[50],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: numWidth,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4.0 * scale),
                                  child: Text(
                                    surname.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // 4. Footer (Copy Button)
            Padding(
              padding: EdgeInsets.all(8.0 * scale),
              child: ElevatedButton.icon(
                onPressed: _copyToClipboard,
                icon: Icon(Icons.copy, size: 16 * scale.clamp(1.0, 2.0)),
                label: Text(
                  'COP.',
                  style: TextStyle(fontSize: 12 * scale.clamp(1.0, 2.0)),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    double.infinity,
                    36 * scale.clamp(1.0, 2.0),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
