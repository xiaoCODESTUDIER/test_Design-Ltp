import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/config.dart';
import 'package:test_dirve/login_fuction/register_page.dart';
import 'package:test_dirve/main_fuction/test1.dart';
import 'package:test_dirve/providers/user_provider.dart';

void main() async{
  runApp(
    const LoginPage()
  );
}
class LoginPage extends StatelessWidget{
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'LoginPage-登录页面',
      home: LoginPageHome(title: 'LoginPage-登录页面'),
    );
  }
}
class LoginPageHome extends StatefulWidget{
  const LoginPageHome({super.key, required this.title});
  final String title;

  @override
  State<LoginPageHome> createState() => _LoginPageHome();
}
class _LoginPageHome extends State<LoginPageHome>{
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  void onLoginPressed() async {
    String userName = _userNameController.text;
    String password = _passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('用户名或密码不能为空'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/useLogin/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': userName,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        String username = responseBody['message'];
        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false).setUser(username);
        _turnInMainPage(username);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('账户或者密码不正确，请重新输入'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  void onRsgisterPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }
  void _turnInMainPage(String username) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (contexy) => Test1(username: username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showImage = screenWidth > 600;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.menu_sharp),
          tooltip: '菜单栏',
          onPressed: () {},
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          final containerWidth = (isSmallScreen ? constraints.maxWidth * 0.9 : 900).toDouble();
          final containerHeight = (isSmallScreen ? constraints.maxHeight * 0.9 : 600).toDouble();
          return DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/menupag.jpeg'),
                fit: BoxFit.cover,
              )
            ),
            child: Center(
              child: Form(
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 212, 202, 202).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (showImage) ...[
                              Expanded(
                                flex: 1,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/image/menupag2.jpeg',
                                      fit: BoxFit.cover,
                                      color: const Color.fromARGB(255, 207, 207, 207).withOpacity(0.4),
                                      colorBlendMode: BlendMode.srcOver,
                                    ),
                                  ],
                                )
                              ),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      controller: _userNameController,
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: '用户名-UserName',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '请填写相关信息';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox( height: 10,),
                                  SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        border: const UnderlineInputBorder(),
                                        labelText: '密码    -Password',
                                        suffixIcon: IconButton(
                                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible = !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: _isPasswordVisible,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '请填写密码';
                                        }
                                        return null;
                                      }
                                    )
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: onLoginPressed,
                                        child: const Text('登录'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: onRsgisterPressed,
                                        child: const Text('注册'),
                                      )
                                    ]
                                  ),
                                ]
                              )
                            )
                          ]
                        ),
                      ],
                    ),
                  )
                )
              )
            )
          );
        },
      )
    );
  }
}
