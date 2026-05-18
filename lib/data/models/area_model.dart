class AreaModel {
  final int areaId;
  final String areaName;
  final bool isActive;

  AreaModel({
    required this.areaId,
    required this.areaName,
    required this.isActive,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      areaId: json['areaId'] ?? 0,
      areaName: json['areaName'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}