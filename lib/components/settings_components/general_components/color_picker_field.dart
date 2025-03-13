import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String defaultColor;

  const ColorPickerField({
    super.key,
    required this.controller,
    required this.label,
    this.defaultColor = '#000000',
  });

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  void _showColorPicker(BuildContext context) {
    Color currentColor;
    try {
      currentColor =
          widget.controller.text.isNotEmpty
              ? Color(int.parse(widget.controller.text.replaceAll('#', '0xFF')))
              : Color(int.parse(widget.defaultColor.replaceAll('#', '0xFF')));
    } catch (e) {
      currentColor = Colors.black;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.label),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: currentColor,
                  onColorChanged: (color) {
                    final colorHex =
                        color.value.toRadixString(16).toUpperCase();
                    widget.controller.text = '#${colorHex.substring(2)}';
                    setState(() {}); // Refresh the color preview
                  },
                  enableAlpha: false,
                  labelTypes: const [],
                  displayThumbColor: true,
                  pickerAreaHeightPercent: 0.8,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    labelText: 'Color Code',
                    hintText: '#RRGGBB',
                    border: const OutlineInputBorder(),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: currentColor,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 7 && value.startsWith('#')) {
                      try {
                        Color newColor = Color(
                          int.parse(value.replaceAll('#', '0xFF')),
                        );
                        setState(() {
                          currentColor = newColor;
                        });
                      } catch (e) {
                        // Invalid color code
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? prefixColor;
    try {
      prefixColor =
          widget.controller.text.isNotEmpty
              ? Color(int.parse(widget.controller.text.replaceAll('#', '0xFF')))
              : Color(int.parse(widget.defaultColor.replaceAll('#', '0xFF')));
    } catch (e) {
      prefixColor = Colors.grey;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black87, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showColorPicker(context),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: prefixColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.controller.text.isEmpty
                            ? widget.defaultColor
                            : widget.controller.text,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Icon(Icons.edit, size: 20, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: Colors.white,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 48,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1,
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}
