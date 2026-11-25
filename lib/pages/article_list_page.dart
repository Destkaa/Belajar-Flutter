import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/api_exception.dart';
import '../services/article_service.dart';
import '../services/auth_service.dart';
import 'article_form_page.dart';
import 'login_page.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final _auth = AuthService();
  final _articleService = ArticleService();
  late Future<List<ArticleModel>> _futureArticles;

  static const Color primaryBlue = Color(0xFF0758ED);
  static const Color inkColor = Color(0xFF151515);
  static const Color mutedColor = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFF0F2F6);
  static const Color errorColor = Color(0xFFD92D20);

  @override
  void initState() {
    super.initState();
    _futureArticles = _articleService.getAll();
  }

  // ---------------------------------------------------------------------------
  // Logic
  // ---------------------------------------------------------------------------

  void _reload() {
    setState(() {
      _futureArticles = _articleService.getAll();
    });
  }

  Future<void> _refresh() async {
    _reload();
    try {
      await _futureArticles;
    } catch (_) {
      // error sudah ditampilkan oleh FutureBuilder
    }
  }

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

  // Buka form. Tanpa parameter = tambah, dengan artikel = edit.
  Future<void> _openForm([ArticleModel? article]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ArticleFormPage(article: article)),
    );
    if (changed == true && mounted) _reload();
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: mutedColor, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: mutedColor, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                color: errorColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _delete(ArticleModel article) async {
    final confirmed = await _confirm(
      title: 'Hapus artikel?',
      message: '"${article.title}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
    );
    if (!confirmed) return;

    try {
      await _articleService.delete(article.id);
      if (!mounted) return;
      _showMessage('Artikel dihapus', isError: false);
      _reload();
    } on ApiException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Terjadi kesalahan tak terduga');
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await _confirm(
      title: 'Keluar dari akun?',
      message: 'Anda perlu login lagi untuk mengakses artikel.',
      confirmLabel: 'Logout',
    );
    if (confirmed) await _logout();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (_) => false,
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildTopBar(int? count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 18, 12),
      child: Row(
        children: [
          // Tombol kembali, muncul kalau halaman ini dibuka dari dashboard.
          if (Navigator.of(context).canPop()) ...[
            IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: inkColor,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Artikel Saya',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: inkColor,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    count == 0 ? 'Belum ada tulisan' : '$count tulisan',
                    style: const TextStyle(fontSize: 13, color: mutedColor),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _confirmLogout,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              fixedSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20, color: inkColor),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? url) {
    const size = 88.0;

    Widget placeholder(IconData icon) => Container(
          width: size,
          height: size,
          color: const Color(0xFFEAF1FF),
          child: Icon(icon, size: 28, color: primaryBlue),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: url == null
          ? placeholder(Icons.article_outlined)
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Di web, pakai elemen <img> HTML supaya tidak terblokir CORS
              // (CanvasKit butuh header CORS untuk gambar, <img> tidak).
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, error, __) {
                debugPrint('IMAGE LOAD GAGAL: $url -> $error');
                return placeholder(Icons.broken_image_outlined);
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  color: const Color(0xFFF1F3F7),
                );
              },
            ),
    );
  }

  Widget _buildArticleCard(ArticleModel a) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openForm(a),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B2A4E).withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(a.imageUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: inkColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Hapus',
                onPressed: () => _delete(a),
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    Widget block() => Container(
          height: 112,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
        );

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [block(), block(), block(), block()],
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    List<Widget> actions = const [],
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 72, 32, 32),
      children: [
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: color),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: inkColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, height: 1.5, color: mutedColor),
        ),
        if (actions.isNotEmpty) const SizedBox(height: 24),
        ...actions,
      ],
    );
  }

  Widget _buildError(Object error) {
    final message = error is ApiException
        ? error.message
        : 'Gagal memuat artikel. Periksa koneksi internet Anda.';

    return _buildMessageState(
      icon: Icons.cloud_off_rounded,
      color: errorColor,
      title: 'Artikel tidak bisa dimuat',
      message: message,
      actions: [
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(
              'Coba lagi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _logout,
          child: const Text(
            'Kembali ke login',
            style: TextStyle(color: mutedColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return _buildMessageState(
      icon: Icons.edit_note_rounded,
      color: primaryBlue,
      title: 'Belum ada artikel',
      message: 'Mulai tulis artikel pertamamu dengan menekan tombol Tulis.',
    );
  }

  Widget _buildList(List<ArticleModel> articles) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      // Ruang ekstra di bawah agar item terakhir tidak tertutup tombol Tulis.
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _buildArticleCard(articles[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tulis',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ArticleModel>>(
          future: _futureArticles,
          builder: (context, snap) {
            final loading = snap.connectionState == ConnectionState.waiting;
            final count = snap.hasData ? snap.data!.length : null;

            Widget body;
            if (loading) {
              body = _buildLoading();
            } else if (snap.hasError) {
              body = RefreshIndicator(
                color: primaryBlue,
                onRefresh: _refresh,
                child: _buildError(snap.error!),
              );
            } else {
              final articles = snap.data ?? const <ArticleModel>[];
              body = RefreshIndicator(
                color: primaryBlue,
                onRefresh: _refresh,
                child: articles.isEmpty ? _buildEmpty() : _buildList(articles),
              );
            }

            return Column(
              children: [
                _buildTopBar(count),
                Expanded(child: body),
              ],
            );
          },
        ),
      ),
    );
  }
}