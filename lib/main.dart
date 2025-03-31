import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/admin_center_page/admin_center_page.dart';
import 'package:test_dirve/login_fuction/login_page.dart';
import 'package:test_dirve/providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const LoginPage(),
    )
  );
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('页面未找到')),
          body: const Center(child: Text('您访问的页面不存在')),
        ));
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 183, 100)),
        useMaterial3: true,
      ),
    );
  }
}