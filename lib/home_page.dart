/* import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'footage_page.dart';
import 'alerts_page.dart';
import 'menu_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? fullName;
  String? _currentAlertStatus; // 'high', 'medium', or null
  String? _currentAlertAction; 

  final List<Widget> _pages = [
    HomeContent(),
    FootagePage(),
    AlertsPage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserFullNameByEmail();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _currentAlertStatus = message.data['risk_level'];
        _currentAlertAction = message.notification?.title; 
      });
    });
  }

  Future<void> fetchUserFullNameByEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          fullName = 'User not logged in';
        });
        return;
      }

      final email = user.email;
      if (email == null) {
        setState(() {
          fullName = 'Email not found';
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('security')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final firstName = data['first_name'] ?? '';
        final lastName = data['last_name'] ?? '';
        setState(() {
          fullName = '$firstName $lastName';
        });
      } else {
        setState(() {
          fullName = 'User data not found';
        });
      }
    } catch (e) {
      setState(() {
        fullName = 'Error loading name';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuPage(),
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: const Color(0xFFF2F2F2),
              foregroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        fullName ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color.fromARGB(255, 255, 255, 255),
        buttonBackgroundColor: Colors.orange,
        height: 60,
        items: <Widget>[
          Icon(Icons.home,
              size: 30,
              color: _selectedIndex == 0 ? Colors.white : Colors.black),
          Icon(Icons.videocam,
              size: 30,
              color: _selectedIndex == 1 ? Colors.white : Colors.black),
          Icon(Icons.warning,
              size: 30,
              color: _selectedIndex == 2 ? Colors.white : Colors.black),
        ],
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String locationText = 'Loading location...';

  @override
  void initState() {
    super.initState();
    fetchSecurityLocation();
  }

  Future<void> fetchSecurityLocation() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buildings')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final List<dynamic> locations = data['locations'] ?? [];
        final String security = data['security'] ?? 'Unknown';

        if (locations.isNotEmpty) {
          final String location = locations[0];
          setState(() {
            locationText = 'Your new location is at $location ';
          });
        } else {
          setState(() {
            locationText = 'Location is not available (Security: $security)';
          });
        }
      } else {
        setState(() {
          locationText = 'No building data found.';
        });
      }
    } catch (e) {
      setState(() {
        locationText = 'Error loading location.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomePageState>();
    final hasAlert = state?._currentAlertStatus != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: tr("search"),
                icon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: const Icon(Icons.mic, color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Alert box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications,
                  color: hasAlert
                      ? (state!._currentAlertStatus == 'high' 
                          ? Colors.red 
                          : Colors.orange)
                      : Colors.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(DateTime.now()),
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        hasAlert
                            ? state!._currentAlertStatus!.toUpperCase()
                            : tr("normal_status"),
                        style: TextStyle(
                          color: hasAlert
                              ? (state!._currentAlertStatus == 'high'
                                  ? Colors.red
                                  : Colors.orange)
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hasAlert
                            ? "${state!._currentAlertAction} detected"
                            : tr("status_description"),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Location info from Firestore
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    locationText,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cameras
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr("cameras"),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FootagePage()),
                  );
                },
                child: Text(tr("more"),
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCameraCard("Class 201-1"),
              _buildCameraCard("Class 202-1"),
              _buildCameraCard("Class 203-1"),
            ],
          ),
          const SizedBox(height: 20),

          // Reports
          Text(tr("reports"),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("8th July, 2024",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 12)),
                      Text(tr("report_reminder"),
                          style: const TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day}th ${monthNames[date.month - 1]}, ${date.year}";
  }

  Widget _buildCameraCard(String label) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.videocam, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
} */

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'footage_page.dart';
import 'alerts_page.dart';
import 'menu_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? fullName;
  String? _currentAlertStatus; // 'critical', 'high', 'medium', or null
  String? _currentAlertAction; 
  String locationText = 'Loading location...';
  String reportText = 'No recent reports.';

  final List<Widget> _pages = [
    HomeContent(),
    FootagePage(),
    AlertsPage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserFullNameByEmail();
    fetchSecurityLocation();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _currentAlertStatus = message.data['risk_level'];
        _currentAlertAction = message.notification?.title; 
        _updateReportText(); // Update report based on alert
      });
    });
  }

  Future<void> fetchUserFullNameByEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          fullName = 'User not logged in';
        });
        return;
      }

      final email = user.email;
      if (email == null) {
        setState(() {
          fullName = 'Email not found';
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('security')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final firstName = data['first_name'] ?? '';
        final lastName = data['last_name'] ?? '';
        setState(() {
          fullName = '$firstName $lastName';
        });
      } else {
        setState(() {
          fullName = 'User data not found';
        });
      }
    } catch (e) {
      setState(() {
        fullName = 'Error loading name';
      });
    }
  }

  Future<void> fetchSecurityLocation() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buildings')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final List<dynamic> locations = data['locations'] ?? [];
        final String security = data['security'] ?? 'Unknown';

        if (locations.isNotEmpty) {
          final String location = locations[0];
          setState(() {
            locationText = 'Your new location is at $location';
          });
        } else {
          setState(() {
            locationText = 'Location is not available (Security: $security)';
          });
        }
      } else {
        setState(() {
          locationText = 'No building data found.';
        });
      }
    } catch (e) {
      setState(() {
        locationText = 'Error loading location.';
      });
    }
  }

  void _updateReportText() {
    if (_currentAlertStatus == 'high' || _currentAlertStatus == 'critical') {
      setState(() {
        reportText = 'Recent alert: ${_currentAlertAction} detected!';
      });
    } else {
      setState(() {
        reportText = 'No recent reports.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuPage(),
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: const Color(0xFFF2F2F2),
              foregroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        fullName ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color.fromARGB(255, 255, 255, 255),
        buttonBackgroundColor: Colors.orange,
        height: 60,
        items: <Widget>[
          Icon(Icons.home,
              size: 30,
              color: _selectedIndex == 0 ? Colors.white : Colors.black),
          Icon(Icons.videocam,
              size: 30,
              color: _selectedIndex == 1 ? Colors.white : Colors.black),
          Icon(Icons.warning,
              size: 30,
              color: _selectedIndex == 2 ? Colors.white : Colors.black),
        ],
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomePageState>();
    final hasAlert = state?._currentAlertStatus != null;

    Color alertColor = Colors.green; // Default to normal
    if (hasAlert) {
      switch (state!._currentAlertStatus) {
        case 'high':
          alertColor = Colors.red; 
          break;
        case 'medium':
          alertColor = Colors.orange;
          break;
        default:
          alertColor = Colors.green; // Normal
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: tr("search"),
                icon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: const Icon(Icons.mic, color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Alert box with shadow
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: alertColor.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications,
                  color: alertColor, // Use dynamic alert color
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(DateTime.now()),
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        hasAlert
                            ? state!._currentAlertStatus!.toUpperCase()
                            : tr("normal_status"),
                        style: TextStyle(
                          color: alertColor, // Use dynamic alert color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hasAlert
                            ? "${state!._currentAlertAction} detected"
                            : tr("status_description"),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Location info from Firestore
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state?.locationText ?? 'No location data available.',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cameras Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr("cameras"),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FootagePage()),
                  );
                },
                child: Text(tr("more"),
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCameraCard("test area"),
            ],
          ),
          const SizedBox(height: 20),

          // Reports
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.report, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAlert && (state!._currentAlertStatus == 'high' || state._currentAlertStatus == 'critical')
                            ? state.reportText
                            : 'No recent reports.',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day}th ${monthNames[date.month - 1]}, ${date.year}";
  }

  Widget _buildCameraCard(String label) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.videocam, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}