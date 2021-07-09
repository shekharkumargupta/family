import 'package:family/model/Media.dart';
import 'package:family/model/Post.dart';

class PostService {

  List<Post> findAll() {

    List<Media> mediaList = List.of({
      Media("IMAGE", "https://picsum.photos/900/600"),
      Media("IMAGE", "https://picsum.photos/900/700"),
      Media("IMAGE", "https://picsum.photos/900/800"),
    });

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

    return List.of({
       shekharPost,
       anjaliPost,
       samriddhiPost
      });
  }

  void increaseLike(Post post){
    post.likesCount = post.likesCount + 1;
  }
}