// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/Service/classmodel_service.dart';
import 'package:test_dirve/Service/page_post_service.dart';
import 'package:test_dirve/Service/user_post_service.dart';
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
  UserModel? _user;
  List<classModel>? _classList;
  final Set<int> _selectedRows = Set<int>();

    @override 
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).user ?? '默认用户名';
    _fetchUserData();
    _fetchClassData();
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

  Future<void> _fetchUserData() async {
    try {
      final userPostService = UserPostService();
      final userModel = await userPostService.queryUser(userId ?? ''); // 使用 userId 查询用户
      if (userModel != null) {
        setState(() {
          _user = userModel; // 更新用户数据
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取用户信息失败：$e')),
      );
    }
    
  }

  Future<void> _fetchClassData() async {
    try {
      final userPostService = UserPostService();
      final classModel = await userPostService.queryClass(userId ?? ''); // 使用 userId 查询用户
      setState(() {
        _classList = classModel;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取帖子数据失败: $e')),
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
                    : const AssetImage('image/default_avatar.png')
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
                  title: const Text(''),
                  onTap: _pickImage,
                ),
                // 编辑个人资料按钮
                ListTile(
                 leading: const Icon(Icons.edit),
                  title: const Text('查看个人资料'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'view_profile';
                    });
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
          Expanded(
            child: _selectedOption == 'view_profile'
                    ? _buildProfileContent()
                    : _selectedOption == 'my_posts'
                      ? _buildPostTable()
                      : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_circle, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text('请选择左侧菜单项查看内容', 
                            style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  color: const Color.fromARGB(255, 253, 246, 246),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blue container with 90, stars, and detection button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.blue,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Large number 90 on the left
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(9.0),
                              ),
                              child: const Text(
                                '90',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Stars and text on the right
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row for the stars
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.white, size: 13),
                                      SizedBox(width: 4),
                                      Icon(Icons.star, color: Colors.white, size: 13),
                                      SizedBox(width: 4),
                                      Icon(Icons.star, color: Colors.white, size: 13),
                                      SizedBox(width: 4),
                                      Icon(Icons.star, color: Colors.white, size: 13),
                                      SizedBox(width: 4),
                                      Icon(Icons.star_border, color: Colors.white, size: 13),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  // Text below stars
                                  Text(
                                    '账号安全状况较好，请继续维护',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Detection button on the far right with a white border
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Add detection logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.blue, 
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 0, // Remove button elevation
                                ),
                                child: const Text('检测'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Login protection button below the blue container
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 253, 246, 246),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add login protection logic here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.blue, 
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 50.0),
                                          elevation: 0, // Remove button elevation
                                        ),
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('我的登录保护', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 3),
                                            Text('建议开启登录保护..', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            SizedBox(height: 3),
                                            Text('去开启 >', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                                const SizedBox(width: 10), // Spacing between buttons
                                Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add login protection logic here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.blue, 
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 50.0),
                                          elevation: 0, // Remove button elevation
                                        ),
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('我的绑定手机', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 3),
                                            Text('手机已绑定，账号..', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            SizedBox(height: 3),
                                            Text('去查看 >', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                                const SizedBox(width: 10), // Spacing between buttons
                                Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add login protection logic here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.blue, 
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 50.0),
                                          elevation: 0, // Remove button elevation
                                        ),
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('我的身份认证', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 3),
                                            Text('身份信息已完善，..', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            SizedBox(height: 3),
                                            Text('已认证 >', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                                const SizedBox(width: 10), // Spacing between buttons
                                Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add login protection logic here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.blue, 
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 50.0),
                                          elevation: 0, // Remove button elevation
                                        ),
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('我的账号密码', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 3),
                                            Text('密码已设置，账号..', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            SizedBox(height: 3),
                                            Text('已设置 >', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                                const SizedBox(width: 10), // Spacing between buttons
                                Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add login protection logic here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.blue, 
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 50.0),
                                          elevation: 0, // Remove button elevation
                                        ),
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('我的用户名', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 3),
                                            Text('用户名已设置，可..', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            SizedBox(height: 3),
                                            Text('已设置 >', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  color: const Color.fromARGB(255, 253, 246, 246),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // First Container with Login Records
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 253, 246, 246),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '登录记录',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: IntrinsicWidth(
                                      child: DataTable(
                                        columns: const <DataColumn>[
                                          DataColumn(label: Text('登录方式')),
                                          DataColumn(label: Text('设备名称')),
                                          DataColumn(label: Text('系统')),
                                          DataColumn(label: Text('登录时间')),
                                        ],
                                        rows: const <DataRow>[
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text('密码登录')),
                                              DataCell(Text('iPhone 12')),
                                              DataCell(Text('iOS 15')),
                                              DataCell(Text('2024-4-01 10:00')),
                                            ],
                                          ),
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text('指纹登录')),
                                              DataCell(Text('Samsung Galaxy S21')),
                                              DataCell(Text('Android 12')),
                                              DataCell(Text('2024-3-12 14:30')),
                                            ],
                                          ),
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text('密码登录')),
                                              DataCell(Text('MacBook Pro')),
                                              DataCell(Text('macOS Monterey')),
                                              DataCell(Text('2023-10-03 09:15')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10), // Spacing between containers
                          // Second Container with Login Records (if needed)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 253, 246, 246),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '操作记录',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: IntrinsicWidth(
                                      child: DataTable(
                                        columns: const <DataColumn>[
                                          DataColumn(label: Text('设备名称')),
                                          DataColumn(label: Text('操作方式')),
                                          DataColumn(label: Text('系统')),
                                          DataColumn(label: Text('操作时间')),
                                        ],
                                        rows: const <DataRow>[
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text('iPhone 12')),
                                              DataCell(Text('发帖')),
                                              DataCell(Text('iOS 15')),
                                              DataCell(Text('2024-4-01 10:00')),
                                            ],
                                          ),
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text('Samsung Galaxy S21')),
                                              DataCell(Text('评论')),
                                              DataCell(Text('Android 12')),
                                              DataCell(Text('2024-3-12 14:30')),
                                            ],
                                          ),
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text('MacBook Pro')),
                                              DataCell(Text('评论')),
                                              DataCell(Text('macOS Monterey')),
                                              DataCell(Text('2023-10-03 09:15')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  color: const Color.fromARGB(255, 253, 246, 246),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Login protection button below the blue container
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 253, 246, 246),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Add login protection logic here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.blue, 
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 140.0),
                                      elevation: 0, // Remove button elevation
                                    ),
                                    child: const Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Icon on the left
                                        Icon(Icons.security, size: 60, color: Colors.blue),
                                        SizedBox(width: 15), // Spacing between icon and text
                                        // Text column on the right
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('账号申诉', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 3),
                                            Text('登录异常，手机停用...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            SizedBox(height: 3),
                                            Text('去申诉 >', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10), // Spacing between buttons
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Add login protection logic here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.blue, 
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 140.0),
                                      elevation: 0, // Remove button elevation
                                    ),
                                    child: const Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Icon on the left
                                        Icon(Icons.delete_outline_outlined, size: 60, color: Colors.blue),
                                        SizedBox(width: 15), // Spacing between icon and text
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('账号注销', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 3),
                                            Text('永久注销，谨慎操作', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            SizedBox(height: 3),
                                            Text('去注销 >', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildProfileItem(Icons.person, '用户名', _user?.name ?? '未设置'),
                _buildProfileItem(Icons.email, '邮箱', _user?.email ?? '未绑定'),
                _buildProfileItem(Icons.phone_android, '联系电话', _user?.phoneNum ?? '未绑定'),
                _buildProfileItem(Icons.calendar_today, '注册时间', _user?.createTime.toString().substring(0,10) ?? '未知'),
                _buildProfileItem(Icons.info, '个人简介', _user?.name ?? '暂无个人简介', maxLines: 3),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('编辑资料'),
                    onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
                  ),
                )
              ]
            ),
          )
        ],
      )
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value, 
    {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, 
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey
                )),
              const SizedBox(height: 4),
              SizedBox(
                width: 100,
                child: Text(value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  //! 帖子管理表格
  Widget _buildPostTable() {
    return Column(
      children: [
        // 按钮操作栏
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 编辑按钮
              _buildIconTextButton(
                icon: Icons.edit,
                label: '编辑',
                //onPressed: _selectedRows.isNotEmpty ? _handleClassEditSelected : null,
              ),
              const SizedBox(width: 16),
              // 删除按钮
              _buildIconTextButton(
                icon: Icons.delete,
                label: '删除',
                iconColor: Colors.red,
                //onPressed: _handleClassDeleteSelected,
              ),
            ],
          ),
        ),
        
        // 帖子 DataTable
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('标题')),
                    DataColumn(label: Text('内容')),
                    DataColumn(label: Text('作者')),
                    DataColumn(label: Text('创建日期')),
                  ],
                  rows: _classList!.map((post) {
                    return DataRow(
                      selected: _selectedRows.contains(post.id),
                      onSelectChanged: (bool? selected) {
                        setState(() {
                          if (selected!) {
                            _selectedRows.add(post.id!);
                          } else {
                            _selectedRows.remove(post.id);
                          }
                        });
                      },
                      cells: <DataCell>[
                        DataCell(SelectableText(post.id.toString())),
                        DataCell(SelectableText(post.title)),
                        DataCell(SelectableText(post.content)),
                        DataCell(SelectableText(post.userName)),
                        DataCell(SelectableText(post.createDate.toString())),
                      ],
                    );
                  }).toList(),
                  columnSpacing: 100,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 自定义带图标的文字按钮组件
  Widget _buildIconTextButton({
    required IconData icon,
    required String label,
    Color? iconColor,
    void Function()? onPressed,
  }) {
    return  Tooltip(
       message: onPressed == null ? '请先选择一行' : '',
       child: ElevatedButton.icon(
        icon: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
        label: Text(label, 
          style: TextStyle(color: Theme.of(context).primaryColor)
        ),
        onPressed: onPressed,
        style: ButtonStyle( // ✅ 关键修复部分
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Theme.of(context).primaryColor;
            }
            return Colors.transparent;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered)) {
              return Theme.of(context).primaryColor;
            }
            return Colors.transparent;
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
          ),
        ),
      )
    );
  }
}