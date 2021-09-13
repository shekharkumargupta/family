
import 'package:camera/camera.dart';
import 'package:family/view/MainTab.dart';
import 'package:family/widgets/TakePictureScreenWidget.dart';
import 'package:flutter/material.dart';


void main() {

  /*
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

  runApp(
    MaterialApp(
      title: 'Test Camera',
      builder: (context, child) =>
        TakePictureScreenWidget(cameras)
      ,
    )
    */

  runApp(MainTab());
}
