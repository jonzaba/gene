import 'package:flutter/material.dart';
import '../models/persona.dart';
import 'custom_menu_bar.dart';
import 'tree_panel.dart';
import 'edit_panel.dart';

class MainLayout extends StatefulWidget {
  final Persona? currentPerson;
  final VoidCallback? onOpenDatabase;
  final VoidCallback? onSaveDatabase;
  final VoidCallback? onCloseDatabase;
  final VoidCallback? onSearchPerson;
  final VoidCallback? onTestApi;
  final Function(int)? onPersonSelected;
  final Function(Persona)? onPersonSaved;

  const MainLayout({
    super.key,
    this.currentPerson,
    this.onOpenDatabase,
    this.onSaveDatabase,
    this.onCloseDatabase,
    this.onSearchPerson,
    this.onTestApi,
    this.onPersonSelected,
    this.onPersonSaved,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Mobile View State: true = Tree, false = Edit
  bool _showTreeOnMobile = true;
  // View State (Lifted from TreePanel)
  bool _verParejas = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Menu
        CustomMenuBar(
          onOpen: widget.onOpenDatabase ?? () {},
          onSave: widget.onSaveDatabase,
          onClose: widget.onCloseDatabase,
          onTestApi: widget.onTestApi,
          // Handle view toggles here if we add menu item callbacks
          // For now, let's assume CustomMenuBar needs an update to accept this
          onToggleParejas: () {
            setState(() {
              _verParejas = !_verParejas;
            });
          },
          verParejas: _verParejas,
        ),
        // Main Content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 800;

              // Components
              Widget treeView = TreePanel(
                key: ValueKey('tree_${widget.currentPerson?.id ?? "none"}'),
                currentPerson: widget.currentPerson,
                verParejas: _verParejas, // Pass state down
                onPersonSelected: (id) {
                  if (widget.onPersonSelected != null) {
                    widget.onPersonSelected!(id);
                  }
                },
              );

              Widget editView = EditPanel(
                key: ValueKey('edit_${widget.currentPerson?.id ?? "none"}'),
                currentPerson: widget.currentPerson,
                onSearch: widget.onSearchPerson,
                onSave: widget.onPersonSaved,
              );

              if (isMobile) {
                return Stack(
                  children: [
                    // Content
                    Positioned.fill(
                      child: _showTreeOnMobile ? treeView : editView,
                    ),
                    // Toggle Button (FAB-ish)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _showTreeOnMobile = !_showTreeOnMobile;
                          });
                        },
                        child: Icon(
                          _showTreeOnMobile
                              ? Icons.edit
                              : Icons.family_restroom,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Desktop Split View
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: treeView),
                    editView, // Fixed width handled internally by EditPanel
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
