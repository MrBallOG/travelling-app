import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/src/camera/front_back_camera_controller.dart'
    show FrontBackCameraController;
import 'package:mobile/src/camera/picture_view.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<StatefulWidget> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  late CameraDescription frontCamera;
  late CameraDescription backCamera;
  late CameraController? controller;
  late Future<void> initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    frontCamera = FrontBackCameraController.frontCamera;
    backCamera = FrontBackCameraController.backCamera;
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
    controller = CameraController(backCamera, ResolutionPreset.veryHigh);
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
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

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
            return CameraPreview(controller!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}
