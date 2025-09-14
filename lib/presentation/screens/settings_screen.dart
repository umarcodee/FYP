import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../widgets/neon_button.dart';
import '../widgets/settings_tile.dart';

/// Settings screen for app preferences and emergency contacts
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppTheme.primaryNeon,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
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
        child: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            if (!settings.isInitialized) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryNeon),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Display & Interface', [
                    SettingsTile.switchTile(
                      title: 'Dark Mode',
                      subtitle: 'Enable futuristic dark theme',
                      icon: Icons.dark_mode,
                      value: settings.isDarkMode,
                      onChanged: settings.setDarkMode,
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                  ]),

                  _buildSection('Detection Settings', [
                    SettingsTile.sliderTile(
                      title: 'Detection Sensitivity',
                      subtitle: 'Adjust ML detection sensitivity (${settings.sensitivityDescription})',
                      icon: Icons.tune,
                      value: settings.detectionSensitivity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      onChanged: settings.setDetectionSensitivity,
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                    SettingsTile.switchTile(
                      title: 'Auto-Start Monitoring',
                      subtitle: 'Start detection automatically on app launch',
                      icon: Icons.auto_mode,
                      value: settings.autoStartMonitoring,
                      onChanged: settings.setAutoStartMonitoring,
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                  ]),

                  _buildSection('Notifications & Alerts', [
                    SettingsTile.switchTile(
                      title: 'Push Notifications',
                      subtitle: 'Receive drowsiness alerts',
                      icon: Icons.notifications,
                      value: settings.enableNotifications,
                      onChanged: settings.setNotifications,
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                    SettingsTile.sliderTile(
                      title: 'Alert Volume',
                      subtitle: 'Sound alert volume (${settings.volumeDescription})',
                      icon: Icons.volume_up,
                      value: settings.alertVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: settings.setAlertVolume,
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                    SettingsTile.switchTile(
                      title: 'SMS Alerts',
                      subtitle: 'Send SMS to emergency contacts',
                      icon: Icons.sms,
                      value: settings.enableSmsAlerts,
                      onChanged: settings.setSmsAlerts,
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                  ]),

                  _buildSection('Emergency Features', [
                    SettingsTile.switchTile(
                      title: 'Auto Emergency Call',
                      subtitle: 'Automatically call emergency services',
                      icon: Icons.emergency,
                      value: settings.emergencyAutoCall,
                      onChanged: settings.setEmergencyAutoCall,
                    ).animate().fadeIn(duration: 600.ms, delay: 700.ms),

                    SettingsTile.switchTile(
                      title: 'Location Services',
                      subtitle: 'Enable GPS for emergency locations',
                      icon: Icons.location_on,
                      value: settings.locationServices,
                      onChanged: settings.setLocationServices,
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
                  ]),

                  _buildSection('Advanced Features', [
                    SettingsTile.switchTile(
                      title: 'Voice Chat',
                      subtitle: 'Enable voice interaction with AI assistant',
                      icon: Icons.mic,
                      value: settings.enableVoiceChat,
                      onChanged: settings.setVoiceChat,
                    ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

                    SettingsTile.sliderTile(
                      title: 'Data Retention',
                      subtitle: 'Keep logs for ${settings.retentionDescription}',
                      icon: Icons.storage,
                      value: settings.dataRetentionDays.toDouble(),
                      min: 7,
                      max: 365,
                      divisions: 12,
                      onChanged: (value) => settings.setDataRetentionDays(value.round()),
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
                  ]),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Action buttons
                  Column(
                    children: [
                      NeonButton(
                        text: 'Manage Emergency Contacts',
                        icon: Icons.contacts,
                        onPressed: () => _showEmergencyContactsDialog(),
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondaryNeon, AppTheme.primaryNeon],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 1100.ms),

                      const SizedBox(height: AppConstants.paddingMedium),

                      NeonOutlineButton(
                        text: 'Reset to Defaults',
                        icon: Icons.restore,
                        color: AppTheme.warningNeon,
                        onPressed: () => _showResetDialog(settings),
                      ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // App info
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
                        child: Column(
                          children: [
                            Text(
                              AppConstants.appName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.primaryNeon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Version ${AppConstants.appVersion}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants.appDescription,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 1300.ms),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryNeon,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: AppTheme.primaryNeon.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
      ],
    );
  }

  void _showResetDialog(SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: Text(
          'Reset Settings',
          style: TextStyle(color: AppTheme.warningNeon),
        ),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          NeonButton(
            text: 'Reset',
            gradient: const LinearGradient(
              colors: [AppTheme.warningNeon, Colors.orange],
            ),
            onPressed: () async {
              await settings.resetToDefaults();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                    backgroundColor: AppTheme.accentNeon,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEmergencyContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: Text(
          'Emergency Contacts',
          style: TextStyle(color: AppTheme.primaryNeon),
        ),
        content: const Text(
          'Emergency contact management will be available in the next update.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          NeonButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}