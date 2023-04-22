import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/src/env_variables/env_variables.dart';
import 'package:mobile/src/main_view/main_view.dart' show MainView;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  static const routeName = '/camera';

  @override
  State<StatefulWidget> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  final ImagePicker picker = ImagePicker();
  late Future<XFile> futurePhoto = getPhoto();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<XFile> getPhoto() async {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final size = mediaQuery.size;
    final width = size.width;
    final height =
        size.height - kBottomNavigationBarHeight - kToolbarHeight - topPadding;
    final response = await picker.retrieveLostData();

    if (!response.isEmpty &&
        response.file != null &&
        response.type == RetrieveType.image) {
      return Future.value(response.file);
    } else {
      return Future.value(await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: width,
          maxHeight: height,
          imageQuality: 80));
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Turn on location services');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
            'Location permissions are neccessary for app usage');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are neccessary for app usage');
    }

    final accuracy = await Geolocator.getLocationAccuracy();
    if (accuracy == LocationAccuracyStatus.reduced) {
      return Future.error('Turn on precise location');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: FutureBuilder<XFile>(
        future: futurePhoto,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                Center(child: Image.file(File(snapshot.data!.path))),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60.0),
                              ),
                              backgroundColor: Colors.red,
                            ),
                            child: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              futurePhoto = getPhoto();
                            }),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60.0),
                              ),
                              backgroundColor: Colors.green,
                            ),
                            child: const Icon(Icons.check),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              try {
                                final position = await determinePosition();

                                final token = await FirebaseAuth
                                    .instance.currentUser!
                                    .getIdToken();
                                var uri = Uri.parse("${API_URL}photo");
                                var request = http.MultipartRequest('POST', uri)
                                  ..headers['Authorization'] = 'Bearer $token'
                                  ..fields['latitude'] =
                                      position.latitude.toString()
                                  ..fields['longitude'] =
                                      position.longitude.toString()
                                  ..files.add(await http.MultipartFile.fromPath(
                                      'photo', snapshot.data!.path,
                                      contentType: MediaType('image', 'jpeg')));
                                var response = await request.send();
                                if (response.statusCode == 200) {
                                  const snackBar = SnackBar(
                                    content: Text("Photo sent"),
                                    duration: Duration(seconds: 3),
                                  );
                                  messenger.showSnackBar(snackBar);
                                  navigator.popAndPushNamed(MainView.routeName);
                                } else {
                                  const snackBar = SnackBar(
                                    content: Text("Something went wrong"),
                                    duration: Duration(seconds: 3),
                                  );
                                  messenger.showSnackBar(snackBar);
                                }
                              } catch (e) {
                                final snackBar = SnackBar(
                                  content: Text(e.toString()),
                                  duration: const Duration(seconds: 3),
                                );
                                messenger.showSnackBar(snackBar);
                                navigator.popAndPushNamed(MainView.routeName);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (snapshot.error is PlatformException) {
                final messenger = ScaffoldMessenger.of(context);
                const snackBar = SnackBar(
                  content: Text("Camera is not available"),
                  duration: Duration(seconds: 3),
                );
                messenger.showSnackBar(snackBar);
              }
              Navigator.of(context).popAndPushNamed(MainView.routeName);
            });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
