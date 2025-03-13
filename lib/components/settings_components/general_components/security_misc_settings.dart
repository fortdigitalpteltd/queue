import 'package:flutter/material.dart';

class SecurityMiscSettings extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;

  const SecurityMiscSettings({
    super.key,
    required this.controllers,
    required this.toggleStates,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('security_misc_settings'),
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Security & Miscellaneous Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security & Login subsection
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
                              Icons.security,
                              color: Color(0xFF0066CB),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Security & Login',
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
                          controller:
                              controllers['settingLoginPassword']
                                ?..text =
                                    controllers['settingLoginPassword']
                                                ?.text
                                                .isEmpty ==
                                            true
                                        ? '123'
                                        : controllers['settingLoginPassword']!
                                            .text,
                          decoration: const InputDecoration(
                            labelText: 'Setting Password',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.lock),
                            helperText:
                                'Password required for accessing settings',
                            isCollapsed: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Regional Settings subsection
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
                              Icons.language,
                              color: Color(0xFF0066CB),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Regional Settings',
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
                          controller:
                              controllers['defaultCountryCode']
                                ?..text =
                                    controllers['defaultCountryCode']
                                                ?.text
                                                .isEmpty ==
                                            true
                                        ? '65'
                                        : controllers['defaultCountryCode']!
                                            .text,
                          decoration: const InputDecoration(
                            labelText: 'Default Country Code',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.phone),
                            helperText:
                                'Sets the default country code (e.g., 65 for Singapore)',
                            isCollapsed: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Mobile Country Code'),
                          value: toggleStates['mobileCountryCode'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('mobileCountryCode', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: const Text('Force ON Mobile Number Field'),
                          value: toggleStates['forceOnMobileNumber'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('forceOnMobileNumber', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // App Display & Info subsection
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
                              'App Display & Info',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0066CB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Display Date and Time'),
                          value: toggleStates['displayDateTime'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('displayDateTime', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller:
                              controllers['appVersion']
                                ?..text =
                                    controllers['appVersion']?.text.isEmpty ==
                                            true
                                        ? 'BB26'
                                        : controllers['appVersion']!.text,
                          decoration: const InputDecoration(
                            labelText: 'App Version',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.apps),
                            isCollapsed: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          readOnly: true,
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
