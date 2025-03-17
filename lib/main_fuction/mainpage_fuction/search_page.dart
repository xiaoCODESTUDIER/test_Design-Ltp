import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
class SearchPage extends StatefulWidget {     // 定义一个可状态化的搜索页面组件
  const SearchPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {    // 搜索页面的状态类
  final TextEditingController _textEditor = TextEditingController();    // 文本编辑控制器，用于管理 TextField 的输入
  List<Map<String, dynamic>> _newsItems = [];
  String _selectedCategory = 'top';    // 默认选择的类别
  final String _query = 'https://tenapi.cn/v2/toutiaohot';    // 默认的头条api链接
  Future<void> _launchUrl(String query) async {     // 异步方法，用于打开指定查询的百度搜索链接
      final url = Uri.parse('http://www.baidu.com/s?wd=$query');
      await launchUrl(url);
  }
  Future<void> _launchTopUrl(String query) async {    // 异步方法，用于打开指定头条的链接
    final url = Uri.parse(query);
    await launchUrl(url);
  }
  Future<void> _fetchNews(String category, String query) async {
    // final params = {
    //   //'key': '0efa0fa0182a613a494f2d7b89382989',
    //   'type': category,     // 搜索类别
    // };
    try{
      //final uri = Uri.parse(apiUrl).replace(queryParameters: params);
      final response = await http.get(Uri.parse(query));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        //final items = data['result']['data'] as List<dynamic>;
        final items = data['data'] as List<dynamic>;
        setState(() {
          _newsItems = items.map((item) {
            return {
              // 'title': item['title'],
              // 'url': item['url'],
              // 'thumbnail_pic_s': item['thumbnail_pic_s'],
              'title': item['name'],
              'url': item['url'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load news: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
  void _performSearch(String query) {     // 执行搜索的方法，调用 _launchUrl 方法
    _launchUrl(query);
  }

  void _selectCategory(String category, String query){
    setState(() {
      _selectedCategory = category;
      _fetchNews(category, query);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNews(_selectedCategory, _query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),    // 设置 AppBar 标题
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),    // 页面四周的内边距
        child: SingleChildScrollView(     // 可滚动的单个子部件容器
          child: Column(    // 垂直方向的列布局
            children: [
              Row(    // 水平方向的行布局
                children: [
                  Expanded(     // 使 TextField 占据剩余空间
                    child: TextField(
                      controller: _textEditor,    // 绑定文本编辑控制器
                      onSubmitted: (value) {    // 当用户提交输入时触发
                        _performSearch(value);    // 执行搜索
                      },
                      decoration: const InputDecoration(
                        hintText: '输入搜索关键词',     // 输入框提示文字
                        border: OutlineInputBorder(),     // 输入框边框样式
                      ),
                    ),
                  ),
                  IconButton(     // 搜索按钮
                    icon: const Icon(Icons.search),     // 按钮图标
                    onPressed: () {     // 点击按钮时触发
                      _performSearch(_textEditor.text);     // 使用当前输入的内容执行搜索
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),     // 间距
              const Text('每日新闻要点'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCategory == 'top' ? Colors.blue : Colors.white,
                          foregroundColor: _selectedCategory == 'top' ? Colors.white : Colors.black,
                          side: const BorderSide(color: Colors.grey, width: 1.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.0),
                              bottomLeft: Radius.circular(4.0),
                            ),
                          ),
                        ),
                        onPressed: () => _selectCategory('top', 'https://tenapi.cn/v2/toutiaohot'),
                        child: const Text('今日热点'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCategory == 'youxi' ? Colors.blue : Colors.white,
                          foregroundColor: _selectedCategory == 'youxi' ? Colors.white : Colors.black,
                          side: const BorderSide(color: Colors.grey, width: 1.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.0),
                              bottomLeft: Radius.circular(4.0),
                            ),
                          ),
                        ),
                        onPressed: () => _selectCategory('youxi', 'https://tenapi.cn/v2/zhihuhot'),
                        child: const Text('知乎热点'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCategory == 'junshi' ? Colors.blue : Colors.white,
                          foregroundColor: _selectedCategory == 'junshi' ? Colors.white : Colors.black,
                          side: const BorderSide(color: Colors.grey, width: 1.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.0),
                              bottomLeft: Radius.circular(4.0),
                            ),
                          ),
                        ),
                        onPressed: () => _selectCategory('junshi', 'https://tenapi.cn/v2/toutiaohot'),
                        child: const Text('微博热点'),
                      ),
                    ),
                  ],
                )
              ),
              const SizedBox(height: 10),
              _newsItems.isEmpty ? const CircularProgressIndicator() : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _newsItems.length,
                itemBuilder: (context, index) {
                  final newsItem = _newsItems[index];
                  return ListTile(
                    //leading: newsItem['thumbnail_pic_s'] != '' ? Image.network(newsItem['thumbnail_pic_s']) : const Icon(Icons.newspaper),
                    title: Text(newsItem['title'] ?? '无标题'),
                    subtitle: Text(newsItem['url'] ?? '无描述'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      _launchTopUrl(newsItem['url']);
                    },
                  );
                },
              ), 
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose(){
    _textEditor.dispose();
    super.dispose();
  }
}