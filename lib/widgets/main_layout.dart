import 'package:flutter/material.dart';
import '../models/persona.dart';
import 'custom_menu_bar.dart';
import 'tree_panel.dart';
import 'edit_panel.dart';

class MainLayout extends StatelessWidget {
  final Persona? currentPerson;
  final VoidCallback? onOpenDatabase;
  final VoidCallback? onSaveDatabase;
  final VoidCallback? onCloseDatabase;
  final VoidCallback? onSearchPerson;
  final VoidCallback? onTestApi;
  final Function(int)? onPersonSelected;

  const MainLayout({
    super.key,
    this.currentPerson,
    this.onOpenDatabase,
    this.onSaveDatabase,
    this.onCloseDatabase,
    this.onSearchPerson,
    this.onTestApi,
    this.onPersonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Menu
        CustomMenuBar(
          onOpen: onOpenDatabase,
          onSave: onSaveDatabase,
          onClose: onCloseDatabase,
          onTestApi: onTestApi,
        ),
        // Main Content Row
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left/Center: Tree View
              Expanded(
                child: TreePanel(
                  currentPerson: currentPerson,
                  onPersonSelected: (id) {
                    if (onPersonSelected != null) onPersonSelected!(id);
                  },
                ),
              ),
              // Right: Edit Panel
              EditPanel(currentPerson: currentPerson, onSearch: onSearchPerson),
            ],
          ),
        ),
      ],
    );
  }
}
