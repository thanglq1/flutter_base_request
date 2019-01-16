class BaseRequestException implements Exception {
  int errorCode;
  String errorMessage;

  BaseRequestException(this.errorCode, this.errorMessage);
}