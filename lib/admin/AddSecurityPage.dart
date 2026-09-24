import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSecurityPage extends StatefulWidget {
  @override
  _AddSecurityPageState createState() => _AddSecurityPageState();
}

class _AddSecurityPageState extends State<AddSecurityPage> {
  final _formKey = GlobalKey<FormState>();

  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String gender = 'Male';
  String phone = '';
  String role = 'security';
  DateTime? birthday;

  Future<void> registerSecurity() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('security')
          .doc(credential.user!.uid)
          .set({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phone,
        'gender': gender,
        'birthday': birthday?.toIso8601String(),
        'role': role,
        'uid': credential.user!.uid,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Security"),
        backgroundColor: const Color(0xFFF2F2F2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(
                  label: "First Name", onChanged: (v) => firstName = v),
              buildTextField(
                  label: "Last Name", onChanged: (v) => lastName = v),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Birthday: ${birthday != null ? birthday!.toLocal().toString().split(' ')[0] : 'Select'}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => birthday = picked);
                },
              ),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => gender = val ?? 'Male'),
              ),
              SizedBox(height: 12),
              buildTextField(
                label: "Phone Number",
                keyboardType: TextInputType.phone,
                onChanged: (v) => phone = v,
              ),
              buildTextField(
                label: "Email",
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => email = v,
              ),
              buildTextField(
                label: "Password",
                obscureText: true,
                onChanged: (v) => password = v,
              ),
              buildTextField(
                label: "Role",
                initialValue: role,
                enabled: false,
                onChanged: (_) {},
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registerSecurity();
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    String? initialValue,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
        onChanged: onChanged,
      ),
    );
  }
}