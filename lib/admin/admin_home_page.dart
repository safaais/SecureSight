import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:securesight/menu_page.dart';
import 'package:securesight/settings/recorded_footage_page.dart';
import 'package:securesight/admin/AddSecurityPage.dart';
import 'building_list_page.dart';
import 'security_list_page.dart';
import 'SecurityDetailsPage.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  String fullName = "";

  final List<Widget> _pages = [
    const AdminDashboardContent(),
    BuildingListPage(),
    RecordedFootagePage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchAdminFullName();
  }

  Future<void> fetchAdminFullName() async {
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
          fullName = 'Admin data not found';
        });
      }
    } catch (e) {
      setState(() {
        fullName = 'Error loading name';
      });
      print('Error fetching admin full name: $e');
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
                        fullName.isNotEmpty ? fullName : tr("user_name"),
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
        color: Colors.white,
        buttonBackgroundColor: Colors.orange,
        height: 60,
        items: <Widget>[
          Icon(Icons.home,
              size: 30,
              color: _selectedIndex == 0 ? Colors.white : Colors.black),
          Icon(Icons.apartment,
              size: 30,
              color: _selectedIndex == 1 ? Colors.white : Colors.black),
          Icon(Icons.video_library,
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

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: tr("search"),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Icons.mic, color: Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr("security"),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecurityListPage()),
                  );
                },
                child: Text(
                  tr("more"),
                  style: const TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 120,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('security')
                  .where('role', isEqualTo: 'security')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No security personnel found'));
                }

                final securityUsers = snapshot.data!.docs;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: securityUsers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == securityUsers.length) {
                      return const _AddSecurityCardRounded();
                    }

                    final doc = securityUsers[index];
                    final userData = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    final firstName = userData['first_name'] ?? '';
                    final lastName = userData['last_name'] ?? '';
                    final name = '$firstName $lastName';

                    if (firstName.isEmpty && lastName.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SecurityDetailsPage(
                              user: userData,
                              docId: docId,
                            ),
                          ),
                        );
                      },
                      child: _SecurityCardRounded(name: name),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Reports
          Text(tr("reports"),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("There is no report",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SecurityCardRounded extends StatelessWidget {
  final String name;
  const _SecurityCardRounded({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSecurityCardRounded extends StatelessWidget {
  const _AddSecurityCardRounded();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddSecurityPage()), // هنا التعديل
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}