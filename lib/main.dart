import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 183, 100)),
        useMaterial3: true,
      ),
    );
  }
}