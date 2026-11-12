
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import 'user_detail_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _api = UserService();
  late Future<List<User>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = _api.fetchUsers(); // dipanggil sekali saat layar dibuat
  }

  // Dipakai tombol refresh dan tombol "Coba lagi"
  void _reload() {
    setState(() {
      _futureUsers = _api.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          // Kondisi 1: error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Kondisi 2: masih loading
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kondisi 3: data siap
          final users = snapshot.data!;

          if (users.isEmpty) {
            return const Center(child: Text('Belum ada data'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final user = users[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${user.id}')),
                  title: Text(
                    user.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    user.email,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailPage(user: user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
