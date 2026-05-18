class VisitPersonModel {
  final int visitPersonId;
  final int visitId;
  final int dealerPositionId;
  final String dealerPositionName;
  final String picName;
  final String? phone;

  VisitPersonModel({
    required this.visitPersonId,
    required this.visitId,
    required this.dealerPositionId,
    required this.dealerPositionName,
    required this.picName,
    this.phone,
  });

  factory VisitPersonModel.fromJson(Map<String, dynamic> json) {
    return VisitPersonModel(
      visitPersonId: json['visitPersonId'] ?? 0,
      visitId: json['visitId'] ?? 0,
      dealerPositionId: json['dealerPositionId'] ?? 0,
      dealerPositionName: json['dealerPositionName'] ?? '',
      picName: json['picName'] ?? '',
      phone: json['phone'],
    );
  }
}

class VisitPhotoModel {
  final int photoId;
  final int visitId;
  final String fileName;
  final String filePath;
  final String? contentType;
  final int? fileSize;
  final DateTime? uploadedAt;

  VisitPhotoModel({
    required this.photoId,
    required this.visitId,
    required this.fileName,
    required this.filePath,
    this.contentType,
    this.fileSize,
    this.uploadedAt,
  });

  factory VisitPhotoModel.fromJson(Map<String, dynamic> json) {
    return VisitPhotoModel(
      photoId: json['photoId'] ?? 0,
      visitId: json['visitId'] ?? 0,
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      contentType: json['contentType'],
      fileSize: json['fileSize'],
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.tryParse(json['uploadedAt'].toString()),
    );
  }
}

class HistoryDetailModel {
  final int visitId;
  final String visitKind;
  final int? planVisitId;

  final int userId;
  final String fullName;

  final int internalPositionId;
  final String internalPositionName;

  final int areaId;
  final String areaName;

  final int branchId;
  final String branchName;

  final int dealerId;
  final String dealerName;

  final int? productId;
  final String? productName;

  final int? visitTypeId;
  final String? visitTypeName;

  final int purposeId;
  final String purposeName;

  final DateTime? visitDate;
  final DateTime? startDate;
  final DateTime? endDate;

  final String? picName;
  final String? themeDiscussion;
  final String? problemPending;
  final String? actionFollowUp;
  final String? description;

  final double? latitude;
  final double? longitude;

  final String status;
  final DateTime? createdAt;

  final List<VisitPersonModel> persons;
  final List<VisitPhotoModel> photos;

  HistoryDetailModel({
    required this.visitId,
    required this.visitKind,
    required this.planVisitId,
    required this.userId,
    required this.fullName,
    required this.internalPositionId,
    required this.internalPositionName,
    required this.areaId,
    required this.areaName,
    required this.branchId,
    required this.branchName,
    required this.dealerId,
    required this.dealerName,
    required this.productId,
    required this.productName,
    required this.visitTypeId,
    required this.visitTypeName,
    required this.purposeId,
    required this.purposeName,
    required this.visitDate,
    required this.startDate,
    required this.endDate,
    required this.picName,
    required this.themeDiscussion,
    required this.problemPending,
    required this.actionFollowUp,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.persons,
    required this.photos,
  });

  factory HistoryDetailModel.fromJson(Map<String, dynamic> json) {
    final personsData = json['persons'] as List? ?? [];
    final photosData = json['photos'] as List? ?? [];

    return HistoryDetailModel(
      visitId: json['visitId'] ?? 0,
      visitKind: json['visitKind'] ?? '',
      planVisitId: json['planVisitId'],
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      internalPositionId: json['internalPositionId'] ?? 0,
      internalPositionName: json['internalPositionName'] ?? '',
      areaId: json['areaId'] ?? 0,
      areaName: json['areaName'] ?? '',
      branchId: json['branchId'] ?? 0,
      branchName: json['branchName'] ?? '',
      dealerId: json['dealerId'] ?? 0,
      dealerName: json['dealerName'] ?? '',
      productId: json['productId'],
      productName: json['productName'],
      visitTypeId: json['visitTypeId'],
      visitTypeName: json['visitTypeName'],
      purposeId: json['purposeId'] ?? 0,
      purposeName: json['purposeName'] ?? '',
      visitDate: json['visitDate'] == null
          ? null
          : DateTime.tryParse(json['visitDate'].toString()),
      startDate: json['startDate'] == null
          ? null
          : DateTime.tryParse(json['startDate'].toString()),
      endDate: json['endDate'] == null
          ? null
          : DateTime.tryParse(json['endDate'].toString()),
      picName: json['picName'],
      themeDiscussion: json['themeDiscussion'],
      problemPending: json['problemPending'],
      actionFollowUp: json['actionFollowUp'],
      description: json['description'],
      latitude: json['latitude'] == null
          ? null
          : double.tryParse(json['latitude'].toString()),
      longitude: json['longitude'] == null
          ? null
          : double.tryParse(json['longitude'].toString()),
      status: json['status'] ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
      persons: personsData
          .map((item) => VisitPersonModel.fromJson(item))
          .toList(),
      photos: photosData
          .map((item) => VisitPhotoModel.fromJson(item))
          .toList(),
    );
  }
}