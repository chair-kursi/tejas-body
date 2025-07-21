class Question {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String? topic;
  final QuestionStatus status;
  final String? imagePath;
  final String studentId;
  final String? tutorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  
  // Related objects
  final Student? student;
  final Tutor? tutor;

  const Question({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    this.topic,
    required this.status,
    this.imagePath,
    required this.studentId,
    this.tutorId,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.completedAt,
    this.student,
    this.tutor,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      print('🎯 Parsing question JSON: ${json['id']} - Status: ${json['status']}');

      return Question(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        subject: json['subject'] as String,
        topic: json['topic'] as String?,
        status: QuestionStatus.fromString(json['status'] as String),
        imagePath: json['imagePath'] as String?,
        studentId: json['studentId'] as String,
        tutorId: json['tutorId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        acceptedAt: json['acceptedAt'] != null
            ? DateTime.parse(json['acceptedAt'] as String)
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        student: json['student'] != null
            ? Student.fromJson(json['student'] as Map<String, dynamic>)
            : null,
        tutor: json['tutor'] != null
            ? Tutor.fromJson(json['tutor'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('🎯 Error parsing question JSON: $e');
      print('🎯 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'topic': topic,
      'status': status.value,
      'imagePath': imagePath,
      'studentId': studentId,
      'tutorId': tutorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'student': student?.toJson(),
      'tutor': tutor?.toJson(),
    };
  }

  Question copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? topic,
    QuestionStatus? status,
    String? imagePath,
    String? studentId,
    String? tutorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    Student? student,
    Tutor? tutor,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      student: student ?? this.student,
      tutor: tutor ?? this.tutor,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, title: $title, subject: $subject, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum QuestionStatus {
  waiting('waiting'),
  accepted('accepted'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled'),
  expired('expired'),
  incomplete('incomplete'); // Add this for API compatibility

  const QuestionStatus(this.value);
  final String value;

  static QuestionStatus fromString(String value) {
    // Handle different API response formats
    final normalizedValue = value.toLowerCase().trim();

    switch (normalizedValue) {
      case 'waiting':
        return QuestionStatus.waiting;
      case 'accepted':
        return QuestionStatus.accepted;
      case 'active':
        return QuestionStatus.accepted; // Backend sends 'active' when tutor accepts
      case 'in_progress':
      case 'inprogress':
        return QuestionStatus.inProgress;
      case 'completed':
        return QuestionStatus.completed;
      case 'cancelled':
        return QuestionStatus.cancelled;
      case 'expired':
        return QuestionStatus.expired;
      case 'incomplete':
        return QuestionStatus.inProgress; // Map incomplete to in_progress
      default:
        print('🎯 Unknown question status: $value, defaulting to waiting');
        return QuestionStatus.waiting;
    }
  }

  String get displayName {
    switch (this) {
      case QuestionStatus.waiting:
        return 'Waiting for Tutor';
      case QuestionStatus.accepted:
        return 'Tutor Assigned';
      case QuestionStatus.inProgress:
        return 'In Progress';
      case QuestionStatus.completed:
        return 'Completed';
      case QuestionStatus.cancelled:
        return 'Cancelled';
      case QuestionStatus.expired:
        return 'Expired';
      case QuestionStatus.incomplete:
        return 'In Progress';
    }
  }

  bool get isActive {
    return this == QuestionStatus.waiting ||
           this == QuestionStatus.accepted ||
           this == QuestionStatus.inProgress ||
           this == QuestionStatus.incomplete;
  }

  bool get isCompleted {
    return this == QuestionStatus.completed;
  }

  bool get isClosed {
    return this == QuestionStatus.completed || 
           this == QuestionStatus.cancelled || 
           this == QuestionStatus.expired;
  }
}

// Simple Student model for question relations
class Student {
  final String id;
  final String userId;
  final String preferredLanguage;
  final String academicLevel;
  final String? academicSubLevel;
  final String? targetExam;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Student({
    required this.id,
    required this.userId,
    required this.preferredLanguage,
    required this.academicLevel,
    this.academicSubLevel,
    this.targetExam,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    try {
      return Student(
        id: json['id'] as String,
        userId: json['userId'] as String,
        preferredLanguage: json['preferredLanguage'] as String,
        academicLevel: json['academicLevel'] as String,
        academicSubLevel: json['academicSubLevel'] as String?,
        targetExam: json['targetExam'] as String?,
        location: json['location'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      print('🎯 Error parsing Student JSON: $e');
      print('🎯 Student JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'preferredLanguage': preferredLanguage,
      'academicLevel': academicLevel,
      'academicSubLevel': academicSubLevel,
      'targetExam': targetExam,
      'location': location,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// Simple Tutor model for question relations
class Tutor {
  final String id;
  final String userId;
  final String preferredLanguage;
  final List<String> subjects;
  final List<String> classLevelsCanTeach;
  final String teachingExperience;

  const Tutor({
    required this.id,
    required this.userId,
    required this.preferredLanguage,
    required this.subjects,
    required this.classLevelsCanTeach,
    required this.teachingExperience,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: json['id'] as String,
      userId: json['userId'] as String,
      preferredLanguage: json['preferredLanguage'] as String,
      subjects: List<String>.from(json['subjects'] as List),
      classLevelsCanTeach: List<String>.from(json['classLevelsCanTeach'] as List),
      teachingExperience: json['teachingExperience'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'preferredLanguage': preferredLanguage,
      'subjects': subjects,
      'classLevelsCanTeach': classLevelsCanTeach,
      'teachingExperience': teachingExperience,
    };
  }
}
