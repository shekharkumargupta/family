import 'dart:async';

import 'package:flutter/material.dart';

class PostList extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Container(
      child: createPostCard(),
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

  Widget createPostCard(){
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.arrow_drop_down_circle),
            title: const Text('Card title 1'),
            subtitle: Text(
              'Secondary Text',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            trailing: Text('Trailing'),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Greyhound divisively hello coldly wonderfully marginally far upon excluding.',
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
}