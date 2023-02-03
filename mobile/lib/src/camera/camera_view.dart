import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/src/camera/cameras_controller.dart'
    show CamerasController;
import 'package:mobile/src/camera/picture_view.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<StatefulWidget> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  late CameraController? controller;
  late Future<void> initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void initCamera() {
    controller = CamerasController.cameraContoller;
    setInitializeControllerFuture();
  }

  void setInitializeControllerFuture() {
    setState(() {
      initializeControllerFuture = controller!.initialize();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (controller == null || !controller!.value.isInitialized) return;

    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      initCamera();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (controller != null) {
        controller?.dispose();
        //controller = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final size = MediaQuery.of(context).size;
            // final screenAspectRatio = MediaQuery.of(context).size.aspectRatio;
            final controllerAspectRatio = controller!.value.aspectRatio;

            // var scale = screenAspectRatio * controllerAspectRatio;
            // if (scale < 1) scale = 1 / scale;

            // return Transform.scale(
            //   scale: scale,
            //   child: Center(child: CameraPreview(controller!)),
            // );
            return AspectRatio(
              aspectRatio: 1 / controller!.value.aspectRatio,
              child: CameraPreview(controller!),
            );
            //final size = MediaQuery.of(context).size;
            // return ClipRect(
            //   child: OverflowBox(
            //     alignment: Alignment.center,
            //     child: FittedBox(
            //       fit: BoxFit.cover,
            //       child: SizedBox(
            //         height: 1,
            //         child: AspectRatio(
            //           aspectRatio: 1 / controller!.value.aspectRatio,
            //           child: CameraPreview(controller!),
            //         ),
            //       ),
            //     ),
            //   ),
            // );
            // return FittedBox(
            //   fit: BoxFit.fitWidth,
            //   child: SizedBox(
            //     width: size.width,
            //     //height: size.width / controller!.value.aspectRatio,
            //     child: CameraPreview(controller!),
            //   ),
            // );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        children: [
          const Spacer(),
          Expanded(
            child: SizedBox(
              width: 80,
              height: 80,
              child: FloatingActionButton(
                heroTag: "take_pic",
                onPressed: () async {
                  try {
                    // Ensure that the camera is initialized.
                    await initializeControllerFuture;

                    // Attempt to take a picture and get the file `image`
                    // where it was saved.
                    final image = await controller!.takePicture();

                    if (!mounted) return;

                    // If the picture was taken, display it on a new screen.
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PictureView(
                          imagePath: image.path,
                        ),
                      ),
                    );
                  } catch (e) {
                    //TODO show snackabr
                    print(e);
                  }
                },
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
          Expanded(
            child: FloatingActionButton(
              heroTag: "toggle_camera",
              onPressed: () async {
                CamerasController.toggleCamera();
                initCamera();
                await CamerasController.updateCamera();
              },
              child: const Icon(Icons.autorenew_rounded),
            ),
          )
        ],
      ),
    );
  }
}
