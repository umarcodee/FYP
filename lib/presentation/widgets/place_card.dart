import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/nearby_place.dart';

/// Card widget for displaying nearby places
class PlaceCard extends StatelessWidget {
  final NearbyPlace place;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard,
            AppTheme.darkCard.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppTheme.primaryNeon.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNeon.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCategoryColor().withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        place.typeIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    
                    const SizedBox(width: AppConstants.paddingMedium),
                    
                    // Place info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Place name
                          Text(
                            place.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              place.category.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: place.isOpen 
                            ? AppTheme.accentNeon.withOpacity(0.2)
                            : AppTheme.dangerNeon.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: place.isOpen ? AppTheme.accentNeon : AppTheme.dangerNeon,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        place.openingStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: place.isOpen ? AppTheme.accentNeon : AppTheme.dangerNeon,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: Text(
                        place.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingSmall),
                
                // Distance and rating row
                Row(
                  children: [
                    // Distance
                    Row(
                      children: [
                        Icon(
                          Icons.navigation,
                          color: AppTheme.primaryNeon,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.formattedDistance,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryNeon,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: AppConstants.paddingLarge),
                    
                    // Rating (if available)
                    if (place.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.warningNeon,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.formattedRating,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    
                    const Spacer(),
                    
                    // Action indicator
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                  ],
                ),
                
                // Additional info (if available)
                if (place.phoneNumber != null || place.priceLevel != null) ...[
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  Wrap(
                    spacing: AppConstants.paddingMedium,
                    runSpacing: AppConstants.paddingSmall,
                    children: [
                      if (place.phoneNumber != null)
                        _buildInfoChip(
                          icon: Icons.phone,
                          label: 'Call',
                          color: AppTheme.accentNeon,
                        ),
                      
                      if (place.priceLevel != null)
                        _buildInfoChip(
                          icon: Icons.attach_money,
                          label: place.priceLevelDescription,
                          color: AppTheme.warningNeon,
                        ),
                      
                      _buildInfoChip(
                        icon: Icons.directions,
                        label: 'Directions',
                        color: AppTheme.primaryNeon,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    if (place.types.contains('gas_station')) return AppTheme.warningNeon;
    if (place.types.contains('hospital')) return AppTheme.dangerNeon;
    if (place.types.contains('rest_area')) return AppTheme.accentNeon;
    if (place.types.contains('restaurant')) return Colors.orange;
    if (place.types.contains('lodging')) return Colors.purple;
    return AppTheme.primaryNeon;
  }
}

/// Compact place card for list views
class CompactPlaceCard extends StatelessWidget {
  final NearbyPlace place;
  final VoidCallback? onTap;

  const CompactPlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryNeon.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            place.typeIcon,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(
          place.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.address,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  place.formattedDistance,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryNeon,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (place.rating != null) ...[
                  const Text(' • ', style: TextStyle(color: Colors.white60)),
                  Icon(
                    Icons.star,
                    color: AppTheme.warningNeon,
                    size: 12,
                  ),
                  Text(
                    ' ${place.rating!.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: place.isOpen 
                ? AppTheme.accentNeon.withOpacity(0.2)
                : AppTheme.dangerNeon.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            place.openingStatus,
            style: TextStyle(
              color: place.isOpen ? AppTheme.accentNeon : AppTheme.dangerNeon,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getCategoryColor() {
    if (place.types.contains('gas_station')) return AppTheme.warningNeon;
    if (place.types.contains('hospital')) return AppTheme.dangerNeon;
    if (place.types.contains('rest_area')) return AppTheme.accentNeon;
    if (place.types.contains('restaurant')) return Colors.orange;
    if (place.types.contains('lodging')) return Colors.purple;
    return AppTheme.primaryNeon;
  }
}