import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_linear_progress_bar.dart';
import 'package:flutter_application_1/timer.dart';
import 'package:flutter_application_1/workout.dart';
import 'dart:convert';
import 'websocket_client.dart';
import 'package:flutter_tts/flutter_tts.dart';

class User {
  String name;
  int point;

  User({required this.name, required this.point});
}

class TimedEvents {
  String name;
  int deltaPoint;
  int time;

  TimedEvents({required this.name, required this.deltaPoint, required this.time});
}

class MidMatchScreen extends StatefulWidget {
  const MidMatchScreen({super.key});

  @override
  State<MidMatchScreen> createState() => _MidMatchScreenState();
}

class _MidMatchScreenState extends State<MidMatchScreen> {
  FlutterTts _flutterTts = FlutterTts();

  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> cameras;
  double accuracy = 80;
  Timer? captureTimer;

  int curTime = 0;

  List<Workout> workouts = [
    Workout(workoutName: "workoutName", workout: "workout"),
    Workout(workoutName: "workoutName", workout: "workout"),
    Workout(workoutName: "workoutName", workout: "workout"),
    Workout(workoutName: "workoutName", workout: "workout"),
    Workout(workoutName: "workoutName", workout: "workout"),
  ];

  void performTimedEvents(TimedEvents event){
    int i = getLeaderBoardPosition(event.name);
    users[i].point += event.deltaPoint;
  }
  List<TimedEvents> timedEvents = [
    TimedEvents(name: "Tom Lee", deltaPoint: 10, time: 3),  // Tom gains 10 points at 3 seconds
    TimedEvents(name: "Ali Khan", deltaPoint: -10, time: 6), // Ali loses 10 points at 6 seconds
    TimedEvents(name: "Eva Cole", deltaPoint: 10, time: 9),  // Eva gains 10 points at 9 seconds
    TimedEvents(name: "Sam Roy", deltaPoint: -10, time: 12), // Sam loses 10 points at 12 seconds
    TimedEvents(name: "Amy Snow", deltaPoint: 10, time: 15), // Amy gains 10 points at 15 seconds
    TimedEvents(name: "Ben Lee", deltaPoint: 10, time: 21),  // Ben gains 10 points at 21 seconds
    TimedEvents(name: "Zoe White", deltaPoint: -10, time: 24), // Zoe loses 10 points at 24 seconds
    TimedEvents(name: "Max Joy", deltaPoint: 10, time: 27),  // Max gains 10 points at 27 seconds
    TimedEvents(name: "Leo Fox", deltaPoint: -10, time: 30), // Leo loses 10 points at 30 seconds
    TimedEvents(name: "Tom Lee", deltaPoint: -10, time: 33), // Tom loses 10 points at 33 seconds
    TimedEvents(name: "Ali Khan", deltaPoint: 10, time: 36), // Ali gains 10 points at 36 seconds
    TimedEvents(name: "Eva Cole", deltaPoint: -10, time: 39), // Eva loses 10 points at 39 seconds
    TimedEvents(name: "Sam Roy", deltaPoint: 10, time: 42),  // Sam gains 10 points at 42 seconds
    TimedEvents(name: "Amy Snow", deltaPoint: -10, time: 45), // Amy loses 10 points at 45 seconds
    TimedEvents(name: "Ben Lee", deltaPoint: -10, time: 51), // Ben loses 10 points at 51 seconds
    TimedEvents(name: "Zoe White", deltaPoint: 10, time: 54), // Zoe gains 10 points at 54 seconds
    TimedEvents(name: "Max Joy", deltaPoint: -10, time: 57), // Max loses 10 points at 57 seconds
    TimedEvents(name: "Leo Fox", deltaPoint: 10, time: 60),  // Leo gains 10 points at 60 seconds
  ];

  List<User> users = [
    User(name: 'Ali Khan', point: 0),
    User(name: 'Tom Lee', point: 0),
    User(name: 'Eva Cole', point: 0),
    User(name: 'Sam Roy', point: 0),
    User(name: 'Amy Snow', point: 0),
    User(name: 'Jo Unnam', point: 0),
    User(name: 'Ben Lee', point: 0),
    User(name: 'Zoe White', point: 0),
    User(name: 'Max Joy', point: 0),
    User(name: 'Leo Fox', point: 0),
  ];

  List<List<User>> leaderBoardList = [

  ];

  int getLeaderBoardPosition(String name) {
    leaderBoard();
    int i = 0;
    for (User user in users) {
      if (user.name == name) return i;
      i += 1;
    }
    print("this is i ");
    print(i);
    return -1;
  }

  void leaderBoard() {
    users.sort((a, b) => a.point - b.point);

    int chosenIndex = 0;
    for (User user in users) {
      if (user.name == "Jo Unnam") {
        break;
      }
      chosenIndex += 1;
    }

    if (chosenIndex > 5) {
      leaderBoardList = [
        [users[0], users[1], users[2]],
        [users[3], users[4], users[5]],
      ];
    }

    leaderBoardList = [
      [users[4], users[5], users[6]],
      [users[7], users[8], users[9]],
    ];
  }

  int timerDuration = 5;
  int currentTime = 0;

  void updateAccuracy(double new_accuracy) {
    setState(() {
      accuracy = new_accuracy;
    });
  }

  void speak() async {
    print("why are you speaking");
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.speak(
      "You look like a broken ikea chair trying to hold itself with positive vibes",
    );
  }

  Future<int> _setVoice() async {
    // Set the language and rate
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.48);  // Adjust the rate to make it more aggressive (higher values are faster)
    await _flutterTts.setPitch(0.8);  // Lower pitch for a deeper, more "aggressive" voice

    

    // List all available voices
    var voices = await _flutterTts.getVoices;
    print("Available voices: $voices");

    // You can choose a male voice from the list if available
    // For example, you can set the first voice or choose a specific one.
    await _flutterTts.setVoice({'name': 'Rishi', 'locale': 'en-IN', 'identifier': 'com.apple.voice.compact.en-IN.Rishi', 'quality': 'default', 'gender': 'male'});

    return 1;
  }

  void asyncInitState() async {
    await _setVoice();
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
        ],
        IosTextToSpeechAudioMode.defaultMode
    );
  }

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    leaderBoardList = [
      [users[0], users[1], users[2]],
      [users[3], users[4], users[5]],
    ];
    _initializeCamera();
    WebSocketClient.connect();

     _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.5); // Adjust speed if necessary
    _flutterTts.setVolume(1.0); // Adjust volume if needed
    _flutterTts.setPitch(1.0); // Adjust pitch if needed
    asyncInitState();

    Future.delayed(Duration(seconds: 5), () {
      // Call the function after 5 seconds
      speak();
    });

    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      for(TimedEvents event in timedEvents) {
        if(event.time == currentTime){
          performTimedEvents(event);
        }
      }
      leaderBoard();
    });
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[1],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    _initializeControllerFuture = _cameraController.initialize();
    await _cameraController.setFocusMode(FocusMode.locked);
    await _cameraController.setExposureMode(ExposureMode.locked);

    setState(() {});

    // Periodically take a picture and send it
    captureTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_cameraController!.value.isInitialized ||
          _cameraController!.value.isTakingPicture)
        return;

      try {
        final XFile picture = await _cameraController!.takePicture();
        final bytes = await picture.readAsBytes();
        final base64Image = base64Encode(bytes);
        WebSocketClient.sendImage(base64Image);
      } catch (e) {
        print("Capture error: $e");
      }
    });
  }

  void resetTimer() {
    print("the timer is working");
    setState(() {
      // Update the timer duration (for example, 30 seconds after it completes)
      currentTime = 0;
      timerDuration = 30;
    });
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    WebSocketClient.disconnect();
    _cameraController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: height * 0.01),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(
                        children: [
                          Container(
                            width: width * 0.95,
                            height: height * 0.6,
                            child: ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Container(
                                    width: width * 0.95,
                                    height:
                                        (width * 0.95) *
                                        _cameraController.value.aspectRatio,
                                    child: CameraPreview(_cameraController),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: width * 0.025,
                            top: height * 0.015,
                            child: LinearTimer(
                              width: width * 0.9,
                              height: height * 0.02,
                              durationInSeconds: timerDuration,
                              progress: currentTime,
                              backgroundColor: Colors.black.withOpacity(0.4),
                              onTimerComplete:
                                  resetTimer, // Reset the timer after completion
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            left: 15,
                            child: VerticalProgressBar(
                              width: height * 0.02,
                              height: height * 0.28,
                              backgroundColor: Colors.black.withOpacity(0.3),
                              progressColor:
                                  accuracy < 40
                                      ? Colors.red
                                      : accuracy < 80
                                      ? Colors.orange
                                      : Colors.green,
                              initialValue: 0,
                              progress: accuracy,
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            left: 45,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  accuracy.toInt().toString() + "%",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Expanded(
                      child: Container(
                        width: width * 0.95,
                        decoration: BoxDecoration(
                          color: Color(0xffF9FAFB),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "Live Leaderboard",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ...leaderBoardList.map((data) {
                                  return Column(
                                    children:
                                        data.map((data2) {
                                          return InkWell(
                                            onTap: speak,
                                            child: Container(
                                              width: width * 0.45,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(
                                                      0.1,
                                                    ), // Gentle shadow with low opacity
                                                    blurRadius:
                                                        8, // Slightly soft shadow
                                                    offset: Offset(
                                                      0,
                                                      4,
                                                    ), // Shadow positioned below the container
                                                  ),
                                                ],
                                              ),
                                              margin: EdgeInsets.only(bottom: 5),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 10),
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        getLeaderBoardPosition(data2.name)
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 7.5),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(height: 3),
                                                      Text(
                                                        data2.name,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 20,
                                                          height: 0.8,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        "Score : " +
                                                            data2.point
                                                                .toString(),
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
