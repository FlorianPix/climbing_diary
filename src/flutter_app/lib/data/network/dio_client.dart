
import 'package:dio/dio.dart';

import 'auth_interceptor.dart';

class DioClient {
  final _dio = Dio();

  DioClient() {
    _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;
}