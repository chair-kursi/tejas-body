import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../core/constants/app_constants.dart';
import '../models/question.dart';
import '../models/question_dto.dart';
import '../models/message.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logger in debug mode
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = StorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - logout user
        }
        handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<Map<String, dynamic>> sendOTP({
    required String mobileNumber,
  }) async {
    try {
      final response = await _dio.post('/auth/send-verification', data: {
        'mobileNumber': mobileNumber,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String mobileNumber,
    required String verificationCode,
  }) async {
    try {
      final response = await _dio.post('/auth/verify-mobile', data: {
        'mobileNumber': mobileNumber,
        'verificationCode': verificationCode,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String mobileNumber,
    required String email,
    required String password,
    required String gender,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'mobileNumber': mobileNumber,
        'email': email,
        'password': password,
        'gender': gender,
        'role': role,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> resendOTP({
    required String mobileNumber,
  }) async {
    try {
      final response = await _dio.post('/auth/resend-verification', data: {
        'mobileNumber': mobileNumber,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Student Profile endpoints
  Future<Map<String, dynamic>> createStudentProfile({
    required String preferredLanguage,
    required String academicLevel,
    String? academicSubLevel,
    String? targetExam,
    String? location,
  }) async {
    try {
      final response = await _dio.post('/users/student/profile', data: {
        'preferredLanguage': preferredLanguage,
        'academicLevel': academicLevel,
        if (academicSubLevel != null) 'academicSubLevel': academicSubLevel,
        if (targetExam != null) 'targetExam': targetExam,
        if (location != null) 'location': location,
      });

      return response.data;
    } catch (e) {
      print('API Error: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final response = await _dio.get('/users/student/profile');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Tutor Profile endpoints
  Future<Map<String, dynamic>> createTutorProfile({
    required String preferredLanguage,
    required String educationStatus,
    String? educationEndDate,
    required String university,
    required String highestQualification,
    required String teachingExperience,
    String? taughtAt,
    required List<String> classLevelsCanTeach,
    required List<String> subjects,
    required List<String> availableDays,
    required List<String> availableSlots,
    required bool isTnCAgreement,
  }) async {
    try {
      final response = await _dio.post('/users/tutor/profile', data: {
        'preferredLanguage': preferredLanguage,
        'educationStatus': educationStatus,
        if (educationEndDate != null) 'educationEndDate': educationEndDate,
        'university': university,
        'highestQualification': highestQualification,
        'teachingExperience': teachingExperience,
        if (taughtAt != null) 'taughtAt': taughtAt,
        'classLevelsCanTeach': classLevelsCanTeach,
        'subjects': subjects,
        'availableDays': availableDays,
        'availableSlots': availableSlots,
        'isTnCAgreement': isTnCAgreement,
      });

      return response.data;
    } catch (e) {
      print('🎓 API Error: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTutorProfile() async {
    try {
      final response = await _dio.get('/users/tutor/profile');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // User endpoints
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put('/users/profile', data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Questions Management endpoints
  Future<Question> createQuestion(CreateQuestionDto questionDto) async {
    try {
      print('📝 Creating question: ${questionDto.title}');
      print('📝 Subject: ${questionDto.subject}, Topic: ${questionDto.topic}');

      FormData formData = FormData.fromMap(questionDto.toJson());

      // Add image if provided
      if (questionDto.image != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            questionDto.image!.path,
            filename: 'question_image.jpg',
          ),
        ));

      }

      final response = await _dio.post('/questions', data: formData);


      return Question.fromJson(response.data);
    } catch (e) {
      print('📝 Error creating question: $e');
      throw _handleError(e);
    }
  }

  Future<List<Question>> getMyQuestions() async {
    try {
      final response = await _dio.get('/questions/my-questions');

      final List<dynamic> questionsJson = response.data;
      final questions = questionsJson.map((json) => Question.fromJson(json)).toList();
      return questions;
    } catch (e) {
      print('📝 Error fetching my questions: $e');
      throw _handleError(e);
    }
  }

  Future<List<Question>> getAvailableQuestions({QuestionFiltersDto? filters}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (filters != null) {
        queryParams = filters.toQueryParams();
      }

      final response = await _dio.get('/questions/available', queryParameters: queryParams);

      final List<dynamic> questionsJson = response.data;
      final questions = questionsJson.map((json) => Question.fromJson(json)).toList();
      return questions;
    } catch (e) {
      print('📝 Error fetching available questions: $e');
      throw _handleError(e);
    }
  }

  Future<Question> acceptQuestion(String questionId) async {
    try {
      final response = await _dio.put('/questions/$questionId/accept');

      final question = Question.fromJson(response.data);

      return question;
    } catch (e) {
      print('📝 Error accepting question: $e');
      throw _handleError(e);
    }
  }

  Future<Question> getQuestionById(String questionId) async {
    try {
      print('📝 Fetching question by ID: $questionId');
      final response = await _dio.get('/questions/$questionId');

      final question = Question.fromJson(response.data);
      print('📝 Question fetched successfully');

      return question;
    } catch (e) {
      print('📝 Error fetching question by ID: $e');
      throw _handleError(e);
    }
  }

  Future<List<Question>> getMyAssignments() async {
    try {
      print('📝 Fetching my assignments...');
      final response = await _dio.get('/questions/my-assignments');

      final List<dynamic> questionsJson = response.data;
      final questions = questionsJson.map((json) => Question.fromJson(json)).toList();

      print('📝 Retrieved ${questions.length} assigned questions');
      return questions;
    } catch (e) {
      print('📝 Error fetching my assignments: $e');
      throw _handleError(e);
    }
  }

  Future<Question> updateQuestionStatus(
    String questionId,
    UpdateQuestionStatusDto statusDto
  ) async {
    try {
      print('📝 Updating question status: $questionId to ${statusDto.status}');
      final response = await _dio.put(
        '/questions/$questionId/status',
        data: statusDto.toJson(),
      );

      final question = Question.fromJson(response.data);
      print('📝 Question status updated successfully');

      return question;
    } catch (e) {
      print('📝 Error updating question status: $e');
      throw _handleError(e);
    }
  }



  // Check if student profile exists
  Future<bool> checkStudentProfile() async {
    try {
      final response = await _dio.get('/users/student/profile');
      return response.statusCode == 200 && response.data != null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return false; // Profile doesn't exist
      }
      print('❌ API Error in checkStudentProfile: $e');
      return false; // Assume profile doesn't exist on error
    }
  }

  // Check if tutor profile exists
  Future<bool> checkTutorProfile() async {
    try {
      final response = await _dio.get('/users/tutor/profile');
      return response.statusCode == 200 && response.data != null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return false; // Profile doesn't exist
      }
      print('❌ API Error in checkTutorProfile: $e');
      return false; // Assume profile doesn't exist on error
    }
  }

  // Chat/Messaging endpoints
  Future<Message> sendMessage(SendMessageDto messageDto) async {
    try {
      final response = await _dio.post('/chat/message', data: messageDto.toJson());

      final message = Message.fromJson(response.data);

      return message;
    } catch (e) {
      print('💬 Error sending message: $e');
      throw _handleError(e);
    }
  }

  Future<List<Message>> getMessages(String questionId) async {
    try {
      final response = await _dio.get('/chat/question/$questionId/messages');

      final List<dynamic> messagesJson = response.data;
      final messages = messagesJson.map((json) => Message.fromJson(json)).toList();
      return messages;
    } catch (e) {
      print('💬 Error fetching messages: $e');
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'An error occurred';
          
          switch (statusCode) {
            case 400:
              return message;
            case 401:
              return 'Unauthorized. Please login again.';
            case 403:
              return 'Access forbidden.';
            case 404:
              return 'Resource not found.';
            case 500:
              return 'Server error. Please try again later.';
            default:
              return message;
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          return 'Network error. Please check your internet connection.';
        default:
          return 'An unexpected error occurred.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
