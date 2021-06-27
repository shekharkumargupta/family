import 'package:flutter/material.dart';
import 'package:family/model/Post.dart';
import 'package:family/view/PostItemBottomBar.dart';
import 'package:family/widgets/ImageWidget.dart';

class PostListItem extends StatelessWidget{

  final Post post;

  PostListItem(this.post);

  @override
  Widget build(BuildContext context) {
    return buildPostCardRow(post);
  }

  Widget buildPostCardRow(Post post){
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                    post.postedBy.characters.first.toUpperCase()
                ),
              ),
            ),
            title: Text(post.postedBy),
            subtitle: Text(
              'Subtitle',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            trailing: Icon(Icons.favorite),
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              post.text,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          Container(
            alignment: Alignment.center,
            child: FutureBuilder<Widget>(
              future: ImageWidget().createImageWidget('https://picsum.photos/900/600'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data;
                } else {
                  return Text('LOADING...');
                }
              },
            ),
          ),
          PostItemBottomBar(post),
        ],
      ),
    );
  }
}