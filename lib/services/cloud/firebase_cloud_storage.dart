import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project0/services/cloud/cloud_note.dart';
import 'package:project0/services/cloud/cloud_storage_constants.dart';
import 'package:project0/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  // to make the data of the notes collection updated in real time , we use the snapshots() (subscribe to it)
  Stream<Iterable<CloudNote>> allNotes({required String userId}) {
    return notes.snapshots().map(
          (event) => event.docs
              .map((doc) => CloudNote.fromSnapshot(doc))
              .where((note) => note.ownerUserId == userId),
        );
  }

  Future<Iterable<CloudNote>> getNotes({required String userId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: userId,
          )
          .get() // takes ansnapshot at a point of time and returns it
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllNoteaException();
    }
  }

  Future<CloudNote> createNote({required String userId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: userId,
      textFieldName: '',
    });
    final fetchedNote = await document
        .get(); // the actual snapshot (contains the data of this document)
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: userId,
      text: '',
    );
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update(
        {textFieldName: text},
      );
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNotes({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // SINGLETON
  // without SINGLETON we can basically create a FirebaseCloudStorage instance anywhere,
  // That's why we use the private instance '_shared' & the private constructor '_sharedInstance'
  // the one and only instance
  FirebaseCloudStorage._sharedInstance();
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
