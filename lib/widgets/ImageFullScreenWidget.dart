import 'package:flutter/material.dart';


class ImageFullScreenWidget extends StatelessWidget{

  String imageUrl = '';

  ImageFullScreenWidget(String imageUrl){
    this.imageUrl = imageUrl;
  }


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
              imageUrl,
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