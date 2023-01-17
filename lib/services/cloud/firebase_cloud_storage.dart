import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // create a singleton
  FirebaseCloudStorage._sharedInstance();
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection("notes");

  Stream<List<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId)
          .toList());

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    // consider .onError
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
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
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote(
      {required String ownerUserId, required String text}) async {
    return await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: text,
    }).then(
      (value) => value.get().then(
            (doc) => CloudNote(
                documentId: doc.id,
                ownerUserId: doc.data()![ownerUserIdFieldName],
                text: doc.data()![textFieldName]),
          ),
    );
  }

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<CloudNote> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      final note = notes.doc(documentId);
      await note.update({textFieldName: text});
      return note.get().then(
            (value) => CloudNote(
              documentId: value.id,
              ownerUserId: value.data()![ownerUserIdFieldName],
              text: value.data()![textFieldName],
            ),
          );
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }
}
