import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/src/camera/front_back_camera_controller.dart'
    show FrontBackCameraController;
import 'package:provider/provider.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<StatefulWidget> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraDescription frontCamera;
  late CameraDescription backCamera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final frontBackCameraController =
          Provider.of<FrontBackCameraController>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
