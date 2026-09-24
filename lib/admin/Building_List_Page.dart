import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:securesight/menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BuildingApp());
}

class BuildingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BuildingListPage(),
    );
  }
}

class BuildingListPage extends StatefulWidget {
  @override
  _BuildingListPageState createState() => _BuildingListPageState();
}

class _BuildingListPageState extends State<BuildingListPage> {
  List<String> buildings = [];
  Map<String, String?> selectedLocations = {};
  Map<String, String?> selectedSecurities = {};
  Map<String, String?> documentIds = {};
  Map<String, List<String>> buildingLocations = {};
  List<String> securityList = [];
  String searchQuery = "";
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _fetchBuildings();
    _fetchSecurityUsers();
  }

  Future<void> _fetchSecurityUsers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('security').get();
    final filtered =
        snapshot.docs.where((doc) => doc['role'] == 'security').toList();
    setState(() {
      securityList = filtered
          .map((doc) => '${doc['first_name']} ${doc['last_name']}')
          .toList();
    });
  }

  Future<void> _fetchBuildings() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('buildings').get();
    setState(() {
      buildings = snapshot.docs.map((doc) => doc['name'] as String).toList();
      documentIds = {
        for (var doc in snapshot.docs) doc['name']: doc.id,
      };
      buildingLocations = {
        for (var doc in snapshot.docs)
          doc['name']: List<String>.from(doc['locations'] ?? []),
      };

      for (var doc in snapshot.docs) {
        String bName = doc['name'];
        List<String> locs = List<String>.from(doc['locations'] ?? []);
        selectedLocations[bName] = locs.isNotEmpty ? locs.first : null;
        selectedSecurities[bName] = doc['security'];
      }

      buildings.sort();
    });
  }

  void _saveChanges() async {
    for (var building in buildings) {
      final id = documentIds[building];
      if (id != null) {
        await FirebaseFirestore.instance
            .collection('buildings')
            .doc(id)
            .update({
          'locations': selectedLocations[building] != null
              ? [selectedLocations[building]]
              : [],
          'security': selectedSecurities[building],
        });
      }
    }
    setState(() {
      hasChanges = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Changes saved")));
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredBuildings = buildings
        .where((building) =>
            building.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Buildings", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: filteredBuildings
                    .map((building) => _buildBuildingTile(building))
                    .toList(),
              ),
            ),
            if (hasChanges)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _saveChanges,
                child:
                    Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () async {
                final newBuilding = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBuildingPage()),
                );
                if (newBuilding != null) {
                  await _fetchBuildings();
                }
              },
              child:
                  Text("New Building", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingTile(String buildingName) {
    List<String> locationsForBuilding = buildingLocations[buildingName] ?? [];

    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(buildingName, style: TextStyle(color: Colors.black)),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final id = documentIds[buildingName];
              if (id != null) {
                await FirebaseFirestore.instance
                    .collection('buildings')
                    .doc(id)
                    .delete();
                setState(() {
                  buildings.remove(buildingName);
                  selectedLocations.remove(buildingName);
                  selectedSecurities.remove(buildingName);
                  documentIds.remove(buildingName);
                  buildingLocations.remove(buildingName);
                  hasChanges = false;
                });
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Building deleted")));
              }
            },
          ),
        ],
      ),
      children: [
        ListTile(
          title: Text("Location", style: TextStyle(color: Colors.black)),
          trailing: DropdownButton<String>(
            value: selectedLocations[buildingName],
            hint: Text("Select"),
            items: locationsForBuilding
                .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedLocations[buildingName] = value;
                hasChanges = true;
              });
            },
          ),
        ),
        ListTile(
          title: Text("Security", style: TextStyle(color: Colors.black)),
          trailing: DropdownButton<String>(
            value: selectedSecurities[buildingName],
            hint: Text("Select"),
            items: securityList
                .map((sec) => DropdownMenuItem(value: sec, child: Text(sec)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedSecurities[buildingName] = value;
                hasChanges = true;
              });
            },
          ),
        ),
      ],
    );
  }
}

class AddBuildingPage extends StatefulWidget {
  @override
  _AddBuildingPageState createState() => _AddBuildingPageState();
}

class _AddBuildingPageState extends State<AddBuildingPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController securityController = TextEditingController();
  List<TextEditingController> locationControllers = [TextEditingController()];

  void _addLocationField() {
    setState(() {
      locationControllers.add(TextEditingController());
    });
  }

  void _saveBuilding() async {
    if (nameController.text.isEmpty ||
        locationControllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Fill all fields")));
      return;
    }

    String name = nameController.text;
    List<String> locations =
        locationControllers.map((controller) => controller.text).toList();
    String? security =
        securityController.text.isNotEmpty ? securityController.text : null;

    await FirebaseFirestore.instance.collection('buildings').add({
      'name': name,
      'locations': locations,
      'security': security,
    });

    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Building"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Building name*"),
            ),
            Column(
              children: [
                ...locationControllers.map((controller) => TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: "Location*"),
                    )),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addLocationField,
                ),
              ],
            ),
            TextField(
              controller: securityController,
              decoration: InputDecoration(labelText: "Security"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: _saveBuilding,
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}