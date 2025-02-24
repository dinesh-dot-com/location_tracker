import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class LocationListView extends StatelessWidget {
  final ValueNotifier<List<String>> locationNotifier;

  const LocationListView({Key? key, required this.locationNotifier}) : super(key: key);

  static Future<void> clearLocationHistory(ValueNotifier<List<String>> notifier) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("locations");
    notifier.value = [];
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return ValueListenableBuilder<List<String>>(
      valueListenable: locationNotifier,
      builder: (context, locations, child) {
        return locations.isEmpty
            ? _buildEmptyState()
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: isTablet
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: locations.length,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemBuilder: (context, index) => LocationCard(
                          location: locations[index],
                          index: index,
                        ),
                      )
                    : ListView.builder(
                        itemCount: locations.length,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemBuilder: (context, index) => LocationCard(
                          location: locations[index],
                          index: index,
                        ),
                      ),
              );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.mapMarkedAlt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No Location Data",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start tracking to see your location history",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String location;
  final int index;

  const LocationCard({
    Key? key,
    required this.location,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String timestamp = "";
    String coordinates = location;
    
    if (location.contains("|")) {
      final parts = location.split("|");
      timestamp = parts[0].trim();
      coordinates = parts[1].trim();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getGradientColor(index),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  FontAwesomeIcons.mapPin,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (timestamp.isNotEmpty) ...[
                    Text(
                      timestamp,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    coordinates,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradientColor(int index) {
    final colors = [
      const Color(0xFF4CAF50),  
      const Color(0xFF2196F3),  
      const Color(0xFF9C27B0),  
      const Color(0xFFFF9800),  
      const Color(0xFF607D8B),  
    ];
    
    return colors[index % colors.length];
  }
}