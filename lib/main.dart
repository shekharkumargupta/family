
import 'package:camera/camera.dart';
import 'package:family/view/MainTab.dart';
import 'package:family/widgets/CameraScreen.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];
late CameraDescription firstCamera;

Future<void> main() async{
  /*
  try {
    WidgetsFlutterBinding.ensureInitialized();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  */
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      //home: MainTab(),
      home: CameraScreen(),
    );
  }
}






/*
Future<void> initializeCamera() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    widget.cameras = await availableCameras().then((cameras) {
      widget.firstCamera = cameras.first;
      controller = CameraController(widget.firstCamera, ResolutionPreset.medium);
      _initializeControllerFuture = controller.initialize();
    }).catchError((e) {
      print('Error Camera:$e');
    });
  } on CameraException catch (e) {
    print(e);
  }
}
*/