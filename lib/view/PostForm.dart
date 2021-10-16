import 'dart:io';

import 'package:family/widgets/CameraExampleHome.dart';
import 'package:family/widgets/CameraScreen.dart';
import 'package:family/widgets/ImageSlider.dart';
import 'package:flutter/material.dart';


class PostForm extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return PostFormState();
  }
}

class PostFormState extends State<PostForm> {

  final _formKey = GlobalKey<FormState>();
  int selectedIndex = 0;
  late File imageFile;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post your thought'),
      ),
      body: Center(
        child: createPostForm(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
            Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  //TakePictureScreenWidget()
                //TakePictureServiceWidget()
                //CameraExampleHome()
                CameraScreen()
              ),
            );
        },
        child: const Icon(Icons.camera_alt),
        backgroundColor: Colors.indigo,
      )
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if(selectedIndex == 0){
      //TakePictureScreenWidget();
    }
    if(selectedIndex == 1){
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
                  child: //imageFile == null ?
                       Text("No Image is picked")
                      //: ImageSlider().createImageItem(imageFile.path),
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