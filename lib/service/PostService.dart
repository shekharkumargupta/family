import 'dart:io';

import 'package:family/model/Media.dart';
import 'package:family/model/Post.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;

class PostService {

  //FirebaseApp familyApp = Firebase.app('family');
  static firebaseStorage.FirebaseStorage storage = firebaseStorage.FirebaseStorage.instance;


  static List<Post> postList = List.of({});

  static List<Media> mediaList = List.of({
    Media("IMAGE", "https://firebasestorage.googleapis.com/v0/b/family-3e0bf.appspot.com/o/WIN_20190818_18_12_04_Pro.jpg?alt=media&token=fee425e4-168b-4bee-b434-258f40190a70"),
    Media("IMAGE", "https://picsum.photos/900/700"),
    Media("IMAGE", "https://picsum.photos/900/800"),
  });


  static void loadSamplePost() {


    Post shekharPost = Post("Shekhar Kumar",
        "Mohandas Karamchand Gandhi was an Indian lawyer, anti-colonial nationalist, and political ethicist who employed nonviolent resistance to lead the successful campaign for India's independence from British rule and in turn inspired movements for civil rights and freedom across the world.",
        10,
        2
    );

    Post anjaliPost = Post("Anjali Kumari",
        "Mohandas Karamchand Gandhi was an Indian lawyer, anti-colonial nationalist, and political ethicist who employed nonviolent resistance to lead the successful campaign for India's independence from British rule and in turn inspired movements for civil rights and freedom across the world.",
        15,
        3
    );

    Post samriddhiPost = Post("Samriddhi Shekhar",
        "Mohandas Karamchand Gandhi was an Indian lawyer, anti-colonial nationalist, and political ethicist who employed nonviolent resistance to lead the successful campaign for India's independence from British rule and in turn inspired movements for civil rights and freedom across the world.",
        25,
        5
    );

    shekharPost.setMedias(mediaList);
    anjaliPost.setMedias(mediaList);
    samriddhiPost.setMedias(mediaList);

    postList.addAll({shekharPost, anjaliPost, samriddhiPost});
  }

  List<Post> findAll(){
    return postList;
  }



  static void increaseLike(Post post){
    post.likesCount = post.likesCount + 1;
  }

  static void addPost(Post post) async {
    postList.add(post);
  }
}