import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/neon_button.dart';
import '../widgets/chat_bubble.dart';

/// Chatbot screen for driver assistance and rest suggestions
class ChatbotScreen extends StatefulWidget {
  final bool isEmergency;

  const ChatbotScreen({
    super.key,
    this.isEmergency = false,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _emergencyPulseController;
  
  bool _showQuickResponses = true;

  @override
  void initState() {
    super.initState();
    
    _emergencyPulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (widget.isEmergency) {
      _emergencyPulseController.repeat();
    }

    // Initialize chatbot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatbotProvider>(context, listen: false)
          .initialize(isEmergency: widget.isEmergency);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _emergencyPulseController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      Provider.of<ChatbotProvider>(context, listen: false).sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
      setState(() => _showQuickResponses = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBg,
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildChatArea()),
            _buildQuickResponses(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Row(
        children: [
          if (widget.isEmergency)
            AnimatedBuilder(
              animation: _emergencyPulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.dangerNeon.withOpacity(
                      0.3 + (_emergencyPulseController.value * 0.4)
                    ),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: AppTheme.dangerNeon,
                    size: 20,
                  ),
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryNeon.withOpacity(0.3),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppTheme.primaryNeon,
                size: 20,
              ),
            ),
          
          const SizedBox(width: AppConstants.paddingMedium),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEmergency ? 'Emergency Assistant' : 'AI Assistant',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.isEmergency ? 'Priority Support' : 'Here to help you drive safely',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<ChatbotProvider>(
          builder: (context, provider, child) {
            return IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.darkCard,
                    title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Are you sure you want to clear the chat history?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearChat();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear', style: TextStyle(color: AppTheme.dangerNeon)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.clear_all, color: Colors.white70),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChatArea() {
    return Consumer<ChatbotProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.messages.length && provider.isTyping) {
              return _buildTypingIndicator();
            }
            
            final message = provider.messages[index];
            return ChatBubble(
              message: message,
              isEmergency: widget.isEmergency,
            ).animate().fadeIn(
              duration: 300.ms,
              delay: (index * 100).ms,
            ).slideX(
              begin: message.isUser ? 0.2 : -0.2,
              duration: 300.ms,
            );
          },
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryNeon.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryNeon.withOpacity(0.7),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          delay: (index * 200).ms,
        );
  }

  Widget _buildQuickResponses() {
    if (!_showQuickResponses) return const SizedBox.shrink();
    
    return Consumer<ChatbotProvider>(
      builder: (context, provider, child) {
        final suggestions = provider.getSuggestedResponses();
        
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppConstants.paddingSmall),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _buildQuickResponseChip(suggestion, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickResponseChip(String text, ChatbotProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.handleQuickResponse(text);
        setState(() => _showQuickResponses = false);
        _scrollToBottom();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryNeon.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNeon.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryNeon,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryNeon.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Voice input button (future enhancement)
            if (AppConstants.enableVoiceChat)
              Container(
                margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
                child: NeonIconButton(
                  icon: Icons.mic,
                  onPressed: () {
                    // TODO: Implement voice input
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice input coming soon!'),
                        backgroundColor: AppTheme.primaryNeon,
                      ),
                    );
                  },
                  size: 40,
                  color: AppTheme.accentNeon,
                ),
              ),
            
            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkBg,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppTheme.primaryNeon.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: widget.isEmergency 
                        ? 'Tell me what you need urgently...' 
                        : 'How can I help you stay safe?',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            
            const SizedBox(width: AppConstants.paddingMedium),
            
            // Send button
            NeonIconButton(
              icon: Icons.send,
              onPressed: _sendMessage,
              size: 40,
              color: widget.isEmergency ? AppTheme.dangerNeon : AppTheme.primaryNeon,
            ),
          ],
        ),
      ),
    );
  }
}