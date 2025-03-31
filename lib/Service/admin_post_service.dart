// 获取用户数据
  import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test_dirve/Service/classmodel_service.dart';
import 'package:test_dirve/config.dart';

class AdminPostService {
  //! 获取用户数据
  Future<List<UserModel>> queryUsers() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/Admin/QueryUser'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      List<UserModel> usersList = [];
      if (body is List){
        for (var item in body) {
          if (item is Map<String, dynamic>) {
            usersList.add(UserModel.fromJson(item));
          } else {
            throw FormatException('无效的数据格式：期望 Map<String, dynamic>, 但实际为 ${item.runtimeType}');
          }
        }
      }
      return usersList;
    } else {
      throw Exception('Failed to load users');
    }
  }

  //! 获取帖子数据
  Future<List<classModel>> queryClass() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/Admin/QueryClass'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      List<classModel> classList = [];
      if (body is List){
        for (var item in body) {
          if (item is Map<String, dynamic>) {
            classList.add(classModel.fromJson(item));
          } else {
            throw FormatException('无效的数据格式：期望 Map<String, dynamic>, 但实际为 ${item.runtimeType}');
          }
        }
      }
      return classList;
    } else {
      throw Exception('Failed to load class');
    }
  }

  //! 使用户状态冻结
  Future<void> lockUserAsync(String userName) async {
    final url = '${AppConfig.baseUrl}/Admin/UserLock?name=$userName';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      // 处理错误情况
      var errorContent = response.body;
      throw Exception('锁定用户失败：$errorContent');
    }
  }

  //! 使用户状态生效
  Future<void> effectUserAsync(String userName) async {
    final url = '${AppConfig.baseUrl}/Admin/UserEffect?name=$userName';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      // 处理错误情况
      var errorContent = response.body;
      throw Exception('解除锁定用户失败：$errorContent');
    }
  }
}
