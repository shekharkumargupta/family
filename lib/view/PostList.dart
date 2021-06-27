import 'package:flutter/material.dart';
import 'package:family/model/Post.dart';
import 'package:family/view/PostListItem.dart';
import 'package:family/service/PostService.dart';

class PostList extends StatefulWidget{


  @override
  State<StatefulWidget> createState() {
      return PostState();
  }
}

class PostState extends State<PostList> {

  List<Post> posts = PostService().findAll();

  @override
  Widget build(BuildContext klcontext) {
    return postList();
  }

  Widget postList(){
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index){
          return PostListItem(posts.elementAt(index));
      },
    );
  }
}