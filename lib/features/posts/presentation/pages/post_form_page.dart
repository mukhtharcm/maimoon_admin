import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class PostFormPage extends StatefulWidget {
  final Post? post;

  const PostFormPage({super.key, this.post});

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

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post?.title ?? '');

    // Initialize the quill controller
    if (widget.post?.content != null && widget.post!.content.isNotEmpty) {
      try {
        // If content is HTML, convert it to Delta
        final document = Document()..insert(0, widget.post!.content);
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

    selectedSeriesId = widget.post?.seriesId;
    selectedDate = widget.post?.date ?? DateTime.now();
    context.read<SeriesBloc>().add(LoadAllSeries());
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
          onPressed: () => context.go('/posts'),
        ),
        title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
        actions: [
          FilledButton.icon(
            onPressed: _savePost,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
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
                    else if (widget.post?.coverUrl != null)
                      Image.network(
                        widget.post!.coverUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                          sharedConfigurations: const QuillSharedConfigurations(
                            locale: Locale('en'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePost() async {
    if (_formKey.currentState!.validate()) {
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
        coverUrl: widget.post?.coverUrl,
        imageUrls: additionalImagePaths,
      );

      try {
        if (widget.post == null) {
          context.read<PostsBloc>().add(
                CreatePost(newPost, selectedCoverImage),
              );
        } else {
          context.read<PostsBloc>().add(
                UpdatePost(widget.post!.id, newPost, selectedCoverImage),
              );
        }

        context.go('/posts');
      } catch (e) {
        debugPrint('Error saving post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving post: $e')),
        );
      }
    }
  }
}
