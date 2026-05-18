import 'package:dio/dio.dart';
import '../api_client.dart';

class PlanVisitService {
  final Dio _dio = ApiClient.dio;

  Future<int> createPlanVisit({
    required int userId,
    required int internalPositionId,
    required int areaId,
    required int branchId,
    required int dealerId,
    required int purposeId,
    required DateTime visitDate,
  }) async {
    final response = await _dio.post(
      '/plan-visit',
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
      throw Exception(body['message'] ?? 'Gagal menyimpan plan visit');
    }

    return body['data']['visitId'] ?? 0;
  }
}