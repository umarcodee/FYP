import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/database_service.dart';
import '../providers/drowsiness_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/neon_button.dart';
import '../widgets/status_card.dart';
import '../widgets/quick_stats_card.dart';

/// Home screen with start/stop detection, logs access, and settings
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _loadInitialData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Load initial data and initialize providers
  Future<void> _loadInitialData() async {
    try {
      // Initialize providers
      await Provider.of<SettingsProvider>(context, listen: false).initialize();
      await Provider.of<LocationProvider>(context, listen: false).initialize();
      
      // Load statistics
      _stats = DatabaseService.getDrowsinessStatistics();
      
      // Auto-start monitoring if enabled
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (settings.autoStartMonitoring) {
        _startDetection();
      }
      
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Start drowsiness detection
  Future<void> _startDetection() async {
    try {
      final drowsinessProvider = Provider.of<DrowsinessProvider>(context, listen: false);
      
      if (!drowsinessProvider.isInitialized) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Initializing camera and ML detection...'),
              backgroundColor: AppTheme.primaryNeon,
            ),
          );
        }
        
        await drowsinessProvider.initialize();
      }
      
      await drowsinessProvider.startMonitoring();
      
      // Navigate to detection screen
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.detection);
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting detection: $e'),
            backgroundColor: AppTheme.dangerNeon,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBg,
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryNeon))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      _buildMainControls(),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      _buildQuickStats(),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      _buildQuickActions(),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      _buildRecentActivity(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// Build the header with app title and settings
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Monitor',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.primaryNeon,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            Text(
              'AI-Powered Safety Assistant',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          icon: const Icon(
            Icons.settings,
            color: AppTheme.primaryNeon,
            size: 28,
          ),
        ).animate().fadeIn(duration: 600.ms).scale(delay: 400.ms),
      ],
    );
  }

  /// Build main detection controls
  Widget _buildMainControls() {
    return Consumer<DrowsinessProvider>(
      builder: (context, drowsinessProvider, child) {
        final isMonitoring = drowsinessProvider.isMonitoring;
        
        return Column(
          children: [
            // Status card
            StatusCard(
              title: isMonitoring ? 'Monitoring Active' : 'Ready to Monitor',
              subtitle: isMonitoring 
                  ? 'AI is watching for drowsiness signs' 
                  : 'Tap start to begin detection',
              status: isMonitoring 
                  ? drowsinessProvider.currentState 
                  : DrowsinessState.normal,
              confidence: drowsinessProvider.currentConfidence,
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Main action button
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: isMonitoring 
                      ? 1.0 + (_pulseController.value * 0.05)
                      : 1.0,
                  child: NeonButton(
                    text: isMonitoring ? 'VIEW DETECTION' : 'START MONITORING',
                    onPressed: isMonitoring 
                        ? () => Navigator.pushNamed(context, AppRoutes.detection)
                        : _startDetection,
                    gradient: LinearGradient(
                      colors: isMonitoring 
                          ? [AppTheme.accentNeon, AppTheme.primaryNeon]
                          : [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                    ),
                    icon: isMonitoring ? Icons.visibility : Icons.play_arrow,
                    isLoading: false,
                  ),
                );
              },
            ).animate().fadeIn(duration: 1000.ms, delay: 400.ms).scale(begin: 0.8),
            
            if (isMonitoring) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              NeonButton(
                text: 'STOP MONITORING',
                onPressed: () async {
                  await drowsinessProvider.stopMonitoring();
                  setState(() {
                    _stats = DatabaseService.getDrowsinessStatistics();
                  });
                },
                gradient: const LinearGradient(
                  colors: [AppTheme.dangerNeon, Colors.red],
                ),
                icon: Icons.stop,
                isSecondary: true,
              ).animate().fadeIn(duration: 600.ms),
            ],
          ],
        );
      },
    );
  }

  /// Build quick statistics cards
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Summary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryNeon,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Row(
          children: [
            Expanded(
              child: QuickStatsCard(
                title: 'Events Today',
                value: _stats['todayEvents']?.toString() ?? '0',
                icon: Icons.warning_amber,
                color: AppTheme.warningNeon,
              ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideX(begin: -0.2),
            ),
            
            const SizedBox(width: AppConstants.paddingMedium),
            
            Expanded(
              child: QuickStatsCard(
                title: 'This Week',
                value: _stats['thisWeekEvents']?.toString() ?? '0',
                icon: Icons.calendar_week,
                color: AppTheme.primaryNeon,
              ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideX(begin: 0.2),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Row(
          children: [
            Expanded(
              child: QuickStatsCard(
                title: 'Critical Alerts',
                value: _stats['criticalEvents']?.toString() ?? '0',
                icon: Icons.crisis_alert,
                color: AppTheme.dangerNeon,
              ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideX(begin: -0.2),
            ),
            
            const SizedBox(width: AppConstants.paddingMedium),
            
            Expanded(
              child: QuickStatsCard(
                title: 'Total Events',
                value: _stats['totalEvents']?.toString() ?? '0',
                icon: Icons.analytics,
                color: AppTheme.accentNeon,
              ).animate().fadeIn(duration: 800.ms, delay: 800.ms).slideX(begin: 0.2),
            ),
          ],
        ),
      ],
    );
  }

  /// Build quick action buttons
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryNeon,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.history,
              label: 'View Logs',
              onTap: () => Navigator.pushNamed(context, AppRoutes.logs),
            ).animate().fadeIn(duration: 800.ms, delay: 200.ms).scale(begin: 0.8),
            
            _buildActionButton(
              icon: Icons.map,
              label: 'Find Places',
              onTap: () => Navigator.pushNamed(context, AppRoutes.maps),
            ).animate().fadeIn(duration: 800.ms, delay: 400.ms).scale(begin: 0.8),
            
            _buildActionButton(
              icon: Icons.chat,
              label: 'Assistant',
              onTap: () => Navigator.pushNamed(context, AppRoutes.chatbot),
            ).animate().fadeIn(duration: 800.ms, delay: 600.ms).scale(begin: 0.8),
            
            _buildActionButton(
              icon: Icons.emergency,
              label: 'Emergency',
              onTap: () => Navigator.pushNamed(context, AppRoutes.emergency),
            ).animate().fadeIn(duration: 800.ms, delay: 800.ms).scale(begin: 0.8),
          ],
        ),
      ],
    );
  }

  /// Build individual action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: AppTheme.primaryNeon.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNeon.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryNeon,
              size: AppConstants.largeIconSize,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build recent activity section
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryNeon,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: AppTheme.primaryNeon.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: _stats['lastEventTime'] != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppTheme.primaryNeon,
                          size: AppConstants.iconSize,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Last Detection',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      _formatLastEventTime(_stats['lastEventTime']),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.accentNeon,
                      size: AppConstants.largeIconSize,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'No recent drowsiness events',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.2),
      ],
    );
  }

  /// Format last event time for display
  String _formatLastEventTime(DateTime? dateTime) {
    if (dateTime == null) return 'No recent events';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}