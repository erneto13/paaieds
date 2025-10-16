import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const TestScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final questions = List<Map<String, dynamic>>.from(data["questions"]);

    return Scaffold(
      appBar: AppBar(
        title: Text("Test: ${data["topic"]}", style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index + 1}. ${q["question"]}",
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List<String>.from(q["options"]).map(
                    (opt) => ListTile(
                      title: Text(opt, style: GoogleFonts.montserrat()),
                      leading: const Icon(
                        Icons.circle_outlined,
                        color: Colors.blueAccent,
                      ),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
