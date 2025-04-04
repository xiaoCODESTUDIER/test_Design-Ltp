import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:test_dirve/config.dart'; // Add dio package in pubspec.yaml
import 'package:test_dirve/Service/classmodel_service.dart';

class UserPostService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<UserModel?> queryUser(String username) async {
    try {
      final url = '$_baseUrl/User/UserQuery?username=$username';
      final response = await post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } on DioException catch (e) {
      throw Exception('获取用户数据失败：$e');
    }
  }

  //! 获取用户创建的帖子数据
  Future<List<classModel>> queryClass(String username) async {
    final response = await post(Uri.parse('${AppConfig.baseUrl}/User/ClassQuery?username=$username'));
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
}