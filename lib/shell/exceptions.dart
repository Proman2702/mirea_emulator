class ExitCommandException implements Exception {}

class CommandParseException implements Exception {
  final String message;
  CommandParseException({required this.message});
}
