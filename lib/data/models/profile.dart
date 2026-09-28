/// Values of `profiles.role`.
enum UserRole {
  student,
  parent,
  teacher,
  admin;

  static UserRole? tryParse(String? value) {
    for (final role in values) {
      if (role.name == value) return role;
    }
    return null;
  }
}

/// Subset of the `profiles` row the app needs.
class Profile {
  const Profile({
    required this.id,
    required this.role,
    this.fullName = '',
    this.archivedAt,
  });

  final String id;

  /// `null` when the row has no role or an unknown one.
  final UserRole? role;

  final String fullName;

  /// Set when a student left the program (migration 0015). Archived
  /// students are not let into the app.
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  /// Names are stored "Familiya Ism": drop the surname for greetings
  /// (same as getGivenName in the platform's src/lib/format-name.ts).
  String get givenName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.skip(1).join(' ') : fullName.trim();
  }

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    role: UserRole.tryParse(json['role'] as String?),
    fullName: (json['full_name'] as String?) ?? '',
    archivedAt: DateTime.tryParse((json['archived_at'] as String?) ?? ''),
  );
}
