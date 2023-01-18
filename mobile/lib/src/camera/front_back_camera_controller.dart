import 'package:camera/camera.dart';

class FrontBackCameraController {
  late List<CameraDescription> _cameras;
  late CameraDescription _frontCamera;
  late CameraDescription _backCamera;

  CameraDescription get frontCamera => _frontCamera;
  CameraDescription get backCamera => _backCamera;

  Future<void> loadCameras() async {
    _cameras = await availableCameras();
    _frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
  }
}
