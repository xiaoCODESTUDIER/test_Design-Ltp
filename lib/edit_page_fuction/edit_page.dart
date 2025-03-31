// ignore_for_file: library_private_types_in_public_api, unused_element, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/Service/classmodel_service.dart';
import 'package:test_dirve/providers/user_provider.dart';

class EditPage extends StatefulWidget{
  const EditPage({super.key});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final classmodel_service _classModelService = classmodel_service();
  String? _userid;
  int? _thamed;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  final Map<String, int> _themeMap = {
    '旅游': 1,
    '美食': 2,
    '趣闻': 3,
    '景点': 4,
    '发现': 5,
    '规划': 6,
    '吐槽': 7,
  };

  @override 
  void initState() {
    super.initState();
    _userid = Provider.of<UserProvider>(context, listen: false).user ?? '默认用户名';
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
    }
  }

  Future<String?> _uploadImageToImgur(Uint8List imageBytes) async {
    const String clientId = 'a81a6dba778e769';
    final uri = Uri.parse('https://api.imgur.com/3/');
    final request = MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Client-ID $clientId'
      ..files.add(MultipartFile.fromBytes(
        '${DateTime.now()}-image',
        imageBytes,
        filename: '${DateTime.now()}-image.jpg',
      ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseJson = jsonDecode(await response.stream.bytesToString());
        return responseJson['data']['link'];
      } else {
        print('上传失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('上传失败: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布新内容'),
        actions: [
          DropdownButton<int>(
            value: _thamed, // 当前选中的主题
            hint: const Text('选择板块'), // 默认提示文本
            onChanged: (int? newValue) {
              setState(() {
                _thamed = newValue!;
              });
            },
            items: _themeMap.entries.map((MapEntry<String, int> entry) {
              return DropdownMenuItem<int>(
                value: entry.value,
                child: Text(entry.key),
              );
            }).toList(),
          ),
          const SizedBox(width: 16,), // 添加间距
          // 发布按钮
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              // 处理发布逻辑
              final String title = _titleController.text;
              final String content = _contentController.text;
              if (title.isNotEmpty && content.isNotEmpty && _thamed != null) {
                try {
                  // 创建 classModel 对象
                  final classModel newClass = classModel(
                    title: title,
                    content: content,
                    x: 0,
                    y: 0,
                    eyes: 0,
                    contentsnum: 0,
                    contents: [],
                    useid: _userid!,
                    contentid: '',
                    goodsid: '',
                    goods: [],
                    goodsnum: 0,
                    badsnum: 0,
                    thamed: _thamed.toString(),
                    createDate: DateTime.now(), 
                    userName: '',
                    imageUrl: null,
                  );
                  // 判断用户是否上传图片
                  if (_imageBytes != null) {
                    final imageUrl = await _uploadImageToImgur(_imageBytes!);
                    if (imageUrl != null) {
                      newClass.imageUrl = imageUrl;
                    }
                  }
                  // 调用 addClassModel 方法
                  _classModelService.addClassModel(newClass);
                  // 返回标题、内容和主题
                  Navigator.pop(context, {'title': title, 'content': content, 'theme': _thamed! - 1});
                } catch (e) {
                  // 处理异常
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('添加失败: $e'),
                    ),
                  );
                }
              }  else {
                // 提示用户输入完整信息
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('请输入完整信息:标题、内容和主题选择不能为空'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              maxLength: 500,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('选择图片'),
            ),
            const SizedBox(height: 16),
            _imageBytes != null
                ? Image.memory(
                  _imageBytes!,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('无法加载图片');
                  },
                )
                : const Text('未选择图片'),
          ],
        ),
      ),
    );
  }
}