// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_dirve/Service/classmodel_service.dart';
import 'package:test_dirve/fuction/info_button.dart';
import 'package:test_dirve/providers/user_provider.dart';

class ForumPage extends StatefulWidget {
  final classModel pin;
  const ForumPage({super.key, required this.pin});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _commentController = TextEditingController();
  final classmodel_service _service = classmodel_service();
  String? _useid;
  List<contentModel> _comments = [];    // 评论列表
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    _useid = Provider.of<UserProvider>(context, listen: false).user ?? '默认用户名';
    _fetchComments();   // 获取评论列表
  }
  void _fetchComments() async {
    try {
      final comments = await _service.getCommentsByPost(widget.pin.contentid);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取评论失败：$e')),
      );
    }
  }
  void _like() async {
    try {
      final updatedClassModel = await _service.like(widget.pin.contentid, widget.pin.goodsid, _useid!);
      setState(() {
        widget.pin.goodsnum = updatedClassModel.goodsnum;
        widget.pin.badsnum = updatedClassModel.badsnum;
        _isLiked = true;
        _isDisliked = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('点赞失败：$e')),
      );
    }
  }
  void _cancelLike() async {
    try {
      final updatedClassModel = await _service.cancelLike(widget.pin.contentid, widget.pin.goodsid, _useid!);
      setState(() {
        widget.pin.goodsnum = updatedClassModel.goodsnum;
        widget.pin.badsnum = updatedClassModel.badsnum;
        _isLiked = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('取消点赞失败：$e')),
      );
    }
  }
  void _dislike() async {
    try {
      final updatedClassModel = await _service.dislike(widget.pin.contentid, widget.pin.goodsid, _useid!);
      setState(() {
        widget.pin.goodsnum = updatedClassModel.goodsnum;
        widget.pin.badsnum = updatedClassModel.badsnum;
        _isLiked = false;
        _isDisliked = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('点踩失败：$e')),
      );
    }
  }
  void _cancelDislike() async {
    try {
      final updatedClassModel = await _service.cancelDislike(widget.pin.contentid, widget.pin.goodsid, _useid!);
      setState(() {
        widget.pin.goodsnum = updatedClassModel.goodsnum;
        widget.pin.badsnum = updatedClassModel.badsnum;
        _isDisliked = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('取消点踩失败：$e')),
      );
    }
  }
  void _submitComment() async {
    final comment = _commentController.text;
    if (comment.isNotEmpty) {
      // 创建一个新的 contentModel 对象
      final newComment = contentModel(
        id: 0,
        contentid: widget.pin.contentid,
        useid: _useid!,
        commnet: comment,
        commentDate: DateTime.now(),
        goodsid: '',
        goods: [],
      );
      // 调用后端 API 提交评论
      bool success = await _service.addComment(widget.pin.id!, newComment);
      if (success) {
        // 刷新评论列表或显示成功消息
        setState(() {
          widget.pin.contents.add(newComment);
          _commentController.clear();
        });
        // 调用后端 API 发送通知
        await _service.notifyPostAuthor(widget.pin.id!, _useid!, comment);
      } else {
        // 显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('评论提交失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text(widget.pin.title),
        actions: [
          InfoPopupMenuButton(
            onNotificationRead: () {
              // 可以在这里处理通知读取后的逻辑，如果需要
            }
          )
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${widget.pin.useid}:',
              style: const TextStyle(fontSize: 14)
            ),
            const SizedBox(height: 4),
            Text(
              widget.pin.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '查看数: ${widget.pin.eyes}    讨论数: ${widget.pin.contentsnum}    创建时间: ${DateTime.now()}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.thumb_up, size: 14.0, color: _isLiked ? Colors.red : null),
                  onPressed: _isDisliked ? null : (_isLiked ? _cancelLike : _like),
                ),
                Text(
                  '${widget.pin.goodsnum}',
                  style: const TextStyle(fontSize: 14, color: Colors.red)
                ),
                IconButton(
                  icon: Icon(Icons.thumb_down, size: 14.0, color: _isDisliked ? Colors.blue : null),
                  onPressed: _isLiked ? null : (_isDisliked ? _cancelDislike : _dislike),
                ),
                Text(
                  '${widget.pin.badsnum}',
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                )
              ]
            ),
            const SizedBox(height: 16),
            const Text(
              '评论:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length + 1,
                itemBuilder: (context, index) {
                  if (index < _comments.length) {
                    final commentData = _comments[index];
                    final useid = commentData.useid;
                    final comment = commentData.commnet;
                    return ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                  text: '@$useid:',
                                  style: const TextStyle(fontSize: 14, color: Colors.red),
                                ),
                                TextSpan(
                                  text: comment,
                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                )
                              ]
                            )
                          ),
                          const Divider(height: 1, color: Colors.black),
                        ]
                      ),
                    );
                  } else {
                    // 最后一项显示“已是最后的评论”和分割线
                    return const Column(
                      children: [
                        Divider(height: 1, color: Colors.grey),
                        Center(
                          child: Text(
                            '已是最后的评论了',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          )
                        )
                      ]
                    );
                  }
                }
              )
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: '添加评论',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _submitComment,
              child: const Text('提交评论'),
            )
          ]
        )
      )
    );
  }
}

// var datas = await baseDbContext.TAgencyOrCustomers
//       .ExcludeDeleted()
//       .Where(data.Filter)
//       .OrderBy(data.OrderBy)
//       .ToPagedListAsync<DDIReportServerBaseDb.TAgencyOrCustomers, AgencyOrCustomersModel>(data.Paging);

// public static async Task<Qufun.FrameworkCore.Outputs.PagedResult<TModel>> ToPagedListAsync<TEntity, TModel>([Required] this IQueryable<TEntity> query, Paging? paging) where TEntity : class where TModel: Model{
//   int totalCount = await query.CountAsync();
//   int count = paging?.StartIndex(toalCount) ?? 0;
//   if (paging != null){
//     query = query.Skip(count).Take(paging.PageSize);
//   }
//   List<TEntity> list = await query.ToListAsync();
//   int pageIndx = paging?.PageIndex ?? 1;
//   int num = paging?.PageSize ?? totalCount;
//   int totalPage = ((totalCount <= 0) ? 1 : ((int)Math.Ceiling((decimal)totalCount / (decimal)num)));
//   Qufun.FrameworkCore.Outputs.PagedResult<TModel> obj = new Qufun.FrameworkCore.Outputs.PagedResult<TModel>{
//     PageIndex = pageIndex,
//     PageSize = num,
//     TotalPages = totalPages,
//     TotalRecords = totalCount
//   };
//   IEnumerable<TModel> items;
//   if (!(typeof(TModel) == typeof(TEntity))){
//     items = list.ToModels<TEntity, TModel>();
//   }
//   else {
//     IEnumerable<TModel> enumerable = list as List<TModel>;
//     items = enumerable;
//   }
//   obj.Items = items;
//   return obj;
// }