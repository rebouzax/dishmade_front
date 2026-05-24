import 'package:dio/dio.dart';

class ApiValidationError {
  final String field;
  final String message;

  const ApiValidationError({required this.field, required this.message});

  factory ApiValidationError.fromJson(Map<String, dynamic> json) {
    return ApiValidationError(
      field: json['field']?.toString() ?? '',
      message: json['message']?.toString() ?? 'Erro de validação.',
    );
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final List<ApiValidationError> errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors = const [],
  });

  factory ApiException.fromDioException(DioException exception) {
    final response = exception.response;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final validationErrors = data['errors'];

      final errors = validationErrors is List
          ? validationErrors
                .whereType<Map<String, dynamic>>()
                .map(ApiValidationError.fromJson)
                .toList()
          : <ApiValidationError>[];

      return ApiException(
        statusCode: response?.statusCode,
        message: data['message']?.toString() ?? 'Erro ao processar requisição.',
        errors: errors,
      );
    }

    return ApiException(
      statusCode: response?.statusCode,
      message: exception.message ?? 'Erro de conexão com a API.',
    );
  }

  @override
  String toString() => message;
}
