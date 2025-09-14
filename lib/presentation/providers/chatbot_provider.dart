import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';

/// Model class for chat messages
class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType type;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.type = ChatMessageType.text,
  });
}

/// Enumeration for chat message types
enum ChatMessageType {
  text,
  suggestion,
  location,
  emergency,
}

/// Provider for managing chatbot interactions and responses
class ChatbotProvider extends ChangeNotifier {
  // Chat state
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isEmergencyMode = false;
  String _currentContext = '';
  
  // Conversation flow state
  int _conversationStep = 0;
  bool _hasAskedForHelp = false;
  bool _hasProvidedSuggestions = false;
  
  // Timer for typing simulation
  Timer? _typingTimer;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isEmergencyMode => _isEmergencyMode;
  String get currentContext => _currentContext;

  /// Initialize chatbot with greeting message
  void initialize({bool isEmergency = false}) {
    _isEmergencyMode = isEmergency;
    _currentContext = isEmergency ? 'emergency' : 'general';
    _conversationStep = 0;
    
    _messages.clear();
    
    // Add initial greeting
    final greeting = _getGreetingMessage();
    _addBotMessage(greeting);
    
    // If emergency mode, add immediate assistance options
    if (isEmergency) {
      _addEmergencyOptions();
    }
    
    notifyListeners();
  }

  /// Get appropriate greeting message
  String _getGreetingMessage() {
    if (_isEmergencyMode) {
      return "I detected you might be feeling drowsy while driving. Your safety is my priority. How can I help you right now?";
    }
    
    final greetings = AppConstants.chatbotGreetings;
    return greetings[DateTime.now().millisecond % greetings.length];
  }

  /// Add emergency assistance options
  void _addEmergencyOptions() {
    Timer(const Duration(milliseconds: 1000), () {
      _addBotMessage(
        "Here's what I can do to help:",
        type: ChatMessageType.suggestion,
      );
      
      Timer(const Duration(milliseconds: 500), () {
        _addBotMessage("• Find nearby rest stops");
        _addBotMessage("• Locate gas stations");
        _addBotMessage("• Show hospitals nearby");
        _addBotMessage("• Contact emergency contacts");
        _addBotMessage("• Provide rest suggestions");
        
        notifyListeners();
      });
    });
  }

  /// Send user message
  void sendMessage(String message) {
    if (message.trim().isEmpty) return;
    
    // Add user message
    _addUserMessage(message);
    
    // Generate bot response
    _generateBotResponse(message);
    
    notifyListeners();
  }

  /// Add user message to chat
  void _addUserMessage(String message) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
  }

  /// Add bot message to chat
  void _addBotMessage(String message, {ChatMessageType type = ChatMessageType.text}) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: false,
      timestamp: DateTime.now(),
      type: type,
    ));
  }

  /// Generate bot response based on user input
  void _generateBotResponse(String userMessage) {
    _isTyping = true;
    notifyListeners();
    
    // Simulate typing delay
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      _isTyping = false;
      
      final response = _analyzeBotResponse(userMessage.toLowerCase());
      _addBotMessage(response);
      
      // Add follow-up actions if needed
      _addFollowUpActions(userMessage.toLowerCase());
      
      notifyListeners();
    });
  }

  /// Analyze user input and generate appropriate response
  String _analyzeBotResponse(String userMessage) {
    // Drowsiness-related keywords
    if (userMessage.contains('tired') || userMessage.contains('sleepy') || 
        userMessage.contains('drowsy') || userMessage.contains('exhausted')) {
      return _getTiredResponse();
    }
    
    // Location/navigation keywords
    if (userMessage.contains('rest') || userMessage.contains('stop') || 
        userMessage.contains('break') || userMessage.contains('pull over')) {
      return "I'll help you find a safe place to rest. Let me search for nearby rest stops and safe areas.";
    }
    
    // Emergency keywords
    if (userMessage.contains('emergency') || userMessage.contains('help') || 
        userMessage.contains('urgent') || userMessage.contains('danger')) {
      return _getEmergencyResponse();
    }
    
    // Coffee/caffeine keywords
    if (userMessage.contains('coffee') || userMessage.contains('caffeine') || 
        userMessage.contains('drink') || userMessage.contains('energy')) {
      return "Good idea! Caffeine can help temporarily, but remember it takes 20-30 minutes to take effect. I'll find nearby coffee shops or gas stations for you.";
    }
    
    // Hotel/sleep keywords
    if (userMessage.contains('hotel') || userMessage.contains('motel') || 
        userMessage.contains('sleep') || userMessage.contains('overnight')) {
      return "That's a wise decision. Getting proper rest is the safest option. I'll find nearby hotels and motels where you can rest safely.";
    }
    
    // Hospital keywords
    if (userMessage.contains('hospital') || userMessage.contains('medical') || 
        userMessage.contains('doctor') || userMessage.contains('sick')) {
      return "I understand your concern. I'll locate the nearest hospitals and medical facilities. Should I also contact your emergency contacts?";
    }
    
    // Positive responses
    if (userMessage.contains('yes') || userMessage.contains('ok') || 
        userMessage.contains('sure') || userMessage.contains('please')) {
      return _getPositiveResponse();
    }
    
    // Negative responses
    if (userMessage.contains('no') || userMessage.contains('not') || 
        userMessage.contains('don\'t') || userMessage.contains('won\'t')) {
      return _getNegativeResponse();
    }
    
    // Greeting responses
    if (userMessage.contains('hello') || userMessage.contains('hi') || 
        userMessage.contains('hey') || userMessage.contains('good')) {
      return "Hello! I'm here to help ensure your safety while driving. How are you feeling right now?";
    }
    
    // Default response
    return _getDefaultResponse();
  }

  /// Get response for tiredness/drowsiness
  String _getTiredResponse() {
    final suggestions = AppConstants.restSuggestions;
    final randomSuggestion = suggestions[Random().nextInt(suggestions.length)];
    
    return "I understand you're feeling tired. This is serious - drowsy driving can be very dangerous. "
           "Here's my immediate suggestion: $randomSuggestion\n\n"
           "Would you like me to find nearby places where you can rest safely?";
  }

  /// Get emergency response
  String _getEmergencyResponse() {
    _isEmergencyMode = true;
    return "This sounds urgent. I'm switching to emergency mode. I can:\n"
           "• Contact your emergency contacts immediately\n"
           "• Find the nearest hospital\n"
           "• Locate police stations\n"
           "• Guide you to pull over safely\n\n"
           "What do you need right now?";
  }

  /// Get positive response
  String _getPositiveResponse() {
    if (!_hasProvidedSuggestions) {
      _hasProvidedSuggestions = true;
      return "Great! I'll help you with that. Let me search for what you need in your area.";
    }
    return "Excellent choice! Your safety is the most important thing. I'm searching for options near you now.";
  }

  /// Get negative response
  String _getNegativeResponse() {
    return "I understand, but your safety is my top priority. Even if you don't want to stop now, "
           "please promise me you'll pull over if you feel any more drowsiness. "
           "Can I at least show you where the nearest safe spots are, just in case?";
  }

  /// Get default response
  String _getDefaultResponse() {
    final responses = [
      "I'm here to help keep you safe. Can you tell me more about how you're feeling?",
      "Your safety matters. What would be most helpful for you right now?",
      "I want to make sure you get to your destination safely. How can I assist you?",
      "Let me help you stay safe on the road. What do you need?",
    ];
    
    return responses[Random().nextInt(responses.length)];
  }

  /// Add follow-up actions based on user message
  void _addFollowUpActions(String userMessage) {
    Timer(const Duration(milliseconds: 1000), () {
      if (userMessage.contains('rest') || userMessage.contains('stop')) {
        _addLocationSuggestions();
      } else if (userMessage.contains('emergency') || userMessage.contains('help')) {
        _addEmergencyActions();
      } else if (userMessage.contains('tired') || userMessage.contains('sleepy')) {
        _addRestSuggestions();
      }
      
      notifyListeners();
    });
  }

  /// Add location-based suggestions
  void _addLocationSuggestions() {
    _addBotMessage("🗺️ Searching for nearby locations...", type: ChatMessageType.location);
    
    Timer(const Duration(milliseconds: 1500), () {
      _addBotMessage("I found several options near you:");
      _addBotMessage("• Rest areas (2.1 km away)");
      _addBotMessage("• Gas stations (1.5 km away)");
      _addBotMessage("• Hotels (3.2 km away)");
      _addBotMessage("\nTap any option to get directions!");
      
      notifyListeners();
    });
  }

  /// Add emergency actions
  void _addEmergencyActions() {
    _addBotMessage("🚨 Emergency assistance activated", type: ChatMessageType.emergency);
    
    Timer(const Duration(milliseconds: 1000), () {
      _addBotMessage("I can:");
      _addBotMessage("1. Call emergency services (911)");
      _addBotMessage("2. Contact your emergency contacts");
      _addBotMessage("3. Share your location with them");
      _addBotMessage("4. Guide you to nearest hospital");
      _addBotMessage("\nWhat would you like me to do?");
      
      notifyListeners();
    });
  }

  /// Add rest suggestions
  void _addRestSuggestions() {
    Timer(const Duration(milliseconds: 1000), () {
      _addBotMessage("Here are some immediate things you can do:");
      
      for (final suggestion in AppConstants.restSuggestions.take(3)) {
        Timer(const Duration(milliseconds: 500), () {
          _addBotMessage("• $suggestion");
          notifyListeners();
        });
      }
      
      Timer(const Duration(milliseconds: 2000), () {
        _addBotMessage("\nRemember: If you're too tired to drive safely, the best option is always to rest. Would you like me to find a safe place for you to stop?");
        notifyListeners();
      });
    });
  }

  /// Handle quick response buttons
  void handleQuickResponse(String response) {
    sendMessage(response);
  }

  /// Get suggested quick responses
  List<String> getSuggestedResponses() {
    if (_isEmergencyMode) {
      return [
        "Find nearest hospital",
        "Contact emergency contacts",
        "I need to pull over now",
        "Call 911",
      ];
    }
    
    return [
      "I'm feeling tired",
      "Find rest stops",
      "Find coffee shops",
      "Find hotels",
      "I'm okay to continue",
    ];
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    _conversationStep = 0;
    _hasAskedForHelp = false;
    _hasProvidedSuggestions = false;
    _isEmergencyMode = false;
    _currentContext = '';
    notifyListeners();
  }

  /// Export chat history
  List<Map<String, dynamic>> exportChatHistory() {
    return _messages.map((message) => {
      'id': message.id,
      'message': message.message,
      'isUser': message.isUser,
      'timestamp': message.timestamp.toIso8601String(),
      'type': message.type.name,
    }).toList();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}