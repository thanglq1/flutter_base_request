import 'dart:async';
import 'dart:convert';
import 'package:flutter_base_request/src/constant.dart';
import 'package:flutter_base_request/src/request_callback.dart';
import 'package:flutter_base_request/src/request_exception.dart';
import 'package:flutter_base_request/src/request_type.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class BaseRequestLoader<T> {
  String _baseUrl;
  String _newBaseUrl;
  String _endPointUrl;
  int _requestType;
  BaseRequestCallback<T> _callback;
  Map<String, String> _headers = Map();
  Map<String, dynamic> _params;
  bool _isAuthRequest;
  String _authToken;
  int _timeout = BaseConstant.timeout;

  BaseRequestLoader<T> addBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    return this;
  }

  BaseRequestLoader<T> changeBaseUrl(String newBaseUrl) {
    _newBaseUrl = newBaseUrl;
    return this;
  }

  BaseRequestLoader<T> addRequestUrl(String endPointUrl) {
    _endPointUrl = endPointUrl;
    return this;
  }

  BaseRequestLoader<T> addRequestMethod(int requestType) {
    _requestType = requestType;
    return this;
  }

  BaseRequestLoader<T> addHeaders(Map<String, String> header) {
    header.addAll(header);
    return this;
  }

  BaseRequestLoader<T> addParams(Map<String, dynamic> params) {
    _params = params;
    return this;
  }

  BaseRequestLoader<T> addCallback(BaseRequestCallback<T> callback) {
    _callback = callback;
    return this;
  }

  BaseRequestLoader<T> isAuthRequest(bool isAuthRequest) {
    _isAuthRequest = isAuthRequest;
    return this;
  }

  BaseRequestLoader<T> addAuthToken(String token) {
    _authToken = token;
    return this;
  }

  BaseRequestLoader<T> setTimeout(int timeout) {
    _timeout = timeout;
    return this;
  }

  Future request() async {
    if (_endPointUrl.isEmpty || _baseUrl.isEmpty) throw Exception('URL is empty!!');

    if (_callback != null) {
      _callback.onStart();
    }
    try {
      if (_newBaseUrl != null && _newBaseUrl.length > 0) {
        _baseUrl = _newBaseUrl;
      }
      _headers["content-type"] = "application/json";
      if (_isAuthRequest && _authToken.length > 0) {
        _headers["authorization"] = "bearer $_authToken";
      }
      // set options
      Dio dio = Dio();
      dio.options.baseUrl = _baseUrl;
      dio.options.headers = _headers;
      dio.options.connectTimeout = _timeout;
      dio.options.receiveTimeout = _timeout;

      print(
          "RequestLoader=>baseurl= $_baseUrl \n endPointUrl= $_endPointUrl \n params= $_params \n isAuthor=$_isAuthRequest \n headers= _$_headers");

      Response response;
      switch (_requestType) {
        case BaseRequestType.POST:
          response = await dio.post(_endPointUrl, data: json.encode(_params));
          break;
        case BaseRequestType.GET:
          response = await dio.get(_endPointUrl, data: json.encode(_params));
          break;
        case BaseRequestType.PUT:
          response = await dio.put(_endPointUrl, data: json.encode(_params));
          break;
        default:
          response = await dio.get(_endPointUrl, data: json.encode(_params));
      }

      if (response != null) {
        int statusCode = response.statusCode;
        String jsonResponse = response.data;
        print("RequestLoader=>statusCode= $statusCode \n json=$jsonResponse");
        if (_callback != null) {
          if (statusCode < BaseConstant.statusCodeSuccess ||
              statusCode >= BaseConstant.statusCodeError) {
            _callback.onError(new BaseRequestException(statusCode, jsonResponse));
          } else {
            _callback.onCompleted(json.decode(jsonResponse));
          }
        }
      }
    } catch (e) {
      print("error=" + e.toString());
      if (e is DioError) {
        var error = e.response.data;
        print("error=>data=" + error);
      }
      if (_callback != null) _callback.onError(e);
    }
  }

// request with http lib
//  Future httpRequest() async {
//    if (_endPointUrl.isEmpty) throw Exception('URL is empty!!');
//    http.Response response;
//    if (_callback != null) {
//      _callback.onStart();
//    }
//    try {
//      String url = _baseUrl + _endPointUrl;
//      if (_newBaseUrl != null && _newBaseUrl.length > 0) {
//        url = _newBaseUrl + _endPointUrl;
//      }
//      _headers["content-type"] = "application/json";
//      if (_isAuthRequest && _authToken.length > 0) {
//        _headers["authorization"] = "bearer " + _authToken;
//      }
//      print(
//          "RequestLoader=>url= $url \n params= $_params \n isAuthor=$_isAuthRequest \n headers= _$_headers");
//      switch (_requestType) {
//        case BaseRequestType.POST:
//          response = await http
//              .post(url, headers: _headers, body: json.encode(_params))
//              .timeout(Duration(seconds: _timeout));
//          break;
//        case BaseRequestType.GET:
//          response = await http
//              .get(url, headers: _headers)
//              .timeout(Duration(seconds: _timeout));
//          break;
//        case BaseRequestType.PUT:
//          response = await http
//              .put(url, headers: _headers, body: json.encode(_params))
//              .timeout(Duration(seconds: _timeout));
//          break;
//        default:
//          response = await http
//              .get(url, headers: _headers)
//              .timeout(Duration(seconds: _timeout));
//      }
//
//      if (response != null) {
//        int statusCode = response.statusCode;
//        String jsonResponse = response.body;
//        print(
//            "RequestLoader=>url= $url \n statusCode= $statusCode \n json=$jsonResponse");
//        if (_callback != null) {
//          if (statusCode < BaseConstant.statusCodeSuccess ||
//              statusCode >= BaseConstant.statusCodeError) {
//            _callback.onError(new BaseRequestException(statusCode, response.body));
//          } else {
//            _callback.onCompleted(json.decode(jsonResponse));
//          }
//        }
//      }
//    } catch (e) {
//      print("error=" + e.toString());
//      if (_callback != null) _callback.onError(e);
//    }
//  }
}
