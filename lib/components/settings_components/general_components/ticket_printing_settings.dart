import 'package:flutter/material.dart';

class TicketPrintingSettings extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;

  const TicketPrintingSettings({
    super.key,
    required this.controllers,
    required this.toggleStates,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('ticket_printing_settings'),
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Ticket Printing Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticket Display Section
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
                            const Icon(Icons.receipt, color: Color(0xFF0066CB)),
                            const SizedBox(width: 12),
                            const Text(
                              'Ticket Display',
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
                          title: const Text('Ticket Print Title'),
                          value: toggleStates['ticketPrintTitle'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('ticketPrintTitle', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (toggleStates['ticketPrintTitle'] == true) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                controllers['ticketPrintTitleText']
                                  ?..text =
                                      controllers['ticketPrintTitleText']
                                                  ?.text
                                                  .isEmpty ==
                                              true
                                          ? 'Queue Registration'
                                          : controllers['ticketPrintTitleText']!
                                              .text,
                            decoration: const InputDecoration(
                              labelText: 'Ticket Print Title Label',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.title),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Ticket Print Subtitle'),
                          value: toggleStates['ticketPrintSubtitle'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('ticketPrintSubtitle', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (toggleStates['ticketPrintSubtitle'] == true) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                controllers['ticketPrintSubtitleLabel']
                                  ?..text =
                                      controllers['ticketPrintSubtitleLabel']
                                                  ?.text
                                                  .isEmpty ==
                                              true
                                          ? 'Thank you for your registration. We will notify you via SMS/Call/TV when your turn is up. Thank you.'
                                          : controllers['ticketPrintSubtitleLabel']!
                                              .text,
                            decoration: const InputDecoration(
                              labelText: 'Ticket Print Subtitle Label',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.subject),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ticket Customization Section
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
                              Icons.edit_note,
                              color: Color(0xFF0066CB),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Ticket Customization',
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
                          title: const Text('Ticket Print Footnote'),
                          value: toggleStates['ticketPrintFootnote'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('ticketPrintFootnote', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: const Text('Show Footnote on Tablet'),
                          value: toggleStates['showFootnoteOnTablet'] ?? false,
                          onChanged:
                              (value) => onToggleChanged(
                                'showFootnoteOnTablet',
                                value,
                              ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: const Text('Ticket Print QR Code'),
                          value: toggleStates['ticketPrintQrCode'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('ticketPrintQrCode', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        TextField(
                          controller:
                              controllers['ticketQrCodeUrl']
                                ?..text =
                                    controllers['ticketQrCodeUrl']
                                                ?.text
                                                .isEmpty ==
                                            true
                                        ? 'https://www.fortdigital.com.sg/qrfd.png'
                                        : controllers['ticketQrCodeUrl']!.text,
                          decoration: const InputDecoration(
                            labelText: 'Ticket QR Code Image URL',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.qr_code),
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
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // SMS & Print Options Section
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
                              'SMS & Print Options',
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
                          title: const Text('Ask for SMS or Ticket'),
                          value: toggleStates['askForSmsOrTicket'] ?? false,
                          onChanged:
                              (value) =>
                                  onToggleChanged('askForSmsOrTicket', value),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (toggleStates['askForSmsOrTicket'] == true) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                controllers['smsButtonTitle']
                                  ?..text =
                                      controllers['smsButtonTitle']
                                                  ?.text
                                                  .isEmpty ==
                                              true
                                          ? 'SMS Ticket'
                                          : controllers['smsButtonTitle']!.text,
                            decoration: const InputDecoration(
                              labelText: 'SMS Button Title',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.message),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                controllers['ticketButtonTitle']
                                  ?..text =
                                      controllers['ticketButtonTitle']
                                                  ?.text
                                                  .isEmpty ==
                                              true
                                          ? 'Print Ticket'
                                          : controllers['ticketButtonTitle']!
                                              .text,
                            decoration: const InputDecoration(
                              labelText: 'Ticket Button Title',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.print),
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
