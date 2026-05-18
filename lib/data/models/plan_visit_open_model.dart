class PlanVisitOpenModel {
  final int visitId;
  final String visitKind;
  final String title;
  final int userId;
  final int internalPositionId;
  final String internalPositionName;
  final int areaId;
  final String areaName;
  final int branchId;
  final String branchName;
  final int dealerId;
  final String dealerName;
  final int purposeId;
  final String purposeName;
  final DateTime? visitDate;
  final String status;

  PlanVisitOpenModel({
    required this.visitId,
    required this.visitKind,
    required this.title,
    required this.userId,
    required this.internalPositionId,
    required this.internalPositionName,
    required this.areaId,
    required this.areaName,
    required this.branchId,
    required this.branchName,
    required this.dealerId,
    required this.dealerName,
    required this.purposeId,
    required this.purposeName,
    required this.visitDate,
    required this.status,
  });

  factory PlanVisitOpenModel.fromJson(Map<String, dynamic> json) {
    return PlanVisitOpenModel(
      visitId: json['visitId'] ?? 0,
      visitKind: json['visitKind'] ?? '',
      title: json['title'] ?? 'Plan Visit',
      userId: json['userId'] ?? 0,
      internalPositionId: json['internalPositionId'] ?? 0,
      internalPositionName: json['internalPositionName'] ?? '',
      areaId: json['areaId'] ?? 0,
      areaName: json['areaName'] ?? '',
      branchId: json['branchId'] ?? 0,
      branchName: json['branchName'] ?? '',
      dealerId: json['dealerId'] ?? 0,
      dealerName: json['dealerName'] ?? '',
      purposeId: json['purposeId'] ?? 0,
      purposeName: json['purposeName'] ?? '',
      visitDate: json['visitDate'] == null
          ? null
          : DateTime.tryParse(json['visitDate'].toString()),
      status: json['status'] ?? '',
    );
  }
}