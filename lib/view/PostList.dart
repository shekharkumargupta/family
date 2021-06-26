import 'dart:async';
import 'package:flutter/material.dart';
import 'package:family/model/Post.dart';
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
          return buildPostCardRow(posts.elementAt(index));
      },
    );
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
            padding: const EdgeInsets.all(16.0),
            child: Text(
              post.text,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          Container(
            alignment: Alignment.center,
            child: FutureBuilder<Widget>(
              future: getImage(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data;
                } else {
                  return Text('LOADING...');
                }
              },
            ),
          ),

          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: () {
                  // Perform some action
                },
                child: const Text('ACTION 1'),
              ),
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: () {
                  // Perform some action
                },
                child: const Text('ACTION 2'),
              ),
            ],
          ),
          Image.asset('https://sureshnanda.files.wordpress.com/2013/10/chinese-general-tso-chicken-suresh-nanda.jpg'),
          Image.asset('assets/card-sample-image-2.jpg'),
        ],
      ),
    );
  }

  Future<Widget> getImage() async {
    final Completer<Widget> completer = Completer();
    final url = 'https://picsum.photos/900/600';
    final image = NetworkImage(url);
    // final config = await image.obtainKey();
    final load = image.resolve(const ImageConfiguration());

    final listener = new ImageStreamListener((ImageInfo info, isSync) async {
      print(info.image.width);
      print(info.image.height);

      if (info.image.width == 80 && info.image.height == 160) {
        completer.complete(Container(child: Text('AZAZA')));
      } else {
        completer.complete(Container(child: Image(image: image)));
      }
    });

    load.addListener(listener);
    return completer.future;
  }

}