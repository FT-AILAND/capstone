import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final bool obscureText;
  final void Function(String) onChanged;
  final void Function(String?) onSaved;
  final String? Function(String?) validator;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final TextEditingController? controller;

  const CustomTextField({
    Key? key,
    required this.label,
    this.initialValue,
    this.obscureText = false,
    required this.onChanged,
    required this.onSaved,
    required this.validator,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.controller,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  Color _borderColor = Colors.white;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _updateBorderColor();
    });
  }

  void _updateBorderColor() {
    setState(() {
      if (_hasError) {
        _borderColor = Colors.red;
      } else if (_focusNode.hasFocus) {
        _borderColor = Colors.green;
      } else {
        _borderColor = Colors.white;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.controller == null ? widget.initialValue : null,
        focusNode: _focusNode,
        autovalidateMode: widget.autovalidateMode,
        obscureText: widget.obscureText,
        onChanged: (value) {
          widget.onChanged(value);
          if (widget.autovalidateMode == AutovalidateMode.onUserInteraction) {
            _validate(value);
          }
        },
        onSaved: widget.onSaved,
        validator: (value) {
          final error = widget.validator(value);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _hasError = error != null;
              _updateBorderColor();
            });
          });
          return error;
        },
        inputFormatters: widget.inputFormatters,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          labelText: widget.label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          filled: true,
          fillColor: Colors.transparent,
          border: _buildBorder(_borderColor),
          enabledBorder: _buildBorder(_borderColor),
          focusedBorder: _buildBorder(_borderColor),
          errorBorder: _buildBorder(Colors.red),
          focusedErrorBorder: _buildBorder(Colors.red),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 15,
            height: 2,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          labelStyle: TextStyle(color: _borderColor, fontSize: 20), 
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  void _validate(String? value) {
    final error = widget.validator(value);
    setState(() {
      _hasError = error != null;
      _updateBorderColor();
    });
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 2, color: color),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
}