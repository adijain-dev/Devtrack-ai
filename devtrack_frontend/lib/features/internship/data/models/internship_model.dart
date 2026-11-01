import '../../domain/entities/internship.dart';

/// Data model that maps JSON from the Spring Boot backend to the domain entity.
class InternshipModel extends Internship {
  const InternshipModel({
    required super.id,
    required super.companyName,
    required super.role,
    super.location,
    super.salary,
    super.jobLink,
    super.status,
    super.appliedDate,
    super.interviewDate,
    super.reminderEnabled,
    super.resumeUrl,
    super.resumeFileName,
    super.notes,
  });

  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    return InternshipModel(
      id: (json['id'] ?? 0).toString(),
      companyName: json['companyName'] as String,
      role: json['role'] as String,
      location: json['location'] as String?,
      salary: json['salary'] as String?,
      jobLink: json['jobLink'] as String?,
      status: InternshipStatus.fromString(json['status'] as String? ?? 'APPLIED'),
      appliedDate: json['appliedDate'] as String?,
      interviewDate: json['interviewDate'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      resumeUrl: json['resumeUrl'] as String?,
      resumeFileName: json['resumeFileName'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'role': role,
        if (location != null) 'location': location,
        if (salary != null) 'salary': salary,
        if (jobLink != null) 'jobLink': jobLink,
        'status': status.name.toUpperCase(),
        if (appliedDate != null) 'appliedDate': appliedDate,
        if (interviewDate != null) 'interviewDate': interviewDate,
        'reminderEnabled': reminderEnabled,
        if (resumeUrl != null) 'resumeUrl': resumeUrl,
        if (resumeFileName != null) 'resumeFileName': resumeFileName,
        if (notes != null) 'notes': notes,
      };

  /// Convert a domain entity to a model for API calls.
  factory InternshipModel.fromEntity(Internship i) => InternshipModel(
        id: i.id,
        companyName: i.companyName,
        role: i.role,
        location: i.location,
        salary: i.salary,
        jobLink: i.jobLink,
        status: i.status,
        appliedDate: i.appliedDate,
        interviewDate: i.interviewDate,
        reminderEnabled: i.reminderEnabled,
        resumeUrl: i.resumeUrl,
        resumeFileName: i.resumeFileName,
        notes: i.notes,
      );
}
