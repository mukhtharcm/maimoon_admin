import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:maimoon_admin/features/posts/presentation/pages/posts_page.dart';
import 'package:maimoon_admin/features/series/presentation/pages/series_page.dart';
import 'package:maimoon_admin/features/tags/presentation/pages/tags_page.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:maimoon_admin/features/tags/bloc/tags_bloc.dart';

class PostFormPage extends StatefulWidget {
  final Post? post;
  final String? initialSeriesId;

  const PostFormPage({
    super.key,
    this.post,
    this.initialSeriesId,
  });

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  late final TextEditingController titleController;
  late final QuillController quillController;
  String? selectedSeriesId;
  late DateTime selectedDate;
  String? coverImagePath;
  List<String> additionalImagePaths = [];
  final _formKey = GlobalKey<FormState>();
  File? selectedCoverImage;
  bool _isSaving = false;
  List<String> selectedTagIds = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post?.title ?? '');

    // Initialize the quill controller
    if (widget.post?.content != null && widget.post!.content.isNotEmpty) {
      try {
        // Parse HTML to Document
        final document = Document.fromHtml(widget.post!.content);
        quillController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        debugPrint('Error parsing content: $e');
        quillController = QuillController.basic();
      }
    } else {
      quillController = QuillController.basic();
    }

    // Use either the post's series ID or the initial series ID
    selectedSeriesId = widget.post?.seriesId ?? widget.initialSeriesId;
    selectedDate = widget.post?.date ?? DateTime.now();
    context.read<SeriesBloc>().add(LoadAllSeries());
    selectedTagIds = widget.post?.tagIds ?? [];
    context.read<TagsBloc>().add(LoadTags());
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSaving
              ? null // Disable back button while saving
              : () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PostsPage()),
                    );
                  }
                },
        ),
        title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
        actions: [
          FilledButton.icon(
            onPressed: _isSaving ? null : _savePost, // Disable while saving
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<SeriesBloc, SeriesState>(
                  builder: (context, state) {
                    if (state is SeriesLoaded) {
                      return DropdownButtonFormField<String>(
                        value: selectedSeriesId,
                        decoration: const InputDecoration(
                          labelText: 'Series',
                          border: OutlineInputBorder(),
                        ),
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
                        onChanged: (value) =>
                            setState(() => selectedSeriesId = value),
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
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
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cover Image',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (selectedCoverImage != null)
                          Image.file(
                            selectedCoverImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else if (widget.post?.coverUrl != null &&
                            widget.post!.coverUrl!.isNotEmpty)
                          Image.network(
                            widget.post!.coverUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text('Choose Image'),
                          onPressed: () async {
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              setState(() {
                                selectedCoverImage = File(image.path);
                                coverImagePath = image.path;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
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
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              controller: quillController,
                              sharedConfigurations:
                                  const QuillSharedConfigurations(
                                locale: Locale('en'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<TagsBloc, TagsState>(
                          builder: (context, state) {
                            if (state is TagsLoaded) {
                              if (state.tags.isEmpty) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No tags available',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const TagsPage(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Create Tags'),
                                    ),
                                  ],
                                );
                              }

                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: state.tags.map((tag) {
                                  final isSelected =
                                      selectedTagIds.contains(tag.id);
                                  return FilterChip(
                                    label: Text(tag.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedTagIds.add(tag.id);
                                        } else {
                                          selectedTagIds.remove(tag.id);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              );
                            }
                            return const LinearProgressIndicator();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _savePost() async {
    if (_formKey.currentState!.validate()) {
      // Validate series selection
      if (selectedSeriesId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a series'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        // Convert Quill Delta to HTML
        final delta = quillController.document.toDelta();
        final converter = QuillDeltaToHtmlConverter(
          delta.toJson(),
          ConverterOptions(
            multiLineBlockquote: true,
            multiLineHeader: true,
            multiLineCodeblock: true,
          ),
        );
        final htmlContent = converter.convert();

        final newPost = Post(
          id: widget.post?.id ?? '',
          title: titleController.text,
          content: htmlContent,
          seriesId: selectedSeriesId,
          date: selectedDate,
          coverFilename: widget.post?.coverFilename,
          coverUrl: widget.post?.coverUrl,
          imageUrls: additionalImagePaths,
          tagIds: selectedTagIds,
        );

        if (widget.post == null) {
          context.read<PostsBloc>().add(
                CreatePost(newPost, selectedCoverImage),
              );
        } else {
          context.read<PostsBloc>().add(
                UpdatePost(widget.post!.id, newPost, selectedCoverImage),
              );
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PostsPage()),
          );
        }
      } catch (e) {
        debugPrint('Error saving post: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving post: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
}
