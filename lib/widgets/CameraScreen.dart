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

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

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
      onNewCameraSelected(cameraController.description);
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
            body:_isCameraInitialized
            //body:true
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
                          //color: Colors.red,
                          child: createCameraPreview()
                        ),

                        //This container is for Flash Buttons
                        Positioned(
                          top: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            //color: Colors.deepPurple,
                            child: createFlashButtonRow(),
                          )
                        ),


                        //This container is for Camera Exposure Slider
                        Positioned(
                            left: 0,
                            top: 50,
                            child: Container(
                              width: 50,
                              height: MediaQuery.of(context).size.height - 100,
                              //color: Colors.amber,
                              child: createCameraExposureSlider(),
                            )
                        ),


                        //This container is for Camera Zoom Slider
                        Positioned(
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              width: MediaQuery.of(context).size.width,
                              height: 120,
                              //color: Colors.deepPurple,
                              child: Column(
                                children: [
                                  createCameraToggleButton(),
                                  createCameraZoomSlider()
                                ],
                              )
                            )
                        )

                      ]
                    )
                  )
                )
                :
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator())
                )
        )
    );
  }

  Widget createCameraPreview() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
              'Tap a camera',
              style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w900),
            );
    } else {
          return Listener(
              onPointerDown: (_) => _currentZoomLevel++,
              onPointerUp: (_) => _currentZoomLevel--,
              child: CameraPreview(controller!,
                      child: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                return GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onScaleStart: _handleScaleStart,
                                          onScaleUpdate: _handleScaleUpdate,
                                          onTapDown: (details) =>
                                              onViewFinderTap(details, constraints),
                                        );
                              }),
                      ),
          );
    }
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
              style: TextStyle(color: Colors.white),
            ),
          ],
        )
    );
  }

  Widget createCameraExposureSlider(){
    return
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Container(
              height: 80,
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

          Text(_currentExposureOffset.toStringAsFixed(1) + 'x',
            style: TextStyle(color: Colors.white),
          )
        ]
      );
  }


  Widget createFlashButtonRow(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    return
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MaterialButton(
            shape: CircleBorder(),
            child: Icon(
                  _isRearCameraSelected
                      ? Icons.camera_front
                      : Icons.camera_rear,
                  color: Colors.white,
                  size: 30,
                ),
            onPressed: () {
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
          ),

          MaterialButton(
            child: Icon(Icons.camera_alt,
                  color: Colors.white,
                  size: 30,
                ),
            onPressed: (){},
          ),

          MaterialButton(
            child:
                Icon(Icons.video_camera_back,
                      color: Colors.white,
                      size: 30,
                  ),
            onPressed: (){},
          ),
      ]
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _minAvailableZoom = _currentZoomLevel;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentZoomLevel = (_minAvailableZoom * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentZoomLevel);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }
}