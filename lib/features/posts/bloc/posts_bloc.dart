import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';
import 'package:maimoon_admin/features/posts/repositories/posts_repository.dart';
import 'dart:io';

// Events
abstract class PostsEvent {}

class LoadPosts extends PostsEvent {}

class CreatePost extends PostsEvent {
  final Post post;
  final File? coverImage;
  CreatePost(this.post, this.coverImage);
}

class UpdatePost extends PostsEvent {
  final String id;
  final Post post;
  final File? coverImage;
  UpdatePost(this.id, this.post, this.coverImage);
}

class DeletePost extends PostsEvent {
  final String id;
  DeletePost(this.id);
}

class UpdatePostOrder extends PostsEvent {
  final String postId;
  final int newOrder;

  UpdatePostOrder({
    required this.postId,
    required this.newOrder,
  });
}

// States
abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}

class PostsError extends PostsState {
  final String message;
  PostsError(this.message);
}

// BLoC
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostsRepository repository;

  PostsBloc({required this.repository}) : super(PostsInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<CreatePost>(_onCreatePost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<UpdatePostOrder>(_onUpdatePostOrder);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    try {
      final posts = await repository.getPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostsState> emit) async {
    try {
      await repository.createPost(event.post, coverImage: event.coverImage);
      add(LoadPosts());
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostsState> emit) async {
    try {
      await repository.updatePost(event.id, event.post,
          coverImage: event.coverImage);
      add(LoadPosts());
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostsState> emit) async {
    try {
      await repository.deletePost(event.id);
      add(LoadPosts());
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> _onUpdatePostOrder(
    UpdatePostOrder event,
    Emitter<PostsState> emit,
  ) async {
    try {
      await repository.updatePostOrder(event.postId, event.newOrder);
      add(LoadPosts()); // Reload posts to get updated order
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }
}
