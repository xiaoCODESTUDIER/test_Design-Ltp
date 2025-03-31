// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/Service/admin_post_service.dart';
import 'package:test_dirve/Service/classmodel_service.dart';
import 'package:test_dirve/providers/user_provider.dart';
import 'package:test_dirve/user_center_page/user_center_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? _selectedOption;
  List<UserModel> usersList = [];
  List<classModel> classList = [];
  bool _isLoading = false;
  String? _useid;
  Set<int> _selectedRows = Set<int>();  //! 存储选中行的ID

  final AdminPostService _adminPostService = AdminPostService();
  final classmodel_service _classModelService = classmodel_service();

  @override
  void initState() {
    _useid = Provider.of<UserProvider>(context, listen: false).user ?? '默认用户名';
    super.initState();
  }

  Future<void> _queryUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final users = await _adminPostService.queryUsers();
      setState(() {
        usersList = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取用户数据失败: $e')),
      );
    }
  }

  Future<void> _queryClass() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final posts = await _adminPostService.queryClass();
      setState(() {
        classList = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取帖子数据失败: $e')),
      );
    }
  }

  Future<void> _lockUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 获取选中的用户ID
      if (_selectedRows.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先选择要冻结的用户')),
        );
        return;
      }

      // 假设我们只处理第一个选中的用户
      final selectedUserId = _selectedRows.first;
      final selectedUser = usersList.firstWhere((user) => user.id == selectedUserId);

      // 调用 lockUserAsync 方法并传递用户名
      await _adminPostService.lockUserAsync(selectedUser.name ?? '');

      // 更新用户列表中的状态
      setState(() {
        final updatedUserIndex = usersList.indexWhere((user) => user.id == selectedUserId);
        if (updatedUserIndex != -1) {
          usersList[updatedUserIndex] = usersList[updatedUserIndex].copyWith(isLock: 1);
        }
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户冻结操作成功')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('用户冻结操作失败: $e')),
      );
    }
  }

  Future<void> _effectUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 获取选中的用户ID
      if (_selectedRows.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先选择要解除冻结的用户')),
        );
        return;
      }

      // 假设我们只处理第一个选中的用户
      final selectedUserId = _selectedRows.first;
      final selectedUser = usersList.firstWhere((user) => user.id == selectedUserId);

      // 调用 lockUserAsync 方法并传递用户名
      await _adminPostService.effectUserAsync(selectedUser.name ?? '');

      // 更新用户列表中的状态
      setState(() {
        final updatedUserIndex = usersList.indexWhere((user) => user.id == selectedUserId);
        if (updatedUserIndex != -1) {
          usersList[updatedUserIndex] = usersList[updatedUserIndex].copyWith(isLock: 0);
        }
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户解除冻结操作成功')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('用户解除冻结操作失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理员中心'),
        actions: [
          TextButton(
            onPressed: () {
              // 导航到用户中心页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserCenterPage(),
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
            child: const Text('用户中心'),
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
                // 用户管理按钮
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('用户管理'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'user_management';
                    });
                    _queryUsers();
                  },
                  selected: _selectedOption == 'user_management',
                  selectedTileColor: Colors.blue,
                  selectedColor: Colors.blue,
                ),
                // 帖子管理按钮
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('帖子管理'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'post_management';
                    });
                    _queryClass();
                  },
                  selected: _selectedOption == 'post_management',
                  selectedTileColor: Colors.blue,
                  selectedColor: Colors.blue,
                ),
                // 用户举报信息处理按钮
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('用户举报信息处理'),
                  onTap: () {
                    setState(() {
                      _selectedOption = 'report_handling';
                    });
                    // 导航到用户举报信息处理页面
                    MaterialPageRoute(
                        builder: (context) => const AdminPage()
                    );
                  },
                  selected: _selectedOption == 'report_handling',
                  selectedTileColor: Colors.blue,
                  selectedColor: Colors.blue,
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1), // 添加垂直分割线
          // 右侧主要内容区域
          Container(
            alignment: Alignment.topLeft,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _selectedOption == 'user_management'
                  ? _buildUserTable()
                  : _selectedOption == 'post_management'
                    ? _buildPostTable()
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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

  //! 用户管理表格
  Widget _buildUserTable() {
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
                onPressed: _selectedRows.isNotEmpty ? () => _handleUserEditSelected() : null,
              ),
              const SizedBox(width: 16),
              // 生效按钮
              _buildIconTextButton(
                icon: Icons.check_circle,
                label: '生效',
                iconColor: _selectedRows.isNotEmpty ? Colors.green : Colors.grey,
                onPressed: _selectedRows.isNotEmpty ? () => _effectUser() : null,
              ),
              const SizedBox(width: 16),
              // 冻结按钮
              _buildIconTextButton(
                icon: Icons.cancel,
                label: '冻结',
                iconColor: _selectedRows.isNotEmpty ? Colors.red : Colors.grey,
                onPressed: _selectedRows.isNotEmpty ? () => _lockUser() : null,
              ),
            ],
          ),
        ),
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
                    DataColumn(label: Text('用户账号')),
                    DataColumn(label: Text('用户名')),
                    DataColumn(label: Text('权限等级')),
                    DataColumn(label: Text('账号状态')),
                    DataColumn(label: Text('电话号码')),
                    DataColumn(label: Text('电子邮箱')),
                  ],
                  rows: usersList.map((user) {
                    return DataRow(
                      selected: _selectedRows.contains(user.id),  //! 添加选中状态
                      //! 点击回调
                      onSelectChanged: (bool? selected) {
                        setState(() {
                          if (selected!) {
                            _selectedRows.add(user.id);
                          } else {
                            _selectedRows.remove(user.id);
                          }
                        });
                      },
                      cells: <DataCell>[
                      DataCell(SelectableText(user.id.toString())),
                      DataCell(SelectableText(user.name ?? '')),
                      DataCell(SelectableText(user.useName ?? '')),
                      DataCell(SelectableText(user.level == 2 ? '管理员' : user.level == 1 ? '普通用户' : '超级管理员')),
                      DataCell(SelectableText(user.isLock == 1 ? '冻结' : '生效')),
                      DataCell(SelectableText(user.phoneNum ?? '')),
                      DataCell(SelectableText(user.email ?? '')),
                    ]);
                  }).toList(),
                  columnSpacing: 100,
                ),
              ],
            ),
          )// 保持原有表格代码
        )
      ],
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
                onPressed: _selectedRows.isNotEmpty ? _handleClassEditSelected : null,
              ),
              const SizedBox(width: 16),
              // 删除按钮
              _buildIconTextButton(
                icon: Icons.delete,
                label: '删除',
                iconColor: Colors.red,
                onPressed: _handleClassDeleteSelected,
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
                  rows: classList.map((post) {
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

  // 按钮点击处理示例
  void _handleUserEditSelected() {
    if (_selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要操作的用户'))
      );
      return;
    }
    // 获取第一个选中的用户
    final selectedUser = usersList.firstWhere(
      (user) => user.id == _selectedRows.first
    );
    _showUserEditDialog(selectedUser);
  }

  //! 定义 _showEditDialog 方法
  void _showUserEditDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('编辑用户信息'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: user.name,
                  decoration: const InputDecoration(labelText: '用户账号'),
                  onChanged: (value) => user.name = value,
                ),
                TextFormField(
                  initialValue: user.useName,
                  decoration: const InputDecoration(labelText: '用户名'),
                  onChanged: (value) => user.useName = value,
                ),
                TextFormField(
                  initialValue: user.phoneNum,
                  decoration: const InputDecoration(labelText: '电话号码'),
                  onChanged: (value) => user.phoneNum = value,
                ),
                TextFormField(
                  initialValue: user.email,
                  decoration: const InputDecoration(labelText: '电子邮箱'),
                  onChanged: (value) => user.email = value,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  //* await _adminPostService.updateUser(user); // 调用服务更新用户信息
                  setState(() {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('用户信息更新成功')),
                    );
                  });
                  Navigator.of(context).pop(); // 关闭对话框
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('更新失败: $e')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _handleClassEditSelected() {
    if (_selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要操作的帖子')),
      );
      return;
    }
    // 获取第一个选中的帖子
    final selectedPost = classList.firstWhere(
      (post) => post.id == _selectedRows.first
    );
    _showClassEditDialog(selectedPost);
  }

  void _handleClassDeleteSelected() {
    if (_selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要删除的帖子')),
      );
      return;
    }
    // 获取第一个选中的帖子
    final selectedPost = classList.firstWhere(
      (post) => post.id == _selectedRows.first
    );
    _deleteClass(selectedPost);
  }

  //! 定义 帖子删除 方法
  void _deleteClass(classModel post) async {
    try {
      await _classModelService.deleteClassModel(post.id);
      setState(() {
        classList.remove(post);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('帖子删除成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  //! 定义 帖子编辑显示框 方法
  void _showClassEditDialog(classModel post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('编辑帖子信息'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: post.title,
                  decoration: const InputDecoration(labelText: '标题'),
                  onChanged: (value) => post.title = value,
                ),
                TextFormField(
                  initialValue: post.content,
                  decoration: const InputDecoration(labelText: '内容'),
                  onChanged: (value) => post.content = value,
                ),
                // 其他字段可以继续添加
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // await _classModelService.updateClassModel(post); // 调用服务更新帖子信息
                  setState(() {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('帖子信息更新成功')),
                    );
                  });
                  Navigator.of(context).pop(); // 关闭对话框
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('更新失败: $e')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}

