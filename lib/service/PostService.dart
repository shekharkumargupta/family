import 'package:family/model/Post.dart';

class PostService {

  List<Post> findAll() {
    return List.of(
      {
        Post("Shekhar Kumar",
            "Mohandas Karamchand Gandhi was an Indian lawyer, anti-colonial nationalist, and political ethicist who employed nonviolent resistance to lead the successful campaign for India's independence from British rule and in turn inspired movements for civil rights and freedom across the world.",
            10,
            2
        ),

        Post("Anjali Kumari",
            "Mohandas Karamchand Gandhi was an Indian lawyer, anti-colonial nationalist, and political ethicist who employed nonviolent resistance to lead the successful campaign for India's independence from British rule and in turn inspired movements for civil rights and freedom across the world.",
            15,
            3
        ),

        Post("Samriddhi Shekhar",
            "Mohandas Karamchand Gandhi was an Indian lawyer, anti-colonial nationalist, and political ethicist who employed nonviolent resistance to lead the successful campaign for India's independence from British rule and in turn inspired movements for civil rights and freedom across the world.",
            25,
            5
        )
      }
    );
  }

  void increaseLike(Post post){
    post.likesCount = post.likesCount + 1;
  }
}