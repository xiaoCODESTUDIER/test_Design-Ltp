// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/Service/page_post_service.dart';
import 'package:test_dirve/admin_center_page/admin_center_page.dart';
import 'package:test_dirve/login_fuction/login_page.dart';
import 'package:test_dirve/providers/user_provider.dart';

class UserCenterPage extends StatefulWidget{
  const UserCenterPage({Key? key});

  @override
  _UserCenterPageState createState() => _UserCenterPageState();
}

class _UserCenterPageState extends State<UserCenterPage>{
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final PagePostService _pagePostService = PagePostService();
  String? _avatarUrl;
  String? userId;
  String? _selectedOption;

    @override 
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).user ?? '默认用户名';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAvatar() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择一张图片')),
      );
      return;
    }
    try {
      final avatarUrl = await _pagePostService.uploadAvatar(_image!, userId!);
      setState(() {
        _avatarUrl = avatarUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像上传成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像上传失败')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户中心'),
        actions: [
          TextButton(
            onPressed: () {
              // 导航到管理员页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPage(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0), // 设置为长方形
              ),
            ),
            child: const Text('管理员页面'),
          ),
        ],
      ),
       body: Row(
        children: [
          // 左侧菜单栏
          Container(
            width: 200, // 设置左侧菜单栏的宽度
            color: Colors.grey[200], // 设置左侧菜单栏背景颜色
            child: ListView(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatarUrl != null
                    ? NetworkImage(_avatarUrl!) as ImageProvider
                    : const AssetImage('image/default_avatar.png'),
                ),
                const SizedBox(height: 10),
                // 用户名部分
                Text(
                  userId ?? '默认用户名',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // 选择图片按钮
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('选择图片'),
                  onTap: _pickImage,
                ),
                // 编辑个人资料按钮
                ListTile(
                 leading: const Icon(Icons.edit),
                  title: const Text('编辑个人资料'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'edit_profile';
                    });
                    // 导航到编辑个人资料页面
                    Navigator.pushNamed(context, '/edit_profile');
                  },
                  selected: _selectedOption == 'edit_profile',
                  selectedTileColor: Colors.blue,
                  selectedColor: Colors.blue,
                ),
                // 查看发布内容按钮
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('我的帖子'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'my_posts';
                    });
                    // 导航到发布内容页面
                    Navigator.pushNamed(context, '/my_posts');
                  },
                  selected: _selectedOption == 'my_posts',
                  selectedTileColor: Colors.blue,
                  selectedColor: Colors.blue,
                ),
                // 收藏内容按钮
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('收藏'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'favorites';
                    });
                    // 导航到收藏内容页面
                    Navigator.pushNamed(context, '/favorites');
                  },
                  selected: _selectedOption == 'favorites',
                  selectedColor: Colors.blue,
                ),
                // 关注用户按钮
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('关注'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'following';
                    });
                    // 导航到关注用户页面
                    Navigator.pushNamed(context, '/following');
                  },
                  selected: _selectedOption == 'following',
                  selectedTileColor: Colors.blue,
                  selectedColor: Colors.blue,
                ),
                // 设置和隐私按钮
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('设置和隐私'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'settings';
                    });
                    // 导航到设置和隐私页面
                    Navigator.pushNamed(context, '/settings');
                  },
                  selected: _selectedOption == 'settings',
                  selectedTileColor: Colors.blue,
                  selectedColor: Colors.blue,
                ),
                // 退出登录按钮
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('退出登录'),
                  onTap: () {
                    // 处理退出登录逻辑
                    // Provider.of<UserProvider>(context, listen: false).logout();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1), // 添加垂直分割线
          // 右侧主要内容区域
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('右侧主要内容区域'),
                  // 在这里添加右侧的具体内容
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}