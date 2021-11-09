import 'package:flutter/material.dart';

import 'package:family/main.dart';

class ImageFullScreenWidget extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Hero(
            tag: 'None',
            child: Image.network(
              imageFile!.path,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

}