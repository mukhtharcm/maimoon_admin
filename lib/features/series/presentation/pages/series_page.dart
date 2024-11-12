import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:maimoon_admin/features/series/models/series.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Series'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSeriesDialog(context),
          ),
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
            return ListView.builder(
              itemCount: state.seriesList.length,
              itemBuilder: (context, index) {
                final series = state.seriesList[index];
                return ListTile(
                  title: Text(series.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, series),
                  ),
                  onTap: () => _showEditSeriesDialog(context, series),
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
