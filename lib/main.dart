import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
//import 'package:ips_firebase_rtdb/flutter/bin/cache/flutter_web_sdk/lib/_engine/engine.dart';
import 'package:vibration/vibration.dart';
import 'dart:developer';
import 'package:ips_firebase_rtdb/widget/custom_button_0.dart';
import 'package:ips_firebase_rtdb/widget/toggle_button_0.dart';
import 'package:ips_firebase_rtdb/widget/coordinate_form.dart';
import 'package:ips_firebase_rtdb/widget/notifier2.dart';
import 'package:ips_firebase_rtdb/widget/timer_form.dart';
import 'package:ips_firebase_rtdb/widget/start_timer_button.dart';
import 'package:ips_firebase_rtdb/widget/userbar_with_delete_button.dart';
import 'package:ips_firebase_rtdb/widget/userform_for_saving_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          body: const MainPage(),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  int xinterval = 1;
  int xtimer = 15;
  int doing_task = 0;
  // Shared preferences properties
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _eeid;
  String eeidString = "empty";
  // Wi-Fi properties
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  bool shouldCheckCan = true;
  // Scan mode properties
  bool running = false;
  Timer? timer;
  int count = 0;
  int sec = 1;
  bool con = false;
  List<bool> currentMode = [true, false, false];
  List<Map<String, dynamic>> newAP = [];
  DateTime starter = DateTime.now();
  String selectedDirection = 'NORTH';

  // --------------------------------- Shared preferences Methods ---------------------------------
  Future<void> _addEeid(String eeid) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _eeid = prefs.setString('eeid', eeid).then((bool success) {
        eeidString = eeid;
        return eeid;
      });
    });
  }

  Future<void> _removeEeid() async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove('eeid');
    setState(() {
      _eeid = _prefs.then(
          (SharedPreferences prefs) => prefs.getString('eeid') ?? "empty");
    });
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  NotificationService notificationService = NotificationService();
  bool isWiFiScanInProgress = false;
  bool isWiFiScanned = false;
  var scannedArray = [];
  int ScanLoopState = 1;

  bool scannedArrayCheck() {
    int notScannedCount = 0;
    for (int i = 0; i < scannedArray.length; i++) {
      if (!scannedArray[i]) {
        notScannedCount += 1;
      }
      if (notScannedCount > 1) {
        return false;
      }
    }
    if (notScannedCount == 1) {
      print(">> Should be this");
      return true;
    }
    return true;
  }

  Future<void> huntWiFis() async {
    try {
      // Check if WiFi scan is already in progress
      if (isWiFiScanInProgress) {
        print("WiFi scan is already in progress. Skipping...");
        toastWithVibrate("WiFi scan is already in progress. Skipping...");
        return;
      }

      // Set the WiFi scan flag to indicate that a scan is in progress
      isWiFiScanInProgress = true;

      print("Start hunting...");

      // Set a timeout for the WiFi scan operation (e.g., 10 seconds)
      if (xinterval <= 1) {
        xinterval = 3;
      }
      final timeoutDuration = Duration(seconds: xinterval);

      // Start the WiFi scan
      final wifiScanFuture =
          WiFiHunter.huntWiFiNetworksWithTimeout(xinterval + 1);

      // Create a delayed Future to handle the timeout
      final timeoutFuture = Future.delayed(timeoutDuration, () {
        // Set the WiFi scan flag to indicate that the scan has timed out
        isWiFiScanInProgress = false;
        if (!isWiFiScanned) {
          if (scannedArray.isEmpty) {
            toastWithVibrate("Single: WiFi scan timed out");
          } else if (!scannedArrayCheck()) {
            toastWithVibrate("Multiple: WiFi scan timed out");
          }
        }

        throw TimeoutException('WiFi scan timed out');
      });

      // Wait for either the WiFi scan to complete or the timeout to occur
      await Future.any([wifiScanFuture, timeoutFuture]).then((result) {
        // Handle the result (it could be either WiFi scan result or TimeoutException)
        if (result is WiFiHunterResult) {
          wiFiHunterResult = result;
          print("scannedArray: $scannedArray");
          showToast("WiFi scan completed");
          isWiFiScanned = true;
          if (scannedArray.isNotEmpty) {
            scannedArray[scannedArray.length - 1] = true;
          }

          print("Done hunting!");
        }
      }).catchError((error) {
        // Handle other errors during WiFi scan
        if (error is TimeoutException) {
          // Ignore the timeout error here since it has been handled above
        } else {
          // Handle other errors
          toastWithVibrate("WiFi scan encountered an error: $error");
          print("WiFi scan error: $error");
        }
      }).whenComplete(() {
        // Set the WiFi scan flag to indicate that the scan is no longer in progress
        isWiFiScanInProgress = false;
      });

      //toastWithVibrate("DONE HUNTING");
      print("Done hunting 2");
    } catch (exception) {
      // Handle unexpected exceptions
      toastWithVibrate("An unexpected error occurred: $exception");
      print("Unexpected error during WiFi scan: $exception");
    }
  }

  // --------------------------------- Wi-Fi Scanner Methods ---------------------------------
  Future<bool> _wifiCanGetScannedResults() async {
    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canGetScannedResults();
      if (can != CanGetScannedResults.yes) {
        log("Cannot get scanned results: $can");
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<List<String>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo? androidInfo; // Use nullable type

    try {
      androidInfo = await deviceInfo.androidInfo;
    } catch (e) {
      print('Error getting Android device info: $e');
    }

    final deviceId = androidInfo?.androidId ?? 'UNKNOWN';
    final deviceModel = androidInfo?.model ?? 'UNKNOWN';

    return [deviceId, deviceModel];
  }

  String formatNewDate(DateTime dateTime) {
    // Format the DateTime using the desired format
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(dateTime);

    // Get the timezone offset
    String timezoneOffset = getTimezoneOffset(dateTime);

    // Combine the formatted date and timezone offset
    return '$formattedDate$timezoneOffset';
  }

  String getTimezoneOffset(DateTime dateTime) {
    // Get the timezone offset in minutes
    int offsetMinutes = dateTime.timeZoneOffset.inMinutes;

    // Calculate the offset in hours and minutes
    int hours = offsetMinutes ~/ 60;
    int minutes = offsetMinutes % 60;

    // Format the offset as "+HH:mm" or "-HH:mm"
    String formattedOffset =
        '${hours.abs().toString().padLeft(2, '0')}:${minutes.abs().toString().padLeft(2, '0')}';

    // Determine the sign of the offset
    String sign = offsetMinutes >= 0 ? '+' : '-';

    return '$sign$formattedOffset';
  }

  Future<bool> _wifiGetResultsInJsonForm() async {
    if (await _wifiCanGetScannedResults()) {
      final results = await WiFiScan.instance.getScannedResults();
      accessPoints = results;
      return true;
    } else {
      accessPoints = <WiFiAccessPoint>[];
      return false;
    }
  }

  Future<List<WiFiAccessPoint>> getWIFI() async {
    if (await _wifiCanGetScannedResults()) {
      final results = await WiFiScan.instance.getScannedResults();
      return results;
    } else {
      return <WiFiAccessPoint>[];
    }
  }

  // --------------------------------- Firebase methods ---------------------------------
  Future<void> sendToFirebase() async {
    if (await _wifiGetResultsInJsonForm()) {
      List<String> ssids = [];
      List<String> bssdis = [];
      List<int> levels = [];
      for (int i = 0; i < accessPoints.length; i++) {
        ssids.add(accessPoints[i].ssid);
        bssdis.add(accessPoints[i].bssid);
        levels.add(accessPoints[i].level);
      }
      final dbref = FirebaseDatabase.instance.ref(eeidString);
      await dbref.child("phone_to_realtime_database").child("ssid").set(ssids);
      await dbref
          .child("phone_to_realtime_database")
          .child("bssdi")
          .set(bssdis);
      await dbref
          .child("phone_to_realtime_database")
          .child("level")
          .set(levels);
    }
  }

  Future<void> addMultipleWIFI() async {
    if (await _wifiGetResultsInJsonForm()) {
      List<Map<String, dynamic>> signals = [];
      List<String> ssids = [];
      List<String> bssdis = [];
      List<int> levels = [];
      //print(accessPoints);
      for (int i = 0; i < accessPoints.length; i++) {
        ssids.add(accessPoints[i].ssid);
        bssdis.add(accessPoints[i].bssid);
        levels.add(accessPoints[i].level);

        signals.add({
          'Ssid': accessPoints[i].ssid,
          'mac_address': accessPoints[i].bssid,
          'Strength': [accessPoints[i].level.toDouble()],
        });
      }
    }
  }

  void addNewStrength(String ssid, String bssid, double level) {
    print("current AP: ");
    //print(newAP);
    for (int i = 0; i < newAP.length; i++) {
      if (newAP[i]['mac_address'] == bssid) {
        newAP[i]['Strength'].add(level);
        newAP[i]['created_at'].add(formatNewDate(DateTime.now()));
        return;
      }
    }

    // If BSSID not found, add a new entry
    newAP.add({
      'Ssid': ssid,
      'mac_address': bssid,
      'Strength': [level.toDouble()],
      'created_at': [formatNewDate(DateTime.now())]
    });
  }

  Future<void> collectPositionData(
      poll_rate, duration, toast, stage, start, mode) async {
    //final apiUrl = 'http://172.20.10.6:8080/api/v1/rssi/collectdata';
    final apiUrl = 'https://bff-api.cie-ips.com/api/v1/rssi/collectdata';
    //cie 10.0.9.6

    final jsonData = {
      'Signals': newAP,
      'Position': {'X': x, 'Y': y, 'Z': z},
      'Duration': duration,
      'stat_collection_stage': stage,
      'Started_At': start,
      'Ended_At': formatNewDate(DateTime.now()),
      'Created_At': formatNewDate(DateTime.now()),
      'Polling_Rate': poll_rate,
      'selected_direction': selectedDirection,
    };

    print("xyz: $x $y $z");
    List<String> deviceInfo = await getDeviceInfo();
    String deviceId = deviceInfo[0];
    String deviceModel = deviceInfo[1];

    // final headers = {
    //   'DeviceId': deviceId,
    //   'Models': deviceModel,
    //   'Content-Type': 'application/json',
    // };

    final headers = {
      'X-Device-ID': deviceId,
      'X-Device-Model': deviceModel,
      'Content-Type': 'application/json',
    };
    print("body obj");
    print(jsonData);
    if (!isWiFiScanned) {
      print("not send data because scan not complete");
      var desc =
          "SING MODE --> coor: ($x,$y,$z) interval: $xinterval record-limit: $xtimer";
      notificationService.notifyMsg(
        'IPS EXPERIMENT: FAILED, SIGNAL NOT SENT',
        desc,
      );
      toastWithVibrate("Signal Not Send, Try Again");
      isWiFiScanned = false;
      ScanLoopState = 1;
      return;
    }

    try {
      final ioClient = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      final http.Client xclient = IOClient(ioClient);
      //final response = await http.post(
      final response = await xclient.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(jsonData),
      );
      print("status code: $response.statusCode");
      if (response.statusCode == 200) {
        print('Request successful: ${response.body}');
        var desc = "SUCCESS NULL DESC";
        if (mode == "SINGLE") {
          desc = "SING MODE --> coor: ($x,$y,$z)";
          toastWithVibrate("Signal Sent");
        } else if (mode == "CUSTOM") {
          desc =
              "CUST MODE --> coor: ($x,$y,$z) interval: $xinterval s/record record-limit: $xtimer";
        } else if (mode == "CONTINUOUS") {
          desc = "CONT MODE --> coor: ($x,$y,$z) interval: $xinterval s/record";
        }

        notificationService.notifyMsg(
          'IPS EXPERIMENT: SUCESS, WHOLE RECORD SENT',
          desc,
        );
        // if (toast < 0) {
        //   toastWithVibrate("Single Sent");
        // }
        // Show "Sent" toast on success
        //clearCoordinateForm(); // Clear entry boxes on success
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        toastWithVibrate('Failed: Something went wrong');
      }
    } catch (error) {
      print('Error: $error');
      toastWithVibrate('Internet Failed: Something went wrong');
      var desc =
          "$mode MODE --> coor: ($x,$y,$z) interval: $xinterval s/record record-limit: $xtimer";
      notificationService.notifyMsg(
        'IPS EXPERIMENT: INTERNET FAILED, WHOLE RECORD NOT SENT',
        desc,
      );
    }
    //isWiFiScanned = false;
    ScanLoopState = 1;
    doing_task = 0;
    //newAP = [];
  }

  void main() {
    //collectPositionData();
  }

  void toggleMode(List<bool> mode) {
    print("onToggleMode CheckMode: $mode");
    currentMode = mode;
  }

  Future<void> vibrateMe() async {
    bool? hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator != null && hasVibrator) {
      Vibration.vibrate(duration: 300);
    }
  }

  Future updateAP() async {
    print("start hunting");
    await huntWiFis();
    print("hunted");
    if (await _wifiGetResultsInJsonForm()) {
      print("accespoints: ");
      //print(accessPoints);
      for (int i = 0; i < accessPoints.length; i++) {
        addNewStrength(accessPoints[i].ssid, accessPoints[i].bssid,
            accessPoints[i].level.toDouble());
      }
      print("updated new ap info");
    }
  }

  void toastWithVibrate(txt) {
    showToast(txt);
    vibrateMe();
  }

  void coorChanger(String axis, String opt) {
    final TextEditingController controller = axis == 'x'
        ? _xController
        : axis == 'y'
            ? _yController
            : _zController;

    String newText;
    if (opt == '+') {
      newText = (double.parse(controller.text) + 1.2).toString();
      if (axis == "x") {
        x += 1.2;
      } else {
        y += 1.2;
      }
    } else {
      newText = (double.parse(controller.text) - 1.2).toString();
      if (axis == "x") {
        x -= 1.2;
      } else {
        y -= 1.2;
      }
    }

    final updatedText = newText;
    controller.value = controller.value.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(offset: updatedText.length),
    );

    // Notify the parent widget about the changed coordinates
    // widget.changeCoordinate(axis, newText);
    // widget.xController.text = x.toString(); // Update x text field
  }

  void onScanSend() {
    print("onScanSend CheckMode: $currentMode");
    List<bool> mode = currentMode;
    if (doing_task == 1) {
      showToast("New Operation Canceled: Already Working On Something");
      return;
    } else if (doing_task == 0) {
      print("starting new op");
      doing_task = 1;
    } else if (doing_task == 2) {
      if (!mode[1]) {
        showToast("New Operation Canceled: Cannot Interfere Continuous Mode");
        return;
      }
    }

    Future<void> sendSingleMode() async {
      print("Single Mode");
      await updateAP();
      await collectPositionData(
          0, -1, -1, 'SINGLE', formatNewDate(DateTime.now()), "SINGLE");
      newAP = [];
      accessPoints = [];
    }

    Future<void> sendContinuousMode() async {
      print("Continuous Mode");
      print("using interval: $xinterval seconds");
      int counter = 1;
      doing_task = 2;

      if (!con) {
        con = true;
        toastWithVibrate("Start Sending Continuously");
        starter = DateTime.now();
        timer = Timer.periodic(Duration(seconds: xinterval), (Timer t) async {
          print("counter: $counter");
          if (ScanLoopState == 1) {
            ScanLoopState = 2;
          } else if (ScanLoopState == 2) {
            if (!isWiFiScanned) {
              toastWithVibrate("Whole Record Not Send, Try again");
              var desc =
                  "CONT MODE --> coor: ($x,$y,$z) interval: $xinterval s/record";
              notificationService.notifyMsg(
                'IPS EXPERIMENT: FAILED, WHOLE RECORD NOT SENT',
                desc,
              );
              newAP = [];
              con = false;
              timer?.cancel();
              doing_task = 0;
              return;
            }
            isWiFiScanned = false;
          }
          scannedArray.add(false);
          await updateAP();
          accessPoints = [];
          counter++;
        });
      } else {
        timer?.cancel();
        DateTime ender = DateTime.now();
        Duration diff = ender.difference(starter);
        int diffsec = diff.inSeconds;
        print("counter: $counter diff: $diffsec");
        await collectPositionData(xinterval, diffsec, 1, 'MULTIPLE',
            formatNewDate(starter), "CONTINUOUS");
        con = false;
        toastWithVibrate("Stop Sending Continuously");

        newAP = [];
      }
    }

    Future<void> sendTimerMode() async {
      print("Timer Mode");
      print("using interval: $xinterval seconds");
      print("using timer: $xtimer seconds");
      int counter = 1;
      toastWithVibrate("Start Auto Scan: $xtimer Records");
      starter = DateTime.now();
      timer = Timer.periodic(Duration(seconds: xinterval), (Timer t) async {
        print("timer counter: $counter");
        if (ScanLoopState == 1) {
          ScanLoopState = 2;
        } else if (ScanLoopState == 2) {
          if (!isWiFiScanned) {
            toastWithVibrate("Whole Record Not Send, Try again");
            var desc =
                "CUST MODE --> coor: ($x,$y,$z) interval: $xinterval s/record record-limit: $xtimer";
            notificationService.notifyMsg(
              'IPS EXPERIMENT: FAILED, WHOLE RECORD NOT SENT',
              desc,
            );
            newAP = [];
            timer?.cancel();
            doing_task = 0;
            return;
          }
          isWiFiScanned = false;
        }
        print("start updating AP: $counter");
        scannedArray.add(false);
        await updateAP();
        accessPoints = [];
        print("stop updating AP: $counter");

        if (counter >= xtimer) {
          print("done timer");
          await collectPositionData(xinterval, xtimer, 2, 'MULTIPLE',
              formatNewDate(starter), "CUSTOM");
          toastWithVibrate("Scanned $xtimer Records Done !");

          timer?.cancel();
          newAP = [];
        }

        counter++;
      });
    }

    if (mode[0] == true) {
      isWiFiScanned = false;
      sendSingleMode();
    } else if (mode[1] == true) {
      if (ScanLoopState > 1) {
        sendContinuousMode();
      } else {
        isWiFiScanned = false;
        //ScanLoopState = 1;
        sendContinuousMode();
      }
    } else if (mode[2] == true) {
      isWiFiScanned = false;
      //ScanLoopState = 1;
      sendTimerMode();
    }
  }

  // --------------------------------- Widgets ---------------------------------
  Widget addUserWidget() => Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: UserFormForSavingID(
            onSaved: (value) => _addEeid(value),
          ),
        ),
      );

  Widget userBarWidget(
    String eeid,
    TextEditingController xController,
    TextEditingController yController,
    TextEditingController zController,
  ) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                UserBarWithDeleteButton(
                  eeid: eeid,
                  onPressedToRemove: () => _removeEeid(),
                ),
                const SizedBox(height: 8),
                CustomToggleButton0(
                  onToggle: (currentIndex) => toggleMode(currentIndex),
                ),
                CoordinateForm(
                  onCoordinatesChanged: (x, y, z) {
                    setState(() {
                      // Update the values of x, y, and z in the _MainPageState
                      this.x = x;
                      this.y = y;
                      this.z = z;
                    });
                    // You can use x, y, and z here, or save them to variables for later use.
                    print('X: $x, Y: $y, Z: $z');
                  },
                  changeCoordinate: coorChanger,
                  xController: _xController,
                  yController: _yController,
                  zController: _zController,
                ),
                TimerForm(
                  onTimerChanged: (i, t) {
                    setState(() {
                      this.xinterval = i;
                      this.xtimer = t;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => coorChanger("x", "-"),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(
                            255, 225, 106, 223), // Change the background color
                        onPrimary: Colors.white, // Change the text color
                      ),
                      child: Text('X-1.2'),
                    ),
                    ElevatedButton(
                      onPressed: () => coorChanger("x", "+"),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(
                            255, 234, 68, 200), // Change the background color
                        onPrimary: Colors.white, // Change the text color
                      ),
                      child: Text('X+1.2'),
                    ),
                    ElevatedButton(
                      onPressed: () => coorChanger("y", "-"),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(
                            255, 98, 132, 243), // Change the background color
                        onPrimary: Colors.white, // Change the text color
                      ),
                      child: Text('Y-1.2'),
                    ),
                    ElevatedButton(
                      onPressed: () => coorChanger("y", "+"),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(
                            255, 54, 92, 244), // Change the background color
                        onPrimary: Colors.white, // Change the text color
                      ),
                      child: Text('Y+1.2'),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: selectedDirection,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDirection = newValue!;
                    });
                  },
                  items: <String>['NORTH', 'EAST', 'SOUTH', 'WEST']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            CustomButton0(
              onPressed: () => onScanSend(),
            ),
          ],
        ),
      );

  TextEditingController _xController = TextEditingController();
  TextEditingController _yController = TextEditingController();
  TextEditingController _zController = TextEditingController();

  Widget landingPageV2(String eeid) => (eeid == "empty")
      ? addUserWidget()
      : userBarWidget(eeid, _xController, _yController, _zController);

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _eeid = _prefs
        .then((SharedPreferences prefs) => prefs.getString('eeid') ?? "empty");
    _eeid.then((value) => eeidString = value);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _eeid,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return landingPageV2(snapshot.data.toString());
              }
          }
        });
  }
}
