import 'dart:isolate';

import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:machine_test_thiran/common/models/details_db_model.dart';
import 'package:machine_test_thiran/services/api.dart';
import 'package:machine_test_thiran/services/db.dart';

class UserListController extends ChangeNotifier {
  final db = DatabaseProvider();

  List<DetailsDbModel> userList = [];
  bool isLoading = true;

  /// Check if data exists in the database
  void checkDataInDatabase() async {
    final hasData = await db.hasData();
    if (hasData) {
      // Data exists in the database, load it
      loadUserDataFromDatabase();
    } else {
      // No data in the database, fetch from API
      callUserListApi();
    }
  }

  /// Fetch user data from the database
  Future<void> loadUserDataFromDatabase() async {
    final items = await db.getDbItems();
    userList.clear();
    userList.addAll(items);
    userList.sort((a, b) => a.name!.compareTo(b.name!));
    isLoading = false;
    notifyListeners();
  }

  /// Call userList API
  Future<void> callUserListApi() async {
    List<DetailsDbModel>? response = await ApiProvider().getUserList();
    userList.clear();
    userList = response ?? [];
    isLoading = false;
    notifyListeners();
  }

  /// Refresh data by fetching from API and updating the database using Isolate
  Future<String> refreshData() async {
    String result = '';

    /// Create a ReceivePort to receive messages from the isolate
    final receivePort = ReceivePort();

    /// Spawn a new isolate and send the SendPort and API endpoint
    await Isolate.spawn(_refreshDataInBackground, receivePort.sendPort);

    final response = await receivePort.first;

    if (response == null) {
      /// this means the isolate exited without sending any results
      result = 'No message';
    } else if (response is List<DetailsDbModel>) {
      /// Clear old data and insert new data into the database
      await db.clearDatabase();
      await db.insertDetails(response).whenComplete(checkDataInDatabase);
      result = 'Success';
    } else {
      result = response as String;
    }

    /// Close the ReceivePort
    receivePort.close();

    return result;
  }
}

/// function to run in the background isolate
void _refreshDataInBackground(SendPort sendPort) async {
  try {
    List<DetailsDbModel>? newData = await ApiProvider().getRefreshedUserList();

    if (newData != null) {
      /// Send the updated data back to the main isolate
      sendPort.send(newData);
    } else {
      /// Send error message back to the main isolate
      sendPort.send('Error: Data already up to date');
    }
  } catch (error) {
    /// Send error message back to the main isolate
    sendPort.send('Error: $error');
  }
}
