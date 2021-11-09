import 'dart:io';

import 'package:family/model/Media.dart';
import 'package:family/model/Post.dart';
import 'package:family/service/PostService.dart';
import 'package:family/widgets/CameraScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:family/main.dart';

import 'PostList.dart';

class PostForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostFormState();
  }
}

class PostFormState extends State<PostForm> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final textEditingController = TextEditingController();
  int selectedIndex = 0;

  //late File imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, body: createPostForm(context));
  }

  // ignore: undefined_annotation
  @override
  void dispose(){
    textEditingController.dispose();
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
    return SafeArea(
        child: Scaffold (
          body: Container(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 0,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: imageFile != null
                            ? Container(
                                child: createImageView()
                              )
                            : Container(
                                color: Colors.black12,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height - 300,
                                child: Center(
                                    child: //imageFile == null ?
                                        imageFile != null
                                            ? Text(imageFile!.path)
                                            : Text("Please select or click a photo")
                                    //: ImageSlider().createImageItem(imageFile.path),
                                    ),
                              ),
                      ),
                      Positioned(
                          bottom: 0,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            color: Colors.white,
                            child:  Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextFormField(
                                      controller: textEditingController,
                                      maxLines: 2,
                                      decoration:
                                          InputDecoration(labelText: 'Express yourself here'),
                                    )),
                                createBottomBar()
                              ]
                            ),
                          )
                      )
                    ],
                  ),
            )
        )
    );
  }

  Widget createBottomBar() {
    return Container(
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
                onPressed: () {},
              ),
              MaterialButton(
                child: Icon(
                  Icons.camera_enhance,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen()),
                  );
                },
              ),
              MaterialButton(
                child: Icon(
                  Icons.send,
                ),
                onPressed: () {
                  String postText = textEditingController.text;
                  Post post = Post('Shekhar Kumar', postText, 0, 0);
                  Media media = Media('MEDIA', imageFile!.path);
                  post.setMedias(List.of({media}));

                  setState(){
                    PostService.addPost(post);
                    showInSnackBar("Total Item $PostService.findAll().length");
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostList()),
                  );
                },
              )
            ]));
  }

  Image createImageView(){
    Image image;
    if (kIsWeb) {
      image = Image.network(imageFile!.path);
    } else {
      image = Image.file(File(imageFile!.path));
    }
    return image;
  }


  void showInSnackBar(String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }
}
