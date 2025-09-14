import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/location_provider.dart';
import '../widgets/neon_button.dart';

/// Emergency screen for critical situations
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _emergencyController;
  bool _isEmergencyActivated = false;
  int _countdown = 10;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _emergencyController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _activateEmergency() {
    setState(() => _isEmergencyActivated = true);
    _emergencyController.forward();
    
    // TODO: Implement actual emergency actions
    // - Send SMS to emergency contacts
    // - Call emergency services (if enabled)
    // - Share location
    // - Log emergency event
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency services have been notified'),
        backgroundColor: AppTheme.dangerNeon,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Icon(
                  Icons.emergency,
                  color: AppTheme.dangerNeon.withOpacity(
                    0.5 + (_pulseController.value * 0.5)
                  ),
                  size: 28,
                );
              },
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(
              'Emergency',
              style: TextStyle(
                color: AppTheme.dangerNeon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBg,
              const Color(0xFF2A1A1A),
              AppTheme.dangerNeon.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                Expanded(child: _buildMainContent()),
                _buildEmergencyActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Emergency icon
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.dangerNeon.withOpacity(0.3 + (_pulseController.value * 0.4)),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: AppTheme.dangerNeon.withOpacity(0.6 + (_pulseController.value * 0.4)),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.dangerNeon.withOpacity(0.3 + (_pulseController.value * 0.3)),
                    blurRadius: 20 + (_pulseController.value * 20),
                    spreadRadius: 5 + (_pulseController.value * 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.emergency,
                size: 80,
                color: AppTheme.dangerNeon,
              ),
            );
          },
        ).animate().scale(duration: 600.ms),
        
        const SizedBox(height: AppConstants.paddingXLarge),
        
        // Warning message
        Text(
          _isEmergencyActivated ? 'EMERGENCY ACTIVATED' : 'EMERGENCY ASSISTANCE',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppTheme.dangerNeon,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        Text(
          _isEmergencyActivated 
              ? 'Emergency services have been notified.\nYour location has been shared with your emergency contacts.'
              : 'Use this only in genuine emergencies.\nThis will alert emergency services and your contacts.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
        
        const SizedBox(height: AppConstants.paddingXLarge),
        
        // Location info
        Consumer<LocationProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: AppTheme.dangerNeon.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: AppTheme.accentNeon,
                        size: AppConstants.iconSize,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'Current Location',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    provider.isLocationAvailable 
                        ? provider.formattedLocation
                        : 'Location not available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: provider.isLocationAvailable ? Colors.white70 : AppTheme.warningNeon,
                    ),
                  ),
                  if (!provider.isLocationAvailable) ...[
                    const SizedBox(height: AppConstants.paddingMedium),
                    NeonOutlineButton(
                      text: 'Get Location',
                      icon: Icons.location_searching,
                      color: AppTheme.warningNeon,
                      onPressed: () => provider.getCurrentLocation(),
                    ),
                  ],
                ],
              ),
            );
          },
        ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
      ],
    );
  }

  Widget _buildEmergencyActions() {
    return Column(
      children: [
        // Main emergency button
        if (!_isEmergencyActivated) ...[
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.dangerNeon,
                        Colors.red.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.dangerNeon.withOpacity(0.4 + (_pulseController.value * 0.3)),
                        blurRadius: 15 + (_pulseController.value * 15),
                        spreadRadius: 3 + (_pulseController.value * 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showEmergencyConfirmation,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emergency,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Text(
                            'ACTIVATE EMERGENCY',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ).animate().fadeIn(duration: 1000.ms, delay: 800.ms),
          
          const SizedBox(height: AppConstants.paddingLarge),
        ],
        
        // Quick action buttons
        Row(
          children: [
            Expanded(
              child: NeonButton(
                text: 'Call 911',
                icon: Icons.phone,
                gradient: const LinearGradient(
                  colors: [AppTheme.dangerNeon, Colors.red],
                ),
                onPressed: _callEmergencyServices,
              ),
            ),
            
            const SizedBox(width: AppConstants.paddingMedium),
            
            Expanded(
              child: NeonButton(
                text: 'Find Hospital',
                icon: Icons.local_hospital,
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNeon, AppTheme.accentNeon],
                ),
                onPressed: _findNearestHospital,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 800.ms, delay: 1000.ms),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Row(
          children: [
            Expanded(
              child: NeonOutlineButton(
                text: 'Contact Family',
                icon: Icons.contacts,
                color: AppTheme.accentNeon,
                onPressed: _contactEmergencyContacts,
              ),
            ),
            
            const SizedBox(width: AppConstants.paddingMedium),
            
            Expanded(
              child: NeonOutlineButton(
                text: 'AI Assistant',
                icon: Icons.chat,
                color: AppTheme.primaryNeon,
                onPressed: _openEmergencyChat,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 800.ms, delay: 1200.ms),
      ],
    );
  }

  void _showEmergencyConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(color: AppTheme.dangerNeon, width: 2),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.dangerNeon,
              size: AppConstants.largeIconSize,
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Text(
              'CONFIRM EMERGENCY',
              style: TextStyle(
                color: AppTheme.dangerNeon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will immediately:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Call emergency services (911)', style: TextStyle(color: Colors.white)),
                Text('• Send SMS to emergency contacts', style: TextStyle(color: Colors.white)),
                Text('• Share your current location', style: TextStyle(color: Colors.white)),
                Text('• Log this as a critical event', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              'Are you sure this is an emergency?',
              style: TextStyle(
                color: AppTheme.dangerNeon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          NeonOutlineButton(
            text: 'Cancel',
            color: Colors.grey,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          NeonButton(
            text: 'CONFIRM EMERGENCY',
            gradient: const LinearGradient(
              colors: [AppTheme.dangerNeon, Colors.red],
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _activateEmergency();
            },
          ),
        ],
      ),
    );
  }

  void _callEmergencyServices() {
    // TODO: Implement actual phone call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling emergency services...'),
        backgroundColor: AppTheme.dangerNeon,
      ),
    );
  }

  void _findNearestHospital() {
    Navigator.pushNamed(
      context,
      AppRoutes.maps,
      arguments: {'searchType': 'hospitals'},
    );
  }

  void _contactEmergencyContacts() {
    // TODO: Implement emergency contacts SMS
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contacting emergency contacts...'),
        backgroundColor: AppTheme.primaryNeon,
      ),
    );
  }

  void _openEmergencyChat() {
    Navigator.pushNamed(
      context,
      AppRoutes.chatbot,
      arguments: {'isEmergency': true},
    );
  }
}