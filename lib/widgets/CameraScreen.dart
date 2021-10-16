import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver{

  CameraController? controller;
  late Future<void> initializeCameraControllerFuture;
  bool _isCameraInitialized = false;

  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;

  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  FlashMode? _currentFlashMode;

  bool _isRearCameraSelected = true;

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
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {

    final previousCameraController = controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    //initializeCameraControllerFuture = cameraController.initialize();

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

      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),

        //initializeCameraControllerFuture = cameraController.initialize(),
      ]);
      _currentFlashMode = controller!.value.flashMode;

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
      onNewCameraSelected(cameraController!.description);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: createCameraScreen()
    );
  }

  Widget createCameraScreen(){
    return SafeArea(
        child: Scaffold(
            //body:_isCameraInitialized
          body:true
                ?
                Center(
                  child:Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        //This container is for Camera Preview
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 200,
                          color: Colors.red,
                        ),

                        //This container is for Flash Buttons
                        Positioned(
                          top: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            color: Colors.deepPurple,
                            child: createFlashButtonRow(),
                          )
                        ),


                        //This container is for Camera Exposure Slider
                        Positioned(
                            right: 0,
                            top: 50,
                            child: Container(
                              width: 50,
                              height: MediaQuery.of(context).size.height - 100,
                              color: Colors.amber,
                              child: createCameraExposureSlider(),
                            )
                        ),

                        //This container is for Camera Zoom Slider
                        Positioned(
                            bottom: 80,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              color: Colors.green,
                              child: createCameraZoomSlider()
                            )
                        ),

                        //This container is for Toggle Buttons and Take Picture
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 80,
                            color: Colors.blue,
                            child: createCameraToggleButton(),
                          )
                        )



                        /*
                        createCameraQualityDropDown(),
                        createCameraZoomSlider(),
                        createCameraExposureSlider(),
                        createFlashButtonRow(),
                        createCameraToggleButton()
                        */
                      ]
                    )
                  )
                )
                : Center(
                    child: CircularProgressIndicator(backgroundColor: Colors.black,),
                )

        )
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

  Widget createCameraZoomSlider(){
    return
      Expanded(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            createCameraQualityDropDown(),
            Slider(
              value: _currentZoomLevel,
              min: _minAvailableZoom,
              max: _maxAvailableZoom,
              activeColor: Colors.blue,
              inactiveColor: Colors.white30,
              onChanged: (value) async {
                setState(() {
                  _currentZoomLevel = value;
                });
                await controller!.setZoomLevel(value);
              },
            ),
            Text(
              _currentZoomLevel.toStringAsFixed(1) +
                    'x',
              style: TextStyle(color: Colors.white,),
            ),
          ],
        )
    );
  }

  Widget createCameraExposureSlider(){
    return
      Row(
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Container(
              height: 30,
              child: Slider(
                value: _currentExposureOffset,
                min: _minAvailableExposureOffset,
                max: _maxAvailableExposureOffset,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) async {
                  setState(() {
                    _currentExposureOffset = value;
                  });
                  await controller!.setExposureOffset(value);
                },
              ),
            ),
          ),

          //spacer
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 16.0),
              child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)
              ),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_currentExposureOffset.toStringAsFixed(1) + 'x',
                            style: TextStyle(color: Colors.black),
                        )
                      ),
                    ),
          ),
        ]
      );
  }


  Widget createFlashButtonRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlashMode = FlashMode.off;
            });
            await controller!.setFlashMode(
                      FlashMode.off,
                  );
          },
          child: Icon(
            Icons.flash_off,
            color: _currentFlashMode == FlashMode.off
                ? Colors.amber
                : Colors.white,
          ),
        ),
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlashMode = FlashMode.auto;
            });
            await controller!.setFlashMode(
                  FlashMode.auto,
                );
            },
          child: Icon(
            Icons.flash_auto,
            color: _currentFlashMode == FlashMode.auto
                ? Colors.amber
                : Colors.white,
          ),
        ),
        InkWell(
          onTap: () async {
            setState(() {
              _isCameraInitialized = false;
            });
            onNewCameraSelected(
              cameras[_isRearCameraSelected ? 1 : 0],
            );
            setState(() {
              _isRearCameraSelected = !_isRearCameraSelected;
            });
          },
          child: Icon(
            Icons.flash_on,
            color: _currentFlashMode == FlashMode.always
                ? Colors.amber
                : Colors.white,
          ),
        ),
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlashMode = FlashMode.torch;
            });
            await controller!.setFlashMode(
                        FlashMode.torch,
                  );
            },
          child: Icon(
            Icons.highlight,
            color: _currentFlashMode == FlashMode.torch
                ? Colors.amber
                : Colors.white,
          ),
        ),
      ],
    );
  }


  Widget createCameraToggleButton(){
    return InkWell(
      onTap: () {
        setState(() {
          _isCameraInitialized = false;
        });
        onNewCameraSelected(
          cameras[_isRearCameraSelected ? 0 : 1],
        );
        setState(() {
          _isRearCameraSelected = !_isRearCameraSelected;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.circle,
            color: Colors.black38,
            size: 60,
          ),
          Icon(
            _isRearCameraSelected
                ? Icons.camera_front
                : Icons.camera_rear,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

}