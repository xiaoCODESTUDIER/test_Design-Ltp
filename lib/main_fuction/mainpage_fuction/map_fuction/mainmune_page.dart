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
                _buildNavItem(Icons.home, '首页' ,0),
                _buildNavItem(Icons.show_chart, '数据', 1),
                _buildNavItem(Icons.settings, '设置', 2),
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
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget> [
              const CarouselSlider(
                images: [
                  'assets/image/a.jpg',
                  'assets/image/b.jpg',
                  'assets/image/c.jpg',
                ],
                height: 100.0,
                indicatorSize: 10.0,
                activeIndicatorColor: Colors.blue,
                inactiveIndicatorColor: Colors.grey,
              ),
              const SizedBox(height: 10),
              OptionSelector<String>(            // OptionSelector 组件是已经封装好的了，想要调用则直接导入即可
                options: const ['1','2','3','4'],
                onOptionSelected: (selectedOption) {
                  // 想要更新 selected 的值需要用到 setState() 方法
                  // 在上面需要先声明一个 final 变量来存储 selected 的值
                  setState(() {
                    selected = selectedOption;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text('Select: $selected'),
            ]
          )
        );
      case 1:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('数据分析', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 300,
                        child: Stack(
                          children: [
                            //  动画定位的饼图组件
                            //  当动画完成时，饼图会向右移动100像素
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 500),
                              left: _isAnimationComplete ? 170 : 0,   //  动画完成时，Left 从 0 变为 100
                              top: 0,
                              right: 0,
                              bottom: 0,
                              child: _buildPieChart(),
                            ),
                            //  动画透明度的数据组件
                            //  当动画完成时，数据组件会逐渐显示出来
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: _isAnimationComplete ? 1.0 : 0.0,    // 动画完成时， opacity 从 0 变为 1.0
                              child: Align(
                                alignment: Alignment.centerRight,     // 数据组件对齐到右侧
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),    // 右侧内边距为 10 像素
                                  child: _buildPieChartData(),
                                ),
                              ),
                            ),
                            const Positioned(     //  文字说明
                              left: 0,
                              right: 0,
                              bottom: 0,    //  将文字说明放在底部
                              child: Padding(
                                padding: EdgeInsets.all(8.0),    //  添加内边距
                                child: Text(
                                  '蓝色表示为订单完成（尾款到账），橙色为订单进行中，红色为订单未完成（订单取消）',
                                  textAlign: TextAlign.center,      //  文字居中对齐
                                  style: TextStyle(
                                    fontSize: 9,     //  字体大小
                                    color: Colors.black,    //  字体颜色
                                  ),
                                ),
                              ),
                            ),                          
                          ],
                        ),
                      ),
                    ), //Expanded(child: _buildPieChartData()),])),    // flex 设置为2占全部地方的2份
                    Container(height: 300, width: 1, color: Colors.blue),     // 使用 Container 包裹 VerticalDivider
                    Expanded(flex: 2,child: _buildLineChart()),
                  ]
                ),
                const Divider(thickness: 1, height: 20),    // 图标下方的水平分割线
              ],
            ),
          ),
        );
      case 2:
        return const Center(
          child: Text('设置'),
        );
      default:
        return const Center(
          child: Text('Unknown Page'),
        );
    }
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 300,      //  设置整个图表的高度为 300 像素
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 130),     //  定义第一个数据点，x = 0, y = 100
                const FlSpot(1, 110),     //  定义第二个数据点，x = 1, y = 150
                const FlSpot(2, 197),     //  定义第三个数据点，x = 2, y = 200
                const FlSpot(3, 190),     //  定义第四个数据点，x = 4，y = 250
              ],
              isCurved: false,     //  设置折线为曲线
              color: Colors.blue,     //  设置折现的颜色为蓝色
              barWidth: 2,      //  设置折现的宽度为 2 像素
              belowBarData: BarAreaData(show: false),     //  不显示折现下方的填充区域
            ),
          ],
          titlesData: FlTitlesData(
            show: true,     //  显示图表的标题
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,     //  显示 x 轴的标题
                interval: 1,      //  设置 x 轴的刻度间隔为 1
                getTitlesWidget: (value, titleMeta) {     //  自定义 x 轴标题的生成逻辑
                  switch (value.toInt()) {      //  根据 x 轴的值返回相应的文本
                    case 0:
                      return const Text('2020');      //  x 轴值为 0 时，显示“2020”
                    case 1:
                      return const Text('2021');      //  x 轴值为 1 时，显示“2021”
                    case 2:
                      return const Text('2022');      //  x 轴值为 2 时，显示“2022”
                    case 3:
                      return const Text('2023');      //  x 轴值为 3 时，显示“2023”
                    default:
                      return const Text('');      //  其他情况下不显示标题
                  }
                },
              )
            ),
          ),
        )
      ),
    );
  }

  Widget _buildPieChart() {
    return AnimatedBuilder(
      animation: _animation,     // 监听动画控制器的变化
      builder: (context, child) {
        return AspectRatio(
          aspectRatio: 1.0,     // 保持宽高比为 1：1，确保饼图是圆形
          child: PieChart(
            PieChartData(
              sections: List.generate(values.length, (index) {
                final isTouched = index == _hoveredSectionIndex;    //  判断当前扇区是否被触摸
                final double fontSize = isTouched ? 28 : 19;    //  被触摸的扇区字体大小为25，否则为16
                final double radius = isTouched ? 60 : 50;    //  被触摸的扇区半径为50，否则为40
                final double animatedValue = _animation.value * values[index];    //  计算动画值
                return PieChartSectionData(
                  color: colors[index],     //  扇区的颜色
                  value: animatedValue,     //  扇区的值，根据动画值动态变化
                  title: '${animatedValue.toStringAsFixed(0)}%',
                  radius: radius,     //  扇区的半径
                  titleStyle: TextStyle(
                    fontSize: fontSize,     //  扇区标题的字体大小
                    fontWeight: FontWeight.bold,    //  字体加粗
                    color: const Color(0xffffffff),     //  字体颜色为白色
                  ),
                  showTitle: true,    //  显示扇区标题
                );
              }),
              sectionsSpace: _animation.value * 2,     // 动画控制扇区间距，随着动画值增加而增加
              centerSpaceRadius: 10 + _animation.value * 20,      // 动画控制中心区域半径，随着动画值增加而增加
              borderData: FlBorderData(show: false),      //  不显示饼图边框
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                      _hoveredSectionIndex = -1;    //  如果没有接触到任何扇区，重置 _hoveredSectionIndex 为 -1
                      return;
                    }
                    _hoveredSectionIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            )
          )
        );
      }
    );
  }

  Widget _buildPieChartData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,    //  水平居中对齐所有子组件
      children: [
        for (int i = 0; i < values.length; i++)     //  遍历 values 列表，生成每个数据项的行
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),     //  上下各添加 8.0 的内边距
            child: Row(
              children: [
                Container(
                  width: 20,      //  设置容器宽度为 20
                  height: 30,     //  设置容器高度为 30
                  color: colors[i],     //  使用 colors 列表中的颜色
                ),
                const SizedBox(width: 10),
                if (i == 0) ...[const Text('订单完成')],
                if (i == 1) ...[const Text('订单进行中')],
                if (i == 2) ...[const Text('订单未完成')],
                const SizedBox(width: 10),      //  添加一个宽度为 10 的间隔
                Text('${values[i].toStringAsFixed(0)}%'),     //  显示数值并格式化为百分比
              ],
            ),
          ),
      ],
    );
  }
}

