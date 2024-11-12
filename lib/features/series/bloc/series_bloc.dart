import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/series/models/series.dart';
import 'package:maimoon_admin/features/series/repositories/series_repository.dart';

// Events
abstract class SeriesEvent {}

class LoadAllSeries extends SeriesEvent {}

class CreateSeries extends SeriesEvent {
  final Series series;
  CreateSeries(this.series);
}

class UpdateSeries extends SeriesEvent {
  final String id;
  final Series series;
  UpdateSeries(this.id, this.series);
}

class DeleteSeries extends SeriesEvent {
  final String id;
  DeleteSeries(this.id);
}

// States
abstract class SeriesState {}

class SeriesInitial extends SeriesState {}

class SeriesLoading extends SeriesState {}

class SeriesLoaded extends SeriesState {
  final List<Series> seriesList;
  SeriesLoaded(this.seriesList);
}

class SeriesError extends SeriesState {
  final String message;
  SeriesError(this.message);
}

// BLoC
class SeriesBloc extends Bloc<SeriesEvent, SeriesState> {
  final SeriesRepository repository;

  SeriesBloc({required this.repository}) : super(SeriesInitial()) {
    on<LoadAllSeries>(_onLoadAllSeries);
    on<CreateSeries>(_onCreateSeries);
    on<UpdateSeries>(_onUpdateSeries);
    on<DeleteSeries>(_onDeleteSeries);
  }

  Future<void> _onLoadAllSeries(
      LoadAllSeries event, Emitter<SeriesState> emit) async {
    emit(SeriesLoading());
    try {
      final seriesList = await repository.getAllSeries();
      emit(SeriesLoaded(seriesList));
    } catch (e) {
      emit(SeriesError(e.toString()));
    }
  }

  Future<void> _onCreateSeries(
      CreateSeries event, Emitter<SeriesState> emit) async {
    try {
      await repository.createSeries(event.series);
      add(LoadAllSeries());
    } catch (e) {
      emit(SeriesError(e.toString()));
    }
  }

  Future<void> _onUpdateSeries(
      UpdateSeries event, Emitter<SeriesState> emit) async {
    try {
      await repository.updateSeries(event.id, event.series);
      add(LoadAllSeries());
    } catch (e) {
      emit(SeriesError(e.toString()));
    }
  }

  Future<void> _onDeleteSeries(
      DeleteSeries event, Emitter<SeriesState> emit) async {
    try {
      await repository.deleteSeries(event.id);
      add(LoadAllSeries());
    } catch (e) {
      emit(SeriesError(e.toString()));
    }
  }
}
