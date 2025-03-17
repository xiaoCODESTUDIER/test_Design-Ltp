// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/Service/classmodel_service.dart';
import 'package:test_dirve/forum/forum_page.dart';
import 'package:test_dirve/providers/user_provider.dart';

class InfoPopupMenuButton extends StatefulWidget {
  final VoidCallback onNotificationRead;

  const InfoPopupMenuButton({
    super.key, 
    required this.onNotificationRead,
  });

  @override
  _InfoPopupMenuButtonState createState() => _InfoPopupMenuButtonState();
}

class _InfoPopupMenuButtonState extends State<InfoPopupMenuButton> {
  final classmodel_service service = classmodel_service();
  List<NotificationModel> _notifications = [];
  int _unreadNotificationCount = 0;
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听用户ID的变化，当用户ID变化时重新获取通知
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final userId = userProvider.user ?? '默认用户名';
    if (userId != null) {
      _fetchNotifications();
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user ?? '默认用户名';
      final notifications = await service.getNotifications(userId);
      if (notifications.isEmpty) {
        throw Exception('通知列表为空');
      }
      setState(() {
        _unreadNotificationCount = notifications.length;
        _notifications = notifications;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取通知失败：$e')),
      );
    }
  }
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('信息'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  title: Text("${notification.userId} 回复了你的帖子"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("帖子ID：${notification.postId}"),
                      Text("回复内容：${notification.content}"),
                    ],
                  ),
                  onTap: () async {
                      try {
                        final post = await service.getClassModelById(notification.postId);
                        // 标记通知为已读
                        await service.markNotificationAsRead(notification.id);
                        setState(() {
                          _notifications.removeAt(index);
                          _unreadNotificationCount--;
                          widget.onNotificationRead();
                        });
                        // 导航到帖子详细页面
                        _showForumPage(context, post);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('标记通知为已读失败: $e')),
                        );
                      }
                    }
                  );
                }
              )
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('关闭'),
                onPressed: () {
                  Navigator.of(context).pop();
                }
              )
            ]
        );
      }
    );
  }

  void _showForumPage(BuildContext context, classModel pin) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumPage(pin: pin,)
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('设置'),
          content: const Text('这是里设置内容'),
          actions: <Widget>[
            TextButton(
              child: const Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              }
            )
          ]
        );
      }
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('帮助'),
          content: const Text('这里是帮助内容'),
          actions: <Widget>[
            TextButton(
              child: const Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              }
            )
          ]
        );
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.info),
          tooltip: '信息',
          onSelected: (String result) {
            switch (result) {
              case 'info':
                _showInfoDialog(context);
                break;
              case 'settings':
                _showSettingsDialog(context);
                break;
              case 'help':
                _showHelpDialog(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'info',
              child: Text('信息', style: TextStyle(fontSize: 12)),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('设置', style: TextStyle(fontSize: 12)),
            ),
            const PopupMenuItem<String>(
              value: 'help',
              child: Text('帮助', style: TextStyle(fontSize: 12)),
            ),
          ],
          offset: const Offset(0 ,40),
        ),
        if (_unreadNotificationCount > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$_unreadNotificationCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              )
            )
          )
      ]
    );
  }
}