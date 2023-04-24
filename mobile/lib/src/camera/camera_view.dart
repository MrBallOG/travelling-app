import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/src/http_client/http_client.dart';
import 'package:mobile/src/main_view/main_view.dart' show MainView;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile/src/widget/snackbars.dart';

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

  Future<void> checkLocationPermissions() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      restorationId: 'camera',
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
                                await checkLocationPermissions();
                              } catch (e) {
                                messenger.showSnackBar(
                                    snackBarFailure(e.toString()));
                                navigator.restorablePopAndPushNamed(
                                    MainView.routeName);
                                return;
                              }

                              try {
                                messenger.showSnackBar(
                                    snackBarProgress("Sending photo..."));
                                navigator.restorablePopAndPushNamed(
                                    MainView.routeName);
                                final position =
                                    await Geolocator.getCurrentPosition(
                                        desiredAccuracy: LocationAccuracy.best);
                                final token = await FirebaseAuth
                                    .instance.currentUser!
                                    .getIdToken();
                                var uri = HttpClient.photoUri;
                                var request = http.MultipartRequest('POST', uri)
                                  ..headers['Authorization'] = 'Bearer $token'
                                  ..fields['latitude'] =
                                      position.latitude.toString()
                                  ..fields['longitude'] =
                                      position.longitude.toString()
                                  ..files.add(await http.MultipartFile.fromPath(
                                      'photo', snapshot.data!.path,
                                      contentType: MediaType('image', 'jpeg')));
                                var response = await HttpClient.client
                                    .send(request)
                                    .timeout(const Duration(minutes: 1));
                                if (response.statusCode == 200) {
                                  messenger.showSnackBar(
                                      snackBarSuccess("Photo delivered"));
                                } else if (response.statusCode == 403) {
                                  messenger.showSnackBar(snackBarFailure(
                                      "Daily photo count limit reached"));
                                } else {
                                  throw Error();
                                }
                              } catch (_) {
                                messenger.showSnackBar(snackBarFailure(
                                    "Photo could not be delivered"));
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
                messenger
                    .showSnackBar(snackBarFailure("Camera is not available"));
              }
              Navigator.of(context)
                  .restorablePopAndPushNamed(MainView.routeName);
            });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
