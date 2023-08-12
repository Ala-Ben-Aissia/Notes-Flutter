import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:project0/extensions/list/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

// The interface between the UI and the notes_service is done through a stream

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
  // comparing users of the same class (DatabaseUser) by their id (which is the pk)
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

  // the noteRow presentation with the named constructor
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

class NotesService {
  Database? _db;
  DatabaseUser? _user;
  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpen();
    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);
      await _cacheNote();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpen {
      // empty
    }
  }

  Future<void> close() async {
    final db = _db;
    db == null ? throw DatabaseNotOpen() : await db.close();
    _db = null;
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      return db;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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
      {
        emailColumn: email.toLowerCase(),
      },
    );
    final newUser = DatabaseUser(
      id: userId,
      email: email,
    );
    return newUser;
  }

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final newUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = newUser;
      }
      return newUser;
    } catch (e) {
      rethrow; // breakpoint
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      // delete() returns the number of deleted rows
      userTable,
      where: 'email = ?', // where email is equal to something
      whereArgs: [email.toLowerCase()], // that thing is email.toLowerCase()
    );
    if (deletedCount == 0) throw CouldNotDeleteUser();
  }

  List<DatabaseNote> _notes = []; // INTERNAL (source of truth)
  // the gate of _notes to the UI ( READ EXTERNALLY)
  late final StreamController<List<DatabaseNote>> _notesStreamController;
  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  // SINGLETON => class instance to ensure that this service (NotesService) is unique to this specific class ,
  // (Only one copy of this process logic)
  // without SINGLETON we can basically create a NotesService instance anywhere,
  // That's why we use the private instance '_shared' & the private constructor '_sharedInstance'
  // the one and only instance
  static final NotesService _shared = NotesService._sharedInstance();
  // private constructor (initializer)
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () => _notesStreamController.sink.add(_notes),
    );
  }
  factory NotesService() =>
      _shared; // this factory constructor promise to return an object of this type (NoteService)

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    final result = notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
    return result;
    // with Future<DatabaseNote>
    // final result = DatabaseNote.fromRow(notes.first);
    // return result;
  }

  Future<void> _cacheNote() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) throw CouldNotFindNote();
    final note = DatabaseNote.fromRow(notes.first);
    // updating the local cache (_notes could be outdated)
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    // reflect the update to the UI
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
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
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // make sure note exists
    await getNote(id: note.id);
    // update DB
    final updatedCount = await db.update(
        noteTable,
        {
          textColumn: text,
          isSyncedWithCloudCloumn: 0,
        },
        where: 'id = ?',
        whereArgs: [note.id]);
    if (updatedCount == 0) throw CouldNotUpdateNote();
    final updatedNote = await getNote(id: note.id);
    // remove the original note from our local cache (_notes)
    _notes.removeWhere((note) => note.id == updatedNote.id);
    // update it with the latest changes
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) throw CouldNotDeleteNote();
    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }
}
