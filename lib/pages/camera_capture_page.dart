import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;

/// Halaman kamera penuh layar. Mengembalikan [XFile] lewat Navigator.pop
/// saat foto diambil, atau null kalau ditutup.
///
/// Dipakai di web/desktop karena `ImageSource.camera` dari image_picker
/// di browser desktop hanya membuka file explorer.
class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  static const Color primaryBlue = Color(0xFF0758ED);

  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = 0;

  bool _initializing = true;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException('noCamera', 'Kamera tidak ditemukan');
      }
      await _startCamera(_cameraIndex);
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code} - ${e.description}');
      if (mounted) setState(() => _error = _messageFor(e));
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) setState(() => _error = 'Kamera tidak bisa dibuka: $e');
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _startCamera(int index) async {
    // Lepas controller lama dari widget tree dulu, baru di-dispose.
    // Kalau di-dispose saat CameraPreview masih memakainya, muncul error
    // "CameraController used after being disposed".
    final old = _controller;
    if (old != null) {
      setState(() => _controller = null);
      await WidgetsBinding.instance.endOfFrame;
      await old.dispose();
    }

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium, // cukup tajam, ukuran file tetap ringan
      enableAudio: false,
    );

    try {
      await controller.initialize();
    } catch (_) {
      await controller.dispose();
      rethrow;
    }

    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  String _messageFor(CameraException e) {
    switch (e.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        return 'Izin kamera ditolak. Klik ikon gembok di address bar '
            'browser, izinkan Kamera, lalu coba lagi.';
      case 'noCamera':
      case 'cameraNotFound':
        return 'Kamera tidak ditemukan di perangkat ini.';
      case 'CameraNotReadable':
      case 'cameraNotReadable':
        return 'Kamera sedang dipakai aplikasi lain.';
      default:
        return 'Kamera tidak bisa dibuka (${e.code}). ${e.description ?? ''}';
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _initializing) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() => _initializing = true);
    try {
      await _startCamera(_cameraIndex);
    } on CameraException catch (e) {
      debugPrint('Camera switch error: ${e.code} - ${e.description}');
      if (mounted) setState(() => _error = _messageFor(e));
    } catch (e) {
      debugPrint('Camera switch error: $e');
      if (mounted) setState(() => _error = 'Kamera tidak bisa dibuka: $e');
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _capturing) {
      return;
    }

    setState(() => _capturing = true);
    try {
      final XFile shot = await controller.takePicture();
      if (mounted) Navigator.pop(context, shot);
    } catch (e) {
      debugPrint('takePicture error: $e');
      if (mounted) {
        setState(() => _capturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil foto, coba lagi')),
        );
      }
    }
  }

  Widget _buildPreview() {
    final controller = _controller;

    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
      );
    }

    if (_error != null || controller == null || !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                size: 48,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Kamera belum siap',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _setup,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Coba lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = !_initializing &&
        _error == null &&
        (_controller?.value.isInitialized ?? false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildPreview()),

            // Tombol tutup
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                tooltip: 'Tutup',
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                ),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),

            // Kontrol bawah
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 56),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: ready ? _capture : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ready
                              ? (_capturing ? Colors.white70 : Colors.white)
                              : Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 56,
                    child: _cameras.length > 1
                        ? IconButton(
                            tooltip: 'Ganti kamera',
                            onPressed: _switchCamera,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.5),
                              fixedSize: const Size(56, 56),
                            ),
                            icon: const Icon(
                              Icons.cameraswitch_outlined,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}