import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ait_project/main.dart';

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
    super.dispose();
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          )
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          onChanged: _updateFormValidity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                  onChanged: (value) {
                  },
                  onSaved: (value) {
                  },
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
                const Spacer(),
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
                          AuthCredential credential = EmailAuthProvider.credential(
                            email: user.email!, 
                            password: _currentPassword!
                          );
                          await user.reauthenticateWithCredential(credential);
                          
                          // 새 비밀번호로 변경
                          await user.updatePassword(_newPassword!);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('비밀번호가 변경되었습니다.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.red,
                            ),
                          );
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
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final void Function(String) onChanged;
  final void Function(String?) onSaved;
  final String? Function(String?) validator;
  final AutovalidateMode autovalidateMode;
  final TextEditingController controller;

  const CustomTextField({
    Key? key,
    required this.label,
    this.obscureText = false,
    required this.onChanged,
    required this.onSaved,
    required this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: SizedBox(
              child: TextFormField(
                controller: controller,
                autovalidateMode: autovalidateMode,
                obscureText: obscureText,
                onChanged: onChanged,
                onSaved: onSaved,
                validator: validator,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: aitGreen),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: aitGreen),
                  ),
                  errorStyle: TextStyle(
                    color: aitGreen,
                    fontSize: 15,
                    height: 2,
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 10),
                ),
                style: const TextStyle(
                  decorationThickness: 0,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
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