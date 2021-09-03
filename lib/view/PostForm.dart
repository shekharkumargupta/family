import 'package:flutter/material.dart';

class PostForm extends StatefulWidget {

  const PostForm ({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PostFormState();
  }
}

class PostFormState extends State<PostForm> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post your feed'),),
      body: Padding(
        padding: EdgeInsets.all(25.0),
        child:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              createPostForm(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget createPostForm(BuildContext context){
    return Container(
      child: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(

                ),
                labelText: 'Express yourself here'
              ),
            )
          ],
        ),
      ),
    );
  }
}