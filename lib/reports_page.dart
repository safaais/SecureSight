import 'package:flutter/material.dart';

class Report {
  String place;
  String date;
  String time;
  String? description;

  Report({
    required this.place,
    required this.date,
    required this.time,
    this.description,
  });
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final List<Report> _allReports = [
    Report(place: 'Area-1', date: '8th July, 2024', time: '2:35'),
    Report(
      place: 'GYM Girls-1',
      date: '2nd July, 2024',
      time: '12:48',
      description:
          '''An incident occurred at the girls' club where some students displayed aggressive behavior toward each other. 
They exchanged harsh words, but the situation did not escalate into a physical altercation. 
Club staff intervened quickly to de-escalate the situation. No injuries were reported, and the involved students have been referred for counseling and disciplinary review to prevent future incidents.''',
    ),
  ];

  List<Report> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _filteredReports = _allReports;
  }

  void _filterReports(String query) {
    setState(() {
      _filteredReports = _allReports
          .where((report) =>
              report.place.toLowerCase().contains(query.toLowerCase()) ||
              report.date.toLowerCase().contains(query.toLowerCase()) ||
              report.time.toLowerCase().contains(query.toLowerCase()) ||
              (report.description != null &&
                  report.description!
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterReports,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
                suffixIcon: const Icon(Icons.mic, color: Color(0xFF9E9E9E)),
                filled: true,
                fillColor: const Color(0xFFE0E0E0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredReports.length,
              itemBuilder: (context, index) {
                final report = _filteredReports[index];
                final isFilled = report.description != null;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlertPage(report: report),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isFilled ? Colors.amber : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warning, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.date,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              report.place,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class AlertPage extends StatefulWidget {
  final Report report;
  const AlertPage({super.key, required this.report});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  late TextEditingController placeController;
  late TextEditingController dayController;
  late TextEditingController timeController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    placeController = TextEditingController(text: widget.report.place);
    dayController = TextEditingController(text: widget.report.date);
    timeController = TextEditingController(text: widget.report.time);
    descController =
        TextEditingController(text: widget.report.description ?? '');
  }

  @override
  void dispose() {
    placeController.dispose();
    dayController.dispose();
    timeController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSaved = widget.report.description != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: placeController,
              decoration: const InputDecoration(labelText: 'Place'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dayController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Write what happened',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaved ||
                      placeController.text.isEmpty ||
                      dayController.text.isEmpty ||
                      timeController.text.isEmpty
                  ? null
                  : () {
                      setState(() {
                        widget.report.place = placeController.text;
                        widget.report.date = dayController.text;
                        widget.report.time = timeController.text;
                        widget.report.description = descController.text;
                      });
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaved ||
                        placeController.text.isEmpty ||
                        dayController.text.isEmpty ||
                        timeController.text.isEmpty
                    ? Colors.grey
                    : Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}