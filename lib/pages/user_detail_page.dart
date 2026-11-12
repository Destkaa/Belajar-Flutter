
import 'package:flutter/material.dart';

import '../models/user.dart';

class UserDetailPage extends StatelessWidget {
  final User user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User #${user.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Username: ${user.username}'),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
            const SizedBox(height: 8),
            Text('Phone: ${user.phone}'),
            const SizedBox(height: 8),
            Text('Website: ${user.website}'),
            const SizedBox(height: 24),
            Text(
              'Alamat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('${user.address.street}, ${user.address.suite}'),
            Text('${user.address.city}, ${user.address.zipcode}'),
            const SizedBox(height: 24),
            Text(
              'Perusahaan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(user.company.name),
            Text(user.company.catchPhrase),
            Text(user.company.bs),
          ],
        ),
      ),
    );
  }
}
