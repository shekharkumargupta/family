import 'Person.dart';

class Comment {

  int id = 0;
  Person _commentedBy;
  String _text;

  Comment(this._commentedBy, this._text);

  String get text => _text;

  set text(String value) {
    _text = value;
  }

  Person get commentedBy => _commentedBy;

  set commentedBy(Person value) {
    _commentedBy = value;
  }
}