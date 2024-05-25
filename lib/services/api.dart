import 'package:http/http.dart' as http;
import 'package:machine_test_thiran/common/models/details_db_model.dart';
import 'package:machine_test_thiran/common/models/details_model.dart';
import 'package:machine_test_thiran/services/db.dart';

class ApiProvider {
  DatabaseProvider dbProvider = DatabaseProvider();
  List<DetailsDbModel> dataList = [];

  /// api function for calling initial list of users
  Future<List<DetailsDbModel>?> getUserList() async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          'https://api.github.com/search/repositories?q=created:%3E2022-04-29&sort=stars&order=desc',
        ),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        DetailsModel userListModel = DetailsModel.fromJson(response.body);

        if (userListModel.items != null) {
          for (Item item in userListModel.items!) {
            dataList.add(dbProvider.convertFunction(item));
          }
        }
        /// Insert users into database
        await dbProvider.insertDetails(dataList);

        return dataList;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// api function for calling a refresh api user list
  Future<List<DetailsDbModel>?> getRefreshedUserList({DateTime? date}) async {
    String time = (date ?? DateTime.now()).toIso8601String().split('T').first;

    try {
      http.Response response = await http.get(
        Uri.parse(
          'https://api.github.com/search/repositories?q=created:>$time&sort=stars&order=desc',
        ),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        DetailsModel userListModel = DetailsModel.fromJson(response.body);
        if ((userListModel.items ?? []).isEmpty) {
          /// if current date is having no data
          /// call the api again with 1 day before as date
          return await getRefreshedUserList(
            date: DateTime.now().subtract(const Duration(days: 1)),
          );
        } else if (userListModel.items != null) {
          for (Item item in userListModel.items!) {
            dataList.add(dbProvider.convertFunction(item));
          }
        }
        return dataList;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
