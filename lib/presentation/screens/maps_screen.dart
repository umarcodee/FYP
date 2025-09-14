import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/location_provider.dart';
import '../widgets/neon_button.dart';
import '../widgets/place_card.dart';

/// Maps screen for finding nearby places (rest stops, gas stations, etc.)
class MapsScreen extends StatefulWidget {
  final String searchType;

  const MapsScreen({
    super.key,
    this.searchType = 'rest_stops',
  });

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  PlaceSearchType _currentSearchType = PlaceSearchType.restStops;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Set initial search type based on parameter
    _currentSearchType = _getSearchTypeFromString(widget.searchType);
    _tabController.index = _getTabIndexFromSearchType(_currentSearchType);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      if (!locationProvider.isLocationAvailable) {
        locationProvider.getCurrentLocation().then((_) {
          if (locationProvider.isLocationAvailable) {
            locationProvider.searchNearbyPlaces(_currentSearchType);
          }
        });
      } else {
        locationProvider.searchNearbyPlaces(_currentSearchType);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  PlaceSearchType _getSearchTypeFromString(String type) {
    switch (type) {
      case 'petrol_pumps': return PlaceSearchType.petrolPumps;
      case 'hospitals': return PlaceSearchType.hospitals;
      case 'restaurants': return PlaceSearchType.restaurants;
      case 'hotels': return PlaceSearchType.hotels;
      default: return PlaceSearchType.restStops;
    }
  }

  int _getTabIndexFromSearchType(PlaceSearchType type) {
    switch (type) {
      case PlaceSearchType.restStops: return 0;
      case PlaceSearchType.petrolPumps: return 1;
      case PlaceSearchType.hospitals: return 2;
      case PlaceSearchType.restaurants: return 3;
      case PlaceSearchType.hotels: return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Find Nearby Places',
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
          Consumer<LocationProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isLocationAvailable
                    ? () => provider.searchNearbyPlaces(_currentSearchType)
                    : null,
                icon: Icon(
                  Icons.refresh,
                  color: provider.isLocationAvailable ? Colors.white : Colors.white38,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryNeon,
          labelColor: AppTheme.primaryNeon,
          unselectedLabelColor: Colors.white60,
          onTap: (index) => _onTabChanged(index),
          tabs: const [
            Tab(text: 'Rest Stops', icon: Icon(Icons.hotel)),
            Tab(text: 'Gas Stations', icon: Icon(Icons.local_gas_station)),
            Tab(text: 'Hospitals', icon: Icon(Icons.local_hospital)),
            Tab(text: 'Restaurants', icon: Icon(Icons.restaurant)),
            Tab(text: 'Hotels', icon: Icon(Icons.hotel_outlined)),
          ],
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
        child: Consumer<LocationProvider>(
          builder: (context, provider, child) {
            if (!provider.isLocationAvailable) {
              return _buildLocationRequiredScreen(provider);
            }
            
            return Column(
              children: [
                _buildLocationHeader(provider),
                Expanded(child: _buildPlacesList(provider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationRequiredScreen(LocationProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: AppTheme.warningNeon,
            ).animate().shake(duration: 800.ms),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            Text(
              'Location Access Required',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.warningNeon,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Text(
              provider.locationError ?? 
              'To find nearby places, we need access to your location.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            NeonButton(
              text: provider.isLoadingLocation ? 'Getting Location...' : 'Enable Location',
              icon: provider.isLoadingLocation ? null : Icons.location_on,
              isLoading: provider.isLoadingLocation,
              onPressed: provider.isLoadingLocation 
                  ? null 
                  : () => provider.getCurrentLocation(),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            NeonOutlineButton(
              text: 'Go Back',
              color: Colors.grey,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader(LocationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryNeon.withOpacity(0.3),
            width: 1,
          ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      provider.formattedLocation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (provider.isLoadingLocation)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryNeon),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          Row(
            children: [
              Icon(
                Icons.search,
                color: AppTheme.primaryNeon,
                size: AppConstants.iconSize,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Searching for ${_getSearchTypeDisplayName(_currentSearchType)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryNeon,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1);
  }

  Widget _buildPlacesList(LocationProvider provider) {
    if (provider.isLoadingPlaces) {
      return _buildLoadingState();
    }
    
    if (provider.placesError != null) {
      return _buildErrorState(provider.placesError!);
    }
    
    if (provider.nearbyPlaces.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      itemCount: provider.nearbyPlaces.length,
      itemBuilder: (context, index) {
        final place = provider.nearbyPlaces[index];
        return PlaceCard(
          place: place,
          onTap: () => _onPlaceSelected(place),
        ).animate()
          .fadeIn(duration: 400.ms, delay: (index * 100).ms)
          .slideX(begin: 0.2, duration: 400.ms);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppTheme.primaryNeon,
              strokeWidth: 4,
            ),
          ).animate().scale(duration: 800.ms),
          
          const SizedBox(height: AppConstants.paddingXLarge),
          
          Text(
            'Searching nearby ${_getSearchTypeDisplayName(_currentSearchType)}...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryNeon,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          Text(
            'This may take a few moments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.dangerNeon,
            ).animate().shake(duration: 800.ms),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            Text(
              'Search Error',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.dangerNeon,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            NeonButton(
              text: 'Retry Search',
              icon: Icons.refresh,
              onPressed: () {
                final provider = Provider.of<LocationProvider>(context, listen: false);
                provider.searchNearbyPlaces(_currentSearchType);
              },
            ),
          ],
        ),
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
              Icons.location_searching,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ).animate().fadeIn(duration: 800.ms),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            Text(
              'No ${_getSearchTypeDisplayName(_currentSearchType)} Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Text(
              'Try expanding your search radius or check a different category.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            NeonButton(
              text: 'Search Again',
              icon: Icons.search,
              onPressed: () {
                final provider = Provider.of<LocationProvider>(context, listen: false);
                provider.searchNearbyPlaces(_currentSearchType);
              },
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  String _getSearchTypeDisplayName(PlaceSearchType type) {
    switch (type) {
      case PlaceSearchType.restStops:
        return 'rest stops';
      case PlaceSearchType.petrolPumps:
        return 'gas stations';
      case PlaceSearchType.hospitals:
        return 'hospitals';
      case PlaceSearchType.restaurants:
        return 'restaurants';
      case PlaceSearchType.hotels:
        return 'hotels';
    }
  }

  void _onTabChanged(int index) {
    PlaceSearchType newType;
    switch (index) {
      case 0: newType = PlaceSearchType.restStops; break;
      case 1: newType = PlaceSearchType.petrolPumps; break;
      case 2: newType = PlaceSearchType.hospitals; break;
      case 3: newType = PlaceSearchType.restaurants; break;
      case 4: newType = PlaceSearchType.hotels; break;
      default: newType = PlaceSearchType.restStops;
    }
    
    if (newType != _currentSearchType) {
      setState(() => _currentSearchType = newType);
      
      final provider = Provider.of<LocationProvider>(context, listen: false);
      if (provider.isLocationAvailable) {
        provider.searchNearbyPlaces(newType);
      }
    }
  }

  void _onPlaceSelected(place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadius + 4),
          ),
        ),
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  place.typeIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            NeonButton(
              text: 'Get Directions',
              icon: Icons.directions,
              onPressed: () {
                Navigator.pop(context);
                // TODO: Open directions in maps app
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening directions to ${place.name}'),
                    backgroundColor: AppTheme.primaryNeon,
                  ),
                );
              },
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            if (place.phoneNumber != null)
              NeonOutlineButton(
                text: 'Call',
                icon: Icons.phone,
                color: AppTheme.accentNeon,
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Make phone call
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${place.phoneNumber}'),
                      backgroundColor: AppTheme.accentNeon,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}