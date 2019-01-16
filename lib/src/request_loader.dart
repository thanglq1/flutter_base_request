import 'dart:async';
import 'dart:convert';
import 'package:flutter_base_request/src/constant.dart';
import 'package:flutter_base_request/src/request_callback.dart';
import 'package:flutter_base_request/src/request_type.dart';
import 'package:http/http.dart' as http;

class RequestLoader<T> {
  String _baseUrl;
  String _newBaseUrl;
  String _endPointUrl;
  int _requestType;
  RequestCallback<T> _callback;
  Map<String, String> _headers = Map();
  Map<String, dynamic> _params;
  bool _isAuthRequest;
  String _authToken;
  int _timeout = Constant.timeout;

  RequestLoader<T> addBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    return this;
  }

  RequestLoader<T> changeBaseUrl(String newBaseUrl) {
    _newBaseUrl = newBaseUrl;
    return this;
  }

  RequestLoader<T> addRequestUrl(String endPointUrl) {
    _endPointUrl = endPointUrl;
    return this;
  }

  RequestLoader<T> addRequestMethod(int requestType) {
    _requestType = requestType;
    return this;
  }

  RequestLoader<T> addHeaders(Map<String, String> header) {
    header.addAll(header);
    return this;
  }

  RequestLoader<T> addParams(Map<String, dynamic> params) {
    _params = params;
    return this;
  }

  RequestLoader<T> addCallback(RequestCallback<T> callback) {
    _callback = callback;
    return this;
  }

  RequestLoader<T> isAuthRequest(bool isAuthRequest) {
    _isAuthRequest = isAuthRequest;
    return this;
  }

  RequestLoader<T> addAuthToken(String token) {
    _authToken = token;
    return this;
  }

  RequestLoader<T> setTimeout(int timeout) {
    _timeout = timeout;
    return this;
  }

  Future request() async {
    if (_endPointUrl.isEmpty) throw Exception('URL is empty!!');
    http.Response response;
    if (_callback != null) {
      _callback.onStart();
    }
    try {
      String url = _baseUrl + _endPointUrl;
      if (_newBaseUrl != null && _newBaseUrl.length > 0) {
        url = _newBaseUrl + _endPointUrl;
      }
      _headers["content-type"] = "application/json";
      if (_isAuthRequest && _authToken.length > 0) {
        _headers["authorization"] = "bearer " + _authToken;
      }
      print(
          "RequestLoader=>url= $url \n params= $_params \n isAuthor=$_isAuthRequest \n headers= _$_headers");
      switch (_requestType) {
        case RequestType.POST:
          response = await http
              .post(url, headers: _headers, body: json.encode(_params))
              .timeout(Duration(seconds: _timeout));
          break;
        case RequestType.GET:
          response = await http
              .get(url, headers: _headers)
              .timeout(Duration(seconds: _timeout));
          break;
        case RequestType.PUT:
          response = await http
              .put(url, headers: _headers, body: json.encode(_params))
              .timeout(Duration(seconds: _timeout));
          break;
        default:
          response = await http
              .get(url, headers: _headers)
              .timeout(Duration(seconds: _timeout));
      }

      if (response != null) {
        int statusCode = response.statusCode;
        String jsonResponse = response.body;
        print(
            "RequestLoader=>url= $url \n statusCode= $statusCode \n json=$jsonResponse");
        if (_callback != null) {
          if (statusCode < Constant.statusCodeSuccess ||
              statusCode >= Constant.statusCodeError) {
            _callback.onError(new RequestException(statusCode, response.body));
          } else {
            _callback.onCompleted(json.decode(jsonResponse));
          }
        }
      }
    } catch (e) {
      print("error=" + e.toString());
      if (_callback != null) _callback.onError(e);
    }
  }
}

class RequestException implements Exception {
  int errorCode;
  String errorMessage;

  RequestException(this.errorCode, this.errorMessage);
}
