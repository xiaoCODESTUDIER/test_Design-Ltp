import 'dart:async';
import 'package:flutter/material.dart';

class CarouselSlider extends StatefulWidget {     // 定义一个可状态管理的轮播图组件
  final List<String> images;
  final double height;
  final double indicatorSize;     // 指示器的大小
  final Color activeIndicatorColor;     // 活动指示器的颜色
  final Color inactiveIndicatorColor;       // 非活动指示器的颜色
  const CarouselSlider({super.key,       // 构造函数，接收必要的参数
    required this.images,
    this.height = 200.0,
    this.indicatorSize = 10.0,
    this.activeIndicatorColor = Colors.blue,
    this.inactiveIndicatorColor = Colors.grey,
  });
  @override
  // ignore: library_private_types_in_public_api
  _CarouselSliderState createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  int _currentPage = 0;   // 当前显示的图片索引
  bool _isHovering = false;    // 检查鼠标悬停
  Timer? _timer;      // 定时器对象
  int nextPage = 0;     // 下一个将要显示的图片索引
  @override
  void initState() {
    super.initState();
    _startAutoPlay();     // 初始化时启动自动轮播
  }

  @override
  void dispose() {
    _cancelAutoPlay();    // 销毁时取消定时任务
    super.dispose();
  }

  void _startAutoPlay() {
    _cancelAutoPlay();      // 取消之前的定时任务
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isHovering) {      // 只有在没有鼠标悬停时才自动播放
        nextPage = (_currentPage + 1) % widget.images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      } else {
        timer.cancel();   // 如果鼠标悬停，取消定时任务
      }
    });
  }
  
  void _cancelAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }
  
  void _onPageHover(int index) {
    setState(() {
      _isHovering = true;
      _currentPage = index;
      nextPage = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageExit() {
    setState(() {
      _isHovering = false;
    });
    _startAutoPlay();     // 鼠标离开后再恢复自动播放
  }
  
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(      // 使用 MouseRegion 监听鼠标进入和离开事件
          onEnter: (_) => _onPageHover(_currentPage),
          onExit: (_) => _onPageExit(),
          child: SizedBox(
            height: nextPage == _currentPage ? widget.height * 1.5 : widget.height,
            child: PageView(
              controller: _pageController,
              children: widget.images.map((imageUrl) => _buildCarouselItem(imageUrl)).toList(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(    // 轮播图指示器
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            return MouseRegion(
              onEnter: (_) => _onPageHover(index),
              onExit: (_) => _onPageExit(),
              child: AnimatedContainer(     // 指示针从小到大效果要用到 AnimatedContainer
                duration: const Duration(milliseconds: 500),
                width: nextPage == index ? widget.indicatorSize * 1.5 : widget.indicatorSize,     // 指示针的大小
                height: nextPage == index ? widget.indicatorSize * 1.5 : widget.indicatorSize,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: nextPage == index ? widget.activeIndicatorColor : widget.inactiveIndicatorColor,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildCarouselItem(String imageUrl) {      // 构建单个轮播图项
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius : BorderRadius.circular(10),
        image: DecorationImage(
          image: imageUrl.startsWith('http') ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
          fit: BoxFit.cover,
        )
      )
    );
  }
}