import 'package:flutter/material.dart';

class SMSNotificationSettings extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;

  const SMSNotificationSettings({
    super.key,
    required this.controllers,
    required this.toggleStates,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('sms_notification_settings'),
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'SMS & Notification Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SMS Configuration Section
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
                            const Icon(Icons.sms, color: Color(0xFF0066CB)),
                            const SizedBox(width: 12),
                            const Text(
                              'SMS Configuration',
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
                          title: const Text('Force ON Mobile Number Field'),
                          value: toggleStates['forceOnMobileNumber'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('forceOnMobileNumber', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Confirmation to Receive SMS Page'),
                          value:
                              toggleStates['confirmationToReceiveSms'] ?? false,
                          onChanged:
                              !toggleStates['forceOnMobileNumber']!
                                  ? (value) => onToggleChanged(
                                    'confirmationToReceiveSms',
                                    value,
                                  )
                                  : null,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (toggleStates['confirmationToReceiveSms'] == true &&
                            !toggleStates['forceOnMobileNumber']!) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                controllers['confirmationSmsTitle']
                                  ?..text =
                                      controllers['confirmationSmsTitle']
                                                  ?.text
                                                  .isEmpty ==
                                              true
                                          ? 'Would you like to be notified via SMS/Call?'
                                          : controllers['confirmationSmsTitle']!
                                              .text,
                            decoration: const InputDecoration(
                              labelText:
                                  'Confirmation to Receive SMS Page Title',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.title),
                              isCollapsed: false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                controllers['confirmationSmsSecondTitle']
                                  ?..text =
                                      controllers['confirmationSmsSecondTitle']
                                                  ?.text
                                                  .isEmpty ==
                                              true
                                          ? 'Not set'
                                          : controllers['confirmationSmsSecondTitle']!
                                              .text,
                            decoration: const InputDecoration(
                              labelText:
                                  'Confirmation to Receive SMS Page Second Title',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.title),
                              isCollapsed: false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                          ),
                        ],
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
