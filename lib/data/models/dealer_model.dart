class DealerModel {
  final int dealerId;
  final int branchId;
  final String branchName;
  final int areaId;
  final String areaName;
  final String dealerName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  DealerModel({
    required this.dealerId,
    required this.branchId,
    required this.branchName,
    required this.areaId,
    required this.areaName,
    required this.dealerName,
    required this.isActive,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      dealerId: json['dealerId'] ?? 0,
      branchId: json['branchId'] ?? 0,
      branchName: json['branchName'] ?? '',
      areaId: json['areaId'] ?? 0,
      areaName: json['areaName'] ?? '',
      dealerName: json['dealerName'] ?? '',
      address: json['address'],
      latitude: json['latitude'] == null
          ? null
          : double.tryParse(json['latitude'].toString()),
      longitude: json['longitude'] == null
          ? null
          : double.tryParse(json['longitude'].toString()),
      isActive: json['isActive'] ?? true,
    );
  }
}