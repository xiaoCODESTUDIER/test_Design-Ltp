// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:test_dirve/config.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final userNameEditor = TextEditingController();
  final emailEditor = TextEditingController();
  final emailCheckCodeEditor = TextEditingController();
  final passwordEditor = TextEditingController();
  final confirmPasswordEditor = TextEditingController();
  final phoneEditor = TextEditingController();
  // 新增变量用于存储用户名错误信息
  String? _usernameErrorText;
  String? _emailCheckCodeErrorText;
  bool _isEmailRegistration = false;
  // 跟踪验证码是否已发送
  bool _isVerificationCodeSent = false;
  Timer? _timer;
  int _start = 60;
  String _countdownText = '发送验证码';

  @override
  void dispose() {
    userNameEditor.dispose();
    passwordEditor.dispose();
    emailEditor.dispose();
    emailCheckCodeEditor.dispose();
    confirmPasswordEditor.dispose();
    phoneEditor.dispose();
    _timer?.cancel();
    super.dispose();
  }
  void _toggleRegistrationMethod(bool isEmailRegistration) {
    setState(() {
      _isEmailRegistration = isEmailRegistration;
      userNameEditor.clear();
      emailEditor.clear();
      emailCheckCodeEditor.clear();
      passwordEditor.clear();
      confirmPasswordEditor.clear();
      phoneEditor.clear();
      _usernameErrorText = null;
      _emailCheckCodeErrorText = null;
      // 重置验证码发送状态
      _isVerificationCodeSent = false;
      // 重置表单状态
      _formKey.currentState?.reset();
      // 重置倒计时
      _restCountdown();
    });
  }
  // void _clearFields() {
  //   userNameEditor.clear();
  //   emailEditor.clear();
  //   emailCheckCodeEditor.clear();
  //   passwordEditor.clear();
  //   confirmPasswordEditor.clear();
  //   phoneEditor.clear();
  // }

  void _restCountdown() {
    _start = 60;
    _countdownText = '发送验证码';
    _timer?.cancel();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _countdownText = '发送验证码';
          _isVerificationCodeSent = false;
        });
      } else {
        setState(() {
          _start--;
          _countdownText = '$_start秒后重新发送..';
        });
      }
    });
  }
  // 验证邮箱码是否正确,并且发送验证码和接收验证码
  Future<void> _sendVerificationCode() async {
    if (emailEditor.text.isNotEmpty && validateEmail(emailEditor.text) == null) {
      final url = Uri.parse('${AppConfig.baseUrl}/useLogin/sendVerificationCode');
      final body = jsonEncode({'email': emailEditor.text,});
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证码已发送')),);
          setState(() {
            // 如果验证码已发送就设置为true
            _isVerificationCodeSent = true;
            _startCountdown();  // 启动计时器
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送验证码失败: ${response.statusCode}')),);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送验证码失败: $e')),);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入有效的邮箱')));
    }
  }

  // 检查验证码是否正确
  Future<void> _checkVerificationCode() async {
  if (emailCheckCodeEditor.text.isNotEmpty) {
    final url = Uri.parse('${AppConfig.baseUrl}/useLogin/verifyVerificationCode');
    final body = jsonEncode({
      'email': emailEditor.text,
      'verificationCode': emailCheckCodeEditor.text,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证码正确')),);
        // 你可以在这里重置验证码发送状态或其他操作
        setState(() {
          _isVerificationCodeSent = false; // 重置验证码发送状态
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('验证码错误: ${response.statusCode}')),);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('验证码验证失败: $e')),);
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入邮箱验证码')),);
  }
}

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_isVerificationCodeSent) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先发送并验证验证码')),);
        return;
      }
      final url = Uri.parse('${AppConfig.baseUrl}/useLogin');
      final body = jsonEncode({
        'name': userNameEditor.text,
        'password': passwordEditor.text,
        'phoneNum': phoneEditor.text,
        'email': emailEditor.text,
        'emailCheckCode': emailCheckCodeEditor.text,
      });
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        if (response.statusCode == 200 && response.body != "该用户名已被注册！") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('注册成功')),);
          Navigator.of(context).pop();
        } else {
          if (response.body == "该用户名已被注册！") {
            setState(() {
              _usernameErrorText = "该用户名已被注册";
            });
          } else if (response.body == "验证码错误！") {
            setState(() {
              _emailCheckCodeErrorText = "验证码错误";
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('注册失败: ${response.statusCode}')),);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('注册失败：$e')),);
      }
    }
  }
  // 检查邮箱格式
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty)  return '请输入邮箱';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value))  return '请输入有效的邮箱地址';
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册页面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: _isEmailRegistration == false ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _toggleRegistrationMethod(false);
                    },
                    child: const Text('手机号注册'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: _isEmailRegistration == true ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _toggleRegistrationMethod(true);
                    },
                    child: const Text('邮箱注册'),
                  ),
                ],
              ),
              Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _isEmailRegistration ? Column(
                        children: [
                          TextFormField(
                            controller: userNameEditor,
                            decoration: InputDecoration(
                              labelText: '用户名',
                              errorText: _usernameErrorText,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入用户名';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: emailEditor,
                                  decoration: const InputDecoration(labelText: '注册邮箱'),
                                  validator: validateEmail,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 22),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                onPressed: _isVerificationCodeSent ? null : _sendVerificationCode,
                                child: Text(_countdownText),
                              ),
                            ]
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: emailCheckCodeEditor,
                                  decoration: InputDecoration(
                                    labelText: '邮箱验证码', 
                                    errorText: _emailCheckCodeErrorText
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入邮箱验证码';
                                    }
                                    if (value.length != 6) {
                                      return '请输入有效的邮箱验证码';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 22),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                // 根据状态来启用或者禁用按钮
                                onPressed: _isVerificationCodeSent ? _checkVerificationCode : null,
                                child: const Text('检查验证码'),
                              ),
                            ]
                          )
                        ]
                      ) :
                      TextFormField(
                        controller: userNameEditor,
                        decoration: InputDecoration(
                          labelText: '用户名',
                          errorText: _usernameErrorText,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: phoneEditor,
                        decoration: const InputDecoration(labelText: '手机号'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入手机号';
                          }
                          return null;
                        }
                      ),
                      TextFormField(
                        controller: passwordEditor,
                        decoration: const InputDecoration(labelText: '密码'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: confirmPasswordEditor,
                        decoration: const InputDecoration(labelText: '确认密码'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请确认密码';
                          }
                          if (value != passwordEditor.text) {
                            return '密码不匹配';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        child: const Text('注册'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('已有账号？'),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('登录', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                          )
                        ]
                      )
                    ]
                  )
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}