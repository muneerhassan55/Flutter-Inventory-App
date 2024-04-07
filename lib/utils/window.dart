import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:bk_app/utils/form.dart';
import 'package:bk_app/app/forms/itemEntryForm.dart';
import 'package:bk_app/app/forms/salesEntryForm.dart';
import 'package:bk_app/app/forms/stockEntryForm.dart';
import 'package:bk_app/app/transactions/monthHistory.dart';
import 'package:bk_app/app/transactions/transactionList.dart';
import 'package:bk_app/app/transactions/dueTransactions.dart';

class WindowUtils {
  static Widget getCard(String label, {color = Colors.white}) {
    return Expanded(
        child: Card(
            color: color,
            elevation: 5.0,
            child: Center(
              heightFactor: 2,
              child: Text(label),
            )));
  }

  static void navigateToPage(BuildContext context,
      {String caller, String target}) async {
    Map _stringToForm = {
      'Item Entry': ItemEntryForm(title: target),
      'Sales Entry': SalesEntryForm(title: target),
      'Stock Entry': StockEntryForm(title: target),
      'Month History': MonthlyHistory(),
      'Transactions': TransactionList(),
      'Due Transactions': DueTransaction(),
    };

    if (caller == target) {
      return;
    }

    var getForm = _stringToForm[target];
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return getForm;
    }));
  }

  static moveToLastScreen(BuildContext context, {bool modified = false}) {
    debugPrint("I am called. Going back screen");
    Navigator.pop(context, modified);
  }

  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  static void showAlertDialog(
      BuildContext context, String title, String message,
      {onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            title,
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text(
              message,
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                moveToLastScreen(context);
                if (onPressed != null) {
                  onPressed(context);
                }
              },
              color: Theme.of(context).accentColor,
            ),
          ],
        );
      },
    );
  }

  static Widget genButton(BuildContext context, String name, var onPressed) {
    return Expanded(
        child: RaisedButton(
            color: Theme.of(context).accentColor,
            textColor: Colors.white, // Theme.of(context).primaryColorLight,
            child: Text(name, textScaleFactor: 1.5),
            onPressed: onPressed) // RaisedButton Calculate
        ); //Expanded
  }

  static String _formValidator(String value, String labelText) {
    if (value.isEmpty) {
      return "Please enter $labelText";
    }
    return null;
  }

  static Widget genTextField(
      {String labelText,
      String hintText,
      TextStyle textStyle,
      TextEditingController controller,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1,
      bool obscureText = false,
      var onChanged,
      var validator = _formValidator,
      bool enabled = true}) {
    final double _minimumPadding = 5.0;

    return Padding(
      padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
      child: TextFormField(
        enabled: enabled,
        keyboardType: keyboardType,
        style: textStyle,
        maxLines: maxLines,
        controller: controller,
        obscureText: obscureText,
        validator: (String value) {
          return validator(value, labelText);
        },
        onChanged: (value) {
          onChanged();
        },
        decoration: InputDecoration(
            labelText: labelText,
            labelStyle: textStyle,
            hintText: hintText,
            errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      ), // Textfield
    );
  } // genTextField function

  static Widget genAutocompleteTextField(
      {String labelText,
      String hintText,
      TextStyle textStyle,
      TextEditingController controller,
      TextInputType keyboardType = TextInputType.text,
      BuildContext context,
      List<Map> suggestions,
      bool enabled,
      var validator = _formValidator,
      var onChanged,
      var getSuggestions}) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        enabled: enabled,
        autofocus: true,
        style: textStyle,
        controller: controller,
        decoration: InputDecoration(
            labelText: labelText,
            labelStyle: textStyle,
            hintText: hintText,
            errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      ),
      validator: (String value) {
        return validator(value, labelText);
      },
      suggestionsCallback: (givenString) {
        onChanged();
        if (suggestions.isEmpty) {
          suggestions = getSuggestions();
        }
        return FormUtils.genFuzzySuggestionsForItem(givenString, suggestions);
      },
      itemBuilder: (context, suggestion) {
        return Container(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  suggestion['name'],
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(width: 10),
                Text(
                  suggestion['nickName'] ?? '',
                ),
              ],
            ));
      },
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion['name'];
        onChanged();
      },
    );
  }
}
