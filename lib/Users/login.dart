import 'package:ait_project/utils/textform_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/Navigator/bottomAppBar.dart';
import '/Users/join.dart';
import '../main.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => LogInPageState();
}

class LogInPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String email = "";
  String password = "";
  bool _isFormValid = false;

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: aitNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      onChanged: _updateFormValidity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'AIT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: aitGreen,
                                      fontSize: 50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // 이메일
                            CustomTextField(
                              label: '이메일',
                              autovalidateMode: _autovalidateMode, 
                              onChanged: (value) {
                                email = value;
                              },
                              onSaved: (value) {
                                email = value as String;
                              },
                              validator: (value) {
                                return null;
                              },
                            ),
                            
                            // 비밀번호
                            CustomTextField(
                              label: '비밀번호',
                              autovalidateMode: _autovalidateMode, 
                              obscureText: true,
                              onChanged: (value) {
                                password = value;
                              },
                              onSaved: (value) {
                                password = value as String;
                              },
                              validator: (value) {
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            // 로그인 버튼
                            LogInButton(
                              label: '로그인',
                              onPressed: () async {
                                setState(() {
                                  // 제출 버튼을 누르면 autovalidateMode를 always로 변경
                                  _autovalidateMode = AutovalidateMode.always;
                                });

                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  try {
                                    UserCredential userCredential =
                                        await FirebaseAuth.instance
                                            .signInWithEmailAndPassword(
                                                email: email,
                                                password: password);

                                    if (userCredential.user != null) {
                                      // 로그인 성공
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              BulidBottomAppBar(index: 0),
                                        ),
                                        (route) => false,
                                      );
                                    } else {
                                      // 사용자 정보가 null인 경우
                                      flutterToast("로그인에 실패했습니다. 다시 시도해주세요.");
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      flutterToast("존재하지 않는 사용자입니다.");
                                    } else if (e.code == 'wrong-password') {
                                      flutterToast('비밀번호가 틀렸습니다.');
                                    } else {
                                      flutterToast(
                                          '로그인 중 오류가 발생했습니다: ${e.message}');
                                    }
                                  } catch (e) {
                                    flutterToast('알 수 없는 오류가 발생했습니다.');
                                  }
                                }
                              },
                              backgroundColor:
                                  _isFormValid ? aitGreen : aitGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: mediaHeight(context, 0.15)),
            ],
          ),
        ),
      ),
    );
  }
}

class LogInButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const LogInButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  });

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