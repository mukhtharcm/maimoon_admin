import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/tags/models/tag.dart';
import 'package:maimoon_admin/features/tags/repositories/tags_repository.dart';

// Events
abstract class TagsEvent {}

class LoadTags extends TagsEvent {}

class CreateTag extends TagsEvent {
  final Tag tag;
  CreateTag(this.tag);
}

class UpdateTag extends TagsEvent {
  final String id;
  final Tag tag;
  UpdateTag(this.id, this.tag);
}

class DeleteTag extends TagsEvent {
  final String id;
  DeleteTag(this.id);
}

// States
abstract class TagsState {}

class TagsInitial extends TagsState {}

class TagsLoading extends TagsState {}

class TagsLoaded extends TagsState {
  final List<Tag> tags;
  TagsLoaded(this.tags);
}

class TagsError extends TagsState {
  final String message;
  TagsError(this.message);
}

// BLoC
class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final TagsRepository repository;

  TagsBloc({required this.repository}) : super(TagsInitial()) {
    on<LoadTags>(_onLoadTags);
    on<CreateTag>(_onCreateTag);
    on<UpdateTag>(_onUpdateTag);
    on<DeleteTag>(_onDeleteTag);
  }

  Future<void> _onLoadTags(LoadTags event, Emitter<TagsState> emit) async {
    emit(TagsLoading());
    try {
      final tags = await repository.getAllTags();
      emit(TagsLoaded(tags));
    } catch (e) {
      emit(TagsError(e.toString()));
    }
  }

  Future<void> _onCreateTag(CreateTag event, Emitter<TagsState> emit) async {
    try {
      await repository.createTag(event.tag);
      add(LoadTags());
    } catch (e) {
      emit(TagsError(e.toString()));
    }
  }

  Future<void> _onUpdateTag(UpdateTag event, Emitter<TagsState> emit) async {
    try {
      await repository.updateTag(event.id, event.tag);
      add(LoadTags());
    } catch (e) {
      emit(TagsError(e.toString()));
    }
  }

  Future<void> _onDeleteTag(DeleteTag event, Emitter<TagsState> emit) async {
    try {
      await repository.deleteTag(event.id);
      add(LoadTags());
    } catch (e) {
      emit(TagsError(e.toString()));
    }
  }
}
