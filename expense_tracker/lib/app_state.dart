import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/transactions/models/transaction.dart' as transaction_model;
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'firebase_options.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String userId;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.userId,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] as String,
      icon: data['icon'] as String,
      userId: data['userId'] as String,
    );
  }
}

enum OnboardingStatus {
  notStarted,
  balanceSet,
  categoriesSet,
  completed
}

class TransactionActions {
  static const add = "ADD";
  static const update = "UPDATE";
  static const delete = "DELETE";
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  int _balance = 0;
  int get balance => _balance;

  bool _isBalanceLoading = true;
  bool get isBalanceLoading => _isBalanceLoading;

  OnboardingStatus _onboardingStatus = OnboardingStatus.notStarted;
  OnboardingStatus get onboardingStatus => _onboardingStatus;

  bool _isCheckingOnboarding = true;
  bool get isCheckingOnboarding => _isCheckingOnboarding;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  bool _isCategoriesLoading = true;
  bool get isCategoriesLoading => _isCategoriesLoading;

  // Added: User's selected categories
  List<String> _userSelectedCategories = [];
  List<String> get userSelectedCategories => _userSelectedCategories;

  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  List<transaction_model.Transaction> _transactions = [];
  List<transaction_model.Transaction> get transactions => _transactions;

  Future<void> init() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _checkOnboardingStatus();
        _fetchUserBalance();
        _fetchCategories(user.uid);
        _transactionSubscription = FirebaseFirestore.instance.collection('transactions').where('userId', isEqualTo: user.uid).orderBy("timestamp", descending: true).snapshots().listen(
          (snapshot) {
            _transactions = [];
            for (final document in snapshot.docs) {
              _transactions.add(
                transaction_model.Transaction(
                  id: document.id,
                  paymentMethod: document.data()['paymentMethod'] as String,
                  category: document.data()['category'] as String,
                  title: document.data()['title'] as String,
                  price: (document.data()['price'] as num).toInt(),
                  comment: document.data()['comment'] as String,
                  type: document.data()['type'] as String,
                  timestamp: (document.data()['timestamp'] as Timestamp).toDate(),
                ),
              );
            }
            notifyListeners();
          },
        );
      } else {
        _loggedIn = false;
        _balance = 0;
        _transactions = [];
        _isBalanceLoading = false;
        _isCheckingOnboarding = false;
        _categories = [];
        _userSelectedCategories = [];
        _isCategoriesLoading = false;
        _onboardingStatus = OnboardingStatus.notStarted;
        _transactionSubscription?.cancel();
      }
      notifyListeners();
    });

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);
  }

  Future<void> _fetchCategories(String userId) async {
    _isCategoriesLoading = true;
    notifyListeners();

    try {
      // Fetch all categories (default and user's custom)
      final categorySnapshot = await FirebaseFirestore.instance.collection('categories').where('userId', whereIn: [
        userId,
        'ALL'
      ]).get();

      _categories = categorySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();

      // Fetch user's selected categories
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data()?['selectedCategories'] != null) {
        _userSelectedCategories = List<String>.from(userDoc.data()?['selectedCategories'] as List<dynamic>);
      } else {
        _userSelectedCategories = [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      _categories = [];
      _userSelectedCategories = [];
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  // Added: Save user's selected categories
  Future<void> saveUserCategories(List<String> selectedCategories) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
      'selectedCategories': selectedCategories,
    }, SetOptions(merge: true));

    _userSelectedCategories = selectedCategories;
    notifyListeners();
  }

  Future<Category> addCustomCategory(String name, String icon) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    final docRef = await FirebaseFirestore.instance.collection('categories').add({
      'name': name,
      'icon': icon,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });

    final newCategory = Category(
      id: docRef.id,
      name: name,
      icon: icon,
      userId: FirebaseAuth.instance.currentUser!.uid,
    );

    _categories.add(newCategory);
    notifyListeners();

    return newCategory;
  }

  Future<void> _checkOnboardingStatus() async {
    _isCheckingOnboarding = true;
    notifyListeners();

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();

      if (!userDoc.exists) {
        _onboardingStatus = OnboardingStatus.notStarted;
      } else {
        final status = userDoc.data()?['onboardingStatus'] as String?;
        _onboardingStatus = status != null ? OnboardingStatus.values.firstWhere((e) => e.toString() == 'OnboardingStatus.$status', orElse: () => OnboardingStatus.notStarted) : OnboardingStatus.notStarted;
      }
    } catch (e) {
      print('Error checking onboarding status: $e');
      _onboardingStatus = OnboardingStatus.notStarted;
    } finally {
      _isCheckingOnboarding = false;
      notifyListeners();
    }
  }

  Future<void> updateOnboardingStatus(OnboardingStatus status) async {
    _onboardingStatus = status;
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
      'onboardingStatus': status.toString().split('.').last,
    }, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> _fetchUserBalance() async {
    _isBalanceLoading = true;
    notifyListeners();

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();

      if (userDoc.exists) {
        _balance = (userDoc.data()?['balance'] as num?)?.toInt() ?? 0;
      } else {
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
          'balance': 0
        });
        _balance = 0;
      }
    } catch (e) {
      print('Error fetching user balance: $e');
      _balance = 0;
    } finally {
      _isBalanceLoading = false;
      notifyListeners();
    }
  }

  Future<void> setBalance(int newBalance) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    _balance = newBalance;
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'balance': _balance
    });
    notifyListeners();
  }

  Future<void> updateBalance({
    String actionType = TransactionActions.add,
    String transactionType = transaction_model.TransactionType.expense,
    int amount = 0,
  }) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    switch (actionType) {
      case TransactionActions.add:
        {
          if (transactionType == transaction_model.TransactionType.expense) {
            _balance -= amount;
          }

          if (transactionType == transaction_model.TransactionType.income) {
            _balance += amount;
          }
        }
        break;
      case TransactionActions.delete:
        {
          if (transactionType == transaction_model.TransactionType.expense) {
            _balance += amount;
          }

          if (transactionType == transaction_model.TransactionType.income) {
            _balance -= amount;
          }
        }
        break;
      case TransactionActions.update:
        {
          if (transactionType == transaction_model.TransactionType.expense) {
            _balance += amount;
          }

          if (transactionType == transaction_model.TransactionType.income) {
            _balance -= amount;
          }
        }
        break;
    }

    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'balance': _balance
    });
    notifyListeners();
  }

  Future<DocumentReference<Map<String, dynamic>>> addTransaction(transaction_model.Transaction transaction) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    await updateBalance(
      actionType: TransactionActions.add,
      transactionType: transaction.type,
      amount: transaction.price,
    );

    return FirebaseFirestore.instance.collection('transactions').add(<String, dynamic>{
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'paymentMethod': transaction.paymentMethod,
      'category': transaction.category,
      'comment': transaction.comment,
      'title': transaction.title,
      'price': transaction.price,
      'timestamp': transaction.timestamp,
      'type': transaction.type,
    });
  }

  Future<void> updateTransaction(transaction_model.Transaction oldTransaction, transaction_model.Transaction newTransaction) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    await updateBalance(
      actionType: TransactionActions.update,
      transactionType: oldTransaction.type,
      amount: oldTransaction.price - newTransaction.price,
    );

    await FirebaseFirestore.instance.collection('transactions').doc(oldTransaction.id).update(<String, dynamic>{
      'paymentMethod': newTransaction.paymentMethod,
      'category': newTransaction.category,
      'comment': newTransaction.comment,
      'title': newTransaction.title,
      'price': newTransaction.price,
      'timestamp': newTransaction.timestamp,
    });
  }

  Future<void> deleteTransaction(transaction_model.Transaction transaction) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    await updateBalance(
      actionType: TransactionActions.delete,
      transactionType: transaction.type,
      amount: transaction.price,
    );

    await FirebaseFirestore.instance.collection('transactions').doc(transaction.id).delete();
  }
}
