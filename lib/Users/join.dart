// 패키지
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
                      autovalidateMode: _autovalidateMode,  // 처음엔 disabled
                      onChanged: _updateFormValidity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            SizedBox(height: mediaHeight(context, 0.03)),
                        
                            // 타이틀
                            Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // [텍스트] 회원가입
                                    const Text(
                                      '회원가입',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        fontSize: 25,
                                      ),
                                    ),

                                    // [스페이스]
                                    const SizedBox(height: 10),

                                    // [상태바]
                                    Row(
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
                                  ]),
                            ),
                        
                            SizedBox(height: mediaHeight(context, 0.1)),
                        
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
                          
                          UserData userData = UserData(
                            email: email,
                            password: password,
                          );

                          // 에러 발생 여부 체크용 변수
                          bool isError = false; 

                          // 최종적으로 UserData를 처리 (서버로 전송)
                          try {
                            // Firebase Authentication (회원가입 처리)
                            // ignore: unused_local_variable
                            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: userData.email,
                              password: userData.password,
                            );

                          } on FirebaseAuthException catch (e) {
                            // FirebaseAuthException을 통해 발생할 수 있는 예외 처리
                            if (e.code == 'weak-password') {
                              flutterToast('패스워드 보안이 취약합니다.');
                              isError = true;
                            } else if (e.code == 'email-already-in-use') {
                              flutterToast('이미 가입된 이메일 계정입니다.');
                              isError = true;
                            }
                          } catch (e) {
                            print(e);
                          }
                          
                          // 에러가 없을 때만 페이지 이동
                          if (!isError) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JoinBodyPage(userData: userData),
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

// 커스텀 텍스트 필드 위젯
class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final void Function(String) onChanged;
  final void Function(String?) onSaved;
  final String? Function(String?) validator;
  final AutovalidateMode autovalidateMode;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    required this.onChanged,
    required this.onSaved,
    required this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // [텍스트] 라벨
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
        // [텍스트필드] 입력 필드
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: SizedBox(
            child: TextFormField(
              autovalidateMode: autovalidateMode,
              obscureText: obscureText,
              onChanged: onChanged,
              onSaved: onSaved,
              validator: validator,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(width: 3, color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 3, color: aitGreen),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(width: 3, color: Colors.white),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 3, color: aitGreen),
                ),
                errorStyle: TextStyle(
                  color: aitGreen,
                  fontSize: 15,
                  height: 2,
                ),
                contentPadding: const EdgeInsets.only(left: 5, bottom: 10, right: 5),
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
    );
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