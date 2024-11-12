import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
// import 'package:maimoon_admin/features/series/models/series.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditPostDialog(context),
          ),
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
            return ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: post.coverUrl != null
                        ? Image.network(
                            post.coverUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.article),
                    title: Text(post.title),
                    subtitle: Text(
                      post.date != null
                          ? DateFormat.yMMMd().format(post.date!)
                          : 'No date',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditPostDialog(
                            context,
                            post: post,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(context, post),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No posts found'));
        },
      ),
    );
  }

  Future<void> _showAddEditPostDialog(BuildContext context,
      {Post? post}) async {
    final titleController = TextEditingController(text: post?.title ?? '');
    final quillController = QuillController(
      document: post?.content.isNotEmpty == true
          ? Document.fromJson(post!.content as List)
          : Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    String? selectedSeriesId = post?.seriesId;
    DateTime selectedDate = post?.date ?? DateTime.now();
    String? coverImagePath;
    List<String> additionalImagePaths = [];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(post == null ? 'Add Post' : 'Edit Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              BlocBuilder<SeriesBloc, SeriesState>(
                builder: (context, state) {
                  if (state is SeriesLoaded) {
                    return DropdownButtonFormField<String>(
                      value: selectedSeriesId,
                      decoration: const InputDecoration(labelText: 'Series'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No Series'),
                        ),
                        ...state.seriesList.map(
                          (series) => DropdownMenuItem(
                            value: series.id,
                            child: Text(series.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => selectedSeriesId = value,
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Date: ${DateFormat.yMMMd().format(selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Add Cover Image'),
                onPressed: () async {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    coverImagePath = image.path;
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: Column(
                  children: [
                    QuillToolbar.simple(
                      configurations: QuillSimpleToolbarConfigurations(
                        controller: quillController,
                        showDividers: false,
                        showFontFamily: false,
                        showFontSize: false,
                        showBoldButton: true,
                        showItalicButton: true,
                        showSmallButton: false,
                        showUnderLineButton: true,
                        showStrikeThrough: false,
                        showInlineCode: false,
                        showColorButton: false,
                        showBackgroundColorButton: false,
                        showClearFormat: true,
                        showAlignmentButtons: true,
                        showLeftAlignment: true,
                        showCenterAlignment: true,
                        showRightAlignment: true,
                        showJustifyAlignment: true,
                        showHeaderStyle: false,
                        showListNumbers: true,
                        showListBullets: true,
                        showListCheck: false,
                        showCodeBlock: false,
                        showQuote: true,
                        showIndent: true,
                        showLink: true,
                        showUndo: true,
                        showRedo: true,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: QuillEditor.basic(
                          configurations: QuillEditorConfigurations(
                            controller: quillController,
                            // readOnly: false,
                            sharedConfigurations:
                                const QuillSharedConfigurations(
                              locale: Locale('en'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final newPost = Post(
                  id: post?.id ?? '',
                  title: titleController.text,
                  content:
                      jsonEncode(quillController.document.toDelta().toJson()),
                  seriesId: selectedSeriesId,
                  date: selectedDate,
                  coverUrl: coverImagePath ?? post?.coverUrl,
                  imageUrls: additionalImagePaths,
                );

                if (post == null) {
                  context.read<PostsBloc>().add(CreatePost(newPost));
                } else {
                  context.read<PostsBloc>().add(UpdatePost(post.id, newPost));
                }
                Navigator.pop(context);
              }
            },
            child: Text(post == null ? 'Add' : 'Save'),
          ),
        ],
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
