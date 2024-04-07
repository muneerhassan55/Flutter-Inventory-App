import 'dart:async';
import 'package:bk_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/services/auth.dart';

class CrudHelper {
  AuthService auth = AuthService();
  final userData;
  CrudHelper({this.userData});

  // Item
  Future<int> addItem(Item item) async {
    String targetEmail = this.userData.targetEmail;
    if (targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('$targetEmail-items')
          .add(item.toMap())
          .catchError((e) {
        print(e);
        return 0;
      });
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> updateItem(Item newItem) async {
    String targetEmail = this.userData.targetEmail;
    if (targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('$targetEmail-items')
          .document(newItem.id)
          .updateData(newItem.toMap())
          .catchError((e) {
        print(e);
        return 0;
      });
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> deleteItem(String itemId) async {
    String targetEmail = this.userData.targetEmail;
    if (targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('$targetEmail-items')
          .document(itemId)
          .delete()
          .catchError((e) {
        print(e);
        return 0;
      });
      return 1;
    } else {
      return 0;
    }
  }

  Stream<List<Item>> getItemStream() {
    String email = this.userData.targetEmail;
    print("Stream current target email $email");
    return Firestore.instance
        .collection('$email-items')
        .orderBy('used', descending: true)
        .snapshots()
        .map(Item.fromQuerySnapshot);
  }

  Future<Item> getItem(String field, String value) async {
    String email = this.userData.targetEmail;
    QuerySnapshot itemSnapshots = await Firestore.instance
        .collection('$email-items')
        .where(field, isEqualTo: value)
        .getDocuments()
        .catchError((e) {
      return null;
    });

    if (itemSnapshots.documents.isEmpty) {
      return null;
    }
    DocumentSnapshot itemSnapshot = itemSnapshots.documents.first;

    if (itemSnapshot.data.isNotEmpty) {
      Item item = Item.fromMapObject(itemSnapshot.data);
      item.id = itemSnapshot.documentID;
      return item;
    } else {
      return null;
    }
  }

  Future<Item> getItemById(String id) async {
    String email = this.userData.targetEmail;
    DocumentSnapshot itemSnapshot = await Firestore.instance
        .document('$email-items/$id')
        .get()
        .catchError((e) {
      return null;
    });
    if (itemSnapshot.data?.isNotEmpty ?? false) {
      Item item = Item.fromMapObject(itemSnapshot.data);
      item.id = itemSnapshot.documentID;
      return item;
    } else {
      return null;
    }
  }

  Future<List<Item>> getItems() async {
    String email = this.userData.targetEmail;
    QuerySnapshot snapshots = await Firestore.instance
        .collection('$email-items')
        .orderBy('used', descending: true)
        .getDocuments();
    List<Item> items = List<Item>();
    snapshots.documents.forEach((DocumentSnapshot snapshot) {
      Item item = Item.fromMapObject(snapshot.data);
      item.id = snapshot.documentID;
      items.add(item);
    });
    return items;
  }

  // Item Transactions
  Stream<List<ItemTransaction>> getItemTransactionStream() {
    String email = this.userData.targetEmail;
    return Firestore.instance
        .collection('$email-transactions')
        .where('signature', isEqualTo: email)
        .snapshots()
        .map(ItemTransaction.fromQuerySnapshot);
  }

  Future<List<ItemTransaction>> getItemTransactions() async {
    String email = this.userData.targetEmail;
    QuerySnapshot snapshots = await Firestore.instance
        .collection('$email-transactions')
        .where('signature', isEqualTo: email)
        .getDocuments();
    return ItemTransaction.fromQuerySnapshot(snapshots);
  }

  Future<List<ItemTransaction>> getPendingTransactions() async {
    String email = this.userData.targetEmail;
    UserData user = await this.getUserData('email', email);
    List roles = user.roles?.keys?.toList() ?? List();
    print("roles $roles");
    if (roles.isEmpty) return List<ItemTransaction>();
    QuerySnapshot snapshots = await Firestore.instance
        .collection('$email-transactions')
        .where('signature', whereIn: roles)
        .getDocuments();
    return ItemTransaction.fromQuerySnapshot(snapshots);
  }

  Future<List<ItemTransaction>> getDueTransactions() async {
    String email = this.userData.targetEmail;
    QuerySnapshot snapshots = await Firestore.instance
        .collection('$email-transactions')
        .where('due_amount', isGreaterThan: 0.0)
        .getDocuments();
    return ItemTransaction.fromQuerySnapshot(snapshots);
  }

  // Users
  Future<UserData> getUserData(String field, String value) async {
    QuerySnapshot userDataSnapshots = await Firestore.instance
        .collection('users')
        .where(field, isEqualTo: value)
        .getDocuments()
        .catchError((e) {
      return null;
    });
    if (userDataSnapshots.documents.isEmpty) {
      return null;
    }
    DocumentSnapshot userDataSnapshot = userDataSnapshots.documents.first;
    if (userDataSnapshot.data.isNotEmpty) {
      UserData userData = UserData.fromMapObject(userDataSnapshot.data);
      userData.uid = userDataSnapshot.documentID;
      return userData;
    } else {
      return null;
    }
  }

  Future<UserData> getUserDataByUid(String uid) async {
    DocumentSnapshot _userData =
        await Firestore.instance.document('users/$uid').get().catchError((e) {
      print("error getting userdata $e");
      return null;
    });

    if (_userData.data == null) {
      print("error getting userdata is $uid");
      return null;
    }

    UserData userData = UserData.fromMapObject(_userData.data);
    print("here we go $userData & roles ${userData.roles}");
    return userData;
  }

  Future<int> updateUserData(UserData userData) async {
    print("got userData and roles ${userData.toMap}");
    await Firestore.instance
        .collection('users')
        .document(userData.uid)
        .setData(userData.toMap())
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }
}
