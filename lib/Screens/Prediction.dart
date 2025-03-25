import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';

class Prediction extends StatefulWidget {
  const Prediction({Key? key}) : super(key: key);

  @override
  State<Prediction> createState() => _PredictionState();
}

class _PredictionState extends State<Prediction> {
  TextEditingController temperature = TextEditingController();
  TextEditingController stepCnt = TextEditingController();
  int? z;

  Future<int> MLdata(double temp, int steps) async {
    final response = await http.post(
      Uri.parse('https://stressmate.onrender.com/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode([
        {"C": temp, "Step count": steps}
      ]),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['prediction'][0];
    } else {
      throw Exception('Failed to fetch ML Data.');
    }
  }

  Future<Map<String, dynamic>> fetchHealthData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in.");
    }

    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final snapshot = await FirebaseFirestore.instance
        .collection("StressData")
        .doc(user.email)
        .collection("Dates")
        .doc(date)
        .get();

    if (!snapshot.exists) {
      throw Exception("Health data not available for today.");
    }

    return snapshot.data()!;
  }

  bool isLoading = true;
  String errorMessage = '';
  int steps = 0;
  double temp = 0.0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await fetchHealthData();
      setState(() {
        steps = data['steps'] ?? 0;
        temp = data['bodyTemperature'] ?? 0.0;
        temperature.text = temp.toString();
        stepCnt.text = steps.toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Smart Stress Prediction'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent.withOpacity(0.8),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Smart Stress Prediction'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent.withOpacity(0.8),
        ),
        body: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Smart Stress Prediction'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTextField("Temperature (°C)", temperature),
              buildTextField("Step Count (Today)", stepCnt), // Updated label
              const SizedBox(height: 20),
              Container(
                height: 250,
                child: z != null
                    ? CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 13.0,
                  animation: true,
                  animationDuration: 600,
                  percent: z == 0
                      ? 0.3
                      : z == 1
                      ? 0.6
                      : 0.9,
                  center: z == 0
                      ? const Text('Low Stress')
                      : z == 1
                      ? const Text('Normal Stress')
                      : const Text('High Stress'),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: z == 0
                      ? Colors.green
                      : z == 1
                      ? Colors.orange
                      : Colors.red,
                )
                    : Container(
                  height: 250,
                  padding: const EdgeInsets.all(20),
                  child: const Image(
                    image: AssetImage('assets/boypic.jpg'),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                    width / 15, height / 20, width / 15, height / 20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.8),
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: MaterialButton(
                    elevation: 10.00,
                    minWidth: width / 1.2,
                    height: height / 11.5,
                    onPressed: () async {
                      try {
                        int x = await MLdata(
                          (temp * 9 / 5 + 32), // Convert Celsius to Fahrenheit
                          steps,
                        );
                        setState(() {
                          z = x;
                        });
                      } catch (e) {
                        setState(() {
                          errorMessage = "Failed to predict stress.";
                        });
                      }
                    },
                    child: const Text(
                      'Predict',
                      style: TextStyle(color: Colors.white, fontSize: 20.00),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
