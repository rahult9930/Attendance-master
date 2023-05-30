import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:qrscan/qrscan.dart' as qrscan;
import 'package:camera/camera.dart';
 import 'package:permission_handler/permission_handler.dart';

import 'package:myqratt/ui/friend.dart';

class Scanner extends StatefulWidget {
  final String username;
  final String password;

  Scanner({this.username, this.password});

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  String _userName;
  String _password;
  String _udid;
  String _ipad;
  String attUrl = "";
  bool attendanceMarked = false;
  bool error = false;
  String errorMsg = "";
  String _qrCode="";

  @override
  void initState() {
    super.initState();
    _userName = widget.username;
    _password = widget.password;
  }

  Future<bool> checkCameraPermission() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    return cameraPermissionStatus == PermissionStatus.granted;
  }
  Future<void> requestCameraPermission() async {
    // Request the permission
    Map<Permission, PermissionStatus> permissionStatus = await [Permission.camera].request();

    // If the permission is granted, initialize the camera
    if (permissionStatus[Permission.camera] == PermissionStatus.granted) {
      initializeCamera();
    }
  }

  Future<void> initializeCamera() async {
    // Get a list of available cameras
    List<CameraDescription> cameras = await availableCameras();

    // Select the first camera from the list
    CameraController cameraController = CameraController(cameras[0], ResolutionPreset.medium);

    // Initialize the camera controller
    await cameraController.initialize();

  }


  Future<void> _scan() async {
    final result = await qrscan.scan();
    setState(() {
      _udid = Uri
          .parse(result)
          .queryParameters['uid'];
      _ipad = Uri
          .parse(result)
          .queryParameters['ipad'];
      attUrl = Uri
          .parse(result)
          .queryParameters['url'];
    });
  }

  Future<void> _loadparas() async {
    if (attUrl != "") {
      setState(() {
        error = false;
      });
      try {
        var responseobjectParas = await http.post(attUrl,
            body: {
              'uid': '$_udid',
              'ipad': '$_ipad',
              'username': '$_userName',
              'password': '$_password'
            });
        var responseParas = json.decode(responseobjectParas.body);
        if (responseParas['status'] == "success") {
          setState(() {
            attUrl = responseParas['url'];
          });
        } else if (responseParas['status'] == "error") {
          setState(() {
            error = true;
            errorMsg = "Something went wrong";
          });
        }
      } catch (e) {
        setState(() {
          error = true;
          errorMsg = "Error occurred: $e";
        });
      }
    }
  }


  Future<void> _makeRequest() async {
    var responseobjectApp = await http.post(attUrl, body: {
      'username': '$_userName',
      'password': '$_password',
      'uid': '$_udid',
      'ipad': '$_ipad'
    });
    var responseApp;
    try {
      responseApp = json.decode(responseobjectApp.body);
    } catch (e) {
      setState(() {
        error = true;
        errorMsg = "Code Expired. Please try Again";
      });
    }
    if (!error) {
      switch (responseApp['status']) {
        case "success":
          errorMsg = "Success";
          setState(() {
            attendanceMarked = true;
          });
          break;
        case "error":
          errorMsg = "Something went wrong";
          setState(() {
            attendanceMarked = false;
          });
          break;
        case "blocked":
          errorMsg =
          "Your account is blocked. Please contact respective administrator";
          setState(() {
            attendanceMarked = false;
          });
          break;
        case "creds":
          errorMsg = "Invalid Creds";
          setState(() {
            attendanceMarked = false;
          });
          break;
        case "over":
          errorMsg =
          "The respective attendance for the code scanned is already completed";
          setState(() {
            attendanceMarked = false;
          });
          break;
        default:
          errorMsg = "Invalid Operation";
          setState(() {
            attendanceMarked = false;
          });
      }
    }
  }

  Future<void> _startOperations() async {
    String barcode = await qrscan.scan();
    setState(() {
      _qrCode = barcode;
    });
    await _loadparas();
    if (attUrl != '') {
      await _makeRequest();
    }
  }

  Widget _buildFeedback(BuildContext context) {
    if (attendanceMarked) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle,
            size: 200.0,
            color: Colors.green,
          ),
          SizedBox(height: 150),
          Text(
            'Attendance Marked Successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 100),
          Container(
            height: 50,
            width: 200,
            child: IconButton(
              icon: Icon(Icons.dashboard),
              color: Theme
                  .of(context)
                  .primaryColor,
              splashColor: Theme
                  .of(context)
                  .colorScheme
                  .secondary,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: 50,
            width: 200,
            child: IconButton(
              icon: Icon(Icons.person_pin),
              color: Theme
                  .of(context)
                  .primaryColor,
              splashColor: Theme
                  .of(context)
                  .colorScheme
                  .secondary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Friend(uid: _udid, ipad: _ipad),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error,
            size: 200.0,
            color: Colors.red,
          ),
          SizedBox(height: 150),
          Text(
            errorMsg,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 100),
          Container(
            height: 50,
            width: 200,
            child: IconButton(
              icon: Icon(Icons.dashboard),
              color: Theme
                  .of(context)
                  .primaryColor,
              splashRadius: 20.0,
              splashColor: Theme
                  .of(context)
                  .colorScheme
                  .secondary,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          SizedBox(height: 30),
          Container(
              height: 50,
              width: 200,
              child: IconButton(
                icon: Icon(Icons.replay),
                color: Theme
                    .of(context)
                    .primaryColor,
                splashRadius: 20.0,
                splashColor: Theme
                    .of(context)
                    .colorScheme
                    .secondary,
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _scan();
                },
              )
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkCameraPermission(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            body: Center(
              child: _buildFeedback(context),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: Text("Camera permission not granted"),
            ),
          );
        }
      },
    );
  }
}