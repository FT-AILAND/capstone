// 패키지
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 페이지
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
                          
                          const SizedBox(height: 50),
                          
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

                        ],
                      ),
                    ),
                  ),
                ),
              ),

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

                    // 에러 발생 여부 체크용 변수
                    bool isError = false; 
                    
                    try {
                      // ignore: unused_local_variable
                      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: password
                      );

                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        flutterToast("존재하지 않는 사용자입니다.");
                        isError = true;
                      } else if (e.code == 'wrong-password') {
                        flutterToast('비밀번호가 틀렸습니다.');
                        isError = true;
                      }
                    }                  

                    // 에러가 없을 때 홈으로 이동
                    if (!isError) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => BulidBottomAppBar(index: 0),
                        ), (route) => false,
                      );
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
      padding: EdgeInsets.only(top:10, bottom:10),
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
