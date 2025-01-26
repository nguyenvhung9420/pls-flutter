import 'package:flutter/material.dart';

TextField PLSTextField({
  required TextEditingController controller,
  String labelText = "label",
  String? hintText = "hint",
  required Function(String) onChanged,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onChanged: (String newVal) {
      onChanged(newVal);
    },
  );
}
