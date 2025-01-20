class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }

  String getMessage() {
    return "$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message]) : super(message, "Error: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

class FormatException extends CustomException {
  FormatException([String? message]) : super(message, "Invalid Format: ");
}

class TypeException extends CustomException {
  TypeException([String? message]) : super(message, "Invalid Format: ");
}

class InternalException extends CustomException {
  InternalException([String? message]) : super(message, "Invalid Format: ");
}
