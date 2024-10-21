// 패키지
import 'package:ait_project/utils/textform_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// 페이지
import '/Navigator/bottomAppBar.dart';
import '/Users/join.dart';
import '../main.dart';

class JoinBodyPage extends StatefulWidget {
  final UserData userData;

  const JoinBodyPage({super.key, required this.userData});

  @override
  State<JoinBodyPage> createState() => JoinBodyPageState();
}

class JoinBodyPageState extends State<JoinBodyPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String nickname = "";
  String height = "";
  String weight = "";
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
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: true,
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    onChanged: _updateFormValidity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: Column(
                        children: [
                          // 타이틀
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LinearPercentIndicator(
                                  width: 150,
                                  animation: true,
                                  animationDuration: 500,
                                  lineHeight: 5,
                                  percent: 1.0,
                                  backgroundColor: Colors.grey,
                                  progressColor: aitGreen,
                                  barRadius: const Radius.circular(100),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 50),

                          // 닉네임
                          CustomTextField(
                            label: '닉네임',
                            autovalidateMode: _autovalidateMode,
                            onChanged: (value) {
                              nickname = value;
                            },
                            onSaved: (value) {
                              nickname = value as String;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '닉네임을 입력해주세요.';
                              }
                              return null;
                            },
                          ),

                          // 신장
                          CustomTextField(
                            label: '신장 (cm)',
                            autovalidateMode: _autovalidateMode,
                            onChanged: (value) {
                              height = value;
                            },
                            onSaved: (value) {
                              height = value as String;
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

                          // 체중
                          CustomTextField(
                            label: '체중 (kg)',
                            autovalidateMode: _autovalidateMode,
                            onChanged: (value) {
                              weight = value;
                            },
                            onSaved: (value) {
                              weight = value as String;
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 회원가입 버튼
              SignUpButton(
                label: '회원가입',
                onPressed: () async {
                  setState(() {
                    // 제출 버튼을 누르면 autovalidateMode를 always로 변경
                    _autovalidateMode = AutovalidateMode.always;
                  });

                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // 이전 페이지에서 받은 데이터에 추가 데이터를 병합
                    widget.userData.nickname = nickname;
                    widget.userData.height = height;
                    widget.userData.weight = weight;

                    try {
                      // Firebase Authentication에 회원가입 처리
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: widget.userData.email,
                        password: widget.userData.password,
                      );

                      var uid = userCredential.user!.uid;

                      // FirebaseFirestore에 회원 정보 저장
                      FirebaseFirestore firestore = FirebaseFirestore.instance;
                      await firestore.collection("Users").doc(uid).set({
                        "uid": uid,
                        "email": widget.userData.email,
                        "nickname": widget.userData.nickname,
                        "height": widget.userData.height,
                        "weight": widget.userData.weight,
                      }).then((_) {
                        print("사용자 정보가 Firestore에 성공적으로 저장되었습니다.");
                      }).catchError((error) {
                        print("Firestore 저장 중 오류 발생: $error");
                        throw error; // 오류를 다시 던져서 catch 블록에서 처리하도록 합니다.
                      });

                      // 랜덤 문서 id로 Goal테이블에 문서 추가
                      // FirebaseFirestore.instance.collection('Goal').doc(uid).set({
                      //   'uid' : uid,
                      //   'push_up': 0,
                      //   'squat': 0,
                      //   'pull_up': 0,
                      // });

                      // child 테이블? 만드는 방법
                      // 현재 사용자의 uid를 문서id로 사용하는 Goal 테이블
                      FirebaseFirestore.instance
                          .collection('Goal')
                          .doc(uid)
                          .set({
                        'uid': uid,
                        'push_up': 0,
                        'squat': 0,
                        'pull_up': 0,
                      });

                      //홈으로 이동
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              BulidBottomAppBar(index: 0),
                        ),
                        (route) => false,
                      );
                    } on FirebaseAuthException catch (e) {
                      // FirebaseAuthException을 통해 발생할 수 있는 예외 처리
                      if (e.code == 'weak-password') {
                        flutterToast('패스워드 보안이 취약합니다.');
                      } else if (e.code == 'email-already-in-use') {
                        flutterToast('이미 가입된 이메일 계정입니다.');
                      } else {
                        flutterToast('오류가 발생했습니다: ${e.message}');
                      }
                    } catch (e) {
                      print('오류: $e');
                    }
                  }
                },
                backgroundColor: _isFormValid ? aitGreen : aitGrey,
              ),

              SizedBox(height: mediaHeight(context, 0.03)),
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
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
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
      ),
    );
  }
}
