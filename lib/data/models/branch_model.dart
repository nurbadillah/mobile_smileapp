class BranchModel {
  final int branchId;
  final int areaId;
  final String areaName;
  final String branchName;
  final bool isActive;

  BranchModel({
    required this.branchId,
    required this.areaId,
    required this.areaName,
    required this.branchName,
    required this.isActive,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      branchId: json['branchId'] ?? 0,
      areaId: json['areaId'] ?? 0,
      areaName: json['areaName'] ?? '',
      branchName: json['branchName'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}