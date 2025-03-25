import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;

class QuizPage extends StatefulWidget {
  const QuizPage(this.questions, this.index, this.disorder, this.colors, {super.key});
  final List<String> questions;
  final String disorder;
  final int index;
  final List<Color> colors;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Question(
          questions: widget.questions,
          questionIndex: widget.index,
          disorder: widget.disorder,
          colors: widget.colors,
        ),
      ),
    );
  }
}

class Question extends StatefulWidget {
  const Question({
    required this.questions,
    required this.questionIndex,
    required this.disorder,
    required this.colors,
    super.key,
  });

  final List<String> questions;
  final int questionIndex;
  final String disorder;
  final List<Color> colors;

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  int answerIndex = 0;
  bool isComplete = false;

  Future<void> sendEmail(String subject, String body, String recipient) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    const serviceId = 'service_x1l5vki';
    const templateId = 'template_bqeo4sk';
    const userId = 'BOaJnD9tU3utMPNW2';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'subject': subject,
            'body': body,
            'recipient': recipient,
          },
        }),
      );
      if (response.statusCode == 200) {
        print("Email sent successfully");
      } else {
        print("Failed to send email");
      }
    } catch (e) {
      print("Error sending email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 5.0,
          percent: (answerIndex + 1) / widget.questions.length,
          center: Text("${answerIndex + 1}/${widget.questions.length}"),
          progressColor: widget.colors[answerIndex % widget.colors.length],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.questions[answerIndex],
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
          onPressed: isComplete ? null : () => setState(() => answerIndex++),
          child: Text(isComplete ? "Quiz Complete" : "Next Question"),
        ),
      ],
    );
  }
}
