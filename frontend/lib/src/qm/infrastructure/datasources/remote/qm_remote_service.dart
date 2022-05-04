import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:frontend/src/core/infrastrucutre/dio_extensions.dart';
import 'package:frontend/src/core/infrastrucutre/exceptions.dart';
import 'package:frontend/src/qm/domain/entities/qm_item.dart';

import 'package:frontend/src/qm/infrastructure/datasources/qm_service.dart';
import 'package:frontend/src/qm/infrastructure/dtos/qm_item_dto.dart';

class QmRemoteService implements QmService {
  final Dio _dio;

  const QmRemoteService({
    required Dio httpClient,
  }) : _dio = httpClient;

  @override
  Future<List<QmItem>> fetchQmItems(Map<String, dynamic> params) async {
    try {
      final response = await _dio.get(
        "/qm",
        queryParameters: params,
      );

      final results = (response.data as Map<String, dynamic>);
      // final isNextAvailable = results["is_next_available"] as bool;

      final data = (results["data"] as List<dynamic>)
          .map((e) => QmItemDto.fromMap(e as Map<String, dynamic>).toDomain())
          .toList();

      return data;
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        throw NoConnectionException(message: e.message);
      }

      if (e.response?.statusCode == 500) {
        final response = jsonDecode(e.response?.data) as Map<String, dynamic>;
        throw InvalidServerResponseException(
          message: response["msg"],
        );
      }

      if (e.type == DioErrorType.connectTimeout) {
        throw ServerConnectionException(message: e.message);
      }

      if (e.type == DioErrorType.receiveTimeout) {
        throw ServerConnectionException(message: e.message);
      }

      rethrow;
    }
  }

  @override
  Future<void> saveQmItem(Map<String, dynamic> params) async {
    try {
      await _dio.post("/qm", data: params);
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        throw NoConnectionException(
          message: e.message,
        );
      }

      if (e.response?.statusCode == 500) {
        final response = jsonDecode(e.response?.data) as Map<String, dynamic>;
        throw InvalidServerResponseException(
          message: response["msg"],
        );
      }

      if (e.type == DioErrorType.connectTimeout) {
        throw ServerConnectionException(
          message: e.message,
        );
      }

      rethrow;
    }
  }

  @override
  Future<void> saveQmList(List<Map<String, dynamic>> params) async {
    try {
      await _dio.post("/qms", data: params);
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        throw NoConnectionException(
          message: e.message,
        );
      }

      if (e.response?.statusCode == 500) {
        final response = jsonDecode(e.response?.data) as Map<String, dynamic>;
        throw InvalidServerResponseException(
          message: response["msg"],
        );
      }

      if (e.type == DioErrorType.connectTimeout) {
        throw ServerConnectionException(
          message: e.message,
        );
      }

      rethrow;
    }
  }
}
