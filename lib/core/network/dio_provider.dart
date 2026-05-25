import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/storage/auth_storage.dart';
import '../config/env.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final authStorage = ref.watch(authStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(authStorage));

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
