import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/src/main_view/main_view.dart' show MainView;

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<StatefulWidget> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  final ImagePicker picker = ImagePicker();
  late Future<XFile> futurePicture = getPicture();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<XFile> getPicture() async {
    final width = MediaQuery.of(context).size.width;
    final response = await picker.retrieveLostData();

    if (!response.isEmpty &&
        response.file != null &&
        response.type == RetrieveType.image) {
      return Future.value(response.file);
    } else {
      return Future.value(
          await picker.pickImage(source: ImageSource.camera, maxWidth: width));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: FutureBuilder<XFile>(
        future: futurePicture,
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
                              futurePicture = getPicture();
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
                            onPressed: () => {},
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
