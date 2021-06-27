class Person {

  String _name;
  String _profession;

  Person(this._name, this._profession);

  String get profession => _profession;

  set profession(String value) {
    _profession = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

}