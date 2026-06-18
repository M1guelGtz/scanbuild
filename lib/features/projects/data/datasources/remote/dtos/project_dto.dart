class ProjectDto {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? clientName;
  final String? location;
  final String workType;
  final String? area;
  final String? totalBudget;
  final String status;
  final String createdAt;
  final String updatedAt;

  const ProjectDto({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.workType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.clientName,
    this.location,
    this.area,
    this.totalBudget,
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      clientName: json['clientName'] as String?,
      location: json['location'] as String?,
      workType: json['workType'] as String,
      area: json['area'] as String?,
      totalBudget: json['totalBudget'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
