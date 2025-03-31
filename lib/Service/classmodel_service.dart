// ignore_for_file: file_names, camel_case_types
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_dirve/config.dart';
class classmodel_service {
  final String _baseUrl = '${AppConfig.baseUrl}/classmodel';
  
  Future<List<classModel>> getClassModel() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<classModel> classModels = body.map((item){
        if (item is Map<String, dynamic>) {
          return classModel.fromJson(item);
        } else {
          throw FormatException('无效的数据格式：期望 Map<String, dynamic>, 但实际为 ${item.runtimeType}');
        }
      }).toList();
      return classModels;
    } else {
      throw Exception('获取数据失败，状态码：${response.statusCode}');
    }
  }
  Future<List<classModel>> queryManuClassModel(String thamed) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/QueryMenuPage?thamed=$thamed'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<classModel> classModels = body.map((item){
        if (item is Map<String, dynamic>) {
          return classModel.fromJson(item);
        } else {
          throw FormatException('无效的数据格式：期望 Map<String, dynamic>, 但实际为 ${item.runtimeType}');
        }
      }).toList();
      return classModels;
    } else {
      throw Exception('查询失败，状态码：${response.statusCode}');
    }
  }
  Future<classModel> getClassModelById(int postId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$postId'));
    if (response.statusCode == 200) {
      return classModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('获取帖子详情失败');
    }
  }
  Future<classModel> addClassModel(classModel classMs) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(classMs.toJson()),
    );
    if (response.statusCode == 201) {
      return classModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('添加数据失败');
    }
  }
  Future<void> deleteClassModel(int? pin) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/deleteClass?id=$pin'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception("删除失败: ${response.statusCode}");
    }
  }
  Future<void> incrementEyesCount(int? id) async {
    if (id != null){
      final url = Uri.parse('$_baseUrl/AddEyesCount?id=$id');
      await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
    }
  }
  // 添加评论
  Future<bool> addComment(int postId, contentModel comment) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/comments/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(comment.toJson()),
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
  // 获取帖子的评论
  Future<List<contentModel>> getCommentsByPost(String postId) async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/comments/$postId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<contentModel> comments = body.map((item) {
        if (item is Map<String, dynamic>) {
          return contentModel.fromJson(item);
        } else {
          throw FormatException('无效的数据格式：期望 Map<String, dynamic>, 但实际为 ${item.runtimeType}');
        }
      }).toList();
      return comments;
    } else {
      throw Exception('获取评论失败，状态码：${response.statusCode}');
    }
  }
  // 点赞操作
  Future<classModel> like(String contentid, String goodsid, String userid) async {
    final response = await http.post(Uri.parse('${AppConfig.baseUrl}/Comments/like?contentId=$contentid&goodsId=$goodsid&useId=$userid'));
    if (response.statusCode == 200) {
      return classModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('无法进行操作：${response.statusCode}');
    }
  }
  // 撤销点赞操作
  Future<classModel> cancelLike(String contentid, String goodsid, String userid) async {
    final response = await http.post(Uri.parse('${AppConfig.baseUrl}/Comments/cancelLike?contentId=$contentid&goodsId=$goodsid&useId=$userid'));
    if (response.statusCode == 200) {
      return classModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('无法进行操作：${response.statusCode}');
    }
  }
  // 点踩操作
  Future<classModel> dislike(String contentid, String goodsid, String userid) async {
    final response = await http.post(Uri.parse('${AppConfig.baseUrl}/Comments/dislike?contentId=$contentid&goodsId=$goodsid&useId=$userid'));
    if (response.statusCode == 200) {
      return classModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('无法进行操作：${response.statusCode}');
    }
  }
  // 撤销点踩操作
  Future<classModel> cancelDislike(String contentid, String goodsid, String userid) async {
    final response = await http.post(Uri.parse('${AppConfig.baseUrl}/Comments/cancelDislike?contentId=$contentid&goodsId=$goodsid&useId=$userid'));
    if (response.statusCode == 200) {
      return classModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('无法进行操作：${response.statusCode}');
    }
  }
  Future<bool> notifyPostAuthor(int postId, String userId, String comment) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/Notification/notify'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'postId': postId,
        'userId': userId,
        'comment': comment,
      }),
    );
    return response.statusCode == 200;
  }
  // 获取通知列表
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/Notification/$userId'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      List<NotificationModel> notifications = [];
      if (body is List){
        for (var item in body) {
          if (item is Map<String, dynamic>) {
            notifications.add(NotificationModel.fromJson(item));
          } else {
            throw FormatException('无效的数据格式：期望 Map<String, dynamic>, 但实际为 ${item.runtimeType}');
          }
        }
      }
      return notifications;
    } else {
      return [];
    }
  }
  // 标记通知为已读
  Future<void> markNotificationAsRead(int notificationId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/Notification/mark-read/$notificationId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('标记通知为已读失败，状态码：${response.statusCode}');
    }
  }
}
// 下面是模型
class contentModel {
  final int id;
  final String contentid;
  final String useid;
  final String commnet;
  final DateTime commentDate;
  final String goodsid;
  final List<goodsModel> goods;

  contentModel({
    required this.id,
    required this.contentid,
    required this.useid,
    required this.commnet,
    required this.commentDate,
    required this.goodsid,
    required this.goods,
  });

  factory contentModel.fromJson(Map<String, dynamic> json) {
    var goodsJson = json['goods'] as List;
    var goods = goodsJson.map((goodsJson) => goodsModel.fromJson(goodsJson)).toList();

    return contentModel(
      id: json['id'] as int,
      contentid: json['contentid'] as String,
      useid: json['useid'] as String,
      commnet: json['commnet'] as String,
      commentDate: DateTime.parse(json['commentDate'] as String),
      goodsid: json['goodsid'] as String,
      goods: goods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentid': contentid,
      'useid': useid,
      'commnet': commnet,
      'commentDate': commentDate.toIso8601String(),
      'goodsid': goodsid,
      'goods': goods.map((goods) => goods.toJson()).toList(),
    };
  }
}

class goodsModel {
  final int id;
  final String goodsid;
  final String useid;
  final bool goods;
  final bool bads;
  final DateTime goodsDate;

  goodsModel({
    required this.id,
    required this.goodsid,
    required this.useid,
    required this.goods,
    required this.bads,
    required this.goodsDate,
  });

  factory goodsModel.fromJson(Map<String, dynamic> json) {
    return goodsModel(
      id: json['id'] as int,
      goodsid: json['goodsid'] as String,
      useid: json['useid'] as String,
      goods: json['goods'] as bool,
      bads: json['bads'] as bool,
      goodsDate: DateTime.parse(json['goodsDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goodsid': goodsid,
      'useid': useid,
      'goods': goods,
      'bads': bads,
      'goodsDate': goodsDate.toIso8601String(),
    };
  }
}

class classModel {
  int? id;
  String title;
  String content;
  double x;
  double y;
  int eyes;
  String goodsid;
  int goodsnum;
  int badsnum;
  List<goodsModel> goods;
  int contentsnum;
  String contentid;
  List<contentModel> contents;
  String useid;
  String userName;
  String? avatarUrl;
  String thamed;
  DateTime createDate;
  String? imageUrl;

  classModel({
    this.id, 
    this.avatarUrl,
    this.imageUrl,
    required this.title, 
    required this.content, 
    required this.x, 
    required this.y, 
    required this.eyes, 
    required this.contentsnum, 
    required this.contentid,
    required this.contents, 
    required this.useid,
    required this.userName,
    required this.goodsid,
    required this.goodsnum,
    required this.badsnum,
    required this.goods,
    required this.thamed,
    required this.createDate
    }
  );

  factory classModel.fromJson(Map<String, dynamic> json) {
    var goodsJson = json['goods'] as List;
    var goods = goodsJson.map((goodsJson) => goodsModel.fromJson(goodsJson)).toList();
    var contentsJson = json['contents'] as List;
    var contents = contentsJson.map((contentsJson) => contentModel.fromJson(contentsJson)).toList();

    return classModel(
      id: json['id'] as int?,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      x: json['x'].toDouble() ?? 0.0,
      y: json['y'].toDouble() ?? 0.0,
      eyes: json['eyes'] as int,
      contentsnum: json['contentsnum'] as int,
      contentid: json['contentid'] as String,
      contents: contents,
      useid: json['useid'] ?? '',
      goodsid: json['goodsid'] as String,
      goodsnum: json['goodsnum'] as int,
      badsnum: json['badsnum'] as int,
      goods: goods, 
      thamed: json['thamed'] as String, 
      createDate: DateTime.now(), 
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Content': content,
      'X': x,
      'Y': y,
      'Eyes': eyes,
      'Contentsnum': contentsnum,
      'Goodsid': goodsid,
      'goodsnum': goodsnum,
      'badsnum': badsnum,
      'Goods': goods.map((goods) => goods.toJson()).toList(),
      'Contentid': contentid,
      'Contents': contents.map((contents) => contents.toJson()).toList(),
      'useid': useid,
      'UserName': userName,
      'AvatarUrl': avatarUrl,
      'Thamed': thamed,
      'CreateDate': createDate.toIso8601String(),
      'ImageUrl': imageUrl,
    };
  }
}

class NotificationModel {
  final int id;
  final int postId;
  final String userId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      postId: json['postId'] as int,
      userId: json['userId'] as String,
      content: json['content'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'PostId': postId,
      'UserId': userId,
      'Content': content,
      'IsRead': isRead,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }
}

class NotificationRequestModel {
  final int id;
  final int postId;
  final String userId;
  final String comment;

  NotificationRequestModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
  });

  factory NotificationRequestModel.fromJson(Map<String, dynamic> json) {
    return NotificationRequestModel(
      id: json['Id'] as int,
      postId: json['PostId'] as int,
      userId: json['UserId'] as String,
      comment: json['Comment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'PostId': postId,
      'UserId': userId,
      'Comment': comment,
    };
  }
}

class UserModel {
  int id;
  String? name;
  int level;
  int isLock;
  String? phoneNum;
  String password;
  String? email;
  String? useName;
  String? avatarUrl;

  UserModel({
    required this.id,
    this.name,
    required this.level,
    required this.isLock,
    this.phoneNum,
    required this.password,
    this.email,
    this.useName,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      level: json['level'] as int,
      isLock: json['isLock'] as int,
      phoneNum: json['phoneNum'] as String?,
      password: json['password'] as String,
      email: json['email'] as String?,
      useName: json['useName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'name': name,
      'level': level,
      'isLock': isLock,
      'phoneNum': phoneNum,
      'password': password,
      'email': email,
      'useName': useName,
      'avatarUrl': avatarUrl,
    };
  }
  
  UserModel copyWith({
    int? id,
    String? name,
    String? useName,
    String? phoneNum,
    String? email,
    String? password,
    int? level,
    int? isLock,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      useName: useName ?? this.useName,
      phoneNum: phoneNum ?? this.phoneNum,
      email: email ?? this.email,
      level: level ?? this.level,
      isLock: isLock ?? this.isLock, 
      password: password ?? this.password,
    );
  }
}