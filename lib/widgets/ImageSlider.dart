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
      widgetList.add(createImageItem(media.url));
    });
    return widgetList;
  }

   createImageItem(String imageUrl) {
     var reference = storage
         .ref()
         .child("WIN_20190818_18_12_04_Pro.jpg");

     String url = "https://picsum.photos/900/800";
     reference.getDownloadURL()
         .then((value) => {

         setState(() {
           url = value;
           print("Firebase Image Url: " + url);
         })
     });

     Widget  widget = createItem(url);

     return widget;
  }

  Widget createItem(String imageUrl){
    return  Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white),
      child: FutureBuilder<Widget>(
        future: ImageWidget().createImageWidget(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.network(imageUrl);
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


}