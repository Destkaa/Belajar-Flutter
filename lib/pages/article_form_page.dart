import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/article_model.dart';
import '../services/api_exception.dart';
import '../services/article_service.dart';
import 'camera_capture_page.dart';

class ArticleFormPage extends StatefulWidget {
  /// null = mode tambah, ada isinya = mode edit
  final ArticleModel? article;

  const ArticleFormPage({super.key, this.article});

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleC;
  late final TextEditingController _contentC;
  final _service = ArticleService();
  final _picker = ImagePicker();

  XFile? _pickedImage; // foto baru yang dipilih user
  Uint8List? _pickedBytes; // isi foto untuk preview (aman di web)
  bool _removeExisting = false; // user minta foto lama dibuang
  bool _loading = false;
  bool _picking = false; // mencegah picker dibuka dua kali

  static const Color primaryBlue = Color(0xFF0758ED);
  static const Color inkColor = Color(0xFF151515);
  static const Color mutedColor = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFF0F2F6);
  static const Color errorColor = Color(0xFFD92D20);

  bool get _isEdit => widget.article != null;

  // Foto lama masih dipakai kalau belum diminta dibuang
  String? get _existingUrl =>
      _removeExisting ? null : widget.article?.imageUrl;

  bool get _hasImage => _pickedImage != null || _existingUrl != null;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.article?.title);
    _contentC = TextEditingController(text: widget.article?.content);
    _recoverLostImage();
  }

  @override
  void dispose() {
    _titleC.dispose();
    _contentC.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Pesan
  // ---------------------------------------------------------------------------

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? errorColor : const Color(0xFF12B76A),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Foto
  // ---------------------------------------------------------------------------

  /// Di Android, aktivitas bisa dimatikan sistem saat kamera terbuka
  /// (terutama di HP dengan RAM kecil). Hasil foto lalu hilang dan terlihat
  /// seperti "gagal mengambil foto". Fungsi ini mengambilnya kembali.
  Future<void> _recoverLostImage() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return;

      final file = response.file;
      if (file != null) await _setPicked(file);
    } catch (e) {
      debugPrint('retrieveLostData gagal: $e');
    }
  }

  /// Menyimpan foto terpilih. Dibaca sebagai bytes supaya preview
  /// bekerja di Android, iOS, dan web (Image.file tidak didukung di web).
  Future<void> _setPicked(XFile file) async {
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _pickedImage = file;
      _pickedBytes = bytes;
      _removeExisting = false;
    });
  }

  String _pickErrorMessage(PlatformException e) {
    switch (e.code) {
      case 'camera_access_denied':
        return 'Izin kamera ditolak. Aktifkan di Pengaturan > Aplikasi.';
      case 'photo_access_denied':
        return 'Izin galeri ditolak. Aktifkan di Pengaturan > Aplikasi.';
      case 'already_active':
        return 'Pemilih foto sedang terbuka, coba lagi sebentar.';
      default:
        return 'Gagal mengambil foto (${e.code})';
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (_picking) return;
    _picking = true;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280, // perkecil dimensi
        imageQuality: 80, // kompres kualitas
      );
      if (picked == null) return; // user membatalkan

      await _setPicked(picked);
    } on PlatformException catch (e) {
      debugPrint('pickImage PlatformException: ${e.code} - ${e.message}');
      _showMessage(_pickErrorMessage(e));
    } catch (e, st) {
      debugPrint('pickImage error: $e\n$st');
      _showMessage('Gagal mengambil foto: $e');
    } finally {
      _picking = false;
    }
  }

  /// Di mobile memakai kamera bawaan lewat image_picker. Di web, image_picker
  /// hanya membuka file explorer di browser desktop, jadi dipakai halaman
  /// kamera sendiri (webcam).
  Future<void> _openCamera() async {
    if (!kIsWeb) {
      await _pick(ImageSource.camera);
      return;
    }

    if (_picking) return;
    _picking = true;

    try {
      final shot = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const CameraCapturePage(),
        ),
      );
      if (shot != null) await _setPicked(shot);
    } catch (e, st) {
      debugPrint('openCamera error: $e\n$st');
      _showMessage('Gagal mengambil foto: $e');
    } finally {
      _picking = false;
    }
  }

  void _showSourceSheet() {
    if (_loading) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto sampul',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: inkColor,
                ),
              ),
              const SizedBox(height: 12),
              _SheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Pilih dari galeri',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pick(ImageSource.gallery);
                },
              ),
              _SheetOption(
                icon: Icons.photo_camera_outlined,
                label: 'Ambil dengan kamera',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openCamera();
                },
              ),
              if (_hasImage)
                _SheetOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus foto',
                  color: errorColor,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removeImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _pickedImage = null;
      _pickedBytes = null;
      // Kalau artikel punya foto di server, tandai untuk dihapus
      _removeExisting = widget.article?.imageUrl != null;
    });
  }

  // ---------------------------------------------------------------------------
  // Simpan
  // ---------------------------------------------------------------------------

  String? _validateTitle(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Judul wajib diisi';
    return null;
  }

  String? _validateContent(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Isi artikel wajib diisi';
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final title = _titleC.text.trim();
    final content = _contentC.text.trim();

    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await _service.update(
          widget.article!.id,
          title: title,
          content: content,
          image: _pickedImage,
          removeImage: _removeExisting,
        );
      } else {
        await _service.create(
          title: title,
          content: content,
          image: _pickedImage,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true); // kabari layar sebelumnya: ada perubahan
    } on ApiException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      debugPrint('save artikel error: $e');
      _showMessage('Terjadi kesalahan tak terduga');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Tampilan
  // ---------------------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    bool multiline = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: multiline,
      labelStyle: const TextStyle(fontSize: 13, color: mutedColor),
      floatingLabelStyle: const TextStyle(
        fontSize: 13,
        color: primaryBlue,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA0A6B1)),
      errorStyle: const TextStyle(fontSize: 11.5, color: errorColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: border(const Color(0xFFE5E7EB)),
      disabledBorder: border(const Color(0xFFE5E7EB)),
      focusedBorder: border(primaryBlue, 1.6),
      errorBorder: border(errorColor),
      focusedErrorBorder: border(errorColor, 1.6),
    );
  }

  Widget _buildCoverImage() {
    if (_pickedBytes != null) {
      return Image.memory(
        _pickedBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _brokenImage(),
      );
    }

    return Image.network(
      _existingUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // Di web, pakai elemen <img> HTML supaya tidak terblokir CORS.
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (_, error, __) {
        debugPrint('IMAGE LOAD GAGAL: $_existingUrl -> $error');
        return _brokenImage();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: primaryBlue, strokeWidth: 2.4),
        );
      },
    );
  }

  Widget _brokenImage() {
    return const Center(
      child: Icon(Icons.broken_image_outlined, size: 40, color: mutedColor),
    );
  }

  Widget _buildEmptyCover() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF1FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 26,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tambah foto sampul',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: inkColor,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Opsional, dari galeri atau kamera',
            style: TextStyle(fontSize: 12, color: mutedColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _loading ? null : _showSourceSheet,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hasImage
                    ? Colors.transparent
                    : primaryBlue.withValues(alpha: 0.3),
                width: 1.4,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_hasImage) _buildCoverImage() else _buildEmptyCover(),
                if (_hasImage)
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Row(
                      children: [
                        _OverlayButton(
                          icon: Icons.edit_outlined,
                          label: 'Ganti',
                          onTap: _loading ? null : _showSourceSheet,
                        ),
                        const SizedBox(width: 8),
                        _OverlayButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'Hapus',
                          onTap: _loading ? null : _removeImage,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: primaryBlue.withValues(alpha: 0.7),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  _isEdit ? 'Simpan perubahan' : 'Terbitkan',
                  key: const ValueKey('label'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: inkColor),
          title: Text(
            _isEdit ? 'Edit artikel' : 'Tulis artikel',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: inkColor,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCover(),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleC,
                    enabled: !_loading,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: _validateTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: inkColor,
                    ),
                    cursorColor: primaryBlue,
                    decoration: _inputDecoration(
                      label: 'Judul',
                      hint: 'Tulis judul yang menarik',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentC,
                    enabled: !_loading,
                    minLines: 8,
                    maxLines: 16,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    validator: _validateContent,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.55,
                      color: inkColor,
                    ),
                    cursorColor: primaryBlue,
                    decoration: _inputDecoration(
                      label: 'Isi artikel',
                      hint: 'Ceritakan idemu di sini...',
                      multiline: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF151515),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}