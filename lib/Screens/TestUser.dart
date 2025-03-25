import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:stressmate/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import 'Instruction.dart';


const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high importance channel', 'High Importance Notifications',
    description: 'This Channel is used for important notifications',
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class TestUserData extends StatefulWidget {
  const TestUserData({Key? key}) : super(key: key);

  @override
  State<TestUserData> createState() => _TestUserDataState();
}
final List<String> funFacts = [
  "Eating a variety of colorful fruits and vegetables can provide nutrients that help your body combat stress.",
  "Regular exercise releases endorphins, which improve your mood and help reduce stress levels.",
  "Staying hydrated can improve focus and reduce feelings of fatigue and stress.",
  "Incorporating strength training into your routine can boost self-confidence and reduce stress through physical activity.",
  "Practicing mindful eating can help you stay present, enjoy your meals, and reduce stress-related overeating.",
];


bool run = true;
int? _steps = 0;
int? stepx = 0;
String? _heart_rate;
HealthValue? _bp_d;
HealthValue? _bp_s;
HealthValue? _oxygen;
HealthValue? _bodytemp;
int c = 0;

class _TestUserDataState extends State<TestUserData> {
  List<EventUsageInfo> events = [];
  Map<String?, NetworkInfo?> _netInfoMap = Map();
  bool notify = false;

  Future func() async {
    HealthFactory health = HealthFactory();

    // Define the types to get
    var types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BODY_TEMPERATURE,
    ];

    await Permission.activityRecognition.request();
    bool requested = await health.requestAuthorization(types);


    var now = DateTime.now();
    // Fetch health data from the last 24 hours
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        now.subtract(Duration(days: 1)), now, types);

    // Get the number of steps for today
    var midnight = DateTime(now.year, now.month, now.day);
    var xyz = DateTime(now.year, now.month, now.day, now.hour, now.minute - 10);
    _steps = await health.getTotalStepsInInterval(midnight, now);
    stepx = await health.getTotalStepsInInterval(xyz, now);
    if (stepx == null) {
      stepx = 0;
    }

    String? heartRate;
    HealthValue? bpd;
    HealthValue? bps;
    HealthValue? oxygen;
    HealthValue? bodytemp;
    for (final data in healthData) {
      if (data.type == HealthDataType.HEART_RATE) {
        if (data.value != null) {
          heartRate = "${data.value}";
        }
      }
      if (data.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
        if (data.value != null) {
          bpd = data.value;
        }
      }
      if (data.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
        if (data.value != null) {
          bps = data.value;
        }
      }
      if (data.type == HealthDataType.BLOOD_OXYGEN) {
        if (data.value != null) {
          oxygen = data.value;
        }
      }
      if (data.type == HealthDataType.BODY_TEMPERATURE) {
        if (data.value != null) {
          bodytemp = data.value;
        }
      }
    }

    setState(() {
      _heart_rate = heartRate;
      _bp_d = bpd;
      _bp_s = bps;
      _oxygen = oxygen;
      _bodytemp = bodytemp;

    });

    // Upload the fetched data to Firebase
    await uploadHealthData();
  }


  Future sendEmail(
      String name1, String name2, String message, String email) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    const serviceId = 'service_x1l5vki';
    const templateId = 'template_bqeo4sk';
    const userId = 'BOaJnD9tU3utMPNW2';
    try {
      final response = await http.post(
        url,
        headers: {
          'origin': 'http:localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'from_name': name1,
            'to_name': name2,
            'message': message,
            'to_email': email,
          },
        }),
      );
      if (response.statusCode == 200) {
        print("Email sent successfully to $email");
      } else {
        print("Error sending email: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error sending email: $e");
    }


  }



  Future<void> sendSms(String fromName, String toName, String message, String phoneNumber) async {
    final smsUrl = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/ACe417ffce86b77a3ca77d43ad34cc9c62/Messages.json');
    const accountSid = 'ACe417ffce86b77a3ca77d43ad34cc9c62'; // Twilio Account SID
    const authToken = 'c49d09861e1bfedf80a69142a3dac43b';    // Twilio Auth Token
    const fromPhoneNumber = '+15614677958';                  // Twilio phone number

    print("Attempting to send SMS to $phoneNumber from $fromName to $toName");

    // Validate input parameters
    if (fromName.isEmpty || toName.isEmpty) {
      print("Invalid sender or recipient name. fromName: $fromName, toName: $toName");
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      print("Invalid phone number: $phoneNumber");
      return; // Exit if the phone number is invalid
    }

    // Prepend the country code (US: +1)
    final formattedPhoneNumber = '+1$phoneNumber';

    try {
      final smsResponse = await http.post(
        smsUrl,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': fromPhoneNumber, // Twilio verified phone number
          'To': formattedPhoneNumber, // Recipient's phone number
          'Body': 'Hello $toName, $fromName sent you a message: $message',
        },
      );

      if (smsResponse.statusCode == 201 || smsResponse.statusCode == 200) {
        print("SMS sent successfully to $formattedPhoneNumber");
      } else {
        print("Failed to send SMS: ${smsResponse.body}");
      }
    } catch (e) {
      print("Error sending SMS: $e");
    }
  }


  void  notification() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    var x = events[1]
        .packageName!
        .replaceFirst("com.", "")
        .replaceFirst(".android", "");
    String statement = (x == 'whatsapp' ||
        x == 'instagram' ||
        x == 'snapchat' ||
        x == 'twitter' ||
        x == 'google.youtube')
        ? '4. Stop using $x'
        : '4. Stop using all the apps now.';

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    if (int.parse(_heart_rate!.split(".")[0]) > 90) {
      flutterLocalNotificationsPlugin.show(
        0,
        "Alert",
        "Stress detected!! \nLet’s reset with a quick relaxation exercise",
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              color: Colors.red,
              playSound: true,
              icon: '@mipmap/ic_launcher'),
        ),
        payload: "optional payload",
      );
    }

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(
                'Alert',
                style: TextStyle(
                    fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                height: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Stress attack detected!!',
                      style: TextStyle(fontSize: 15.00, color: Colors.blue),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '1. Stop using your phone\n' +
                          '2. Take Deep breaths and Relax\n' +
                          '3. Take a Juice break\n' +
                          statement,
                      style: TextStyle(fontSize: 15.00, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
                TextButton(
                  child: Text('Call ${User_Info.friendName}'),
                  onPressed: () {

                  },
                ),
              ],
            ),
          );
        }, onDidReceiveBackgroundNotificationResponse: (NotificationResponse) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(
                'Alert',
                style: TextStyle(
                    fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                height: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Stress attack detected!!',
                      style: TextStyle(fontSize: 15.00, color: Colors.blue),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '1. Stop using your phone\n' +
                          '2. Take Deep breaths and Relax\n' +
                          '3. Take a Juice break\n' +
                          statement,
                      style: TextStyle(fontSize: 15.00, color: Colors.black),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
                TextButton(
                  child: Text('Call ${User_Info.friendName}'),
                  onPressed: () {

                  },
                ),
              ],
            ),
          );
        });
  }







// Helper function to show an alert dialog
  void showAlertDialog(BuildContext context, String statement) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Alert',
          style: TextStyle(
              fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Stress attack detected!!',
                style: TextStyle(fontSize: 15.00, color: Colors.blue),
              ),
              SizedBox(height: 5),
              Text(
                '1. Stop using your phone\n2. Take Deep breaths and Relax\n3. Take a Juice break\n$statement',
                style: TextStyle(fontSize: 15.00, color: Colors.black),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          if (User_Info.friendName != null && User_Info.phoneNo != null)
            TextButton(
              child: Text('Call ${User_Info.friendName}'),
              onPressed: () {
                // Trigger call action here
              },
            ),
        ],
      ),
    );
  }



  Future<void> initUsage() async {
    UsageStats.grantUsagePermission();
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 1));

    List<EventUsageInfo> queryEvents = await UsageStats.queryEvents(startDate, endDate);
    List<NetworkInfo> networkInfos = await UsageStats.queryNetworkUsageStats(startDate, endDate);
    Map<String?, NetworkInfo?> netInfoMap = Map.fromIterable(networkInfos,
        key: (v) => v.packageName, value: (v) => v);

    this.setState(() {
      events = queryEvents.reversed.toList();
      _netInfoMap = netInfoMap;
    });

    // Set up background handler after initializing usage data
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveBackgroundNotificationResponse: backgroundHandler, // Register background handler here
    );
  }

// The background handler needs to be a top-level function
  void backgroundHandler(NotificationResponse response) {
    // This function handles notifications in the background
    // You can use the response to get the notification data
    print("Background notification clicked: ${response.payload}");
    // You can perform any background tasks based on the notification here
  }


  @override
  @override
  void initState() {
    super.initState();
    if (run) {
      initUsage();
      func();
      notification();
      setState(() {
        run = false;
      });
    }
    Timer.periodic(Duration(seconds: 2), (timer) {
      func();
    });
    Timer.periodic(Duration(seconds: 20), (timer) {
      notification();
      if (int.parse(_heart_rate!.split(".")[0]) > 90) {
        c = 1;
        sendEmail(
          User_Info.name!,
          User_Info.friendName!,
          'Your friend ${User_Info.name} had a Stress attack',
          User_Info.friendContact!,
        );
      }
    });
    Timer.periodic(Duration(hours: 3), (timer) {
      if (c == 1) {
        sendEmail(
          User_Info.name!,
          User_Info.friendName!,
          'Your friend ${User_Info.name} had a Stress attack',
          User_Info.friendContact!,
        );
        c = 0;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    final randomFact = (funFacts.toList()..shuffle()).first;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stress Mate'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent.withOpacity(0.9),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline), // Icon for instructions
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Instruction(), // Navigate to Instruction page
                  ),
                );
              },
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/images/lightbulb.png', width: 24, height: 24), 
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Did You Know?",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              randomFact,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Heart rate box
                DataBox(
                  image: 'assets/images/heart_rate.png', 
                  data: "${_heart_rate ?? 'N/A'} BPM",
                  dataName: "Heart rate",
                ),
                SizedBox(height: height / 30),

                DataBox(
                  image: 'assets/images/bp_diastolic.png', 
                  data: "${_bp_s ?? 'N/A'} mm Hg",
                  dataName: "Systolic BP",
                ),
                SizedBox(height: height / 30),

                // Diastolic BP box
                DataBox(
                  image: 'assets/images/bp_diastolic.png', 
                  data: "${_bp_d ?? 'N/A'} mm Hg",
                  dataName: "Diastolic BP",
                ),
                SizedBox(height: height / 30),

                // Blood oxygen box
                DataBox(
                  image: 'assets/images/blood_oxygen.png', 
                  data: "${_oxygen ?? 'N/A'} %",
                  dataName: "Blood oxygen",
                ),
                SizedBox(height: height / 30),

                // Temperature box
                DataBox(
                  image: 'assets/images/temperature.png', 
                  data: "${_bodytemp ?? 'N/A'}°C",
                  dataName: "Temperature",
                ),
                SizedBox(height: height / 30),

                // Steps (today) box
                DataBox(
                  image: 'assets/images/steps.png', 
                  data: "${_steps ?? '0'} Steps",
                  dataName: "Steps (today)",
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DataBox extends StatelessWidget {
  final String image;
  final String data;
  final String dataName;

  DataBox({required this.image, required this.data, required this.dataName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Image.asset(
            image, // Displaying the custom image
            width: 30, // Adjust the size as necessary
            height: 30,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}



Future<void> uploadHealthData() async {
  try {
    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    User? user = FirebaseAuth.instance.currentUser;

    String email=user?.email??'unknown';


    // Convert health data values to plain Dart types
    final healthData = {
      "bloodOxygen": _oxygen != null ? (_oxygen as NumericHealthValue).numericValue : null,
      "bloodPressureDiastolic": _bp_d != null ? (_bp_d as NumericHealthValue).numericValue : null,
      "bloodPressureSystolic": _bp_s != null ? (_bp_s as NumericHealthValue).numericValue : null,
      "bodyTemperature": _bodytemp != null ? (_bodytemp as NumericHealthValue).numericValue : null,
      "heartRate": _heart_rate != null ? int.tryParse(_heart_rate!.split(".")[0]) : null,
      "steps": _steps,
    };

    // Write data to Firestore in the desired structure
    await FirebaseFirestore.instance
        .collection("StressData")
        .doc(email)
        .collection("Dates")
        .doc(date)
        .set(healthData);

    print("Health data uploaded successfully. to "+email);
  } catch (e) {
    print("Error uploading health data: $e");
  }
}





class DataValue extends StatelessWidget {
  const DataValue(
      {required this.data, required this.dataName, required this.dataIcon});

  final String data;
  final String dataName;
  final IconData dataIcon;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Container(
      width: width / 2.3,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200]!.withOpacity(0.7)),
      child: Column(
        children: [
          Icon(dataIcon, size: 0.174 * width, color: Colors.red[600]),
          SizedBox(height: height / 40),
          Text(
            dataName,
            style: TextStyle(
                fontSize: 0.036 * width,
                color: Colors.blue,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: height / 40),
          Text(data),
        ],
      ),
    );
  }
}



