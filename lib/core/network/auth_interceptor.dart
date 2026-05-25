import 'package:dio/dio.dart';

import '../../features/auth/data/storage/auth_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthStorage _authStorage;

  const AuthInterceptor(this._authStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _authStorage.clear();
    }

    handler.next(err);
  }
}
