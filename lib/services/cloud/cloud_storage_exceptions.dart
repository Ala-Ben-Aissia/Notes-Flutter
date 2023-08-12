class CloudStrageException implements Exception {
  const CloudStrageException();
}

class CouldNotCreateNoteException extends CloudStrageException {}

class CouldNotGetAllNoteaException extends CloudStrageException {}

class CouldNotUpdateNoteException extends CloudStrageException {}

class CouldNotDeleteNoteException extends CloudStrageException {}
