import 'dart:io';
import 'package:family/widgets/ImageSlider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class PostForm extends StatefulWidget {

  const PostForm ({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PostFormState();
  }
}

class PostFormState extends State<PostForm> {

  final _formKey = GlobalKey<FormState>();
  int selectedIndex = 0;
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
      appBar: AppBar(
        title: const Text('Post your thought'),
      ),
      body: Center(
        child: createPostForm(context),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Take Photo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'From Gallary',
          )
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if(selectedIndex == 0){
      getImageFromCamera();
    }
    if(selectedIndex == 1){
      getImageFromGallary();
    }
  }

  Widget createPostForm(BuildContext context){

    return Container(
      child: Form(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                //height: 200.0,
                child: Center(
                  child: imageFile == null
                      ? Text("No Image is picked")
                      : ImageSlider().createImageItem(imageFile.path),
                ),
              ),
            ),

            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                  border: OutlineInputBorder(

                  ),
                  labelText: 'Express yourself here'
              ),
            ),
          ],
        ),
      ),
    );
  }
}