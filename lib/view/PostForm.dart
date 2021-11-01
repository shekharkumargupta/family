import 'dart:io';

import 'package:family/widgets/CameraScreen.dart';
import 'package:family/widgets/ImageWidget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

import 'package:family/main.dart';

class PostForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostFormState();
  }
}

class PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  int selectedIndex = 0;
  //late File imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Post your thought'),
        ),
        body: Center(
          child: createPostForm(context),
        )
      );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (selectedIndex == 0) {
      //TakePictureScreenWidget();
    }
    if (selectedIndex == 1) {}
  }

  Widget createPostForm(BuildContext context) {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: 0,
            child:
              imageFile != null
              ?
               Container(
                 child: FutureBuilder<Widget>(
                   future: ImageWidget().createImageWidget(imageFile!.path),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.network(imageFile!.path);
                      } else {
                        return  LoadingRotating.square(
                          size: 40,
                          backgroundColor: Colors.black12,
                        );
                      }
                    },
                  ),
               )
              :
               Container(
                color: Colors.black12,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 300,
                child: Center(
                    child: //imageFile == null ?
                    Text("Select or click an image")
                  //: ImageSlider().createImageItem(imageFile.path),
                ),
              ),

          ),



          Positioned(
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Positioned(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        maxLines: 2,
                        decoration:
                        InputDecoration(labelText: 'Express yourself here'),
                      )
                  ),
                ),
                createBottomBar()
              ],
            )
          )
        ],
      ),
    );
  }

  Widget createBottomBar() {
    return Container(
        //color: Colors.black12,
        padding: EdgeInsets.all(12.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                shape: CircleBorder(),
                child: Icon(
                  Icons.camera,
                  size: 30,
                ),
                onPressed: () {

                },
              ),
              MaterialButton(
                child:Icon(
                        Icons.camera_enhance,
                        size: 30,
                      ),
                onPressed: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>
                        CameraScreen()
                    ),
                  );
                },
              ),
              MaterialButton(
                child: Icon(
                        Icons.send,
                      ),
                onPressed: () {},
              )
            ]
        )
    );
  }
}
