import 'package:flutter/material.dart';
import 'package:family/model/Post.dart';
import 'package:family/service/PostService.dart';

class PostItemBottomBar extends StatefulWidget {

  final Post post;

  PostItemBottomBar(this.post);

  @override
  State<StatefulWidget> createState() {
    return PostItemBottomBarState(post);
  }
}

class PostItemBottomBarState extends State<PostItemBottomBar> {

  Post post;
  PostItemBottomBarState(this.post);

  @override
  Widget build(BuildContext context) {
    return buildBottomBar(post);
  }


  Widget buildBottomBar(Post post) {
    return Container(
      child: Column(
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              Text('Likes ${post.likesCount}'),
              Text('Comments ${post.commentsCount}')
            ],
          ),

          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                //textColor: const Color(0xFF6200EE),
                onPressed: () {
                  setState(() {
                    PostService().increaseLike(post);
                    print(post.likesCount);
                  });
                },
                child: Icon(Icons.thumb_up_alt_outlined),
              ),
              TextButton(
                //textColor: const Color(0xFF6200EE),
                  onPressed: () {
                    // Perform some action
                  },
                  child: Icon(Icons.comment_outlined)
              ),
              TextButton(
                //textColor: const Color(0xFF6200EE),
                  onPressed: () {
                    // Perform some action
                  },
                  child: Icon(Icons.forward_5_outlined)
              ),
            ],
          )
        ],
      ),
    );
  }

}