import 'dart:io';
import 'package:family/widgets/ImageSlider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostForm extends StatefulWidget {

  const PostForm ({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PostFormState();
  }
}

class PostFormState extends State<PostForm> {

  final _formKey = GlobalKey<FormState>();
  File imageFile;

  Future getImageFromCamera() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
  Future getImageFromGallary() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200.0,
                child: Center(
                  child: imageFile == null
                      ? Text("No Image is picked")
                      : ImageSlider().createImageItem(imageFile.path),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: getImageFromCamera,
                  tooltip: "pickImage",
                  child: Icon(Icons.add_a_photo),
                ),
                FloatingActionButton(
                  onPressed: getImageFromGallary,
                  tooltip: "Pick Image",
                  child: Icon(Icons.camera_alt),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}