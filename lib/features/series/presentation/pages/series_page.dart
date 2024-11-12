import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:maimoon_admin/features/series/models/series.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:intl/intl.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<SeriesBloc>().add(LoadAllSeries());
    context.read<PostsBloc>().add(LoadPosts());
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
        title: const Text('Series'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showAddSeriesDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('New Series'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<SeriesBloc, SeriesState>(
        builder: (context, state) {
          if (state is SeriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SeriesError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is SeriesLoaded) {
            if (state.seriesList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No series yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showAddSeriesDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create your first series'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.seriesList.length,
              itemBuilder: (context, index) {
                final series = state.seriesList[index];
                return _SeriesCard(
                  series: series,
                  onEdit: () => _showEditSeriesDialog(context, series),
                  onDelete: () => _confirmDelete(context, series),
                );
              },
            );
          }
          return const Center(child: Text('No series found'));
        },
      ),
    );
  }

  Future<void> _showAddSeriesDialog(BuildContext context) async {
    final nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Series'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Series Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<SeriesBloc>().add(
                      CreateSeries(
                        Series(id: '', name: nameController.text),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSeriesDialog(
      BuildContext context, Series series) async {
    final nameController = TextEditingController(text: series.name);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Series'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Series Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<SeriesBloc>().add(
                      UpdateSeries(
                        series.id,
                        Series(id: series.id, name: nameController.text),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Series series) async {
    final postsBloc = context.read<PostsBloc>();
    final postsState = postsBloc.state;

    if (postsState is PostsLoaded) {
      final seriesPosts =
          postsState.posts.where((post) => post.seriesId == series.id).toList();

      if (seriesPosts.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete series with existing posts.'),
          ),
        );
        return;
      }
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Series'),
        content: Text('Are you sure you want to delete "${series.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<SeriesBloc>().add(DeleteSeries(series.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  final Series series;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SeriesCard({
    required this.series,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              series.name,
              style: theme.textTheme.titleLarge,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () =>
                      context.go('/posts/new', extra: {'seriesId': series.id}),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Post'),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context, series),
                ),
              ],
            ),
          ),
          BlocBuilder<PostsBloc, PostsState>(
            builder: (context, state) {
              if (state is PostsLoaded) {
                final seriesPosts = state.posts
                    .where((post) => post.seriesId == series.id)
                    .toList()
                  ..sort((a, b) => a.order.compareTo(b.order));

                if (seriesPosts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No posts in this series yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        'Posts',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: seriesPosts.length,
                      onReorder: (oldIndex, newIndex) {
                        // TODO: Implement reordering logic
                      },
                      itemBuilder: (context, index) {
                        final post = seriesPosts[index];
                        return ListTile(
                          key: Key(post.id),
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                post.order.toString(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                          title: Text(post.title),
                          subtitle: Text(
                            post.date != null
                                ? DateFormat.yMMMd().format(post.date!)
                                : 'No date',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: const Icon(Icons.drag_handle),
                          onTap: () => context.go(
                            '/posts/edit/${post.id}',
                            extra: post,
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Series series) async {
    final postsBloc = context.read<PostsBloc>();
    final postsState = postsBloc.state;

    if (postsState is PostsLoaded) {
      final seriesPosts =
          postsState.posts.where((post) => post.seriesId == series.id).toList();

      if (seriesPosts.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete series with existing posts.'),
          ),
        );
        return;
      }
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Series'),
        content: Text('Are you sure you want to delete "${series.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<SeriesBloc>().add(DeleteSeries(series.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
