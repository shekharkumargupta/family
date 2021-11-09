import 'package:family/model/Media.dart';
import 'package:family/model/Post.dart';

class PostService {


  static List<Post> postList = List.of({});

  static List<Media> mediaList = List.of({
    Media("IMAGE", "https://picsum.photos/900/600"),
    Media("IMAGE", "https://picsum.photos/900/700"),
    Media("IMAGE", "https://picsum.photos/900/800"),
  });


  static List<Post> getPostList() {

    /*
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
    */

    return postList;
  }

  static List<Post> findAll(){
    return getPostList();
  }



  static void increaseLike(Post post){
    post.likesCount = post.likesCount + 1;
  }

  static void addPost(Post post){
    if(post.medias == null) {
      post.setMedias(mediaList);
    }
    getPostList().add(post);
  }
}