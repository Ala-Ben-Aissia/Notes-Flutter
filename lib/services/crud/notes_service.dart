import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

class NoteService {
  Database? _db;

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    final result = notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
    return result;
    // with Future<DatabaseNote>
    // final result = DatabaseNote.fromRow(notes.first);
    // return result;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) throw CouldNotFindNote();
    return DatabaseNote.fromRow(notes.first);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    // MAKING SURE THE OWNER EXISTS IN THE DATABASE WITH THE CORRECT ID
    // SEE THE BOOL OPERATOR'S OVVERRIDE IN THE DATABASEUSER
    if (dbUser != owner) throw CouldNotFindUser();
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudCloumn: 1,
    });
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    final updatedCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudCloumn: 0,
    });
    if (updatedCount == 0) throw CouldNotUpdateNote();
    final updatedNote = await getNote(id: note.id);
    return updatedNote;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) throw CouldNotDeleteNote();
  }

  Future<void> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    await db.delete(noteTable);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) throw CouldNotFindUser();
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final users = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (users.isNotEmpty) throw UserAlreadyExists();
    final userId = await db.insert(
      userTable,
      users
          .first, // or { emailColumn: email.toLowerCase() } no need for id: its already a pk
    );
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      // delete returns the number of deleted rows
      userTable,
      where: 'email = ?', // where email is equal to something
      whereArgs: [email.toLowerCase()], // that thing is email.toLowerCase()
    );
    if (deletedCount == 0) throw CouldNotDeleteUser();
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpen();
    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createNoteTable); // create user table
      await db.execute(createUserTable); // create note table
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    db == null ? throw DatabaseNotOpen() : await db.close();
    _db = null;
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
  // every user of this DatabaseUser table will be represented by a row
  @override
  String toString() =>
      'UserId: $id, UserEmail: $email'; // to avoid 'instance of DatabaseUser'
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  // comparing users of the same DatabaseUser class by their id (which is the pk)
  @override
  int get hashCode => id.hashCode; // id is the primary key of this class
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  // the noteRow presentation
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudCloumn] as int) == 1 ? true : false;
  @override
  String toString() {
    return 'NoteId: $id, UserId: $userId, Note: $text, Synced: $isSyncedWithCloud';
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
}

const dbName = 'Project0.db';
const userTable = 'user';
const noteTable = 'note';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudCloumn = 'is_synced_with_cloud';
const createUserTable = ''' 
      CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';
const createNoteTable = ''' 
      CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );
      ''';
