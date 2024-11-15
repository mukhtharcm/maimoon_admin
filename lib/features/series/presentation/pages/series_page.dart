import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';
import 'package:maimoon_admin/features/posts/presentation/pages/post_form_page.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:maimoon_admin/features/series/models/series.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
          onPressed: () => Navigator.pop(context),
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
    final descriptionController = TextEditingController();
    File? selectedImage;
    bool isSaving = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add Series',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Series Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              StatefulBuilder(
                                builder: (context, setState) => Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (selectedImage != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          selectedImage!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.image),
                                      label: const Text('Choose Image'),
                                      onPressed: () async {
                                        final image = await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        if (image != null) {
                                          setState(() {
                                            selectedImage = File(image.path);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                isSaving ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (nameController.text.isNotEmpty) {
                                      setState(() {
                                        isSaving = true;
                                      });
                                      context.read<SeriesBloc>().add(
                                            CreateSeries(
                                              Series(
                                                id: '',
                                                name: nameController.text,
                                                description:
                                                    descriptionController.text,
                                              ),
                                              selectedImage,
                                            ),
                                          );
                                      Navigator.pop(context);
                                    }
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSaving)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                Text(isSaving ? 'Saving...' : 'Add'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSaving)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditSeriesDialog(
      BuildContext context, Series series) async {
    final nameController = TextEditingController(text: series.name);
    final descriptionController =
        TextEditingController(text: series.description);
    File? selectedImage;
    bool isSaving = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Edit Series',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Series Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              StatefulBuilder(
                                builder: (context, setState) => Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (selectedImage != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          selectedImage!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else if (series.imageUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          series.imageUrl!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.image),
                                      label: const Text('Choose Image'),
                                      onPressed: () async {
                                        final image = await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        if (image != null) {
                                          setState(() {
                                            selectedImage = File(image.path);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                isSaving ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (nameController.text.isNotEmpty) {
                                      setState(() {
                                        isSaving = true;
                                      });
                                      context.read<SeriesBloc>().add(
                                            UpdateSeries(
                                              series.id,
                                              Series(
                                                id: series.id,
                                                name: nameController.text,
                                                description:
                                                    descriptionController.text,
                                                imageFilename:
                                                    series.imageFilename,
                                                imageUrl: series.imageUrl,
                                              ),
                                              selectedImage,
                                            ),
                                          );
                                      Navigator.pop(context);
                                    }
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSaving)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                Text(isSaving ? 'Saving...' : 'Save'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSaving)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostFormPage(
                        initialSeriesId: series.id,
                      ),
                    ),
                  ),
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
                        // Adjust newIndex if moving downwards
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }

                        // Get the reordered posts list
                        final posts = List<Post>.from(seriesPosts);
                        final item = posts.removeAt(oldIndex);
                        posts.insert(newIndex, item);

                        // Update order numbers
                        for (var i = 0; i < posts.length; i++) {
                          final post = posts[i];
                          if (post.order != i + 1) {
                            context.read<PostsBloc>().add(
                                  UpdatePostOrder(
                                    postId: post.id,
                                    newOrder: i + 1,
                                  ),
                                );
                          }
                        }
                      },
                      itemBuilder: (context, index) {
                        final post = seriesPosts[index];
                        return Padding(
                          key: Key(post.id),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
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
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(post.title),
                              trailing: const Icon(Icons.drag_handle),
                            ),
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
