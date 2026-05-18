import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/area_model.dart';
import '../models/branch_model.dart';
import '../models/dealer_model.dart';
import '../models/master_item_model.dart';

class MasterService {
  final Dio _dio = ApiClient.dio;

  Future<List<MasterItemModel>> getProducts() async {
    final response = await _dio.get('/produk');
    final List data = response.data['data'] ?? [];

    return data
        .map(
          (item) => MasterItemModel.fromJson(
            item,
            idKey: 'productId',
            nameKey: 'productName',
          ),
        )
        .toList();
  }

  Future<List<AreaModel>> getAreas() async {
    final response = await _dio.get('/area');
    final List data = response.data['data'] ?? [];

    return data.map((item) => AreaModel.fromJson(item)).toList();
  }

  Future<List<BranchModel>> getBranches({int? areaId}) async {
    final response = await _dio.get(
      '/cabang',
      queryParameters: {
        if (areaId != null) 'areaId': areaId,
      },
    );

    final List data = response.data['data'] ?? [];
    return data.map((item) => BranchModel.fromJson(item)).toList();
  }

  Future<List<DealerModel>> getDealers({int? branchId}) async {
    final response = await _dio.get(
      '/dealer',
      queryParameters: {
        if (branchId != null) 'branchId': branchId,
      },
    );

    final List data = response.data['data'] ?? [];
    return data.map((item) => DealerModel.fromJson(item)).toList();
  }

  Future<List<MasterItemModel>> getInternalPositions() async {
    final response = await _dio.get('/jabatan-internal');
    final List data = response.data['data'] ?? [];

    return data
        .map(
          (item) => MasterItemModel.fromJson(
            item,
            idKey: 'internalPositionId',
            nameKey: 'positionName',
          ),
        )
        .toList();
  }

  Future<List<MasterItemModel>> getDealerPositions() async {
    final response = await _dio.get('/jabatan-dealer');
    final List data = response.data['data'] ?? [];

    return data
        .map(
          (item) => MasterItemModel.fromJson(
            item,
            idKey: 'dealerPositionId',
            nameKey: 'positionName',
          ),
        )
        .toList();
  }

  Future<List<MasterItemModel>> getVisitTypes() async {
    final response = await _dio.get('/tipe-visit');
    final List data = response.data['data'] ?? [];

    return data
        .map(
          (item) => MasterItemModel.fromJson(
            item,
            idKey: 'visitTypeId',
            nameKey: 'visitTypeName',
          ),
        )
        .toList();
  }

  Future<List<MasterItemModel>> getVisitPurposes({int? tipeVisitId}) async {
    final response = await _dio.get(
      '/tujuan-visit',
      queryParameters: {
        if (tipeVisitId != null) 'tipeVisitId': tipeVisitId,
      },
    );

    final List data = response.data['data'] ?? [];

    return data
        .map(
          (item) => MasterItemModel.fromJson(
            item,
            idKey: 'purposeId',
            nameKey: 'purposeName',
          ),
        )
        .toList();
  }
}