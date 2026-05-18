class HistoryListModel {
  final int visitId;
  final String visitKind;
  final String title;
  final int userId;
  final String fullName;
  final int dealerId;
  final String dealerName;
  final int areaId;
  final String areaName;
  final int branchId;
  final String branchName;
  final String? purposeName;
  final DateTime? visitDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final DateTime? createdAt;

  HistoryListModel({
    required this.visitId,
    required this.visitKind,
    required this.title,
    required this.userId,
    required this.fullName,
    required this.dealerId,
    required this.dealerName,
    required this.areaId,
    required this.areaName,
    required this.branchId,
    required this.branchName,
    required this.purposeName,
    required this.visitDate,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  factory HistoryListModel.fromJson(Map<String, dynamic> json) {
    return HistoryListModel(
      visitId: json['visitId'] ?? 0,
      visitKind: json['visitKind'] ?? '',
      title: json['title'] ?? '',
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      dealerId: json['dealerId'] ?? 0,
      dealerName: json['dealerName'] ?? '',
      areaId: json['areaId'] ?? 0,
      areaName: json['areaName'] ?? '',
      branchId: json['branchId'] ?? 0,
      branchName: json['branchName'] ?? '',
      purposeName: json['purposeName'],
      visitDate: json['visitDate'] == null
          ? null
          : DateTime.tryParse(json['visitDate'].toString()),
      startDate: json['startDate'] == null
          ? null
          : DateTime.tryParse(json['startDate'].toString()),
      endDate: json['endDate'] == null
          ? null
          : DateTime.tryParse(json['endDate'].toString()),
      status: json['status'] ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  DateTime? get displayDate {
    if (visitKind == 'PLAN') {
      return visitDate;
    }

    return startDate;
  }
}