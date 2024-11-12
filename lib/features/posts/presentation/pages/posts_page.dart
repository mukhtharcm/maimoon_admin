import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
// import 'package:maimoon_admin/features/series/models/series.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';
import 'package:maimoon_admin/features/series/models/series.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PostsBloc>().add(LoadPosts());
    context.read<SeriesBloc>().add(LoadAllSeries());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Posts'),
        actions: [
          FilledButton.icon(
            onPressed: () => context.go('/posts/new'),
            icon: const Icon(Icons.add),
            label: const Text('New Post'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          if (state is PostsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PostsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is PostsLoaded) {
            if (state.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No posts yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.go('/posts/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create your first post'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return _PostCard(
                  post: post,
                  onEdit: () =>
                      context.go('/posts/edit/${post.id}', extra: post),
                  onDelete: () => _confirmDelete(context, post),
                );
              },
            );
          }
          return const Center(child: Text('No posts found'));
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Post post) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<PostsBloc>().add(DeletePost(post.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.coverUrl != null) ...[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  post.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        icon: const Icon(Icons.delete),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.date != null
                            ? DateFormat.yMMMd().format(post.date!)
                            : 'No date',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (post.seriesId != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.library_books,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<SeriesBloc, SeriesState>(
                          builder: (context, state) {
                            if (state is SeriesLoaded) {
                              final series = state.seriesList.firstWhere(
                                (s) => s.id == post.seriesId,
                                orElse: () =>
                                    Series(id: '', name: 'Unknown Series'),
                              );
                              return Text(
                                series.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ],
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
