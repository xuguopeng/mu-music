import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mu_music/common/index.dart';

const String APPLICATION_JSON = "application/json";
const String CONTENT_TYPE = "content-type";
const String ACCEPT = "accept";
const String AUTHORIZATION = "cookie";
const String DEFAULT_LANGUAGE = "en";
const String TOKEN = "";
const String BASE_URL = Constants.apiUrl;

/// api 请求工具类
class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();
  factory HttpUtil() => _instance;

  late Dio _dio;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// 单例初始
  HttpUtil._internal() {
    // header 头
    Map<String, String> headers = {
      CONTENT_TYPE: APPLICATION_JSON,
      ACCEPT: APPLICATION_JSON,
      AUTHORIZATION: TOKEN,
      DEFAULT_LANGUAGE: DEFAULT_LANGUAGE
    };

    // 初始选项
    var options = BaseOptions(
      baseUrl: BASE_URL,
      headers: headers,
      connectTimeout: const Duration(seconds: 10), // 10秒
      receiveTimeout: const Duration(seconds: 15), // 15秒
      sendTimeout: const Duration(seconds: 10), // 10秒
      responseType: ResponseType.json,
    );

    // 初始 dio
    _dio = Dio(options);

    // 只保留最基本的日志记录，避免拦截器冲突
    if (!kReleaseMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false, // 减少日志噪音
        error: true,
        logPrint: (obj) => print('💡 Dio: $obj'), // 自定义日志前缀
      ));
    }
  }

  /// 简单的网络检查 - 直接返回 true，让 Dio 处理网络错误
  Future<bool> _checkNetworkConnection() async {
    // 简化网络检查，避免 connectivity_plus 插件问题
    // 让 Dio 自己处理网络连接错误
    print(
        "✅ Network check: Skipping connectivity check, let Dio handle network errors");
    return true;
  }

  /// 带重试的请求方法
  Future<T> _retryRequest<T>(
    Future<T> Function() requestFunc,
    String methodName,
  ) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print("🔄 $methodName attempt $attempt/$_maxRetries");

        // 检查网络连接
        if (!await _checkNetworkConnection()) {
          throw DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'No internet connection',
            type: DioExceptionType.connectionError,
          );
        }

        final result = await requestFunc();
        print("✅ $methodName succeeded on attempt $attempt");
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print("❌ $methodName failed on attempt $attempt: $e");

        // 如果是最后一次尝试，或者是不应该重试的错误，直接抛出
        if (attempt >= _maxRetries || !_shouldRetry(e)) {
          break;
        }

        print("⏳ Waiting ${_retryDelay.inSeconds}s before retry...");
        await Future.delayed(_retryDelay);
      }
    }

    print("💥 $methodName failed after $_maxRetries attempts");
    throw lastException!;
  }

  /// 判断是否应该重试
  bool _shouldRetry(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          return true;
        case DioExceptionType.badResponse:
          // 5xx 错误可以重试，4xx 错误不重试
          final statusCode = error.response?.statusCode;
          return statusCode != null && statusCode >= 500;
        case DioExceptionType.cancel:
          return false;
        default:
          return false;
      }
    }
    return true; // 其他错误默认重试
  }

  /// get 请求
  Future<Response> get(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _retryRequest<Response>(
      () async {
        Options requestOptions = options ?? Options();
        Response response = await _dio.get(
          url,
          queryParameters: params,
          options: requestOptions,
          cancelToken: cancelToken,
        );
        return response;
      },
      'GET $url',
    );
  }

  /// post 请求
  Future<Response> post(
    String url, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _retryRequest<Response>(
      () async {
        var requestOptions = options ?? Options();
        Response response = await _dio.post(
          url,
          data: data ?? {},
          options: requestOptions,
          cancelToken: cancelToken,
        );
        return response;
      },
      'POST $url',
    );
  }

  /// put 请求
  Future<Response> put(
    String url, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var requestOptions = options ?? Options();
    Response response = await _dio.put(
      url,
      data: data ?? {},
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response;
  }

  /// delete 请求
  Future<Response> delete(
    String url, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var requestOptions = options ?? Options();
    Response response = await _dio.delete(
      url,
      data: data ?? {},
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response;
  }
}
