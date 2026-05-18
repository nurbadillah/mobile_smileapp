import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/plan_visit_open_model.dart';

class DirectVisitService {
  final Dio _dio = ApiClient.dio;

  Future<List<PlanVisitOpenModel>> getOpenPlanVisits({
    required int userId,
  }) async {
    final response = await _dio.get(
      '/plan-visit/open',
      queryParameters: {
        'userId': userId,
      },
    );

    final body = response.data;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal mengambil plan visit open');
    }

    final List data = body['data'] ?? [];

    return data.map((item) => PlanVisitOpenModel.fromJson(item)).toList();
  }

  Future<int> createDirectVisit({
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
    final response = await _dio.post(
      '/direct-visit',
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
      throw Exception(body['message'] ?? 'Gagal menyimpan direct visit');
    }

    return body['data']['visitId'] ?? 0;
  }
}