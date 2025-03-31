import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test_dirve/config.dart';

class PagePostService {
  final String _baseUrl = '${AppConfig.baseUrl}/PagePost/UploadAvatar';
  // 上传头像
  Future<String?> uploadAvatar(File imageFile, String userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/upload-avatar');
      final request = http.MultipartRequest('POST', uri)
        ..fields['userId'] = userId.toString()
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final avatarUrl = jsonDecode(responseBody)['avatarUrl'];
        return avatarUrl;
      } else {
        throw Exception('上传失败，状态码：${response.statusCode}');
      }
    } catch (e) {
      throw Exception('上传失败: $e');
    }
  }
}