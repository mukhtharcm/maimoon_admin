import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/books/bloc/books_bloc.dart';
import 'package:maimoon_admin/features/books/domain/models/book.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  @override
  void initState() {
    super.initState();
    context.read<BooksBloc>().add(LoadBooks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = (width / 300).floor();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Books'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showAddBookDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('New Book'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<BooksBloc, BooksState>(
        builder: (context, state) {
          if (state is BooksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BooksError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is BooksLoaded) {
            if (state.books.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No books yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first book to get started',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _showAddBookDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Book'),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.7,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: state.books.length,
              itemBuilder: (context, index) {
                final book = state.books[index];
                return _BookCard(
                  book: book,
                  onEdit: () => _showEditBookDialog(context, book),
                  onDelete: () => _confirmDelete(context, book),
                );
              },
            );
          }
          return const Center(child: Text('No books found'));
        },
      ),
    );
  }

  Future<void> _showAddBookDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final pagesController = TextEditingController();
    DateTime? selectedDate;
    File? selectedCoverImage;
    bool isSaving = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add Book',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Cover Image Section
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cover Image',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    if (selectedCoverImage != null) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          selectedCoverImage!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.image),
                                      label: const Text('Choose Cover'),
                                      onPressed: () async {
                                        final image = await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        if (image != null) {
                                          setState(() {
                                            selectedCoverImage =
                                                File(image.path);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
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
                            TextFormField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: priceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Price',
                                      border: OutlineInputBorder(),
                                      prefixText: '₹ ',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a price';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (double.parse(value) < 0) {
                                        return 'Price cannot be negative';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: pagesController,
                                    decoration: const InputDecoration(
                                      labelText: 'Pages',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter pages';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (int.parse(value) <= 0) {
                                        return 'Pages must be greater than 0';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (selectedDate == null)
                              Text(
                                'Please select a publish date',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                selectedDate != null
                                    ? 'Publish Date: ${DateFormat.yMMMd().format(selectedDate!)}'
                                    : 'Select Publish Date',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() => selectedDate = date);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: isSaving
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          if (formKey.currentState!
                                                  .validate() &&
                                              selectedDate != null) {
                                            setState(() => isSaving = true);

                                            final coverBytes =
                                                selectedCoverImage != null
                                                    ? await selectedCoverImage!
                                                        .readAsBytes()
                                                    : null;

                                            context.read<BooksBloc>().add(
                                                  CreateBook(
                                                    title: titleController.text,
                                                    description:
                                                        descriptionController
                                                            .text,
                                                    coverBytes: coverBytes,
                                                    coverName:
                                                        selectedCoverImage?.path
                                                            .split('/')
                                                            .last,
                                                    price: double.parse(
                                                        priceController.text),
                                                    pages: int.parse(
                                                        pagesController.text),
                                                    publishDate: selectedDate,
                                                  ),
                                                );
                                            Navigator.pop(context);
                                          } else if (selectedDate == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please select a publish date'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
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
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              isSaving ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate() &&
                                      selectedDate != null) {
                                    setState(() => isSaving = true);

                                    final coverBytes =
                                        selectedCoverImage != null
                                            ? await selectedCoverImage!
                                                .readAsBytes()
                                            : null;

                                    context.read<BooksBloc>().add(
                                          CreateBook(
                                            title: titleController.text,
                                            description:
                                                descriptionController.text,
                                            coverBytes: coverBytes,
                                            coverName: selectedCoverImage?.path
                                                .split('/')
                                                .last,
                                            price: double.parse(
                                                priceController.text),
                                            pages:
                                                int.parse(pagesController.text),
                                            publishDate: selectedDate,
                                          ),
                                        );
                                    Navigator.pop(context);
                                  } else if (selectedDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please select a publish date'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditBookDialog(BuildContext context, Book book) async {
    final titleController = TextEditingController(text: book.title);
    final descriptionController = TextEditingController(text: book.description);
    final priceController = TextEditingController(
      text: book.price?.toString() ?? '',
    );
    final pagesController = TextEditingController(
      text: book.pages?.toString() ?? '',
    );
    DateTime? selectedDate = book.publishDate;
    File? selectedCoverImage;
    bool isSaving = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Book',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cover Image',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (selectedCoverImage != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        selectedCoverImage!,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else if (book.coverUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        book.coverUrl!,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.image),
                                    label: const Text('Change Cover'),
                                    onPressed: () async {
                                      final image = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      if (image != null) {
                                        setState(() {
                                          selectedCoverImage = File(image.path);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                    border: OutlineInputBorder(),
                                    prefixText: '₹ ',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: pagesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Pages',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              selectedDate != null
                                  ? 'Publish Date: ${DateFormat.yMMMd().format(selectedDate!)}'
                                  : 'Select Publish Date',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => selectedDate = date);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (titleController.text.isNotEmpty) {
                                  setState(() => isSaving = true);

                                  final coverBytes = selectedCoverImage != null
                                      ? await selectedCoverImage!.readAsBytes()
                                      : null;

                                  context.read<BooksBloc>().add(
                                        UpdateBook(
                                          id: book.id,
                                          title: titleController.text,
                                          description:
                                              descriptionController.text,
                                          coverBytes: coverBytes,
                                          coverName: selectedCoverImage?.path
                                              .split('/')
                                              .last,
                                          price: double.tryParse(
                                              priceController.text),
                                          pages: int.tryParse(
                                              pagesController.text),
                                          publishDate: selectedDate,
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
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Book book) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
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
              context.read<BooksBloc>().add(DeleteBook(book.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookCard({
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: book.coverUrl != null
                  ? Image.network(
                      book.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder(theme);
                      },
                    )
                  : _buildPlaceholder(theme),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (book.price != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '₹${book.price!.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.book,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
