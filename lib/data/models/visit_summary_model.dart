class VisitSummaryModel {
  final int totalVisit;
  final int planVisit;
  final int directVisit;

  VisitSummaryModel({
    required this.totalVisit,
    required this.planVisit,
    required this.directVisit,
  });

  factory VisitSummaryModel.fromJson(Map<String, dynamic> json) {
    return VisitSummaryModel(
      totalVisit: json['totalVisit'] ?? 0,
      planVisit: json['planVisit'] ?? 0,
      directVisit: json['directVisit'] ?? 0,
    );
  }
}