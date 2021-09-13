import 'dart:io';

import 'package:camera/camera.dart';
import 'package:family/widgets/ImageSlider.dart';
import 'package:family/widgets/TakePictureScreenWidget.dart';
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
  File imageFile;

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
          List<CameraDescription> cameras = [];
          Future<void> main() async {
            // Fetch the available cameras before initializing the app.
            try {
              WidgetsFlutterBinding.ensureInitialized();
              cameras = await availableCameras();
              print("Number of cameras: " + cameras.length.toString());
              /*
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => TakePictureScreenWidget(cameras)),
              );
              */
            } on CameraException catch (e) {
              //print(e.code + " " + e.description);
              print(e);
            }
          }

          Navigator.push(context,
            MaterialPageRoute(builder: (context) => TakePictureScreenWidget(cameras)),
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
                  child: imageFile == null ?
                       Text("No Image is picked")
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