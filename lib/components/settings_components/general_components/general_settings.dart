import 'package:flutter/material.dart';
import './color_picker_field.dart';

class GeneralSettings extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;

  const GeneralSettings({
    super.key,
    required this.controllers,
    required this.toggleStates,
    required this.onToggleChanged,
  });

  Widget _buildGeneralUISection() {
    return Card(
      key: const ValueKey('general_ui'),
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Color(0xFF0066CB)),
                const SizedBox(width: 12),
                const Text(
                  'General UI',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0066CB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Colors
            const Text(
              'Colors',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            if (controllers['titleFontColor'] != null)
              ColorPickerField(
                controller: controllers['titleFontColor']!,
                label: 'Title Font Color',
                defaultColor: '#000000',
              ),
            const SizedBox(height: 12),
            if (controllers['buttonTextFontColor'] != null)
              ColorPickerField(
                controller: controllers['buttonTextFontColor']!,
                label: 'Button Text Font Color',
                defaultColor: '#000000',
              ),
            const SizedBox(height: 12),
            if (controllers['buttonsBackgroundColor'] != null)
              ColorPickerField(
                controller: controllers['buttonsBackgroundColor']!,
                label: 'Buttons Background Color',
                defaultColor: '#FFFFFF',
              ),
            const SizedBox(height: 12),
            if (controllers['sixBigButtonsBackgroundColor'] != null)
              ColorPickerField(
                controller: controllers['sixBigButtonsBackgroundColor']!,
                label: 'Six Big Buttons Background Color',
                defaultColor: '#FFFFFF',
              ),
            const SizedBox(height: 12),
            // Font Sizes
            const Text(
              'Font Sizes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controllers['bigButtonsTextSize']!,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Six Big Buttons Text Size',
                hintText: '24',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.text_fields),
                suffixText: 'px',
                isCollapsed: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controllers['bigButtonsSecondTitleSize']!,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Six Big Buttons Text Size (Subtitle)',
                hintText: '14',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.text_fields),
                suffixText: 'px',
                isCollapsed: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('general_settings'),
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'General Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General UI Section
                _buildGeneralUISection(),
                const SizedBox(height: 16),

                // Queue Information Display Section
                Card(
                  elevation: 0,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF0066CB),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Queue Information Display',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0066CB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (controllers['waitingTimeFontSize'] != null)
                          TextField(
                            controller: controllers['waitingTimeFontSize']!,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Time & Behind Ticket Font Size',
                              hintText: '14',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.text_fields),
                              suffixText: 'px',
                              isCollapsed: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                          ),
                        const SizedBox(height: 16),
                        if (controllers['waitingTimeFontColor'] != null)
                          ColorPickerField(
                            controller: controllers['waitingTimeFontColor']!,
                            label: 'Waiting Time & Behind Ticket Font Color',
                            defaultColor: '#000000',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Branding & Images Section
                Card(
                  elevation: 0,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.branding_watermark,
                              color: Color(0xFF0066CB),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Branding & Images',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0066CB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controllers['logoSize'],
                          decoration: InputDecoration(
                            labelText: 'Logo Size',
                            hintText: '80',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              Icons.photo_size_select_large,
                            ),
                            helperText: 'Adjusts the size of the app\'s logo',
                            isCollapsed: false,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller:
                              controllers['backgroundImageUrl'] ??
                              (controllers['backgroundImageUrl'] =
                                  TextEditingController(
                                    text:
                                        'https://www.fortdigital.com.sg/background1.jpg',
                                  )),
                          decoration: InputDecoration(
                            labelText: 'Background Image',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.image),
                            helperText: 'URL for the background image',
                            isCollapsed: false,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
