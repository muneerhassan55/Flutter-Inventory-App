import 'package:bk_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/app/wrapper.dart';
import 'package:bk_app/app/forms/salesEntryForm.dart';
import 'package:bk_app/app/itemlist.dart';
import 'package:bk_app/app/transactions/transactionList.dart';
import 'package:bk_app/app/settings.dart';
import 'package:bk_app/services/auth.dart';

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserData>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bookkeeping app',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ), // ThemeData
        routes: <String, WidgetBuilder>{
          "/mainForm": (BuildContext context) =>
              SalesEntryForm(title: "Sales Entry"),
          "/itemList": (BuildContext context) => ItemList(),
          "/transactionList": (BuildContext context) => TransactionList(),
          "/settings": (BuildContext context) => Setting(),
        },
        home: Wrapper(),
      ),
    );
  }
}
