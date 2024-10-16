// 패키지
import 'package:ait_project/utils/textform_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// 페이지
import '/Users/joinBody.dart';
import '../main.dart';

// 이메일 정규표현식
final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

// 유저 클래스
class UserData {
  String email;
  String password;
  String? nickname;
  String? height;
  String? weight;

  UserData({
    required this.email,
    required this.password,
    this.nickname,
    this.height,
    this.weight,
  });
}

// 위젯
class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String email = "";
  String password = "";
  String passwordCheck = "";
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
              top: true,
              child: Center(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autovalidateMode, // 처음엔 disabled
                          onChanged: _updateFormValidity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 10,
                            ),
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
                                        percent: 0.5,
                                        backgroundColor: Colors.grey,
                                        progressColor: aitGreen,
                                        barRadius: const Radius.circular(100),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // 이메일 주소
                                CustomTextField(
                                  label: '이메일 주소',
                                  autovalidateMode: _autovalidateMode,
                                  onChanged: (value) {
                                    email = value;
                                  },
                                  onSaved: (value) {
                                    email = value as String;
                                  },
                                  validator: (value) {
                                    int length = value!.length;

                                    if (length < 1) {
                                      return '필수 입력란입니다.';
                                    }

                                    if (length > 0) {
                                      if (!emailRegExp.hasMatch(value)) {
                                        return '유효한 이메일 주소를 입력해주세요';
                                      }
                                    }

                                    return null;
                                  },
                                ),

                                // 비밀번호
                                CustomTextField(
                                  label: '비밀번호',
                                  obscureText: true,
                                  autovalidateMode: _autovalidateMode,
                                  onChanged: (value) {
                                    password = value;
                                  },
                                  onSaved: (value) {
                                    password = value as String;
                                  },
                                  validator: (value) {
                                    int length = value!.length;

                                    if (length < 6) {
                                      return '6자리 이상 입력해주세요.';
                                    }

                                    return null;
                                  },
                                ),

                                // 비밀번호 확인
                                CustomTextField(
                                  label: '비밀번호 확인',
                                  obscureText: true,
                                  autovalidateMode: _autovalidateMode,
                                  onChanged: (value) {
                                    passwordCheck = value;
                                  },
                                  onSaved: (value) {
                                    passwordCheck = value as String;
                                  },
                                  validator: (value) {
                                    if (password != value) {
                                      return '비밀번호가 일치하지 않습니다.';
                                    }

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 추가정보 입력
                    Column(
                      children: [
                        // [버튼] 추가정보 입력
                        InputNextButton(
                          label: '추가정보 입력',
                          onPressed: () async {
                            setState(() {
                              // 제출 버튼을 누르면 autovalidateMode를 always로 변경
                              _autovalidateMode = AutovalidateMode.always;
                            });

                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              // 에러 발생 여부 체크용 변수
                              bool isError = false;

                              UserData userData = UserData(
                                email: email,
                                password: password,
                              );

                              try {
                                // 존재 여부를 확인하기 위해 임의의 잘못된 패스워드를 사용하여 로그인 시도
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: email,
                                  password: 'dummyPasswordThatWillFail',
                                );
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  // 이메일이 존재하지 않음
                                  // isError = false;
                                } else if (e.code == 'wrong-password') {
                                  // 이메일이 존재하지만 잘못된 패스워드
                                  flutterToast('이미 가입된 이메일 계정입니다.');
                                  isError = true;
                                } else {
                                  // 그 외 다른 에러 처리
                                  flutterToast('오류가 발생했습니다: ${e.message}');
                                  print('${e.message}');
                                  isError = true;
                                }
                              }

                              // 에러가 없을 때만 페이지 이동
                              if (!isError) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        JoinBodyPage(userData: userData),
                                  ),
                                );
                              }
                            }
                          },
                          backgroundColor: _isFormValid ? aitGreen : aitGrey,
                        ),

                        // [스페이스]
                        SizedBox(height: mediaHeight(context, 0.03)),
                      ],
                    ),
                  ],
                ),
              )),
        ));
  }
}

// 추가정보 입력 버튼 위젯
class InputNextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const InputNextButton({
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

// Toast 메시지
void flutterToast(_text_toast) {
  Fluttertoast.showToast(
    msg: _text_toast,
    gravity: ToastGravity.BOTTOM,
    fontSize: 20.0,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}
