// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:test_dirve/main_fuction/test1.dart';
void main(){
  runApp(const ListItemView());
}
class ListItemView extends StatelessWidget{
  const ListItemView({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListItemView',
      home: const ListItemViewPage(title: '列表视图'),
      routes: {
        '/test2': (context) => const Test1(username: '',),
      },
    );
  }
}
class ListItemViewPage extends StatefulWidget{
  final String title;
  const ListItemViewPage({super.key, required this.title});
  @override
  State<ListItemViewPage> createState() => _ListItemViewPageState();
}
class _ListItemViewPageState extends State<ListItemViewPage> {
  void _backTest1Page(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Test1(username: '',))
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '返回',
          onPressed: _backTest1Page,
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('heyheyhey'),
          ]
        )
      )
    );
  }
}