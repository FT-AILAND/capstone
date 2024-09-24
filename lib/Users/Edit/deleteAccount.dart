
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ait_project/main.dart';
import 'package:ait_project/Users/Edit/editPassword.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({Key? key}) : super(key: key);

  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  String? _currentPassword;
  bool _isFormValid = false;
  String? _errorMessage;
  Timer? _errorTimer;

  late TextEditingController _currentPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: aitNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 24), // 상하 패딩 추가
          content: SizedBox(
            height: 120, // 전체 높이 설정
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 세로 방향으로 균등 배치
              children: [
                const SizedBox(height: 5), 
                const Text(
                  '탈퇴하시겠습니까?',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text('탈퇴하기', style: TextStyle(color: aitGreen, fontSize: 15)),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _deleteAccount();
                      },
                    ),
                    const SizedBox(width: 5), // 버튼 사이 간격 추가
                    TextButton(
                      child: const Text('취소', style: TextStyle(color: Colors.white, fontSize: 15)),
                      onPressed: () {
                        Navigator.of(context).pop(); // 모달 닫기
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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

  Future<void> _deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // 현재 비밀번호 확인
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPassword!
        );
        await user.reauthenticateWithCredential(credential);
        
        // Firestore에서 사용자 문서 삭제
        await _firestore.collection('Users').doc(user.uid).delete();
        
        // 계정 삭제
        await user.delete();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정이 삭제되었습니다.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.white,
          ),
        );
        
        // MyApp() 페이지로 이동
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyApp()),
          (Route<dynamic> route) => false,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'wrong-password') {
            _showErrorMessage('비밀번호가 올바르지 않습니다.');
          } else {
            _showErrorMessage('계정 삭제에 실패했습니다.');
          }
        });
      } catch (e) {
        setState(() {
          _showErrorMessage('오류가 발생했습니다: $e');
        });
      }
    }
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
        title: const Text('회원 탈퇴', 
          style: TextStyle(
            fontSize: 25, 
            color: Colors.white,
            fontWeight: FontWeight.w900,
          )
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.all(10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
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
                      const Spacer(),
                      SignUpButton(
                        label: '탈퇴하기',
                        onPressed: () {
                          setState(() {
                            _autovalidateMode = AutovalidateMode.always;
                          });
                          
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _showDeleteConfirmationDialog();
                          }
                        },
                        backgroundColor: _isFormValid ? aitGreen : Colors.grey,
                      ),
                    ],
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