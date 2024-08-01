// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  CustomTextForm({
    Key? key,
    required this.labelText,
    this.validator,
    this.controller,
    this.icon,
    this.isPassword,
    this.focusNode,
    this.maxLines,
  }) : super(key: key);
  final String labelText;
  final TextEditingController? controller;
  final Icon? icon;
  final String? Function(String? val)? validator;
  final bool? isPassword;
  final FocusNode? focusNode;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPassword!,
      controller: controller,
      focusNode: focusNode,
      cursorColor: Colors.transparent,
      validator: validator,
      maxLines: maxLines!,
      decoration: InputDecoration(
        border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        icon: icon,
        labelText: labelText,
      ),
    );
  }
}
