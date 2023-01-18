import 'package:camera/camera.dart';

class FrontBackCameraController {
  static late List<CameraDescription> _cameras;
  static late CameraDescription _frontCamera;
  static late CameraDescription _backCamera;

  static CameraDescription get frontCamera => _frontCamera;
  static CameraDescription get backCamera => _backCamera;

  static Future<void> loadCameras() async {
    _cameras = await availableCameras();
    _frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
  }
}
