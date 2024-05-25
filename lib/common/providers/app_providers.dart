import 'package:machine_test_thiran/screens/user_list/controller/user_list_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';


class AppProviders {
  static List<SingleChildWidget> multiProviders = [
    ChangeNotifierProvider(create: (_) => UserListController()),
  ];
}
