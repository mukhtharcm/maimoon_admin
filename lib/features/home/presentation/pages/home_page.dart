import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:maimoon_admin/features/books/bloc/books_bloc.dart';
import 'package:maimoon_admin/features/posts/presentation/pages/posts_page.dart';
import 'package:maimoon_admin/features/series/presentation/pages/series_page.dart';
import 'package:maimoon_admin/features/books/presentation/pages/books_page.dart';
import 'package:maimoon_admin/features/auth/bloc/auth_bloc.dart';
import 'package:maimoon_admin/features/auth/presentation/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    context.read<PostsBloc>().add(LoadPosts());
    context.read<SeriesBloc>().add(LoadAllSeries());
    context.read<BooksBloc>().add(LoadBooks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Maimoon Admin',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Content Management',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Posts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Series'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SeriesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Books'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BooksPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutEvent());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content Overview',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: isSmallScreen ? double.infinity : 300,
                    child: _StatCard(
                      title: 'Posts',
                      subtitle: 'Total number of posts',
                      icon: Icons.article_rounded,
                      iconColor: theme.colorScheme.primary,
                      value: BlocBuilder<PostsBloc, PostsState>(
                        buildWhen: (previous, current) =>
                            current is PostsLoaded || current is PostsLoading,
                        builder: (context, state) {
                          if (state is PostsLoaded) {
                            return Text(
                              state.posts.length.toString(),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PostsPage()),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isSmallScreen ? double.infinity : 300,
                    child: _StatCard(
                      title: 'Series',
                      subtitle: 'Total number of series',
                      icon: Icons.library_books_rounded,
                      iconColor: theme.colorScheme.secondary,
                      value: BlocBuilder<SeriesBloc, SeriesState>(
                        buildWhen: (previous, current) =>
                            current is SeriesLoaded || current is SeriesLoading,
                        builder: (context, state) {
                          if (state is SeriesLoaded) {
                            return Text(
                              state.seriesList.length.toString(),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SeriesPage()),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isSmallScreen ? double.infinity : 300,
                    child: _StatCard(
                      title: 'Books',
                      subtitle: 'Total number of books',
                      icon: Icons.book_rounded,
                      iconColor: theme.colorScheme.tertiary,
                      value: BlocBuilder<BooksBloc, BooksState>(
                        buildWhen: (previous, current) =>
                            current is BooksLoaded || current is BooksLoading,
                        builder: (context, state) {
                          if (state is BooksLoaded) {
                            return Text(
                              state.books.length.toString(),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BooksPage()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Quick Actions',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ActionButton(
                    title: 'New Post',
                    subtitle: 'Create a new blog post',
                    icon: Icons.post_add_rounded,
                    color: theme.colorScheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PostsPage()),
                    ),
                  ),
                  _ActionButton(
                    title: 'New Series',
                    subtitle: 'Create a new series',
                    icon: Icons.create_new_folder_rounded,
                    color: theme.colorScheme.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SeriesPage()),
                    ),
                  ),
                  _ActionButton(
                    title: 'New Book',
                    subtitle: 'Add a new book',
                    icon: Icons.book_rounded,
                    color: theme.colorScheme.tertiary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BooksPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget value;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(child: value),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 280,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
}
