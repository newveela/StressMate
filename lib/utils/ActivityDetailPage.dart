import 'package:flutter/material.dart';

class ActivityDetailPage extends StatelessWidget {
  final String activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    String details = _getActivityDetails(activity);
    List<String>? steps = _getActivitySteps(activity);

    return Scaffold(
      appBar: AppBar(
        title: Text(activity),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying the logo image at the top
            Image.asset(
              'assets/managestress.jpg', // Ensure this path matches your logo location
              height: 100,  // Set the height of the logo as needed
              width: double.infinity, // Ensure it stretches across the screen
              fit: BoxFit.fitHeight, // Adjust the fit to contain the image
            ),
            const SizedBox(height: 16), // Spacer after logo
            Text(
              activity,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              details,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (steps != null)
              Expanded(
                child: ListView.builder(
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(steps[index]),
                    );
                  },
                ),
              )
            else
              const Center(
                child: Text(
                  'Coming Soon...',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Returns activity-specific details.
  String _getActivityDetails(String activity) {
    switch (activity) {
      case "Deep Breathing Exercise":
        return "Deep breathing exercises help calm your mind and reduce stress.";
      case "Meditation":
        return "Meditation helps focus your mind and reduce stress.";
      case "Progressive Muscle Relaxation":
        return "This technique helps reduce muscle tension and promote relaxation.";
      case "Guided Imagery":
        return "Guided imagery involves visualizing peaceful scenes to reduce stress.";
      case "Yoga":
        return "Yoga combines physical postures, breathing exercises, and meditation to promote relaxation.";
      case "Listening to Calming Music":
        return "Listening to calming music can help reduce stress and improve mood.";
      case "Taking a Walk":
        return "Taking a walk can clear your mind and boost your mood.";
      case "Journaling":
        return "Journaling helps organize your thoughts and manage emotions.";
      default:
        return "More details will be added soon.";
    }
  }

  /// Returns step-by-step instructions for the activity.
  List<String>? _getActivitySteps(String activity) {
    switch (activity) {
      case "Deep Breathing Exercise":
        return [
          "Inhale deeply through your nose for 4 seconds.",
          "Hold your breath for 7 seconds.",
          "Exhale slowly through your mouth for 8 seconds.",
          "Repeat this cycle 4-5 times.",
        ];
      case "Meditation":
        return [
          "Find a quiet place where you won't be disturbed.",
          "Sit in a comfortable position with your back straight.",
          "Close your eyes and take a few deep breaths.",
          "Focus on your breath as it flows in and out.",
          "If your mind wanders, gently bring your focus back to your breath.",
        ];
      case "Progressive Muscle Relaxation":
        return [
          "Find a quiet place and sit or lie down comfortably.",
          "Start with your feet, tensing the muscles for 5 seconds, then releasing.",
          "Move up your body, tensing and releasing each muscle group.",
          "Focus on the sensation of relaxation in each area.",
          "End with a few deep breaths to relax completely.",
        ];
      case "Guided Imagery":
        return [
          "Find a quiet, comfortable place to sit or lie down.",
          "Close your eyes and take a few deep breaths.",
          "Visualize a peaceful scene, like a beach or forest.",
          "Focus on the details—sounds, smells, and textures.",
          "Stay in the scene for a few minutes, then slowly return to the present.",
        ];
      case "Yoga":
        return [
          "Begin in a comfortable seated position.",
          "Take a few deep breaths to center yourself.",
          "Move into a simple stretch like Cat-Cow to warm up.",
          "Flow through basic poses such as Downward Dog, Warrior I, and Child’s Pose.",
          "End with a relaxing pose, like Savasana, for a few minutes.",
        ];
      case "Listening to Calming Music":
        return [
          "Choose a playlist or album of calming music.",
          "Find a comfortable place to sit or lie down.",
          "Close your eyes and take a few deep breaths.",
          "Focus on the music and let go of any stressful thoughts.",
          "Allow yourself to relax for 10-15 minutes or longer.",
        ];
      case "Taking a Walk":
        return [
          "Put on comfortable shoes and step outside.",
          "Choose a safe and peaceful path to walk.",
          "Walk at a steady pace, focusing on your surroundings.",
          "Breathe deeply and clear your mind as you walk.",
          "Walk for at least 10-20 minutes to refresh yourself.",
        ];
      case "Journaling":
        return [
          "Find a quiet place with minimal distractions.",
          "Open a journal or notebook, or use a digital app.",
          "Write down your thoughts, feelings, or a summary of your day.",
          "Focus on expressing yourself without judgment.",
          "Spend 10-15 minutes journaling to clear your mind.",
        ];
      default:
        return null; // Indicates that instructions are "Coming Soon".
    }
  }
}
