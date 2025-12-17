import '../db/firestore_service.dart';
import '../db/db_helper.dart';
import '../expense/expense_model.dart';

class SyncService {
  static bool isInitialSyncDone = false;

  static Future<void> initialSync() async {
    isInitialSyncDone = false;

    final firestoreExpenses = await FirestoreService.fetchExpenses();

    await DBHelper.clearExpenses();

    for (final expense in firestoreExpenses) {
      await DBHelper.insertExpense(expense);
    }

    isInitialSyncDone = true;
  }
}

