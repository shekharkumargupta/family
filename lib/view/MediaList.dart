import 'package:flutter/material.dart';

import 'PostForm.dart';

class MediaList extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        child: new Text("PeopleList"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          //print('Current index ${selectedTabIndex}');
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => PostForm()),
          );
        },
        child: const Icon(Icons.add_photo_alternate),
        backgroundColor: Colors.indigo,
      ),
    );
  }

}