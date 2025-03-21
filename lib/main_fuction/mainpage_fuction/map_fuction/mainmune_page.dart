import 'package:flutter/material.dart';
import 'package:test_dirve/fuction/option_selected.dart';
import 'package:test_dirve/SpecialEffect/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';

class MainMunePage extends StatefulWidget {
  const MainMunePage ({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MainMunePageState createState() => _MainMunePageState();
}

class _MainMunePageState extends State<MainMunePage> with SingleTickerProviderStateMixin {
  var selected = '';
  int _selectedIndex = 0;
  int _hoveredSectionIndex = -1;    //  新增状态变量，用于记录当前鼠标悬停的饼图区块
  final List<double> values = [15, 35, 50];
  final List<Color> colors = const [Color.fromARGB(255, 4, 212, 240), Color.fromARGB(255, 245, 165, 17), Colors.red];    //  存储随机颜色
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<double> currentValues = [0, 0, 0];
  bool _isAnimationComplete = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    // final random = Random();    //  随机数
    // for (int i = 0; i < values.length; i++) {
    //   colors.add(Color.fromARGB(      //  随机生成浅蓝色变种颜色并进行存储
    //     255,
    //     135 + random.nextInt(120),
    //     206 + random.nextInt(50),
    //     250 + random.nextInt(6),
    //   ));
    // }
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isAnimationComplete = true;
          });
        }
      });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 多声明一个变量，可以解决连跳的问题
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Row(
        children: [
          Container(      // 左侧导航栏
            width: 200,     // 设置导航栏的宽度
            color: Colors.grey[200],    // 设置导航栏背景颜色
            child: ListView(
              children: [
                _buildNavItem(Icons.play_arrow_outlined, '旅游', 0),
                _buildNavItem(Icons.food_bank_outlined, '美食', 1),
                _buildNavItem(Icons.newspaper_outlined, '趣闻', 2),
                _buildNavItem(Icons.settings_applications, '景点', 3),
                _buildNavItem(Icons.search_outlined, '发现', 4),
                _buildNavItem(Icons.roundabout_left_outlined, '规划', 5),
                _buildNavItem(Icons.back_hand_outlined, '吐槽', 6),
              ]
            )
          ),
          const VerticalDivider(thickness: 1, width: 1),      // 添加垂直分割线
          Expanded(     // 右侧主要内容区域
            child: _buildContent(),
          )
        ]
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {      // 左侧导航栏的方法
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;     // 更新选中的导航项索引
          _isAnimationComplete = false;     // 重置动画完成状态
          _animationController.reset();
          _animationController.forward();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),      // 设置内边距
        color: _selectedIndex == index ? Colors.blue : null,      // 选中时背景颜色为蓝色
        child: Row(
          children: [
            Icon(icon, color: _selectedIndex == index ? Colors.white : Colors.black),     // 选中时图标颜色为白色
            const SizedBox(width: 16),      // 图标和文字之间的间距
            Text(label, style: TextStyle(color: _selectedIndex == index ? Colors.white : Colors.black)),      // 选中时文字颜色为白色
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        
      case 1:
        
      case 2:
        
      case 3:

      case 4:

      case 5:

      case 6:

      default:
        return const Center(
          child: Text('Unknown Page'),
        );
    }
  }
}

