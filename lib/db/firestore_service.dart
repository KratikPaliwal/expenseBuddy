import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../expense/expense_model.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  static Future<void> addExpense(Expense expense) async {
    print("Firestore addExpense called");
    print("Current UID: $_userId");

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .add({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("Firestore write SUCCESS");
  }

  static Future<List<Expense>> fetchExpenses() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Expense(
        id: doc.id,
        title: data['title'],
        amount: (data['amount'] as num).toDouble(),
        date: DateTime.parse(data['date']),
      );
    }).toList();
  }
  static Future<void> deleteExpense(String expenseId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  static Future<void> updateExpense(Expense expense) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .doc(expense.id)
        .update({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
    });
  }



}
