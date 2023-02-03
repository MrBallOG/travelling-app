import 'package:camera/camera.dart';
import 'package:mobile/src/storage/local_storage.dart';

class CamerasService {
  late CameraDescription _frontCamera;
  late CameraDescription _backCamera;

  CameraDescription get frontCamera => _frontCamera;
  CameraDescription get backCamera => _backCamera;

  Future<void> loadCameras() async {
    final cameras = await availableCameras();

    _frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
  }

  CameraDescription camera() {
    final cameraString = LocalStorage.storage.getString("camera");

    switch (cameraString) {
      case "front":
        return _frontCamera;
      default:
        return _backCamera;
    }
  }

  // downgrade camera package!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  Future<void> updateCamera(String cameraString) async {
    await LocalStorage.storage.setString("camera", cameraString);
  }
}
