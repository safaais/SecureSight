import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String fullName = 'Unknown User';

  @override
  void initState() {
    super.initState();
    fetchUserFullNameByEmail();
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
        print('User found: $fullName');
      } else {
        setState(() {
          fullName = 'User data not found';
        });
        print('No user document found for email: $email');
      }
    } catch (e) {
      setState(() {
        fullName = 'Error loading name';
      });
      print('Error fetching user full name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF1881A),
              Color(0xFFF96358),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child:
                        Icon(Icons.person, size: 40, color: Color(0xFFF1881A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildMenuItem(context, Icons.person, 'profile'.tr(),
                routeName: '/profile'),
            _buildMenuItem(context, Icons.history, 'reports'.tr(),
                routeName: '/reports'),
            _buildMenuItem(context, Icons.settings, 'settings'.tr(),
                routeName: '/settings'),
            _buildMenuItem(context, Icons.logout, 'logout'.tr(),
                isLogout: true),
          ],
        ),
      ),
    );
  }

  static Widget _buildMenuItem(
      BuildContext context, IconData icon, String title,
      {String? routeName, bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);

        if (isLogout) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else if (routeName != null) {
          Navigator.pushNamed(context, routeName);
        }
      },
    );
  }
}