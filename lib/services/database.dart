import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virata_app/model/bills.dart';
import 'dart:math';
import 'dart:convert';

import 'package:virata_app/model/item.dart';
import 'package:virata_app/model/transaction.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/model/wallet.dart';

class DatabaseService {
  final String? uid;
  final String? wallet_id;
  final String? transid;
  final String? bills_id;
  DatabaseService({
    this.uid,
    this.wallet_id,
    this.transid,
    this.bills_id,
  });

  final CollectionReference shopperCollection =
      FirebaseFirestore.instance.collection("shopper");

  final CollectionReference walletCollection =
      FirebaseFirestore.instance.collection("wallet");

  Future setShopperData(String username, String email, String phonenum,
      String dob, String gender, String nationality) async {
    return await shopperCollection.doc(uid).set({
      'name': username,
      'email': email,
      'phonenum': phonenum,
      'birthdate': dob,
      'gender': gender,
      'nationality': nationality,
    });
  }

  Future updateShopperData(String username, String email, String phonenum,
      String dob, String gender, String nationality) async {
    return await shopperCollection.doc(uid).update({
      'name': username,
      'email': email,
      'phonenum': phonenum,
      'birthdate': dob,
      'gender': gender,
      'nationality': nationality,
    });
  }

  Future UpdateShopperAvatar(String avatarpath) async {
    return await shopperCollection.doc(uid).update({
      'avatar_profile': avatarpath,
    });
  }

  Future setWalletData(double amount, double minAmount, double maxAmount,
      String currency) async {
    return await FirebaseFirestore.instance
        .collection("shopper")
        .doc(uid)
        .collection('wallet')
        .doc(uid.toString() + currency)
        .set({
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'currency': currency,
      'amount': amount,
      'isAvailable': false,
    });
  }

  Future updateWalletData(bool isAvailable, double amount) async {
    return await shopperCollection
        .doc(uid)
        .collection('wallet')
        .doc(wallet_id)
        .update({
      'isAvailable': isAvailable,
      'amount': amount,
    });
  }

  Future updateWalletCapacity(double minAmount, double maxAmount) async {
    return await shopperCollection
        .doc(uid)
        .collection('wallet')
        .doc(wallet_id)
        .update({
      'minAmount': minAmount,
      'maxAmount': maxAmount,
    });
  }

  Future deleteWallet() async {
    try {
      await shopperCollection
          .doc(uid)
          .collection('wallet')
          .doc(wallet_id)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  Future setBillsData(
      double value, String currencycode, int quantity, String imagepath) async {
    return await shopperCollection
        .doc(uid)
        .collection('wallet')
        .doc(wallet_id)
        .collection('bills')
        .doc(currencycode + value.toString())
        .set({
      'value': value,
      'currency': currencycode,
      'quantity': quantity,
      'image': 'bills/' + currencycode + "/" + imagepath,
    });
  }

  Future updateBillsQty(int quantity) async {
    return await shopperCollection
        .doc(uid)
        .collection('wallet')
        .doc(wallet_id)
        .collection('bills')
        .doc(bills_id)
        .update({
      'quantity': quantity,
    });
  }

  ShopperData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return ShopperData(
      shopperid: uid,
      username: snapshot.get('name') ?? "",
      email: snapshot.get('email') ?? "",
      phonenum: snapshot.get('phonenum') ?? "",
      dob: snapshot.get('birthdate') ?? "",
      gender: snapshot.get('gender') ?? "",
      nationality: snapshot.get('nationality') ?? "",
      avatarpath: snapshot.get('avatar_profile') ?? "",
    );
  }

  Stream<ShopperData> get userData {
    return shopperCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  Wallet _walletDataFromSnapshot(DocumentSnapshot snapshot) {
    return Wallet(
      walletid: snapshot.id,
      amount: snapshot.get('amount') ?? 0,
      minAmount: snapshot.get('minAmount') ?? 0,
      maxAmount: snapshot.get('maxAmount') ?? 0,
      isAvailable: snapshot.get('isAvailable') ?? "",
      currency: snapshot.get('currency') ?? "",
    );
  }

  //user doc stream wallet
  Stream<Wallet> get walletData {
    return FirebaseFirestore.instance
        .collection("shopper")
        .doc(uid)
        .collection('wallet')
        .doc(wallet_id)
        .snapshots()
        .map((_walletDataFromSnapshot));
  }

  //user doc stream bills

  Bills _billsDataFromSnapshot(DocumentSnapshot snapshot) {
    return Bills(
      currency: snapshot.get('currency') ?? "",
      value: snapshot.get('value') ?? 0,
      quantity: snapshot.get('quantity') ?? 0,
      image: snapshot.get('image') ?? "",
    );
  }

  //list of bills
  List<Bills> _billsListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Bills(
        currency: doc.get('currency') ?? "",
        value: doc.get('value') ?? 0,
        quantity: doc.get('quantity') ?? 0,
        image: doc.get('image') ?? "",
      );
    }).toList();
  }

  //return list of transaction
  Stream<List<Bills>> get bills {
    return shopperCollection
        .doc(uid)
        .collection('wallet')
        .doc(wallet_id)
        .collection('bills')
        .snapshots()
        .map((_billsListFromSnapshot));
  }

  /* Stream<Wallet> get billsData {
    return shopperCollection
        .doc(uid)
        .collection('wallet')
        .doc(walletid)
        .snapshots()
        .map((_walletDataFromSnapshot));
  }*/

  Future updateInitialTransactionData(String currency) async {
    return await shopperCollection
        .doc(uid)
        .collection('transaction')
        .doc(transid)
        .set({
      'startTime': DateTime.now(),
      'shopperid': uid,
      'currency': currency,
      'amount': 0.0,
      'status': 'Incomplete',
    });
  }

  Future updatePaymentTransactionData(double amount, double cashAmt) async {
    return await shopperCollection
        .doc(uid)
        .collection('transaction')
        .doc(transid)
        .update({
      'amount': amount,
      'cash': cashAmt,
      'paymentTime': DateTime.now(),
    });
  }

  Future returnBalanceTransactionData(double balanceAmt) async {
    return await shopperCollection
        .doc(uid)
        .collection('transaction')
        .doc(transid)
        .update({
      'change': balanceAmt,
      'status': 'Success',
    });
  }

  Future deleteTransaction() async {
    try {
      await shopperCollection
          .doc(uid)
          .collection('transaction')
          .doc(transid)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  //list of transcation
  List<TransactionData> _transactionListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return TransactionData(
        id: doc.id,
        startTime: doc.get('startTime'),
        paymentTime: doc.get('paymentTime') ?? null,
        currency: doc.get('currency') ?? null,
        amount: doc.get('amount') ?? 0.0,
        cash: doc.get('cash') ?? 0.0,
        change: doc.get('change') ?? 0.0,
        status: doc.get('status') ?? "",
        shopperid: doc.get('shopperid'),
      );
    }).toList();
  }

  //return list of transaction
  Stream<List<TransactionData>> get transaction {
    return shopperCollection
        .doc(uid)
        .collection('transaction')
        .snapshots()
        .map(_transactionListFromSnapshot);
  }

  TransactionData _transDataFromSnapshot(DocumentSnapshot snapshot) {
    return TransactionData(
      id: snapshot.id,
      startTime: snapshot.get('startTime'),
      paymentTime: snapshot.get('paymentTime') ?? null,
      currency: snapshot.get('currency') ?? null,
      amount: snapshot.get('amount') ?? 0,
      cash: snapshot.get('cash') ?? 0.0,
      change: snapshot.get('change') ?? 0.0,
      status: snapshot.get('status') ?? "",
      shopperid: snapshot.get('shopperid'),
    );
  }

  Stream<TransactionData> get transData {
    return FirebaseFirestore.instance
        .collection('shopper')
        .doc(uid)
        .collection('transaction')
        .doc(transid)
        .snapshots()
        .map((_transDataFromSnapshot));
  }

  Future updateItemData(
      String itemid, String name, double price, int qty) async {
    return await shopperCollection
        .doc(uid)
        .collection('transaction')
        .doc(transid)
        .collection('item')
        .doc(itemid)
        .set({
      'name': name,
      'priceperunit': price,
      'quantity': qty,
    });
  }

  Future deleteItem(String itemid) async {
    try {
      await shopperCollection
          .doc(uid)
          .collection('transaction')
          .doc(transid)
          .collection('item')
          .doc(itemid)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  List<Item> _itemListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Item(
          itemid: doc.id,
          name: doc.get('name') ?? "",
          price: doc.get('priceperunit') ?? 0,
          quantity: doc.get('quantity') ?? 0);
    }).toList();
  }

  //return list of items
  Stream<List<Item>> get items {
    return shopperCollection
        .doc(uid)
        .collection('transaction')
        .doc(transid)
        .collection('item')
        .snapshots()
        .map(_itemListFromSnapshot);
  }

  //add notifications
  Future setNotification(String title, String body, String payload) async {
    return await shopperCollection
        .doc(uid)
        .collection('notification')
        .doc(transid)
        .set({
      'time': DateTime.now(),
      'title': title,
      'body': body,
      'payload': payload,
    });
  }
}
