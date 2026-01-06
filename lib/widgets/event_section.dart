import 'package:flutter/material.dart';
import '../utils/date_helper.dart';

class EventSection extends StatefulWidget {
  final String title;
  final bool? isActive;
  final ValueChanged<bool>? onActiveChanged;
  final String date; // YYYYMMDD
  final Function(String) onDateChanged;
  final String location;
  final Function(String) onLocationChanged;
  final List<String> locations;
  final bool hasDoc;
  final ValueChanged<bool> onDocChanged;
  final String docStatus;
  final Set<String> modifiedFields;
  final String prefix; // 'nac' or 'fall' for field tracking

  const EventSection({
    super.key,
    required this.title,
    this.isActive,
    this.onActiveChanged,
    required this.date,
    required this.onDateChanged,
    required this.location,
    required this.onLocationChanged,
    required this.locations,
    required this.hasDoc,
    required this.onDocChanged,
    required this.docStatus,
    required this.modifiedFields,
    required this.prefix,
  });

  @override
  State<EventSection> createState() => _EventSectionState();
}

class _EventSectionState extends State<EventSection> {
  late TextEditingController _yearController;
  late TextEditingController _monthController;
  late TextEditingController _dayController;
  late TextEditingController _locationController;
  final FocusNode _yearFocusNode = FocusNode();
  final FocusNode _monthFocusNode = FocusNode();
  final FocusNode _dayFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  bool _isInternalUpdating = false;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController();
    _monthController = TextEditingController();
    _dayController = TextEditingController();
    _locationController = TextEditingController();

    _parseDate(widget.date);
    _locationController.text = widget.location;

    _yearController.addListener(_onDatePartChanged);
    _monthController.addListener(_onDatePartChanged);
    _dayController.addListener(_onDatePartChanged);
    _locationController.addListener(_onLocationPartChanged);

    _yearFocusNode.addListener(() => _onFocusChanged(_yearFocusNode, 'year'));
    _monthFocusNode.addListener(
      () => _onFocusChanged(_monthFocusNode, 'month'),
    );
    _dayFocusNode.addListener(() => _onFocusChanged(_dayFocusNode, 'day'));
  }

  @override
  void didUpdateWidget(EventSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date && !_isInternalUpdating) {
      _parseDate(widget.date);
    }
    if (widget.location != oldWidget.location && !_isInternalUpdating) {
      _isInternalUpdating = true;
      _locationController.text = widget.location;
      _isInternalUpdating = false;
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _locationController.dispose();
    _yearFocusNode.dispose();
    _monthFocusNode.dispose();
    _dayFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _parseDate(String date) {
    _isInternalUpdating = true;
    if (date.length < 8) {
      if (!_yearFocusNode.hasFocus) _yearController.text = "";
      if (!_monthFocusNode.hasFocus) _monthController.text = "";
      if (!_dayFocusNode.hasFocus) _dayController.text = "";
    } else {
      final y = date.substring(0, 4);
      final m = date.substring(4, 6);
      final d = date.substring(6, 8);

      if (!_yearFocusNode.hasFocus) {
        _yearController.text = y == "0000" ? "" : y;
      }
      if (!_monthFocusNode.hasFocus) {
        _monthController.text = m == "00" ? "" : m;
      }
      if (!_dayFocusNode.hasFocus) {
        _dayController.text = d == "00" ? "" : d;
      }
    }
    _isInternalUpdating = false;
  }

  void _onFocusChanged(FocusNode node, String type) {
    if (!node.hasFocus) {
      // Focus lost: perform padding and notify parent of official value
      _isInternalUpdating = true;
      if (type == 'year') {
        final text = _yearController.text.trim();
        if (text.isNotEmpty) {
          _yearController.text = text.padLeft(4, '0');
        }
      } else if (type == 'month') {
        final text = _monthController.text.trim();
        if (text.isNotEmpty) {
          _monthController.text = text.padLeft(2, '0');
        }
      } else if (type == 'day') {
        final text = _dayController.text.trim();
        if (text.isNotEmpty) {
          _dayController.text = text.padLeft(2, '0');
        }
      }
      _isInternalUpdating = false;
      _onDatePartChanged(); // Sync to parent with padded values
    }
  }

  void _onDatePartChanged() {
    if (_isInternalUpdating) return;
    _isInternalUpdating = true;
    // Notify parent but without forcing padding into controllers while typing
    final y = _yearController.text.padLeft(4, '0');
    final m = _monthController.text.padLeft(2, '0');
    final d = _dayController.text.padLeft(2, '0');
    widget.onDateChanged("$y$m$d");
    _isInternalUpdating = false;
  }

  void _onLocationPartChanged() {
    if (_isInternalUpdating) return;
    _isInternalUpdating = true;
    widget.onLocationChanged(_locationController.text);
    _isInternalUpdating = false;
  }

  @override
  Widget build(BuildContext context) {
    final dateFieldName = "${widget.prefix}Fecha";
    final locationFieldName = "${widget.prefix}Lugar";
    final docFieldName = "tieneDoc${widget.prefix == 'nac' ? 'Nac' : 'Fall'}";
    final activeFieldName = widget.prefix == 'fall' ? 'fallecido' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            if (widget.isActive != null) ...[
              const SizedBox(width: 8),
              _buildSimpleCheckbox(activeFieldName!, widget.isActive!),
            ],
          ],
        ),
        // Date row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text(
                  'Fecha',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
              const SizedBox(width: 8),
              _buildDateTextField(
                _yearController,
                'AAAA',
                40,
                dateFieldName,
                _yearFocusNode,
              ),
              const SizedBox(width: 4),
              _buildDateTextField(
                _monthController,
                'MM',
                25,
                dateFieldName,
                _monthFocusNode,
              ),
              const SizedBox(width: 4),
              _buildDateTextField(
                _dayController,
                'DD',
                25,
                dateFieldName,
                _dayFocusNode,
              ),
              const SizedBox(width: 8),
              _buildValidationIcon(widget.date),
            ],
          ),
        ),
        // Location row
        _buildAutocompleteField(
          'Lugar',
          controller: _locationController,
          fieldName: locationFieldName,
          focusNode: _locationFocusNode,
          horizontal: true,
        ),
        // Doc row
        _buildDocRow(docFieldName, widget.hasDoc, widget.docStatus),
      ],
    );
  }

  Widget _buildDateTextField(
    TextEditingController controller,
    String hint,
    double width,
    String fieldName,
    FocusNode focusNode,
  ) {
    final isModified = widget.modifiedFields.contains(fieldName);
    return SizedBox(
      width: width,
      height: 30,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 2,
          ),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: isModified ? Colors.green[100] : Colors.white,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSimpleCheckbox(String fieldName, bool value) {
    final isModified = widget.modifiedFields.contains(fieldName);
    return SizedBox(
      height: 24,
      width: 24,
      child: Checkbox(
        value: value,
        onChanged: (val) {
          if (val != null && widget.onActiveChanged != null) {
            widget.onActiveChanged!(val);
          }
        },
        side: isModified
            ? const BorderSide(color: Colors.green, width: 2)
            : null,
      ),
    );
  }

  Widget _buildDocRow(String fieldName, bool value, String docStatus) {
    final isModified = widget.modifiedFields.contains(fieldName);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          const SizedBox(
            width: 60,
            child: Text(
              'Doc',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: (val) {
                if (val != null) widget.onDocChanged(val);
              },
              side: isModified
                  ? const BorderSide(color: Colors.green, width: 2)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onDoubleTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Abriendo documento: $docStatus')),
              );
            },
            child: Text(
              value ? docStatus : 'Vacío',
              style: TextStyle(
                fontSize: 11,
                color: value ? Colors.blue : Colors.grey,
                decoration: value ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteField(
    String label, {
    required TextEditingController controller,
    required String fieldName,
    FocusNode? focusNode,
    bool horizontal = false,
  }) {
    final isModified = widget.modifiedFields.contains(fieldName);

    Widget autocomplete = LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode ?? FocusNode(),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return widget.locations.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (String selection) {
            controller.text = selection;
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return SizedBox(
                  height: 30,
                  child: TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: isModified ? Colors.green[100] : Colors.white,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          option,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () => onSelected(option),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (horizontal) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: autocomplete),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        autocomplete,
      ],
    );
  }

  Widget _buildValidationIcon(String date) {
    if (!DateHelper.isDateComplete(date)) {
      return const SizedBox(width: 24);
    }

    final isValid = DateHelper.isValidDate(date);
    return Icon(
      isValid ? Icons.check_circle : Icons.error,
      color: isValid ? Colors.green : Colors.red,
      size: 18,
    );
  }
}
