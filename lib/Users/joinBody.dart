// 패키지
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
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          SizedBox(height: mediaHeight(context, 0.03)),
                          
                          // 타이틀
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '회원가입',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 25,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
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

                    // FirebaseFirestore에 회원가입 상세정보 저장
                    // Users 테이블(컬렉션)에 현재 사용자의 uid 문서(doc)로 저장
                    var currentUser = FirebaseAuth.instance.currentUser;
                    var uid = currentUser!.uid;

                    FirebaseFirestore _firestore = FirebaseFirestore.instance;
                    await _firestore.collection("Users").doc(uid).set({
                      "uid" : currentUser.uid,
                      "email": currentUser.email,
                      "nickname": widget.userData.nickname,
                      "height": widget.userData.height,
                      "weight": widget.userData.weight,
                    });

                    // (필요시) child 테이블? 만드는 방법
                    // ex.현재 사용자의 uid를 사용하는 leaderboard_DB 테이블
                    // FirebaseFirestore.instance.collection('leaderboard_DB').doc(uid).set({
                    //   'push_up': 0,
                    //   'squrt': 0,
                    //   'pull_up': 0,
                    //   'score': 0
                    // });

                    // 로그아웃 할 때 다른데에서 쓰기
                    // FirebaseAuth.instance.signOut();
                    // Navigator.pop(context);

                    // 홈으로 이동
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => BulidBottomAppBar(index: 0),
                      ), (route) => false,
                    );

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

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final void Function(String) onChanged;
  final void Function(String?) onSaved;
  final String? Function(String?) validator;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    required this.onChanged,
    required this.onSaved,
    required this.validator,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:10, bottom:10),
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
                autovalidateMode: autovalidateMode,
                obscureText: obscureText,
                onChanged: onChanged,
                onSaved: onSaved,
                validator: validator,
                inputFormatters: inputFormatters,
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
