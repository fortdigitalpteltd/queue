import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class PhoneNumberPage extends StatefulWidget {
  final String serviceTitle;

  const PhoneNumberPage({
    super.key,
    required this.serviceTitle,
  });

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  late DateTime _currentTime;
  late Timer _timer;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    _phoneController.text = '+65';
  }

  @override
  void dispose() {
    _timer.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'Clear') {
        _phoneController.text = '+65';
      } else if (value == 'BACK') {
        if (_phoneController.text.length > 3) {
          _phoneController.text = _phoneController.text.substring(0, _phoneController.text.length - 1);
        }
      } else if (value == 'SUBMIT') {
        if (_phoneController.text.length >= 11) { // +65 + 8 digits
          Navigator.pop(context, _phoneController.text);
        }
      } else {
        if (_phoneController.text.length < 11) { // Limit to 8 digits after +65
          _phoneController.text += value;
        }
      }
    });
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxWidth * 0.9,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _onKeyPressed(number),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return Container(
      height: 50,
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => text == 'SUBMIT' ? _onKeyPressed('SUBMIT') : Navigator.pop(context),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEE, d MMM yyyy HH:mm:ss').format(_currentTime);

    return Scaffold(
      backgroundColor: const Color(0xFF0066CB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo
            Image.asset(
              'assets/images/fd_logo_transparent.png',
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            // Queue Registration Text
            const Text(
              'Queue Registration',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Date and Time
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Mobile Number Text
            const Text(
              'Mobile Number',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Phone Number Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      '+65',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _phoneController.text.substring(3),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton('BACK'),
                  _buildActionButton('SUBMIT'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Number Pad
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: constraints.maxHeight * 0.23,
                            child: Row(children: ['1', '2', '3'].map(_buildNumberButton).toList()),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.23,
                            child: Row(children: ['4', '5', '6'].map(_buildNumberButton).toList()),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.23,
                            child: Row(children: ['7', '8', '9'].map(_buildNumberButton).toList()),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.23,
                            child: Row(children: [
                              _buildNumberButton('Clear'),
                              _buildNumberButton('0'),
                              _buildNumberButton('⌫'),
                            ]),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 