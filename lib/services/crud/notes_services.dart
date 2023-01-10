import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await getNote(id: note.id);
    final updatedCount = await db.update(
      noteTable,
      where: idColumn,
      {textColumn: text, isSyncedWithCloud: 0},
    );
    if (updatedCount == 0) {
      throw CouldNotUpdateNotesException();
    }
    return await getNote(id: note.id);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final notes =
        await db.query(noteTable, limit: 1, where: idColumn, whereArgs: [id]);
    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }
    return DatabaseNote.fromRow(notes.first);
  }

  Future<int> deleteAllNotes() {
    return db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final deletedCount = await db.delete(
      noteTable,
      where: 'id',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    //check if user really exists
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotDeleteUserException();
    }

    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: '',
      isSyncedWithCloud: 1,
    });

    final databaseNote = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: '',
      isSyncedWithCloud: true,
    );
    return databaseNote;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final id = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(
      id: id,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final deleteCount =
        await db.delete(userTable, where: 'email = ?', whereArgs: [
      email.toLowerCase(),
    ]);
    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database get db {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    return db;
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createUserTableCommand);

      await db.execute(createNoteTableCommand);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    if (db.isOpen) {
      return await db.close();
    }
    throw DatabaseIsNotOpenException();
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
  final bool isSyncedWithCloud;
  const DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = map[''] as bool;
  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const noteTable = "notes";
const userTable = "users";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloud = "is_synced_with_cloud";
const createUserTableCommand = '''CREATE TABLE IF NOT EXISTS "user" (
        "id" INTEGER PRIMARY KEY NOT NULL,
        "email" TEXT NOT NULL,
      )''';
const createNoteTableCommand = '''CREATE TABLE IF NOT EXISTS "note" (
        "id" INTEGER PRIMARY KEY NOT NULL,
        "user_id" INTEGER NOT NULL,
        "text" TEXT,
        'is_synced_with_cloud' INTEGER NOT NULL DEFAULT 0,
         FOREIGN KEY ("user_id") REFERENCES "users"("id")
      )''';
