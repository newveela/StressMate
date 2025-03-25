import 'package:flutter/material.dart';

class Instruction extends StatefulWidget {
  const Instruction({Key? key}) : super(key: key);

  @override
  State<Instruction> createState() => _InstructionState();
}

class _InstructionState extends State<Instruction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Follow these steps to connect your wearable device to Google Fit:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              const InstructionStep(
                stepNumber: 1,
                text:
                'Ensure that your wearable device is compatible with Google Fit. Check the list of supported devices on the Google Fit website.',
              ),
              const InstructionStep(
                stepNumber: 2,
                text:
                'Install the Google Fit app on your phone from the Google Play Store.',
              ),
              const InstructionStep(
                stepNumber: 3,
                text:
                'Turn on Bluetooth on both your phone and the wearable device.',
              ),
              const InstructionStep(
                stepNumber: 4,
                text:
                'Open the Google Fit app on your phone and tap the profile icon in the top right corner.',
              ),
              const InstructionStep(
                stepNumber: 5,
                text: 'Tap "Settings" and then tap "Connected devices".',
              ),
              const InstructionStep(
                stepNumber: 6,
                text:
                'Tap "Add a device" and select your wearable device from the list of available devices.',
              ),
              const InstructionStep(
                stepNumber: 7,
                text:
                'Select the data source for the heart rate by choosing the connected device name.',
              ),
              const SizedBox(height: 20),
              const Text(
                'Once paired, your device will automatically sync with Google Fit whenever it is in range and Bluetooth is enabled.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Note:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const Text(
                'The specific steps may vary slightly depending on the type of wearable device you are using.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstructionStep extends StatelessWidget {
  final int stepNumber;
  final String text;

  const InstructionStep({Key? key, required this.stepNumber, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber. ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
