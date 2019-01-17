import 'package:flutter_base_request/src/constant.dart';
import 'package:flutter_base_request/src/request_callback.dart';
import 'request_loader.dart';
import 'dart:async';
import 'request_type.dart';

class BaseRequestFactory<T> {
  String _baseUrl;
  String _newBaseUrl;
  String _endPointUrl;
  int _requestMethod;
  BaseRequestType _requestType;
  BaseRequestCallback<T> _callback;
  Map<String, String> _headers;
  Map<String, dynamic> _params;
  bool _isAuthRequest = true;
  bool _isContentTypeApplicationJson = true;
  String _authToken;
  int _timeout = BaseConstant.timeout;

  BaseRequestFactory<T> addBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    return this;
  }

  BaseRequestFactory<T> changeBaseUrl(String newBaseUrl) {
    _newBaseUrl = newBaseUrl;
    return this;
  }

  BaseRequestFactory<T> addEndPointUrl(String url) {
    _endPointUrl = url;
    return this;
  }

  BaseRequestFactory<T> addRequestMethod(int requestMethod) {
    _requestMethod = requestMethod;
    return this;
  }

  BaseRequestFactory<T> addRequestType(BaseRequestType requestType) {
    _requestType = requestType;
    return this;
  }

  BaseRequestFactory<T> addHeaders(Map<String, String> header) {
    _headers = header;
    return this;
  }

  BaseRequestFactory<T> addParams(Map<String, dynamic> params) {
    _params = params;
    return this;
  }

  BaseRequestFactory<T> addCallback(BaseRequestCallback<T> callback) {
    _callback = callback;
    return this;
  }

  BaseRequestFactory<T> isAuthRequest(bool isAuthRequest) {
    _isAuthRequest = isAuthRequest;
    return this;
  }

  BaseRequestFactory<T> isContentTypeApplicationJsonRequest(
      bool isContentTypeApplicationJson) {
    _isContentTypeApplicationJson = _isContentTypeApplicationJson;
    return this;
  }

  BaseRequestFactory<T> addAuthToken(String token) {
    _authToken = token;
    return this;
  }

  BaseRequestFactory<T> setTimeout(int timeout) {
    _timeout = timeout;
    return this;
  }

  Future doRequest() {
    if (_endPointUrl == null) throw Exception("Url must not be null");
    if (_requestMethod == null)
      throw Exception("Request type must not be null");

    var requestLoader = new BaseRequestLoader<T>();
    requestLoader.addRequestUrl(_endPointUrl);
    requestLoader.addRequestMethod(_requestMethod);
    requestLoader.isAuthRequest(_isAuthRequest);
    requestLoader.isContentTypeApplicationJsonRequest(_isAuthRequest);
    requestLoader.setTimeout(_timeout);

    if (_baseUrl != null && _baseUrl.length > 0)
      requestLoader.addBaseUrl(_baseUrl);

    if (_newBaseUrl != null && _newBaseUrl.length > 0)
      requestLoader.changeBaseUrl(_newBaseUrl);

    if (_headers != null) requestLoader.addHeaders(_headers);

    if (_params != null) requestLoader.addParams(_params);

    if (_callback != null) requestLoader.addCallback(_callback);

    if (_authToken != null && _authToken.length > 0)
      requestLoader.addAuthToken(_authToken);

    switch (_requestType) {
      case BaseRequestType.DIO:
        return requestLoader.dioRequest();
      case BaseRequestType.HTTP:
        return requestLoader.httpRequest();
      default:
        return requestLoader.httpRequest();
    }
  }
}
