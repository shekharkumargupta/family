import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loading_animations/loading_animations.dart';


import 'package:family/model/Media.dart';
import 'package:family/widgets/ImageWidget.dart';

class ImageSlider extends StatefulWidget {


  List<Media> medias;
  ImageSlider(this.medias);

  @override
  State<StatefulWidget> createState() {
    return ImageSliderState();
  }
}

class ImageSliderState extends State<ImageSlider>{

  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return createImageSlider(widget.medias);
  }

  createImageSlider(List<Media> medias){
    return CarouselSlider(
      items: createImageSliderItems(medias),
      options: CarouselOptions(
        //height: 180.0,
        enlargeCenterPage: true,
        autoPlay: false,
        aspectRatio: 12 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 900),
        viewportFraction: 1,
      ),
    );
  }

  createImageSliderItems(List<Media> medias){
    List<Widget> widgetList = [];

    medias.forEach((media) {
      widgetList.add(createItem(media.url));
    });

    return widgetList;
  }


  Widget createItem(String imageUrl){
    print("Firebase Image Url: " + imageUrl);
    return  Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white),
      child: FutureBuilder<String>(
        future: loadImage(),
        builder: (BuildContext context, AsyncSnapshot<String> image) {
          if (image.hasData) {
            return Image.network(image.data.toString());
          } else {
            return  LoadingRotating.square(
              size: 40,
              backgroundColor: Colors.black12,
            );
          }
        },
      ),
    );
  }


  Future<String> loadImage() async {
    var reference = storage
        .ref()
        .child("WIN_20190818_18_12_04_Pro.jpg");

    var url = await reference.getDownloadURL();
    return url;
  }


}