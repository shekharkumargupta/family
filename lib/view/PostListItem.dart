import 'package:family/model/Media.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:family/model/Post.dart';
import 'package:family/view/PostItemBottomBar.dart';
import 'package:family/widgets/ImageWidget.dart';
import 'package:family/widgets/ImageSlider.dart';

class PostListItem extends StatelessWidget {
  final Post post;

  PostListItem(this.post);

  @override
  Widget build(BuildContext context) {
    return buildPostCardRow(post);
  }

  Widget buildPostCardRow(Post post) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Container(
                alignment: Alignment.center,
                child: Text(post.postedBy.characters.first.toUpperCase()),
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
            child: Text(post.text, textAlign: TextAlign.left),
          ),
          ImageSlider(post.medias),
          PostItemBottomBar(post),
        ],
      ),
    );
  }
}
