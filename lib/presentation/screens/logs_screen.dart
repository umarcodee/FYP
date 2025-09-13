import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/database_service.dart';
import '../../data/models/drowsiness_event.dart';
import '../widgets/neon_button.dart';

/// Logs screen showing drowsiness event history
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<DrowsinessEvent> _events = [];
  bool _isLoading = true;
  String _filterType = 'all';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    
    try {
      final events = DatabaseService.getAllDrowsinessEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $e'),
            backgroundColor: AppTheme.dangerNeon,
          ),
        );
      }
    }
  }

  List<DrowsinessEvent> get filteredEvents {
    var filtered = _events;
    
    // Filter by type
    if (_filterType != 'all') {
      switch (_filterType) {
        case 'critical':
          filtered = filtered.where((e) => e.drowsinessLevel == DrowsinessState.critical).toList();
          break;
        case 'alert':
          filtered = filtered.where((e) => e.drowsinessLevel == DrowsinessState.alert).toList();
          break;
        case 'drowsy':
          filtered = filtered.where((e) => e.drowsinessLevel == DrowsinessState.drowsy).toList();
          break;
      }
    }
    
    // Filter by date range
    if (_filterStartDate != null && _filterEndDate != null) {
      filtered = filtered.where((e) => 
        e.timestamp.isAfter(_filterStartDate!) && 
        e.timestamp.isBefore(_filterEndDate!)
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Event Logs',
          style: TextStyle(
            color: AppTheme.primaryNeon,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters ? AppTheme.primaryNeon : Colors.white70,
            ),
          ),
          IconButton(
            onPressed: _showOptionsDialog,
            icon: const Icon(Icons.more_vert, color: Colors.white70),
          ),
        ],
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
        child: _isLoading ? _buildLoadingScreen() : _buildEventsList(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryNeon),
          SizedBox(height: AppConstants.paddingLarge),
          Text(
            'Loading event logs...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final events = filteredEvents;
    
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Summary stats
        _buildSummaryCard(),
        
        // Events list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event, index)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                  .slideX(begin: 0.2, duration: 400.ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final events = filteredEvents;
    final criticalCount = events.where((e) => e.drowsinessLevel == DrowsinessState.critical).length;
    final alertCount = events.where((e) => e.drowsinessLevel == DrowsinessState.alert).length;
    final drowsyCount = events.where((e) => e.drowsinessLevel == DrowsinessState.drowsy).length;

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingLarge),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkCard, AppTheme.darkCard.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppTheme.primaryNeon.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryNeon,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total', events.length, AppTheme.primaryNeon),
              _buildSummaryItem('Critical', criticalCount, AppTheme.dangerNeon),
              _buildSummaryItem('Alert', alertCount, Colors.orange),
              _buildSummaryItem('Drowsy', drowsyCount, AppTheme.warningNeon),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(DrowsinessEvent event, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkCard, AppTheme.darkCard.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Color(event.severityColor).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(event.severityColor).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.paddingLarge),
        leading: Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          decoration: BoxDecoration(
            color: Color(event.severityColor).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getEventIcon(event.detectionType),
            color: Color(event.severityColor),
            size: AppConstants.largeIconSize,
          ),
        ),
        title: Text(
          event.detectionTypeDescription,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  event.formattedTimestamp,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Color(event.severityColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.drowsinessLevelDescription.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  '${(event.confidenceScore * 100).toStringAsFixed(1)}% confidence',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            if (event.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: event.emergencyTriggered
            ? Icon(
                Icons.emergency,
                color: AppTheme.dangerNeon,
                size: AppConstants.iconSize,
              )
            : null,
        onTap: () => _showEventDetails(event),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ).animate().fadeIn(duration: 800.ms),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              _hasActiveFilters ? 'No events match your filters' : 'No drowsiness events recorded',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              _hasActiveFilters 
                  ? 'Try adjusting your filter criteria'
                  : 'Start monitoring to see detection events here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: AppConstants.paddingXLarge),
              NeonButton(
                text: 'Clear Filters',
                onPressed: _clearFilters,
                icon: Icons.clear,
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(DetectionType type) {
    switch (type) {
      case DetectionType.eyesClosed:
        return Icons.remove_red_eye;
      case DetectionType.yawning:
        return Icons.sentiment_very_dissatisfied;
      case DetectionType.headNodding:
        return Icons.swap_vert;
      case DetectionType.faceNotDetected:
        return Icons.face_retouching_off;
    }
  }

  bool get _hasActiveFilters {
    return _filterType != 'all' || 
           _filterStartDate != null || 
           _filterEndDate != null;
  }

  void _clearFilters() {
    setState(() {
      _filterType = 'all';
      _filterStartDate = null;
      _filterEndDate = null;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Filter Events', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _filterType,
              decoration: const InputDecoration(
                labelText: 'Event Type',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              dropdownColor: AppTheme.darkCard,
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Events')),
                DropdownMenuItem(value: 'critical', child: Text('Critical')),
                DropdownMenuItem(value: 'alert', child: Text('Alert')),
                DropdownMenuItem(value: 'drowsy', child: Text('Drowsy')),
              ],
              onChanged: (value) => setState(() => _filterType = value ?? 'all'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          NeonButton(
            text: 'Apply',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Options', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.dangerNeon),
              title: const Text('Clear All Logs', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showClearLogsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: AppTheme.primaryNeon),
              title: const Text('Refresh', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _loadEvents();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Clear All Logs', style: TextStyle(color: AppTheme.dangerNeon)),
        content: const Text(
          'Are you sure you want to delete all event logs? This action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          NeonButton(
            text: 'Delete All',
            gradient: const LinearGradient(
              colors: [AppTheme.dangerNeon, Colors.red],
            ),
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService.clearAllDrowsinessEvents();
              _loadEvents();
            },
          ),
        ],
      ),
    );
  }

  void _showEventDetails(DrowsinessEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Text(
          'Event Details',
          style: TextStyle(color: Color(event.severityColor)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${event.detectionTypeDescription}', style: const TextStyle(color: Colors.white)),
            Text('Level: ${event.drowsinessLevelDescription}', style: const TextStyle(color: Colors.white)),
            Text('Confidence: ${(event.confidenceScore * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white)),
            Text('Time: ${event.formattedTimestamp}', style: const TextStyle(color: Colors.white)),
            if (event.location != null)
              Text('Location: ${event.location}', style: const TextStyle(color: Colors.white)),
            if (event.emergencyTriggered)
              const Text('⚠️ Emergency was triggered', style: TextStyle(color: AppTheme.dangerNeon)),
          ],
        ),
        actions: [
          NeonButton(
            text: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}