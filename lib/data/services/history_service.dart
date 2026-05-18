import 'package:dio/dio.dart';

import '../api_client.dart';
import '../models/history_detail_model.dart';
import '../models/history_list_model.dart';
import '../models/visit_summary_model.dart';

class HistoryService {
  final Dio _dio = ApiClient.dio;

  Future<List<HistoryListModel>> getHistory() async {
    final response = await _dio.get('/history');

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal mengambil history');
    }

    final List data = body['data'] ?? [];

    return data.map((item) => HistoryListModel.fromJson(item)).toList();
  }

  Future<VisitSummaryModel> getSummary() async {
    final response = await _dio.get('/history/summary');

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal mengambil ringkasan kunjungan');
    }

    return VisitSummaryModel.fromJson(body['data']);
  }

  Future<HistoryDetailModel> getDetail({
    required int visitId,
  }) async {
    final response = await _dio.get('/history/$visitId');

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal mengambil detail history');
    }

    return HistoryDetailModel.fromJson(body['data']);
  }

  Future<void> updatePlanVisit({
    required int visitId,
    required int userId,
    required int internalPositionId,
    required int areaId,
    required int branchId,
    required int dealerId,
    required int purposeId,
    required DateTime visitDate,
  }) async {
    final response = await _dio.put(
      '/history/plan/$visitId',
      data: {
        'userId': userId,
        'internalPositionId': internalPositionId,
        'areaId': areaId,
        'branchId': branchId,
        'dealerId': dealerId,
        'purposeId': purposeId,
        'visitDate': visitDate.toIso8601String(),
      },
    );

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal memperbarui plan visit');
    }
  }

  Future<void> updateDirectVisit({
    required int visitId,
    int? planVisitId,
    required int userId,
    required int internalPositionId,
    required int areaId,
    required int branchId,
    required int dealerId,
    required int productId,
    required int visitTypeId,
    required int purposeId,
    required DateTime startDate,
    required DateTime endDate,
    String? picName,
    String? themeDiscussion,
    String? problemPending,
    String? actionFollowUp,
    String? description,
    double? latitude,
    double? longitude,
    List<Map<String, dynamic>> persons = const [],
  }) async {
    final response = await _dio.put(
      '/history/direct/$visitId',
      data: {
        'planVisitId': planVisitId,
        'userId': userId,
        'internalPositionId': internalPositionId,
        'areaId': areaId,
        'branchId': branchId,
        'dealerId': dealerId,
        'productId': productId,
        'visitTypeId': visitTypeId,
        'purposeId': purposeId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'picName': picName,
        'themeDiscussion': themeDiscussion,
        'problemPending': problemPending,
        'actionFollowUp': actionFollowUp,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'persons': persons,
      },
    );

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal memperbarui direct visit');
    }
  }

  Future<void> deleteHistory({
    required int visitId,
  }) async {
    final response = await _dio.delete('/history/$visitId');

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal menghapus history');
    }
  }
}