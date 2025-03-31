// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/Service/classmodel_service.dart';
import 'package:test_dirve/forum/forum_page.dart';
import 'package:test_dirve/providers/user_provider.dart';
class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MapPageState createState() => _MapPageState();
}
class _MapPageState extends State<MapPage> {
  final Set<int> _highlightedPins = {};
  final Map<int, TextEditingController> _controller = {};
  final List<classModel> _userClass = [];
  final List<classModel> _otherClass = [];
  final classmodel_service _classModelService = classmodel_service();
  List<classModel> classModels = [];
  String? _useid;
  int? _highlightedIndex;
  final TextEditingController _search = TextEditingController();
  String _sortOption = 'title';

  @override
  void initState() {
    super.initState();
    _useid = Provider.of<UserProvider>(context, listen: false).user ?? '默认用户名';
    _loadclassModel();
  }
  void _loadclassModel() async {
    try {
      classModels = await _classModelService.getClassModel();
      setState(() {
        _userClass.clear();
        _otherClass.clear();
        for (int i = 0; i < classModels.length; i++) {
          final pin = classModels[i];
          if (pin.x != 0 && pin.y != 0){
            if (pin.useid == _useid) {
              _userClass.add(pin);
            } else {
              _otherClass.add(pin);
            }
          }
          _controller[i] = TextEditingController(text: pin.title);
        }
        _sortData();
      });
    } catch (e) {
      throw Exception('加载数据失败：$e');
    }
  }
  Future<String> loadHtmlFromAssets() async {
    return await rootBundle.loadString('assets/set-theme-style.html');
  }
  void _showInputDialog(BuildContext context, Offset position) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("创建新帖子"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '标题'),
                  maxLength: 25,
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: '内容'),
                  maxLines: null,
                  maxLength: 300,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () async {
                String title = titleController.text;
                String content = contentController.text;
                double x = position.dx;
                double y = position.dy;
                String thamed = '1';
                String? useid = Provider.of<UserProvider>(context, listen: false).user ?? '默认用户名';
                classModel newClass = classModel(title: title, content: content, x: x, y: y, eyes: 0, contentsnum: 0,contents: [], useid: useid, contentid: '', goodsid: '', goods: [], goodsnum: 0, badsnum: 0, thamed: thamed, createDate: DateTime.now(), userName: '', avatarUrl: null);
                try {
                  await _classModelService.addClassModel(newClass);
                  setState(() {
                    _loadclassModel();
                    if (newClass.useid == _useid) {
                      _userClass.add(newClass);
                    } else {
                      _otherClass.add(newClass);
                    }
                    _controller[_userClass.length + _otherClass.length - 1] = TextEditingController(text: title);
                  });
                } catch (e) {
                  throw Exception('添加失败：$e');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showForumPage(BuildContext context, classModel pin) async {
    await _classModelService.incrementEyesCount(pin.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumPage(pin: pin,)
      ),
    );
  }
  void _sortData() {
    setState(() {
      switch (_sortOption) {
        case 'title':
          _userClass.sort((a, b) => a.title.compareTo(b.title));
          _otherClass.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'eyes':
          _userClass.sort((a, b) => b.eyes.compareTo(a.eyes));
          _otherClass.sort((a, b) => b.eyes.compareTo(a.eyes));
          break;
        case 'contentsnum':
          _userClass.sort((a, b) => b.contentsnum.compareTo(a.contentsnum));
          _otherClass.sort((a, b) => b.contentsnum.compareTo(a.contentsnum));
          break;
      }
    });
  }
  @override
  Widget build(BuildContext context){
    String apiKey = '2d23a345aca4c497d8f4cff1f65ab234';
    String location = '113.276524,23.11802';
    String zoom = '14';
    String size = '1024*1024';
    String staticMapUrl = 'https://restapi.amap.com/v3/staticmap?location=$location&zoom=$zoom&size=$size&key=$apiKey';

    List<classModel> filteredUserClass = _userClass.where((pin) => pin.title.toLowerCase().contains(_search.text.toLowerCase())).toList();
    List<classModel> filteredOtherClass = _otherClass.where((pin) => pin.title.toLowerCase().contains(_search.text.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _search,
          decoration: const InputDecoration(
            hintText: '搜索...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _sortOption = result;
                _sortData();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'title',
                child: Text('按标题排序'),
              ),
              const PopupMenuItem<String>(
                value: 'eyes',
                child: Text('按查看数排序'),
              ),
              const PopupMenuItem<String>(
                value: 'contentsnum',
                child: Text('按讨论数排序'),
              )
            ]
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _search.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Flexible(
                flex: 1, 
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredUserClass.length,
                        itemBuilder: (context, index) {
                          final pin = filteredUserClass[index];
                          return MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                _highlightedPins.add(index);
                                _highlightedIndex = index;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                _highlightedPins.remove(index);
                                _highlightedIndex = null;
                              });
                            },
                            child: ListTile(
                              tileColor: _highlightedIndex == index ? Colors.blue[100] : null,
                              title: Text(pin.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                              subtitle: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage: pin.avatarUrl != null && pin.avatarUrl!.isNotEmpty
                                      ? NetworkImage(pin.avatarUrl!) as ImageProvider
                                      : const AssetImage('image/default_avatar.png'),
                                  ),
                                  const SizedBox(width: 8),
                                  RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        const TextSpan(
                                          text: '发起者: '
                                        ),
                                        TextSpan(
                                          text: '@${pin.userName}',
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                        TextSpan(
                                          text: '查看数: ${pin.eyes}, 讨论数: ${pin.contentsnum}, 点赞数：${pin.goodsnum}, 点踩数：${pin.badsnum},'
                                        )
                                      ]
                                    )
                                  ),
                                ]
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _deletePin(pin, index);
                                      });
                                    },
                                    iconSize: 16,
                                  )
                                ],
                              ),
                              onTap: () {
                                _showForumPage(context, pin);
                              }
                            ),
                          );
                      },
                    )
                  ),
                  const Divider(height: 1, thickness: 2, color: Colors.grey),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredOtherClass.length,
                      itemBuilder: (context, index) {
                        final pin = filteredOtherClass[index];
                        final globalIndex = index + filteredUserClass.length;
                        _highlightedPins.contains(index + filteredUserClass.length);
                        if (!_controller.containsKey(globalIndex)) {
                          _controller[globalIndex] = TextEditingController(text: pin.title);
                        }
                        return MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              _highlightedPins.add(index + filteredUserClass.length);
                              _highlightedIndex = globalIndex;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _highlightedPins.remove(index + filteredUserClass.length);
                              _highlightedIndex = null;
                            });
                          },
                          child: ListTile(
                            tileColor: _highlightedIndex == globalIndex ? Colors.blue[100] : null,
                            title: Text(pin.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            subtitle: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: pin.avatarUrl != null && pin.avatarUrl!.isNotEmpty
                                    ? NetworkImage(pin.avatarUrl!) as ImageProvider
                                    : const AssetImage('image/default_avatar.png'),
                                ),
                                const SizedBox(width: 8),
                                RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      const TextSpan(
                                        text: '发起者: '
                                      ),
                                      TextSpan(
                                        text: '@${pin.userName}',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      TextSpan(
                                        text: '查看数: ${pin.eyes}, 讨论数: ${pin.contentsnum}, 点赞数：${pin.goodsnum}, 点踩数：${pin.badsnum},'
                                      )
                                    ]
                                  )
                                ),
                              ]
                            ),
                            trailing:  const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              ),
              Flexible(
                flex: 2,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        _showInputDialog(context, details.localPosition);
                      },
                      child: Image.network(
                        staticMapUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('无法加载地图');
                        }
                      )
                    );
                  }
                ),
              )
            ],
          ),
          ..._userClass.asMap().entries.map((entry) {
            final i = entry.key;
            final position = entry.value;
            final isHighlighted = _highlightedPins.contains(i);
            final pinSize = isHighlighted ? 22.0 : 20.0;
            final containerWidth = isHighlighted ? 150.0 : 40.0;
            final containerHeight = isHighlighted ? 60.0 : 30.0;
            return Positioned(
              left: position.x + (MediaQuery.of(context).size.width / 3) - 10,
              top: position.y - 20,
              child: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _highlightedPins.add(i);
                  });
                },
                onExit: (_) {
                  setState(() {
                    _highlightedPins.remove(i);
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    _showForumPage(context, position);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: isHighlighted ? Colors.blue[300] : Colors.transparent,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: isHighlighted
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isHighlighted ? (position.title.length > 10 ? '${position.title.substring(0, 10)}...' : position.title) : '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  isHighlighted ? (position.content.length > 15 ? '${position.content.substring(0, 15)}...' : position.content) : '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.location_pin,
                              size: pinSize,
                              color: Colors.red,
                            ),
                          ),
                  )
                )
              )
            );
          }),
          ..._otherClass.asMap().entries.map((entry) {
            final i = entry.key;
            final position = entry.value;
            final isHighlighted = _highlightedPins.contains(i + _userClass.length);
            final pinSize = isHighlighted ? 22.0 : 20.0;
            final containerWidth = isHighlighted ? 150.0 : 40.0;
            final containerHeight = isHighlighted ? 60.0 : 30.0;
            return Positioned(
              left: position.x + (MediaQuery.of(context).size.width / 3) - 10,
              top: position.y - 20,
              child: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _highlightedPins.add(i + _userClass.length);
                  });
                },
                onExit: (_) {
                  setState(() {
                    _highlightedPins.remove(i + _userClass.length);
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    _showForumPage(context, position);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration (
                      color: isHighlighted ? Colors.blue[300] : Colors.transparent,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: isHighlighted
                      ? Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHighlighted ? (position.title.length > 10 ? '${position.title.substring(0, 10)}...' : position.title) : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                isHighlighted ? (position.content.length > 15 ? '${position.content.substring(0, 15)}...' : position.content) : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.location_pin,
                            size: pinSize,
                            color: Colors.red,
                          ),
                        ),
                  ),
                ),
              )
            );
          }),
        ],
      ),
    );
  }
  void _deletePin(classModel pin, int index) async {
    try {
      await _classModelService.deleteClassModel(pin.id);
      setState (() {
        _userClass.removeAt(index);
        _highlightedPins.remove(index);
        _controller.remove(index);
        _sortData();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：$e'),)
      );
    }
  }
}