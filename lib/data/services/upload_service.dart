import 'dart:io';

import 'package:dio/dio.dart';
import '../api_client.dart';

class UploadService {
  final Dio _dio = ApiClient.dio;

  Future<int> uploadVisitPhoto({
    required int visitId,
    required File photoFile,
  }) async {
    final fileName = photoFile.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        photoFile.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      '/history/$visitId/photo',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal upload foto');
    }

    return body['data']['photoId'] ?? 0;
  }

  Future<void> deleteVisitPhoto({
    required int photoId,
  }) async {
    final response = await _dio.delete('/history/photo/$photoId');

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal menghapus foto');
    }
  }
}