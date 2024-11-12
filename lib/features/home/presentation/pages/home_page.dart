import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maimoon Admin'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Maimoon Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Posts'),
              onTap: () => context.go('/posts'),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Series'),
              onTap: () => context.go('/series'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Maimoon Admin',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/posts'),
                  icon: const Icon(Icons.article),
                  label: const Text('Manage Posts'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/series'),
                  icon: const Icon(Icons.library_books),
                  label: const Text('Manage Series'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
