class BladeException implements Exception {
  final String message;

  BladeException(this.message);

  factory BladeException.noSuchDirective(name) =>
      new BladeException("No directive found by name '$name'.");

  @override
  String toString() => 'Blade exception: $message';
}
