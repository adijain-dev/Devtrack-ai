/// Domain entity representing an internship application.
class Internship {
  final String id;
  final String companyName;
  final String role;
  final String? location;
  final String? salary;
  final String? jobLink;
  final InternshipStatus status;
  final String? appliedDate; // stored as ISO string (yyyy-MM-dd)
  final String? interviewDate; // stored as ISO string (yyyy-MM-ddTHH:mm:ss)
  final bool reminderEnabled;
  final String? resumeUrl;
  final String? resumeFileName;
  final String? notes;

  const Internship({
    required this.id,
    required this.companyName,
    required this.role,
    this.location,
    this.salary,
    this.jobLink,
    this.status = InternshipStatus.applied,
    this.appliedDate,
    this.interviewDate,
    this.reminderEnabled = false,
    this.resumeUrl,
    this.resumeFileName,
    this.notes,
  });

  Internship copyWith({
    String? id,
    String? companyName,
    String? role,
    String? location,
    String? salary,
    String? jobLink,
    InternshipStatus? status,
    String? appliedDate,
    String? interviewDate,
    bool? reminderEnabled,
    String? resumeUrl,
    String? resumeFileName,
    String? notes,
  }) {
    return Internship(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      role: role ?? this.role,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      jobLink: jobLink ?? this.jobLink,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      interviewDate: interviewDate ?? this.interviewDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      notes: notes ?? this.notes,
    );
  }
}

enum InternshipStatus {
  applied,
  interview,
  offer,
  rejected;

  String get label {
    switch (this) {
      case InternshipStatus.applied:
        return 'Applied';
      case InternshipStatus.interview:
        return 'Interview';
      case InternshipStatus.offer:
        return 'Offer';
      case InternshipStatus.rejected:
        return 'Rejected';
    }
  }

  /// Match backend enum string (e.g. "APPLIED", "INTERVIEW")
  static InternshipStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INTERVIEW':
        return InternshipStatus.interview;
      case 'OFFER':
        return InternshipStatus.offer;
      case 'REJECTED':
        return InternshipStatus.rejected;
      default:
        return InternshipStatus.applied;
    }
  }
}
