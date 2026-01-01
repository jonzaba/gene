import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/persona.dart';

class NodoFamilia extends StatelessWidget {
  final Persona persona;
  final double width;
  final double height;
  final bool hasDocBoda; // Calculated externally
  final bool hasDocSeparacion; // Calculated externally
  final ui.Image? imgFotoMasc;
  final ui.Image? imgFotoFem;
  final ui.Image? imgDocNac;
  final ui.Image? imgDocFall;
  final ui.Image? imgDocBoda;
  final ui.Image? imgDocSep;

  final bool isActive; // Added for highlighting

  const NodoFamilia({
    super.key,
    required this.persona,
    required this.width,
    required this.height,
    this.isActive = false,
    this.hasDocBoda = false,
    this.hasDocSeparacion = false,
    this.imgFotoMasc,
    this.imgFotoFem,
    this.imgDocNac,
    this.imgDocFall,
    this.imgDocBoda,
    this.imgDocSep,
  });

  @override
  Widget build(BuildContext context) {
    // Colors
    Color bgColor;
    if (isActive) {
      bgColor = Colors.yellowAccent;
    } else {
      bgColor = persona.esHombre
          ? const Color(0xFF5FF5FF)
          : const Color(0xFFFFEBEB);
    }
    final Color borderColor = Colors.black;

    // Photo Calculation
    // Java: offset = (foto.getWidth() * alto) / foto.getHeight();
    // Logic: If has photo, we split width.
    // However, the Java code draws photo OUTSIDE/Offset relative to text block?
    // "buffer.fill3DRect(x - offset / 2...)" vs "buffer.drawImage(bloque, x + offset / 2...)"
    // It implies the node width grows? Or shifts?
    // "nodo[i][j].setCoordenadas(x - offset / 2, y, x + ancho + offset / 2, y + alto);"
    // So the HIT AREA includes both.
    // Here we will build a Row: [Photo] [Text Box]

    // We need the photo aspect ratio.
    // Assuming standard aspect or utilizing the loaded ui.Images if available.
    // If not loaded yet, we can't calc perfect aspect, but we can default.

    Widget? photoWidget;
    double photoWidth = 0;

    if (persona.tieneFoto && height > 40) {
      // Height check approx from Java
      // Resolve specific image
      ui.Image? img = persona.esHombre ? imgFotoMasc : imgFotoFem;
      if (img != null) {
        double aspectRatio = img.width.toDouble() / img.height.toDouble();
        photoWidth = height * aspectRatio;
        double maxW = height * 0.8;
        // Java: if (offset > OFFSET) offset = OFFSET; OFFSET = ALTO * 0.8
        if (photoWidth > maxW) photoWidth = maxW;

        photoWidget = Container(
          width: photoWidth,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.all(2), // Margin for photo
          child: RawImage(image: img, fit: BoxFit.fill),
        );
      }
    }

    // Text & Icons Block
    Widget textBlock = Container(
      // width: width, // Removed to allow Expanded to control width
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Stack(
        children: [
          // Centered Text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  persona.nombreCompleto
                      .toUpperCase(), // Java often uppercases? Image showed caps.
                  textAlign: TextAlign.center,
                  style: _getTextStyle(height),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(_getPeriodo(), style: _getTextStyle(height)),
                Text(
                  persona.lugarNacimiento,
                  style: _getTextStyle(height),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Icons on Right Edge
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: width * 0.15, // 10% in Java, giving a bit more
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // From bottom up
              children: [
                // Order from bottom: Sep, Boda, Death, Birth
                // Wait, Java:
                // Birth: alto - 4 lines up (Top)
                // Death: alto - 3 lines up
                // Boda:  alto - 2 lines up
                // Sep:   alto - 1 lines up (Bottom)

                // In Column (Top to Bottom): Birth, Death, Boda, Sep
                if (persona.tieneDocNacimiento && imgDocNac != null)
                  _buildIcon(imgDocNac!),
                if (persona.tieneDocFallecimiento && imgDocFall != null)
                  _buildIcon(
                    imgDocFall!,
                  ), // Actually Java handles death cross differently (lines)
                if (hasDocBoda && imgDocBoda != null) _buildIcon(imgDocBoda!),
                if (hasDocSeparacion && imgDocSep != null)
                  _buildIcon(imgDocSep!),
              ],
            ),
          ),

          // Death Cross (Gray lines) on Right
          if (persona.fallecido)
            Positioned(
              right: 5,
              top: 5,
              child: Icon(
                Icons.add,
                color: Colors.grey,
                size: 20,
              ), // Placeholder for drawn cross
              // Or we can use CustomPaint for the cross if we want exact Java look
            ),
        ],
      ),
    );

    return Row(
      children: [
        if (photoWidget != null) photoWidget!,
        Expanded(child: textBlock),
      ],
    );
  }

  Widget _buildIcon(ui.Image img) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: SizedBox(width: 12, height: 12, child: RawImage(image: img)),
    );
  }

  TextStyle _getTextStyle(double boxHeight) {
    double size = boxHeight / 8;
    if (size < 9) size = 9;
    return TextStyle(
      fontFamily: 'Arial',
      fontSize: size,
      color: Colors.black,
      height: 1.1,
    );
  }

  String _getPeriodo() {
    // Replicate logic from PanelFamilia/Nodo/Persona
    // Java: persona.periodo calculated in Persona.calcularPeriodo
    // If dead: "(Born - Died)" or "(Born - ?)"
    // If alive: "(Born)"

    String f = persona.fechaNacimiento;
    String t = persona.fechaFallecimiento;

    String cleanYear(String d) {
      if (d.length >= 4) return d.substring(0, 4);
      return "?";
    }

    String born = cleanYear(f);

    if (persona.fallecido) {
      String died = cleanYear(t);
      return "($born - $died)";
    } else {
      return "($born)";
    }
  }
}
