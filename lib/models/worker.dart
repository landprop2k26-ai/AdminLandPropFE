class Worker {
  final String id;
  final String name;
  final String? phone;
  final List<String> roles;
  final List<Map<String, dynamic>> rawSkills; // Store full skill objects for editing
  final bool isActive;
  final double earningsThisMonth;
  final String? profileImage;

  Worker({
    required this.id,
    required this.name,
    this.phone,
    required this.roles,
    required this.rawSkills,
    required this.isActive,
    required this.earningsThisMonth,
    this.profileImage,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    final skills = (json['skills'] as List?) ?? [];
    return Worker(
      id: json['workerId'].toString(),
      name: json['name'] ?? 'Unknown',
      phone: json['phone'],
      roles: skills.map((s) => s['subCategoryName'] as String).toList(),
      rawSkills: skills.map((s) => Map<String, dynamic>.from(s)).toList(),
      isActive: json['status'] == 'active',
      earningsThisMonth: 0,
    );
  }
}
