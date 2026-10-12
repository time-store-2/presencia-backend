class AlreadyExistsException implements Exception {
  final String value;
  AlreadyExistsException(this.value);

  @override
  String toString() => 'AlreadyExistsException: $value';
}
