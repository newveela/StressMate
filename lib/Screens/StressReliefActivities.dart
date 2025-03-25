import 'package:flutter/material.dart';
import 'package:stressmate/utils/ActivityDetailPage.dart';

class StressReliefActivities extends StatelessWidget {
  const StressReliefActivities({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> activities = [
      "Deep Breathing Exercise",
      "Meditation",
      "Progressive Muscle Relaxation",
      "Guided Imagery",
      "Yoga",
      "Listening to Calming Music",
      "Taking a Walk",
      "Journaling",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress-Relief Activities'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250, // Adjust height for the top image
            width: double.infinity,
            child: Image.asset(
              'assets/managestress.jpg', // Replace with your image path
              fit: BoxFit.fitHeight, // Ensures the image fills the space
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(activities[index]),
                    leading: const Icon(Icons.self_improvement, color: Colors.blueAccent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailPage(activity: activities[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
