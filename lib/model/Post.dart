class Post {

  String _text;
  String _postedBy;
  int _likes;
  int _comments;

  Post(this._postedBy, this._text, this._likes, this._comments);


  String get text => _text;

  set text(String value) {
    _text = value;
  }

  String get postedBy => _postedBy;

  int get comments => _comments;

  set comments(int value) {
    _comments = value;
  }

  int get likes => _likes;

  set likes(int value) {
    _likes = value;
  }

  set postedBy(String value) {
    _postedBy = value;
  }
}