import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/features/books/domain/models/book.dart';
import 'package:maimoon_admin/features/books/repositories/books_repository.dart';

// Events
abstract class BooksEvent {}

class LoadBooks extends BooksEvent {}

class CreateBook extends BooksEvent {
  final String title;
  final String? description;
  final Uint8List? coverBytes;
  final String? coverName;
  final String? authorId;
  final double? price;
  final int? pages;
  final DateTime? publishDate;

  CreateBook({
    required this.title,
    this.description,
    this.coverBytes,
    this.coverName,
    this.authorId,
    this.price,
    this.pages,
    this.publishDate,
  });
}

class UpdateBook extends BooksEvent {
  final String id;
  final String? title;
  final String? description;
  final Uint8List? coverBytes;
  final String? coverName;
  final String? authorId;
  final double? price;
  final int? pages;
  final DateTime? publishDate;

  UpdateBook({
    required this.id,
    this.title,
    this.description,
    this.coverBytes,
    this.coverName,
    this.authorId,
    this.price,
    this.pages,
    this.publishDate,
  });
}

class DeleteBook extends BooksEvent {
  final String id;

  DeleteBook(this.id);
}

// States
abstract class BooksState {}

class BooksInitial extends BooksState {}

class BooksLoading extends BooksState {}

class BooksLoaded extends BooksState {
  final List<Book> books;

  BooksLoaded(this.books);
}

class BooksError extends BooksState {
  final String message;

  BooksError(this.message);
}

// Bloc
class BooksBloc extends Bloc<BooksEvent, BooksState> {
  final BooksRepository repository;

  BooksBloc({required this.repository}) : super(BooksInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<CreateBook>(_onCreateBook);
    on<UpdateBook>(_onUpdateBook);
    on<DeleteBook>(_onDeleteBook);
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<BooksState> emit) async {
    emit(BooksLoading());
    try {
      final books = await repository.getBooks();
      emit(BooksLoaded(books));
    } catch (e) {
      emit(BooksError(e.toString()));
    }
  }

  Future<void> _onCreateBook(CreateBook event, Emitter<BooksState> emit) async {
    try {
      await repository.createBook(
        event.title,
        event.description,
        event.coverBytes,
        event.coverName,
        event.authorId,
        event.price,
        event.pages,
        event.publishDate,
      );
      add(LoadBooks());
    } catch (e) {
      emit(BooksError(e.toString()));
    }
  }

  Future<void> _onUpdateBook(UpdateBook event, Emitter<BooksState> emit) async {
    try {
      await repository.updateBook(
        event.id,
        title: event.title,
        description: event.description,
        coverBytes: event.coverBytes,
        coverName: event.coverName,
        authorId: event.authorId,
        price: event.price,
        pages: event.pages,
        publishDate: event.publishDate,
      );
      add(LoadBooks());
    } catch (e) {
      emit(BooksError(e.toString()));
    }
  }

  Future<void> _onDeleteBook(DeleteBook event, Emitter<BooksState> emit) async {
    try {
      await repository.deleteBook(event.id);
      add(LoadBooks());
    } catch (e) {
      emit(BooksError(e.toString()));
    }
  }
}
