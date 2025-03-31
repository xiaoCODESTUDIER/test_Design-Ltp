// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:test_dirve/Service/classmodel_service.dart';
import 'package:test_dirve/edit_page_fuction/edit_page.dart';

class MainMunePage extends StatefulWidget {
  const MainMunePage ({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MainMunePageState createState() => _MainMunePageState();
}

class _MainMunePageState extends State<MainMunePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;  //  新增状态变量
  late AnimationController _animationController;
  List<classModel> _posts = [];  // 存储从后端获取的帖子数据
  final classmodel_service _classModelService = classmodel_service();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _loadPost((_selectedIndex + 1).toString());
  }

  Future<void> _loadPost(String themeValue) async {
    try {
      final posts = await _classModelService.queryManuClassModel(themeValue);
      setState(() {
        _posts = posts;   // 更新数据
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditPage(),
            )
          );
          // 如果返回结果不为空，刷新页面
          if (result != null) {
            final title = result['title'];
            final content = result['content'];
            final theme = result['theme'];

            // 创建 classModel 对象
            final classModel newClass = classModel(
              title: title,
              content: content,
              x: 0,
              y: 0,
              eyes: 0,
              contentsnum: 0,
              contents: [],
              useid: '默认用户名', // 这里假设用户ID为默认用户名，可以根据实际情况调整
              contentid: '',
              goodsid: '',
              goods: [],
              goodsnum: 0,
              badsnum: 0,
              thamed: theme.toString(),
              createDate: DateTime.now(), 
              userName: '默认用户名', // 这里假设用户名为默认用户名，可以根据实际情况调整
              imageUrl: null,
            );

            // 调用 addClassModel 方法
            await _classModelService.addClassModel(newClass);

            // 重新加载数据
            _loadPost(theme.toString());
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      )
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {      // 左侧导航栏的方法
    return InkWell(
      onTap: () async {
        setState(() {
          _selectedIndex = index;     // 更新选中的导航项索引
          _animationController.reset();
          _animationController.forward();
        });

        // 根据选中的主题调用后端接口
        final themeValue = (index + 1).toString();  // 将索引转换为主题值
        try {
          final posts = await _classModelService.queryManuClassModel(themeValue);
          setState(() {
            _posts = posts;  // 更新数据
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('加载失败: $e')),
          );
        }
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
    if (_posts.isEmpty) {
      return const Center(
        child: Text('暂无帖子'),
      );
    }

    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return ListTile(
          title: Text(post.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.content.length > 55 ? '${post.content.substring(0, 55)}...}' : post.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(post.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                ]
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: post.avatarUrl != null && post.avatarUrl!.isNotEmpty
                      ? NetworkImage(post.avatarUrl!) as ImageProvider
                      : const AssetImage('image/default_avatar.png'),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        const TextSpan(
                          text: '发起者: '
                        ),
                        TextSpan(
                          text: '@${post.userName}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextSpan(
                          text: '查看数: ${post.eyes}, 讨论数: ${post.contentsnum}, 点赞数：${post.goodsnum}, 点踩数：${post.badsnum},'
                        )
                      ]
                    )
                  ),
                ]
              ),
            ]
          )
        );
      }
    );
  }
}

