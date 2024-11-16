import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:maimoon_admin/features/series/models/series.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SeriesFormPage extends StatefulWidget {
  final Series? series;

  const SeriesFormPage({super.key, this.series});

  @override
  State<SeriesFormPage> createState() => _SeriesFormPageState();
}

class _SeriesFormPageState extends State<SeriesFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.series?.name ?? '';
    _descriptionController.text = widget.series?.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
        title: Text(widget.series == null ? 'New Series' : 'Edit Series'),
        actions: [
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveSeries,
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
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (widget.series?.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.series!.imageUrl!,
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
                            .pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _selectedImage = File(image.path);
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
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
          ],
        ),
      ),
    );
  }

  Future<void> _saveSeries() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final series = Series(
          id: widget.series?.id ?? '',
          name: _nameController.text,
          description: _descriptionController.text,
        );

        if (widget.series == null) {
          context.read<SeriesBloc>().add(
                CreateSeries(series, _selectedImage),
              );
        } else {
          context.read<SeriesBloc>().add(
                UpdateSeries(widget.series!.id, series, _selectedImage),
              );
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving series: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}
