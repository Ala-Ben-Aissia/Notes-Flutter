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
            (value) => value.docs.map(
              (doc) => CloudNote(
                documentId: doc.id,
                ownerUserId: doc.data()[ownerUserIdFieldName],
                text: doc.data()[textFieldName],
              ),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNoteaException();
    }
  }

  void createNote({required String userId}) async {
    await notes.add({
      ownerUserIdFieldName: userId,
      textFieldName: '',
    });
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
  FirebaseCloudStorage._sharedInstance();
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
