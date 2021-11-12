import 'package:camera/camera.dart';
import 'package:family/model/Post.dart';
import 'package:family/service/PostService.dart';
import 'package:family/view/PostListItem.dart';
import 'package:flutter/material.dart';

import 'PostForm.dart';
import 'package:family/main.dart';

class PostList extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {

      postService.loadSamplePost();
      return PostState();
  }
}

class PostState extends State<PostList> {

  List<Post> posts = postService.findAll();

  @override
  Widget build(BuildContext klcontext) {

    return  Scaffold(
        body: postList(),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            //print('Current index ${selectedTabIndex}');
            Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  PostForm()),
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