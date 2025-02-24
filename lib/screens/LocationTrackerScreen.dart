import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'LocationListView.dart';

class LocationTrackerScreen extends StatefulWidget {
  const LocationTrackerScreen({Key? key}) : super(key: key);

  @override
  _LocationTrackerScreenState createState() => _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends State<LocationTrackerScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  final ValueNotifier<List<String>> _locationNotifier = ValueNotifier([]);
  bool _isTrackingActive = false;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  void _loadSavedLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _locationNotifier.value = prefs.getStringList("locations") ?? [];
  }

  void requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _showCustomToast("Location permission granted", Colors.green);
    } else {
      _showCustomToast("Location permission denied", Colors.red);
    }
  }

  void requestNotificationPermission() async {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      _showCustomToast("Notification permission granted", Colors.green);
    } else {
      _showCustomToast("Notification permission denied", Colors.red);
    }
  }

  void _showCustomToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }

  void startLocationUpdates() async {
    if (_timer != null) {
      _showCustomToast("Location updates already running", Colors.amber);
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showCustomToast("Location services are disabled", Colors.red);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showCustomToast("Location permission denied", Colors.red);
        return;
      }
    }

    setState(() {
      _isTrackingActive = true;
      _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        Position position = await Geolocator.getCurrentPosition();
        _showCustomToast("Location updated", Colors.green);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> locations = prefs.getStringList("locations") ?? [];

        // Format with timestamp
        String timestamp = DateFormat('MM/dd HH:mm:ss').format(DateTime.now());
        String newLocation = "$timestamp | Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
        locations.insert(0, newLocation);
        await prefs.setStringList("locations", locations);

        // Update notifier
        _locationNotifier.value = List.from(locations);
      });
    });
  }

  void stopLocationUpdates() async {
    bool confirmStop = await _showConfirmationDialog();
    if (!confirmStop) return;

    if (_timer != null) {
      _timer?.cancel();
      setState(() {
        _timer = null;
        _isTrackingActive = false;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("locations");

    _showCustomToast("Location updates stopped and history cleared", Colors.blue);

    // Notify UI to refresh
    _locationNotifier.value = [];
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  SizedBox(width: 10),
                  Text("Stop Tracking?"),
                ],
              ),
              content: const Text("Are you sure you want to stop location updates and clear history?"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Stop"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Location Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("About Location Tracker"),
                  content: const Text("This app tracks your location at regular intervals and saves the history."),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                if (_isTrackingActive)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.greenAccent,
                                    Colors.green,
                                  ],
                                  center: Alignment.center,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.6),
                                    blurRadius: (_animationController.value * 20),
                                    spreadRadius: (_animationController.value * 10),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 36,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.location_off,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  _isTrackingActive ? "Tracking Active" : "Tracking Inactive",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (_isTrackingActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Updating every 30 seconds",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
            child: isTablet
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildButtons(),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildButtons()[0]),
                          const SizedBox(width: 8),
                          Expanded(child: _buildButtons()[1]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildButtons()[2]),
                          const SizedBox(width: 8),
                          Expanded(child: _buildButtons()[3]),
                        ],
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Location History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                ValueListenableBuilder<List<String>>(
                  valueListenable: _locationNotifier,
                  builder: (context, locations, _) {
                    return Text(
                      "${locations.length} entries",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: LocationListView(locationNotifier: _locationNotifier),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildButtons() {
    return [
      CustomButton(
        icon: FontAwesomeIcons.mapMarkerAlt,
        text: "Location Access",
        color: const Color(0xFF2196F3),
        onPressed: requestLocationPermission,
      ),
      CustomButton(
        icon: FontAwesomeIcons.bell,
        text: "Notifications",
        color: const Color(0xFFFFA000),
        onPressed: requestNotificationPermission,
      ),
      CustomButton(
        icon: FontAwesomeIcons.play,
        text: "Start Tracking",
        color: const Color(0xFF4CAF50),
        onPressed: startLocationUpdates,
        disabled: _isTrackingActive,
      ),
      CustomButton(
        icon: FontAwesomeIcons.stop,
        text: "Stop Tracking",
        color: const Color(0xFFF44336),
        onPressed: stopLocationUpdates,
        disabled: !_isTrackingActive,
      ),
    ];
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final bool disabled;

  const CustomButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? Colors.grey[300] : color,
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.grey[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: disabled ? 0 : 3,
        shadowColor: disabled ? Colors.transparent : color.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      onPressed: disabled ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 20),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}