import 'dart:io';

/// DTO for creating a new question
class CreateQuestionDto {
  final String title;
  final String description;
  final String subject;
  final String? topic;
  final File? image; // For image upload

  const CreateQuestionDto({
    required this.title,
    required this.description,
    required this.subject,
    this.topic,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      if (topic != null) 'topic': topic,
    };
  }

  bool get isValid {
    return title.trim().isNotEmpty && 
           description.trim().isNotEmpty && 
           subject.trim().isNotEmpty;
  }

  @override
  String toString() {
    return 'CreateQuestionDto(title: $title, subject: $subject, topic: $topic)';
  }
}

/// DTO for updating question status
class UpdateQuestionStatusDto {
  final String status;
  final String? notes;

  const UpdateQuestionStatusDto({
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  String toString() {
    return 'UpdateQuestionStatusDto(status: $status, notes: $notes)';
  }
}

/// DTO for question filters (for tutors browsing available questions)
class QuestionFiltersDto {
  final List<String>? subjects;
  final List<String>? topics;
  final String? status;
  final int? limit;
  final int? offset;

  const QuestionFiltersDto({
    this.subjects,
    this.topics,
    this.status,
    this.limit,
    this.offset,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (subjects != null && subjects!.isNotEmpty) {
      params['subjects'] = subjects!.join(',');
    }
    
    if (topics != null && topics!.isNotEmpty) {
      params['topics'] = topics!.join(',');
    }
    
    if (status != null) {
      params['status'] = status;
    }
    
    if (limit != null) {
      params['limit'] = limit.toString();
    }
    
    if (offset != null) {
      params['offset'] = offset.toString();
    }
    
    return params;
  }

  @override
  String toString() {
    return 'QuestionFiltersDto(subjects: $subjects, topics: $topics, status: $status)';
  }
}

/// Response wrapper for API responses
class QuestionResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  const QuestionResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory QuestionResponse.success(T data, {String? message}) {
    return QuestionResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory QuestionResponse.error(String error) {
    return QuestionResponse(
      success: false,
      error: error,
    );
  }

  @override
  String toString() {
    return 'QuestionResponse(success: $success, message: $message, error: $error)';
  }
}

/// Common subjects available in the system
class QuestionSubjects {
  static const List<String> allSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Hindi',
    'History',
    'Geography',
    'Economics',
    'Political Science',
    'Computer Science',
    'Accountancy',
    'Business Studies',
    'Psychology',
    'Sociology',
    'Philosophy',
    'Physical Education',
    'Art',
    'Music',
    'Other',
  ];

  static const Map<String, List<String>> subjectTopics = {
    'Mathematics': [
      'Algebra',
      'Geometry',
      'Trigonometry',
      'Calculus',
      'Statistics',
      'Probability',
      'Number Theory',
      'Coordinate Geometry',
      'Mensuration',
      'Other',
    ],
    'Physics': [
      'Mechanics',
      'Thermodynamics',
      'Electromagnetism',
      'Optics',
      'Modern Physics',
      'Waves',
      'Atomic Physics',
      'Nuclear Physics',
      'Electronics',
      'Other',
    ],
    'Chemistry': [
      'Organic Chemistry',
      'Inorganic Chemistry',
      'Physical Chemistry',
      'Analytical Chemistry',
      'Biochemistry',
      'Environmental Chemistry',
      'Industrial Chemistry',
      'Other',
    ],
    'Biology': [
      'Cell Biology',
      'Genetics',
      'Evolution',
      'Ecology',
      'Human Physiology',
      'Plant Biology',
      'Animal Biology',
      'Microbiology',
      'Biotechnology',
      'Other',
    ],
    'English': [
      'Grammar',
      'Literature',
      'Writing',
      'Reading Comprehension',
      'Poetry',
      'Drama',
      'Novel',
      'Essay Writing',
      'Vocabulary',
      'Other',
    ],
  };

  static List<String> getTopicsForSubject(String subject) {
    return subjectTopics[subject] ?? ['Other'];
  }

  static bool isValidSubject(String subject) {
    return allSubjects.contains(subject);
  }
}
