class User {
  final String id;
  final String name;
  final String email;
  final String role; // e.g. Student, Chairman, etc.
  final String? department;
  final String? year;
  final String? batch;
  final String? section;
  final String? adviser;
  final bool isCR;
  final String status;
  final String? profileImageUrl;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Student',
    this.department,
    this.year,
    this.batch,
    this.section,
    this.adviser,
    this.isCR = false,
    this.status = 'approved',
    this.profileImageUrl,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'Student',
      department: json['department'],
      year: json['year'],
      batch: json['batch'],
      section: json['section'],
      adviser: json['adviser'],
      isCR: json['isCR'] ?? false,
      status: json['status'] ?? 'approved',
      profileImageUrl: json['profileImageUrl'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'year': year,
      'batch': batch,
      'section': section,
      'adviser': adviser,
      'isCR': isCR,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
    };
  }
}
