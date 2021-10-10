
import 'Comment.dart';
import 'Media.dart';
import 'Person.dart';

class Post {

  String _text;
  String _postedBy;
  Set<Person> _likers = {};
  List<Comment> _comments = [];
  List<Media> _medias = [];


  int _likesCount;
  int _commentsCount;


  Post(this._postedBy, this._text, this._likesCount, this._commentsCount);

  int get commentsCount => _commentsCount;

  set commentsCount(int value) {
    _commentsCount = value;
  }

  int get likesCount => _likesCount;

  set likesCount(int value) {
    _likesCount = value;
  }

  List<Comment> get comments => _comments;

  set comments(List<Comment> value) {
    _comments = value;
  }

  Set<Person> get likers => _likers;

  set likers(Set<Person> value) {
    _likers = value;
  }

  String get postedBy => _postedBy;

  set postedBy(String value) {
    _postedBy = value;
  }

  String get text => _text;

  set text(String value) {
    _text = value;
  }

  List<Media> get medias => _medias;

  set medias(List<Media> value) {
    _medias = value;
  }

  setMedias(List<Media> value){
    _medias = value;
  }
}