import 'package:flutter/material.dart';

class CustomMenuBar extends StatelessWidget {
  final VoidCallback? onOpen;
  final VoidCallback? onSave;
  final VoidCallback? onClose;
  final VoidCallback? onTestApi;

  const CustomMenuBar({
    super.key,
    this.onOpen,
    this.onSave,
    this.onClose,
    this.onTestApi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.grey[200],
      child: Row(
        children: [
          _buildMenuButton(context, 'Archivo', [
            PopupMenuItem(enabled: false, child: Text('Nuevo')),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'open',
              enabled: onOpen != null,
              child: const Text('Abrir'),
            ),
            PopupMenuItem(
              value: 'close',
              enabled: onClose != null,
              child: const Text('Cerrar'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(enabled: false, child: Text('Compactar BD')),
            const PopupMenuItem(enabled: false, child: Text('Ver Log')),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'save',
              enabled: onSave != null,
              child: const Text('Guardar copia'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(enabled: false, child: Text('Salir')),
          ]),
          _buildMenuButton(context, 'Editar', [
            const PopupMenuItem(enabled: false, child: Text('Deshacer')),
            const PopupMenuDivider(),
            const PopupMenuItem(enabled: false, child: Text('Cambiar Persona')),
          ]),
          _buildMenuButton(context, 'Visualizar', [
            const PopupMenuItem(
              enabled: false,
              child: Text('Parejas' /* vs Hermanos */),
            ),
            const PopupMenuItem(
              enabled: false,
              child: Text('Edad' /* vs Periodo */),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(enabled: false, child: Text('Fijar Foco')),
          ]),
          _buildMenuButton(context, 'Utilidades', [
            const PopupMenuItem(enabled: false, child: Text('Buscar')),
            const PopupMenuItem(
              enabled: false,
              child: Text('Lista Personas'),
            ), // Was in main panel too
            PopupMenuItem(
              value: 'test_api',
              enabled: onTestApi != null,
              child: const Text('Probar API'),
            ),
          ]),
          _buildMenuButton(context, 'Informes', [
            const PopupMenuItem(
              enabled: false,
              child: Text('Lista de Personas'),
            ),
            const PopupMenuItem(
              enabled: false,
              child: Text('Lista de Uniones'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              enabled: false,
              child: Text('Arbol Descendientes'),
            ),
            const PopupMenuItem(enabled: false, child: Text('Arbol Lineal')),
            const PopupMenuItem(enabled: false, child: Text('Arbol Circular')),
          ]),
          _buildMenuButton(context, 'Ayuda', [
            const PopupMenuItem(enabled: false, child: Text('Novedades')),
            const PopupMenuItem(enabled: false, child: Text('Acerca de...')),
          ]),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    List<PopupMenuEntry<String>> items,
  ) {
    return PopupMenuButton<String>(
      tooltip: title,
      onSelected: (value) {
        if (value == 'open' && onOpen != null) onOpen!();
        if (value == 'save' && onSave != null) onSave!();
        if (value == 'close' && onClose != null) onClose!();
        if (value == 'test_api' && onTestApi != null) onTestApi!();
      },
      itemBuilder: (context) => items,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}
