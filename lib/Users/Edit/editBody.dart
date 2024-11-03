import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ait_project/main.dart';

import '../../utils/textform_field.dart';

class EditBody extends StatefulWidget {
  const EditBody({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditBodyState createState() => _EditBodyState();
}

class _EditBodyState extends State<EditBody> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  String? _nickname;
  String? _height;
  String? _weight;
  bool _isFormValid = false;

  late TextEditingController _nicknameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    // 컨트롤러 초기화
    _nicknameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _nicknameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('Users').doc(user.uid).get();
      setState(() {
        _nickname = doc['nickname'];
        _height = doc['height'].toString(); // double을 String으로 변환
        _weight = doc['weight'].toString(); // double을 String으로 변환

        // 컨트롤러에 값 설정
        _nicknameController.text = _nickname ?? '';
        _heightController.text = _height ?? '';
        _weightController.text = _weight ?? '';
      });
    }
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
        title: const Text('신체 정보 수정',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: '닉네임',
                  controller: _nicknameController,
                  autovalidateMode: _autovalidateMode,
                  onChanged: (value) {
                    _nickname = value;
                  },
                  onSaved: (value) {
                    _nickname = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  label: '신장 (cm)',
                  controller: _heightController,
                  autovalidateMode: _autovalidateMode,
                  onChanged: (value) {
                    _height = value;
                  },
                  onSaved: (value) {
                    _height = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '신장을 입력해주세요.';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                CustomTextField(
                  label: '체중 (kg)',
                  controller: _weightController,
                  autovalidateMode: _autovalidateMode,
                  onChanged: (value) {
                    _weight = value;
                  },
                  onSaved: (value) {
                    _weight = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '체중을 입력해주세요.';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 20), // Added consistent spacing
                SignUpButton(
                  label: '수정하기',
                  onPressed: () async {
                    setState(() {
                      _autovalidateMode = AutovalidateMode.always;
                    });

                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      User? user = _auth.currentUser;
                      if (user != null) {
                        await _firestore
                            .collection("Users")
                            .doc(user.uid)
                            .update({
                          "nickname": _nickname,
                          "height": _height,
                          "weight": _weight,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('정보가 수정되었습니다.',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.white,
                          ),
                        );

                        Navigator.pop(context);
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
