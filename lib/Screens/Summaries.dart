import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stressmate/Screens/StressReliefActivities.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  int _currentIndex = 0;
  final List<String> periods = ["Daily", "Weekly", "Monthly"];
  final PageController _pageController = PageController(initialPage: 0);
  double _averageScore = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Data Summary'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: periods.length,
              itemBuilder: (context, index) {
                return _buildSummary(context, periods[index]);
              },
            ),
          ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _pageController.animateToPage(index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.today),
                label: "Daily",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_view_week),
                label: "Weekly",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: "Monthly",
              ),
            ],
          ),
          if (_averageScore < 80)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StressReliefActivities()),
                  );
                },
                child: const Text(
                  'Explore Stress-Relief Activities',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          if (_averageScore < 80)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Maintain a healthy score above 80 to reduce stress!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, String period) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("User is not logged in."));
    }

    String email = user.email ?? 'unknown';
    DateTime now = DateTime.now();

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("StressData")
          .doc(email)
          .collection("Dates")
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No data available for the selected period."));
        }

        List<int> data = [];
        List<String> labels = [];
        double totalScore = 0.0;

        if (period == "Daily") {
          // Fetch all data for the current day
          String currentDate = now.toIso8601String().split('T').first;
          snapshot.data!.docs.forEach((doc) {
            if (doc.id == currentDate) {
              Map<String, dynamic> healthData = doc.data() as Map<String, dynamic>;
              totalScore = _calculateStressScore(healthData);
              data.add(totalScore.toInt());
              labels.add("Today");
            }
          });
        } else if (period == "Weekly") {
          DateTime startDate = now.subtract(const Duration(days: 7));
          snapshot.data!.docs.forEach((doc) {
            DateTime docDate = DateTime.parse(doc.id);
            if (docDate.isAfter(startDate) && docDate.isBefore(now)) {
              Map<String, dynamic> healthData = doc.data() as Map<String, dynamic>;
              double score = _calculateStressScore(healthData);
              data.add(score.toInt());
            }
          });
          labels = List.generate(data.length, (index) => "Day ${index + 1}");
        } else if (period == "Monthly") {
          DateTime startDate = now.subtract(const Duration(days: 30));
          Map<int, List<int>> weeklyData = {};
          snapshot.data!.docs.forEach((doc) {
            DateTime docDate = DateTime.parse(doc.id);
            if (docDate.isAfter(startDate) && docDate.isBefore(now)) {
              int weekOfMonth = (docDate.day - 1) ~/ 7;
              Map<String, dynamic> healthData = doc.data() as Map<String, dynamic>;
              double score = _calculateStressScore(healthData);
              weeklyData.putIfAbsent(weekOfMonth, () => []).add(score.toInt());
            }
          });
          data = weeklyData.values.map((scores) => scores.reduce((a, b) => a + b) ~/ scores.length).toList();
          labels = ["Week 1", "Week 2", "Week 3", "Week 4"];
        }

        // Ensure the average score is not above 100
        _averageScore = data.isNotEmpty ? (data.reduce((a, b) => a + b) / data.length).clamp(0.0, 100.0) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$period Summary',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (period == "Daily")
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(
                              value: totalScore,
                              color: _getBarColor(totalScore.toInt()),
                              title: '${totalScore.toStringAsFixed(1)}',
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            PieChartSectionData(
                              value: 100 - totalScore,
                              color: Colors.grey.shade300,
                              title: '',
                            ),
                          ],

                        ),
                      ),
                    ),
                  if (period != "Daily")
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),  // Hide left axis titles
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                    return Text(
                                      labels[value.toInt()],
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),  // Show border around the chart
                          gridData: FlGridData(show: false),  // Remove grid lines
                          barGroups: data
                              .asMap()
                              .map((index, value) {
                            return MapEntry(
                              index,
                              BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    fromY: 0,
                                    toY: value.toDouble(),
                                    width: 15,
                                    color: _getBarColor(value),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ],
                              ),
                            );
                          })
                              .values
                              .toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'Average Score: ${_averageScore.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateStressScore(Map<String, dynamic> healthData) {
    int steps = (healthData['steps'] ?? 0).toInt();
    int heartRate = (healthData['heartRate'] ?? 0).toInt();
    int bloodPressureSys = (healthData['bloodPressureSystolic'] ?? 0).toInt();
    int bloodPressureDia = (healthData['bloodPressureDiastolic'] ?? 0).toInt();
    double bloodOxygen = (healthData['bloodOxygen'] ?? 0).toDouble();
    double temperature = (healthData['temperature'] ?? 0).toDouble();

    // Updated formula with 10% and 18% contributions
    double score = (steps * 0.1) +
        (heartRate * 0.18) +
        (bloodPressureSys * 0.18) +
        (bloodPressureDia * 0.18) +
        (bloodOxygen * 0.18) +
        (temperature * 0.18);

    return score.clamp(0.0, 100.0); // Ensure the score is within 0-100
  }




  Color _getBarColor(int value) {
    if (value >= 90) {
      return Colors.green;
    } else if (value >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
