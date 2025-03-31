import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:test_dirve/config.dart';

class ImagePostService {
  final String _baseUrl = '${AppConfig.baseUrl}/ImagePost';
  
  Future<String> uploadImage(Uint8List? imageBytes, String userId) async {
    if (imageBytes == null){
      throw Exception('图片字节数据不能为空');
    }

    final uri = Uri.parse('$_baseUrl/UploadImage?userId=$userId');
    final request = MultipartRequest('POST', uri);
      
    final file = MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      contentType: MediaType('image', 'jpeg')
    );

    request.files.add(file);

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final imageUrl = jsonDecode(responseBody)['imageUrl'];
      return imageUrl;
    } else {
      throw Exception('上传失败，状态码：${response.statusCode}');
    }
  }

  Future<void> updateImageUrl(int? postId, String imageUrl) async {
    final response = await put(
      Uri.parse('$_baseUrl/UpdateImageUrl?postId=$postId&imageUrl=$imageUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'imageUrl': imageUrl,
      }),
    );
    if (response.statusCode == 200) {
      throw Exception('更新失败，状态码：${response.statusCode}');
    }
  }
}

