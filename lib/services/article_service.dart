import 'package:image_picker/image_picker.dart';

import '../constant/api_constant.dart';
import '../models/article_model.dart';
import 'api_client.dart';

class ArticleService {
  final ApiClient _api = ApiClient();

  // READ: mengambil semua artikel
  Future<List<ArticleModel>> getAll() async {
    final body = await _api.request(
      'GET',
      ApiConstants.articles,
    );

    final list = body['data'] as List;

    return list
        .map((item) => ArticleModel.fromJson(item))
        .toList();
  }

  // CREATE: menambahkan artikel, dengan atau tanpa foto
  Future<ArticleModel> create({
    required String title,
    required String content,
    XFile? image,
  }) async {
    final body = await _api.multipart(
      ApiConstants.articles,
      fields: {
        'title': title,
        'content': content,
      },
      file: image,
    );

    return ArticleModel.fromJson(body['data']);
  }

  // UPDATE: mengubah artikel dan opsional mengganti atau menghapus foto
  Future<ArticleModel> update(
    int id, {
    required String title,
    required String content,
    XFile? image,
    bool removeImage = false,
  }) async {
    final fields = <String, String>{
      '_method': 'PUT',
      'title': title,
      'content': content,
    };

    // Hanya kirim flag hapus jika tidak ada foto baru yang dipilih.
    if (removeImage && image == null) {
      fields['remove_image'] = '1';
    }

    final body = await _api.multipart(
      '${ApiConstants.articles}/$id',
      fields: fields,
      file: image,
    );

    return ArticleModel.fromJson(body['data']);
  }

  // DELETE: menghapus artikel
  Future<void> delete(int id) async {
    await _api.request(
      'DELETE',
      '${ApiConstants.articles}/$id',
    );
  }
}