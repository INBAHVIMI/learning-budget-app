import '../models.dart';

class OneDriveSyncService {
  Future<void> syncEncryptedBackup(YearPlan plan, {required String passphrase}) async {
    // TODO: Implement Graph API auth and upload encrypted data file to OneDrive.
    // Recommended path in OneDrive: Apps/LearningBudget/data.enc
    await Future<void>.value();
  }

  Future<YearPlan?> restoreEncryptedBackup({required String passphrase}) async {
    // TODO: Download encrypted file from OneDrive, decrypt, and parse into YearPlan.
    await Future<void>.value();
    return null;
  }
}
