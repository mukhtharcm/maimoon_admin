import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/books/bloc/books_bloc.dart';
import 'package:maimoon_admin/features/books/domain/models/book.dart';
import 'package:maimoon_admin/features/auth/models/user.dart';
import 'package:maimoon_admin/features/auth/repositories/users_repository.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

class BookFormPage extends StatefulWidget {
  final Book? book;

  const BookFormPage({super.key, this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _pagesController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedCoverImage;
  String? _selectedAuthorId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.book?.title ?? '';
    _descriptionController.text = widget.book?.description ?? '';
    _priceController.text = widget.book?.price?.toString() ?? '';
    _pagesController.text = widget.book?.pages?.toString() ?? '';
    _selectedDate = widget.book?.publishDate;
    _selectedAuthorId = widget.book?.authorId?.isNotEmpty == true
        ? widget.book?.authorId
        : getIt<PocketBase>().authStore.model?.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _pagesController.dispose();
    super.dispose();
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
        title: Text(widget.book == null ? 'New Book' : 'Edit Book'),
        actions: [
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveBook,
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cover Image',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedCoverImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedCoverImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (widget.book?.coverUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.book!.coverUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Choose Cover'),
                      onPressed: () async {
                        final image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _selectedCoverImage = File(image.path);
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
              controller: _titleController,
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
              controller: _descriptionController,
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
            FutureBuilder<List<User>>(
              future: getIt<UsersRepository>().getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error loading authors',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                return DropdownButtonFormField<String>(
                  value: _selectedAuthorId,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Select Author'),
                    ),
                    ...users.map(
                      (user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedAuthorId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an author';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
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
                    controller: _pagesController,
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
            if (_selectedDate == null)
              Text(
                'Please select a publish date',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _selectedDate != null
                    ? 'Publish Date: ${DateFormat.yMMMd().format(_selectedDate!)}'
                    : 'Select Publish Date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isSaving = true);

      try {
        final book = Book(
          id: widget.book?.id ?? '',
          title: _titleController.text,
          description: _descriptionController.text,
          authorId: _selectedAuthorId,
          price: double.parse(_priceController.text),
          pages: int.parse(_pagesController.text),
          publishDate: _selectedDate,
        );

        if (widget.book == null) {
          context.read<BooksBloc>().add(
                CreateBook(
                  title: book.title,
                  description: book.description,
                  coverBytes: _selectedCoverImage != null
                      ? await _selectedCoverImage!.readAsBytes()
                      : null,
                  coverName: _selectedCoverImage?.path.split('/').last,
                  authorId: book.authorId,
                  price: book.price,
                  pages: book.pages,
                  publishDate: book.publishDate,
                ),
              );
        } else {
          context.read<BooksBloc>().add(
                UpdateBook(
                  id: widget.book!.id,
                  title: book.title,
                  description: book.description,
                  coverBytes: _selectedCoverImage != null
                      ? await _selectedCoverImage!.readAsBytes()
                      : null,
                  coverName: _selectedCoverImage?.path.split('/').last,
                  authorId: book.authorId,
                  price: book.price,
                  pages: book.pages,
                  publishDate: book.publishDate,
                ),
              );
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving book: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a publish date'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
