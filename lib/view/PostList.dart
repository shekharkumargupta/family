import 'package:camera/camera.dart';
import 'package:family/model/Post.dart';
import 'package:family/service/PostService.dart';
import 'package:family/view/PostListItem.dart';
import 'package:flutter/material.dart';

import 'PostForm.dart';

class PostList extends StatefulWidget{

  final List<CameraDescription> cameras;

  const PostList({
    Key key,
    this.cameras
  }) : super(key: key);


  @override
  State<StatefulWidget> createState() {
      return PostState();
  }
}

class PostState extends State<PostList> {

  List<Post> posts = PostService().findAll();

  @override
  Widget build(BuildContext klcontext) {
    return  Scaffold(
        body: postList(),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            //print('Current index ${selectedTabIndex}');
            Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  PostForm(cameras: widget.cameras)),
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.indigo,
        ),
    );

      //postList();
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