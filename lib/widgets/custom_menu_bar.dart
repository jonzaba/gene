import 'package:flutter/material.dart';

class CustomMenuBar extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback? onSave;
  final VoidCallback? onClose;
  final VoidCallback? onTestApi;
  final VoidCallback? onToggleParejas;
  final bool verParejas;
  final VoidCallback? onToggleApellidos;
  final bool verApellidos;

  const CustomMenuBar({
    super.key,
    required this.onOpen,
    this.onSave,
    this.onClose,
    this.onTestApi,
    this.onToggleParejas,
    this.verParejas = true,
    this.onToggleApellidos,
    this.verApellidos = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      height: 40,
      child: Row(
        children: [
          _buildMenuButton(context, 'Archivo', [
            PopupMenuItem(enabled: false, child: Text('Nuevo')),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'open',
              onTap: onOpen,
              child: const Text('Abrir'),
            ),
            PopupMenuItem(
              value: 'close',
              enabled: onClose != null,
              onTap: onClose,
              child: const Text('Cerrar'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(enabled: false, child: Text('Compactar BD')),
            const PopupMenuItem(enabled: false, child: Text('Ver Log')),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'save',
              enabled: onSave != null,
              onTap: onSave,
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
          _buildMenuButton(context, 'Visualización', [
            PopupMenuItem(
              enabled: onToggleParejas != null,
              onTap: onToggleParejas,
              child: Row(
                children: [
                  Icon(
                    verParejas
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 18,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  const Text('Ver Parejas'),
                ],
              ),
            ),
            PopupMenuItem(
              enabled: onToggleApellidos != null,
              onTap: onToggleApellidos,
              child: Row(
                children: [
                  Icon(
                    verApellidos
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 18,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  const Text('Panel Apellidos'),
                ],
              ),
            ),
            PopupMenuItem(enabled: false, child: Text('Edad')),
            const PopupMenuDivider(),
            const PopupMenuItem(enabled: false, child: Text('Fijar Foco')),
          ]),
          _buildMenuButton(context, 'Utilidades', [
            const PopupMenuItem(enabled: false, child: Text('Buscar')),
            PopupMenuItem(
              value: 'test_api',
              enabled: onTestApi != null,
              onTap: onTestApi,
              child: const Text('Probar API'),
            ),
          ]),
          _buildMenuButton(context, 'Ayuda', [
            const PopupMenuItem(enabled: false, child: Text('Ayuda')),
            const PopupMenuDivider(),
            const PopupMenuItem(enabled: false, child: Text('Acerca de...')),
          ]),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    List<PopupMenuEntry> items,
  ) {
    return PopupMenuButton(
      itemBuilder: (context) => items,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(label),
      ),
    );
  }
}
