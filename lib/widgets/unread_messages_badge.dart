import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/global_chat_service.dart';

class UnreadMessagesBadge extends StatelessWidget {
  final Widget child;
  final String? questionId; // If provided, shows count for specific question
  final bool showTotal; // If true, shows total unread count across all questions

  const UnreadMessagesBadge({
    Key? key,
    required this.child,
    this.questionId,
    this.showTotal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalChatService>(
      builder: (context, globalChatService, _) {
        int unreadCount = 0;
        
        if (questionId != null) {
          // Show unread count for specific question
          unreadCount = globalChatService.getUnreadCount(questionId!);
        } else if (showTotal) {
          // Show total unread count across all questions
          unreadCount = globalChatService.getTotalUnreadCount();
        }

        if (unreadCount == 0) {
          return child;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Badge for showing unread count on question cards
class QuestionUnreadBadge extends StatelessWidget {
  final String questionId;

  const QuestionUnreadBadge({
    Key? key,
    required this.questionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalChatService>(
      builder: (context, globalChatService, _) {
        final unreadCount = globalChatService.getUnreadCount(questionId);
        
        if (unreadCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
