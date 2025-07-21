class Message {
  final String id;
  final String questionId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageSender? sender;

  const Message({
    required this.id,
    required this.questionId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      print('🎯 Parsing message JSON: ${json['id']} - Text: ${json['text']}');
      
      return Message(
        id: json['id'] as String,
        questionId: json['questionId'] as String,
        senderId: json['senderId'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        sender: json['sender'] != null
            ? MessageSender.fromJson(json['sender'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('🎯 Error parsing message JSON: $e');
      print('🎯 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'sender': sender?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Message(id: $id, questionId: $questionId, senderId: $senderId, text: $text, timestamp: $timestamp)';
  }
}

class MessageSender {
  final String id;
  final String email;
  final String role;

  const MessageSender({
    required this.id,
    required this.email,
    required this.role,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'MessageSender(id: $id, email: $email, role: $role)';
  }
}

/// DTO for sending messages
class SendMessageDto {
  final String questionId;
  final String text;

  const SendMessageDto({
    required this.questionId,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'SendMessageDto(questionId: $questionId, text: $text)';
  }
}
