import 'package:flutter/material.dart';

class QueueSystemSettings extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;

  const QueueSystemSettings({
    super.key,
    required this.controllers,
    required this.toggleStates,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('queue_system_settings'),
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Queue System Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Selection subsection
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
                              Icons.settings,
                              color: Color(0xFF0066CB),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Service Selection',
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
                          controller: controllers['selectServiceTitle'],
                          decoration: InputDecoration(
                            labelText: 'Select Service Title',
                            hintText: 'Select Service',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.title),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.touch_app,
                              color: Color(0xFF0066CB),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Total Service Buttons to Activate',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            activeTrackColor: const Color(0xFF0066CB),
                            inactiveTrackColor: Colors.grey.shade200,
                            thumbColor: const Color(0xFF0066CB),
                            overlayColor: const Color(
                              0xFF0066CB,
                            ).withOpacity(0.12),
                          ),
                          child: Column(
                            children: [
                              Slider(
                                value:
                                    double.tryParse(
                                      controllers['totalActivatedButtons']
                                              ?.text ??
                                          '1',
                                    ) ??
                                    1,
                                min: 1,
                                max: 6,
                                divisions: 5,
                                label:
                                    controllers['totalActivatedButtons']
                                        ?.text ??
                                    '1',
                                onChanged: (value) {
                                  final numberOfButtons = value.toInt();
                                  controllers['totalActivatedButtons']?.text =
                                      numberOfButtons.toString();

                                  // Enable or disable buttons based on the slider value
                                  for (int i = 1; i <= 6; i++) {
                                    if (i <= numberOfButtons) {
                                      if (controllers['buttonFirstTitle$i']
                                              ?.text
                                              .isEmpty ==
                                          true) {
                                        controllers['buttonFirstTitle$i']
                                            ?.text = 'Button $i';
                                      }
                                    } else {
                                      controllers['buttonFirstTitle$i']?.text =
                                          '';
                                      controllers['buttonSecondTitle$i']?.text =
                                          '';
                                      controllers['buttonServiceDestination$i']
                                          ?.text = '';
                                      controllers['buttonLogo$i']?.text = '';
                                      onToggleChanged(
                                        'buttonShowWaitingTime$i',
                                        false,
                                      );
                                      onToggleChanged(
                                        'buttonShowTicketBehind$i',
                                        false,
                                      );
                                      onToggleChanged(
                                        'buttonConvertToDropDown$i',
                                        false,
                                      );
                                      onToggleChanged(
                                        'buttonMissedQueueReActivation$i',
                                        false,
                                      );
                                    }
                                  }
                                },
                              ),
                              Text(
                                '${controllers['totalActivatedButtons']?.text ?? '1'} button(s) activated',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Switch to Round Button'),
                          value: toggleStates['roundButton'] ?? false,
                          onChanged:
                              (value) => onToggleChanged('roundButton', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Queue Management subsection
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
                            const Icon(Icons.queue, color: Color(0xFF0066CB)),
                            const SizedBox(width: 12),
                            const Text(
                              'Queue Management',
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
                          controller: controllers['reActivationLabel'],
                          decoration: InputDecoration(
                            labelText: 'Re-Activate Missed Queue Prompt',
                            hintText: 'Key In Your Queue Number',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.refresh),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('After Registration Button'),
                          value:
                              toggleStates['afterRegistrationButton'] ?? false,
                          onChanged:
                              (value) => onToggleChanged(
                                'afterRegistrationButton',
                                value,
                              ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (toggleStates['afterRegistrationButton'] ==
                            true) ...[
                          TextField(
                            controller:
                                controllers['afterRegistrationButtonText']
                                  ?..text =
                                      controllers['afterRegistrationButtonText']
                                                  ?.text
                                                  .isEmpty ==
                                              true
                                          ? 'New Registration'
                                          : controllers['afterRegistrationButtonText']!
                                              .text,
                            decoration: InputDecoration(
                              labelText: 'After Registration Button Text',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.text_fields),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text(
                              'Display Waiting Time After Registration',
                            ),
                            value:
                                toggleStates['afterRegistrationDisplayWaitingTime'] ??
                                false,
                            onChanged:
                                (value) => onToggleChanged(
                                  'afterRegistrationDisplayWaitingTime',
                                  value,
                                ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                controllers['afterRegisterText']
                                  ?..text =
                                      controllers['afterRegisterText']
                                                  ?.text
                                                  .isEmpty ==
                                              true
                                          ? 'Your Queue Number is'
                                          : controllers['afterRegisterText']!
                                              .text,
                            decoration: InputDecoration(
                              labelText: 'After Register Text',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.text_fields),
                            ),
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
