import 'package:camera/camera.dart';
import 'package:mobile/src/camera/cameras_service.dart';

class CamerasController {
  static final CamerasService _camerasService = CamerasService();
  static late CameraDescription _camera;
  static late String _cameraString;

  static CameraController get cameraContoller =>
      CameraController(_camera, ResolutionPreset.high);

  static Future<void> loadCameras() async {
    await _camerasService.loadCameras();
    _camera = _camerasService.camera();
  }

  static void toggleCamera() {
    switch (_camera.lensDirection) {
      case CameraLensDirection.front:
        _camera = _camerasService.backCamera;
        _cameraString = "back";
        break;
      default:
        _camera = _camerasService.frontCamera;
        _cameraString = "front";
        break;
    }
  }

  static Future<void> updateCamera() async {
    await _camerasService.updateCamera(_cameraString);
  }
}
