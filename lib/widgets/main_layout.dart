import 'package:flutter/material.dart';
import '../models/persona.dart';
import 'custom_menu_bar.dart';
import 'tree_panel.dart';
import 'edit_panel.dart';
import 'surnames_panel.dart';

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
  bool _verApellidos = false;
  double _surnamesPanelWidth = 180.0;
  int _numApellidos = 16;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          onToggleApellidos: () {
            setState(() {
              _verApellidos = !_verApellidos;
            });
          },
          verApellidos: _verApellidos,
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
                return Scaffold(
                  key: _scaffoldKey,
                  drawer: Drawer(
                    width: _surnamesPanelWidth,
                    child: SurnamesPanel(
                      key: ValueKey(
                        'surnames_drawer_${widget.currentPerson?.id ?? "none"}',
                      ),
                      currentPerson: widget.currentPerson,
                      width: _surnamesPanelWidth,
                      onWidthChanged: (newWidth) {
                        setState(() {
                          _surnamesPanelWidth = newWidth;
                        });
                      },
                      numApellidos: _numApellidos,
                      onNumApellidosChanged: (newVal) {
                        setState(() {
                          _numApellidos = newVal;
                        });
                      },
                    ),
                  ),
                  body: Stack(
                    children: [
                      // Content
                      Positioned.fill(
                        child: _showTreeOnMobile ? treeView : editView,
                      ),
                      // Toggle Button (FAB-ish)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_verApellidos) ...[
                              FloatingActionButton(
                                mini: true,
                                heroTag: 'surnamesBtn',
                                onPressed: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                backgroundColor: Colors.orange,
                                child: const Icon(
                                  Icons.list_alt,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            FloatingActionButton(
                              heroTag: 'viewToggleBtn',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Desktop Split View
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_verApellidos)
                      SurnamesPanel(
                        key: ValueKey(
                          'surnames_${widget.currentPerson?.id ?? "none"}',
                        ),
                        currentPerson: widget.currentPerson,
                        width: _surnamesPanelWidth,
                        onWidthChanged: (newWidth) {
                          setState(() {
                            _surnamesPanelWidth = newWidth;
                          });
                        },
                        numApellidos: _numApellidos,
                        onNumApellidosChanged: (newVal) {
                          setState(() {
                            _numApellidos = newVal;
                          });
                        },
                      ),
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
