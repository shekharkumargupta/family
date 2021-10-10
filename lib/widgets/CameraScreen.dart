import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver{

  CameraController? controller;
  bool _isCameraInitialized = false;

  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void initCamera(){
    availableCameras().then((availableCameras)  {
      cameras = availableCameras;
      if (cameras.length > 0) {
        onNewCameraSelected(cameras.first);
      }else{
        print("No camera available");
      }
    });
  }


  @override
  void initState() {
    super.initState();
    initCamera();
    //onNewCameraSelected(firstCamera);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? AspectRatio(
              aspectRatio: 1 / controller!.value.aspectRatio,
              child: controller!.buildPreview(),

          )
        : Container(
            child: createCameraQualityDropDown(),
          ),
    );
  }

  Widget createCameraQualityDropDown(){
    return DropdownButton<ResolutionPreset>(
        dropdownColor: Colors.black87,
        underline: Container(),
        value: currentResolutionPreset,
        items: [
                for (ResolutionPreset preset in resolutionPresets)
                  DropdownMenuItem(
                    child: Text(preset.toString().split('.')[1].toUpperCase(),
                              style:
                              TextStyle(color: Colors.white),
                            ),
                    value: preset,
                )
              ],
        onChanged: (value) {
                      setState(() {
                        currentResolutionPreset = value!;
                        _isCameraInitialized = false;
                        }
                      );
                        onNewCameraSelected(controller!.description);
                    },
        hint: Text("Select item"),
        );
  }
}