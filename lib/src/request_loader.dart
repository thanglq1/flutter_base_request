import 'dart:async';
import 'dart:convert';
import 'package:flutter_base_request/src/constant.dart';
import 'package:flutter_base_request/src/request_callback.dart';
import 'package:flutter_base_request/src/request_exception.dart';
import 'package:flutter_base_request/src/request_method.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http/io_client.dart';
import 'dart:io';

class BaseRequestLoader<T> {
  static const TAG = "BaseRequestLoaderV5 ";

  String _baseUrl;
  String _newBaseUrl;
  String _endPointUrl;
  int _requestMethod;
  BaseRequestCallback<T> _callback;
  Map<String, String> _headers = Map();
  Map<String, dynamic> _params;
  bool _isAuthRequest;
  bool _isContentTypeApplicationJson;
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
    _requestMethod = requestType;
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

  BaseRequestLoader<T> isContentTypeApplicationJsonRequest(
      bool isContentTypeApplicationJson) {
    _isContentTypeApplicationJson = isContentTypeApplicationJson;
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

  // request with dio lib
  Future dioRequest() async {
    if (_endPointUrl.isEmpty || _baseUrl.isEmpty)
      throw Exception('URL is empty!!');

    if (_callback != null) {
      _callback.onStart();
    }
    try {
      if (_newBaseUrl != null && _newBaseUrl.length > 0) {
        _baseUrl = _newBaseUrl;
      }
      if (_isContentTypeApplicationJson) {
        _headers["content-type"] =
            "application/json"; //api upload image not use content type application/json
      }
      if (_isAuthRequest && _authToken.length > 0) {
        _headers["authorization"] = "bearer $_authToken";
      }
      Dio dio = Dio();
      // certificate always return true
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          print(TAG + " pass cirtificate");
          return true;
        };
      };
      // set options
      dio.options.baseUrl = _baseUrl;
      if (_headers != null) {
        dio.options.headers = _headers;
      }
      dio.options.connectTimeout = _timeout;
      dio.options.receiveTimeout = _timeout;

      Response response;
      FormData formData = FormData.from(_params);
      print(TAG +
          "dioRequest()=>baseurl= $_baseUrl \n endPointUrl= $_endPointUrl \n params= $_params \n isAuthor=$_isAuthRequest \n headers= _$_headers");

      switch (_requestMethod) {
        case BaseRequestMethod.POST:
          response = await dio.post(_endPointUrl, data: formData);
          break;
        case BaseRequestMethod.GET:
          response = await dio.get(_endPointUrl, queryParameters: _params);
          break;
        case BaseRequestMethod.PUT:
          response = await dio.put(_endPointUrl, data: formData);
          break;
        default:
          response = await dio.get(_endPointUrl, queryParameters: _params);
      }

      if (response != null) {
        int statusCode = response.statusCode;
        String jsonResponse = response.data.toString();
        print(TAG +
            "dioRequest()=>statusCode= $statusCode \n json=$jsonResponse");
        if (_callback != null) {
          if (statusCode < BaseConstant.statusCodeSuccess ||
              statusCode >= BaseConstant.statusCodeError) {
            _callback
                .onError(new BaseRequestException(statusCode, jsonResponse));
          } else {
            _callback.onCompleted(response.data);
          }
        }
      }
    } catch (e) {
      print(TAG + "dioRequest()=>error=" + e.toString());
      if (_callback != null) _callback.onError(e);
    }
  }

// request with http lib
  Future httpRequest() async {
    if (_endPointUrl.isEmpty || _baseUrl.isEmpty)
      throw Exception('URL is empty!!');
    http.Response response;
    if (_callback != null) {
      _callback.onStart();
    }
    HttpClient httpClient;
    IOClient ioClient;
    try {
      String url = _baseUrl + _endPointUrl;
      if (_newBaseUrl != null && _newBaseUrl.length > 0) {
        url = _newBaseUrl + _endPointUrl;
      }
      _headers["content-type"] = "application/json";
      if (_isAuthRequest && _authToken.length > 0) {
        _headers["authorization"] = "bearer " + _authToken;
      }
      print(TAG +
          "httpRequest()=>url= $url \n params= $_params \n isAuthor=$_isAuthRequest \n headers= _$_headers");
      httpClient = new HttpClient();
      httpClient.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      ioClient = new IOClient(httpClient);

      switch (_requestMethod) {
        case BaseRequestMethod.POST:
          response = await ioClient
              .post(url, headers: _headers, body: json.encode(_params))
              .timeout(Duration(milliseconds: _timeout));
          break;
        case BaseRequestMethod.GET:
          response = await ioClient
              .get(url, headers: _headers)
              .timeout(Duration(milliseconds: _timeout));
          break;
        case BaseRequestMethod.PUT:
          response = await ioClient
              .put(url, headers: _headers, body: json.encode(_params))
              .timeout(Duration(milliseconds: _timeout));
          break;
        default:
          response = await ioClient
              .get(url, headers: _headers)
              .timeout(Duration(milliseconds: _timeout));
      }

      if (response != null) {
        int statusCode = response.statusCode;
        String jsonResponse = response.body;
        print(TAG +
            "httpRequest()=>url= $url \n statusCode= $statusCode \n json=$jsonResponse");
        if (_callback != null) {
          if (statusCode < BaseConstant.statusCodeSuccess ||
              statusCode >= BaseConstant.statusCodeError) {
            _callback
                .onError(new BaseRequestException(statusCode, response.body));
          } else {
            _callback.onCompleted(json.decode(jsonResponse));
          }
        }

//        if (ioClient != null) ioClient.close();
//        if (httpClient != null) httpClient.close();
      }
    } catch (e) {
      print(TAG + "httpRequest()=>error=" + e.toString());
      if (_callback != null) _callback.onError(e);
//      if (ioClient != null) ioClient.close();
//      if (httpClient != null) httpClient.close();
    }
  }
}
