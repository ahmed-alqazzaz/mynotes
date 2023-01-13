import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class NotesService {
  static final _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  Database? _db;

  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
  Future<void> _cache() async {
    final allNotes = await getAllNotes();
    _notesStreamController.add(allNotes.toList());
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      return await getUser(email: email);
    } on CouldNotFindUserException {
      return await createUser(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    Database DB = await db;
    await getNote(id: note.id);
    final updatedCount = await DB.update(
      noteTable,
      where: idColumn,
      {textColumn: text, isSyncedWithCloudColumn: 0},
    );
    if (updatedCount == 0) {
      throw CouldNotUpdateNotesException();
    }
    final updatedNote = await getNote(id: note.id);
    _notes.remove(note);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    Database DB = await db;
    final notes = await DB.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    Database DB = await db;
    final notes = await DB
        .query(noteTable, limit: 1, where: "$idColumn = ?", whereArgs: [id]);
    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }
    final note = DatabaseNote.fromRow(notes.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<int> deleteAllNotes() async {
    Database DB = await db;
    _notes.clear();
    _notesStreamController.add(_notes);
    return await DB.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    Database DB = await db;
    final deletedCount = await DB.delete(
      noteTable,
      where: 'id',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }

    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote?> createNote(
      {required DatabaseUser owner, required String text}) async {
    if (text.isEmpty) {
      return null;
    }
    Database DB = await db;
    //check if user really exists
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotDeleteUserException();
    }

    final noteId = await DB.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    final databaseNote = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: 0,
    );
    _notes.add(databaseNote);
    _notesStreamController.add(_notes);
    return databaseNote;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    Database DB = await db;
    final results = await DB.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      //in case no user found create the user and recursively execute the function
      await createUser(email: email);
      return await getUser(email: email);
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    Database DB = await db;
    final results = await DB.query(
      userTable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final id = await DB.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(
      id: id,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    Database DB = await db;
    final deleteCount =
        await DB.delete(userTable, where: 'email = ?', whereArgs: [
      email.toLowerCase(),
    ]);
    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<Database> get db async {
    final DB = _db;
    if (DB?.isOpen == true) {
      return DB!;
    }
    await open();
    return db;
  }

  Future<void> open() async {
    if (_db?.isOpen == true) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final DB = await openDatabase(dbPath);

      await DB.execute(createUserTableCommand);

      await DB.execute(createNoteTableCommand);
      _db = DB;
      await _cache();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    Database DB = await db;
    return await DB.close();
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person: id = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final int isSyncedWithCloud;
  const DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = map[isSyncedWithCloudColumn] as int;
  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";
const createUserTableCommand =
    '''CREATE TABLE IF NOT EXISTS "user" ("id" INTEGER PRIMARY KEY,
    "email" TEXT NOT NULL
    )''';
const createNoteTableCommand = '''CREATE TABLE IF NOT EXISTS "note" (
        "id" INTEGER PRIMARY KEY NOT NULL,
        "user_id" INTEGER NOT NULL,
        "text" TEXT NOT NULL,
        'is_synced_with_cloud' INTEGER NOT NULL DEFAULT 0,
         FOREIGN KEY ("user_id") REFERENCES "users"("id")
      )''';
