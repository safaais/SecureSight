import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddSecurityPage.dart';
import 'SecurityDetailsPage.dart';

class SecurityListPage extends StatefulWidget {
  @override
  _SecurityListPageState createState() => _SecurityListPageState();
}

class _SecurityListPageState extends State<SecurityListPage> {
  List<Map<String, dynamic>> securityUsers = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSecurityUsers();
  }

  Future<void> fetchSecurityUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('security')
          .where('role', isEqualTo: 'security')
          .get();

      setState(() {
        securityUsers = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = securityUsers.where((user) {
      final name = '${user['first_name']} ${user['last_name']}'.toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Security"),
        backgroundColor: const Color(0xFFF2F2F2),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Container(
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
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search by name...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.mic, color: Colors.black54),
                ],
              ),
            ),
          ),

          // List of security users
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No security personnel found.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final user = filtered[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.account_circle, size: 36),
                          title: Text(
                            '${user['first_name']} ${user['last_name']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SecurityDetailsPage(user: user),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),

          // "New Account" button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddSecurityPage()),
                );
                fetchSecurityUsers(); // Refresh list
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'New Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}