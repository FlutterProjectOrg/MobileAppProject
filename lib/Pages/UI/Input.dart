import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool enabled;
  final bool isInvalid;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? initialValue;
  final bool obscureText;

  const Input({
    Key? key,
    this.controller,
    this.placeholder,
    this.enabled = true,
    this.isInvalid = false,
    this.keyboardType,
    this.onChanged,
    this.initialValue,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: placeholder,
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isInvalid ? Colors.red : Colors.grey,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isInvalid ? Colors.red : Colors.blue,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey[500],
        fontSize: 16,
      ),
    );
  }
}
