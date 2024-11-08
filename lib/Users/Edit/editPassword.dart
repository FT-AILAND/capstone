import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:ait_project/main.dart';

import '../../utils/textform_field.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({Key? key}) : super(key: key);

  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  String? _currentPassword;
  String? _newPassword;
  bool _isFormValid = false;
  String? _errorMessage;
  Timer? _errorTimer;

  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF3D3F5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D3F5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('비밀번호 변경',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: [
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  color: Colors.red,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode,
                  onChanged: _updateFormValidity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: '현재 비밀번호',
                        controller: _currentPasswordController,
                        obscureText: true,
                        autovalidateMode: _autovalidateMode,
                        onChanged: (value) {
                          _currentPassword = value;
                        },
                        onSaved: (value) {
                          _currentPassword = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '현재 비밀번호를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: '새 비밀번호',
                        controller: _newPasswordController,
                        obscureText: true,
                        autovalidateMode: _autovalidateMode,
                        onChanged: (value) {
                          _newPassword = value;
                        },
                        onSaved: (value) {
                          _newPassword = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '새 비밀번호를 입력해주세요.';
                          }
                          if (value.length < 6) {
                            return '비밀번호는 6자리 이상이어야 합니다.';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: '새 비밀번호 확인',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        autovalidateMode: _autovalidateMode,
                        onChanged: (value) {},
                        onSaved: (value) {},
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '새 비밀번호 확인을 입력해주세요.';
                          }
                          if (value != _newPasswordController.text) {
                            return '새 비밀번호와 일치하지 않습니다.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                          height: 20), // Add some space before the button
                      SignUpButton(
                        label: '비밀번호 변경',
                        onPressed: () async {
                          setState(() {
                            _autovalidateMode = AutovalidateMode.always;
                          });

                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            User? user = _auth.currentUser;
                            if (user != null) {
                              try {
                                // 현재 비밀번호 확인
                                AuthCredential credential =
                                    EmailAuthProvider.credential(
                                  email: user.email!,
                                  password: _currentPassword!,
                                );
                                await user
                                    .reauthenticateWithCredential(credential);

                                // 새 비밀번호로 변경
                                await user.updatePassword(_newPassword!);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('비밀번호가 변경되었습니다.',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.white,
                                  ),
                                );

                                Navigator.pop(context);
                              } on FirebaseAuthException catch (e) {
                                String errorMessage = '비밀번호 변경에 실패했습니다.';
                                if (e.code == 'wrong-password') {
                                  errorMessage = '현재 비밀번호가 올바르지 않습니다.';
                                }
                                _showErrorMessage(errorMessage);
                              }
                            }
                          }
                        },
                        backgroundColor: _isFormValid ? aitGreen : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const SignUpButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
