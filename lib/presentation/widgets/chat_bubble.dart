import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/chatbot_provider.dart';

/// Chat bubble widget for displaying messages in the chatbot
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isEmergency;

  const ChatBubble({
    super.key,
    required this.message,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(),
            const SizedBox(width: AppConstants.paddingSmall),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: _getBubbleColor(),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser ? null : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : null,
                ),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getBorderColor().withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _buildTimestamp(context),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: AppConstants.paddingSmall),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isEmergency
              ? [AppTheme.dangerNeon, Colors.red]
              : [AppTheme.primaryNeon, AppTheme.accentNeon],
        ),
        boxShadow: [
          BoxShadow(
            color: (isEmergency ? AppTheme.dangerNeon : AppTheme.primaryNeon)
                .withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        isEmergency ? Icons.emergency : Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.darkCard,
        border: Border.all(
          color: AppTheme.primaryNeon.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: AppTheme.primaryNeon,
        size: 20,
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case ChatMessageType.suggestion:
        return _buildSuggestionMessage();
      case ChatMessageType.location:
        return _buildLocationMessage();
      case ChatMessageType.emergency:
        return _buildEmergencyMessage();
      default:
        return _buildTextMessage();
    }
  }

  Widget _buildTextMessage() {
    return Text(
      message.message,
      style: TextStyle(
        color: message.isUser ? Colors.black : Colors.white,
        fontSize: 16,
        height: 1.4,
      ),
    );
  }

  Widget _buildSuggestionMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppTheme.warningNeon,
              size: 20,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(
              'Suggestion',
              style: TextStyle(
                color: AppTheme.warningNeon,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          message.message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppTheme.accentNeon,
              size: 20,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(
              'Location Search',
              style: TextStyle(
                color: AppTheme.accentNeon,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          message.message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emergency,
              color: AppTheme.dangerNeon,
              size: 20,
            ).animate().shake(duration: 600.ms),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(
              'EMERGENCY',
              style: TextStyle(
                color: AppTheme.dangerNeon,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          message.message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          size: 12,
          color: Colors.white.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          _formatTimestamp(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getBubbleColor() {
    if (message.isUser) {
      return isEmergency 
          ? AppTheme.dangerNeon.withOpacity(0.9)
          : AppTheme.primaryNeon;
    }
    
    switch (message.type) {
      case ChatMessageType.emergency:
        return AppTheme.dangerNeon.withOpacity(0.2);
      case ChatMessageType.suggestion:
        return AppTheme.warningNeon.withOpacity(0.2);
      case ChatMessageType.location:
        return AppTheme.accentNeon.withOpacity(0.2);
      default:
        return AppTheme.darkCard;
    }
  }

  Color _getBorderColor() {
    if (message.isUser) {
      return isEmergency 
          ? AppTheme.dangerNeon
          : AppTheme.primaryNeon;
    }
    
    switch (message.type) {
      case ChatMessageType.emergency:
        return AppTheme.dangerNeon;
      case ChatMessageType.suggestion:
        return AppTheme.warningNeon;
      case ChatMessageType.location:
        return AppTheme.accentNeon;
      default:
        return AppTheme.primaryNeon.withOpacity(0.3);
    }
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final diff = now.difference(message.timestamp);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${message.timestamp.day}/${message.timestamp.month}';
    }
  }
}

/// Typing indicator animation for chatbot
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
    
    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryNeon.withOpacity(_animations[index].value),
              ),
            );
          },
        );
      }),
    );
  }
}