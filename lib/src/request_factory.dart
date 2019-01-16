import 'package:flutter_base_request/src/constant.dart';
import 'package:flutter_base_request/src/request_callback.dart';
import 'request_loader.dart';
import 'dart:async';

class RequestFactory<T> {
  String _baseUrl;
  String _newBaseUrl;
  String _endPointUrl;
  int _requestType;
  RequestCallback<T> _callback;
  Map<String, String> _headers;
  Map<String, dynamic> _params;
  bool _isAuthRequest = true;
  String _authToken;
  int _timeout = Constant.timeout;

  RequestFactory<T> addBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    return this;
  }

  RequestFactory<T> changeBaseUrl(String newBaseUrl) {
    _newBaseUrl = newBaseUrl;
    return this;
  }

  RequestFactory<T> addEndPointUrl(String url) {
    _endPointUrl = url;
    return this;
  }

  RequestFactory<T> addRequestMethod(int requestType) {
    _requestType = requestType;
    return this;
  }

  RequestFactory<T> addHeaders(Map<String, String> header) {
    _headers = header;
    return this;
  }

  RequestFactory<T> addParams(Map<String, dynamic> params) {
    _params = params;
    return this;
  }

  RequestFactory<T> addCallback(RequestCallback<T> callback) {
    _callback = callback;
    return this;
  }

  RequestFactory<T> isAuthRequest(bool isAuthRequest) {
    _isAuthRequest = isAuthRequest;
    return this;
  }

  RequestFactory<T> addAuthToken(String token) {
    _authToken = token;
    return this;
  }

  RequestFactory<T> setTimeout(int timeout) {
    _timeout = timeout;
    return this;
  }

  Future doRequest() {
    if (_endPointUrl == null) throw Exception("Url must not be null");
    if (_requestType == null) throw Exception("Request type must not be null");

    var requestLoader = new RequestLoader<T>();
    requestLoader.addRequestUrl(_endPointUrl);
    requestLoader.addRequestMethod(_requestType);

    if (_baseUrl != null && _baseUrl.length > 0)
      requestLoader.addBaseUrl(_baseUrl);

    if (_newBaseUrl != null && _newBaseUrl.length > 0)
      requestLoader.changeBaseUrl(_newBaseUrl);

    if (_headers != null)
      requestLoader.addHeaders(_headers);

    if (_params != null)
      requestLoader.addParams(_params);

    if (_callback != null)
      requestLoader.addCallback(_callback);

    if (_authToken != null && _authToken.length > 0)
      requestLoader.addAuthToken(_authToken);

    requestLoader.isAuthRequest(_isAuthRequest);
    requestLoader.setTimeout(_timeout);

    return requestLoader.request();
  }
}
