import 'package:flutter/material.dart';
import 'package:test_dirve/main_fuction/mainpage_fuction/map_fuction/listitem_view.dart';
import 'package:test_dirve/login_fuction/login_page.dart';
import 'package:test_dirve/main_fuction/mainpage_fuction/map_fuction/mainmune_page.dart';
import 'package:test_dirve/main_fuction/mainpage_fuction/map_page.dart';
import 'package:test_dirve/main_fuction/mainpage_fuction/search_page.dart';
import 'package:test_dirve/main.dart';
// ignore: library_prefixes
import 'package:test_dirve/fuction/menu_bar.dart' as customBar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LoginPage());
}
class Test1 extends StatelessWidget {
  final String username;
  const Test1({required this.username, super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Test1 Page',
      home: Test1Page(title: '这是第三个页面'),
    );
  }
}
class ListTitle extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback? onTap;
  const ListTitle({super.key, required this.leading, required this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      onTap: onTap,
    );
  }
}
class Test1Page extends StatefulWidget {
  const Test1Page({super.key, required this.title});
  final String title;
  @override
  State<Test1Page> createState() => _Test1Page();
}
class _Test1Page extends State<Test1Page> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // 主页面跳转函数
  void _turnMainPage(){
    // Navigator.of(context) 获取当前 context 对应的 Navigator 示例
    // push() 方法用于向页面栈添加一个新的页面
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MainApp())
    );
  }

  void _turnListItemView(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ListItemView())
    );
  }

  void _turnLoginPage(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginPage())
    );
  }

  void _onItemTapped(int index){
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {

    // 创建按钮列表
    final buttons = [
      customBar.MenuButton(text: '主页面', onPressed: _turnMainPage),
      customBar.MenuButton(text: '列表浏览图', onPressed: _turnListItemView),
      customBar.MenuButton(text: '登出', onPressed: _turnLoginPage),
    ];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: '菜单栏',
            onPressed: (){
              _scaffoldKey.currentState?.openDrawer();
            },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索',
            onPressed: (){
            },
          ),
        ],
      ),
      drawer: customBar.MenuBar(
        buttons: buttons,
      ),
      
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          MapPage(),
          MainMunePage(),
          SearchPage(),
          Center(child: Text('这是个人中心页面')),
        ]
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '个人中心',
          )
        ]
      )
    );
  }
}