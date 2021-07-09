class Media {

  int id;
  String _type;
  String _url;

  Media(this._type, this._url);

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get url => _url;

  set url(String value) {
    _url = value;
  }
}