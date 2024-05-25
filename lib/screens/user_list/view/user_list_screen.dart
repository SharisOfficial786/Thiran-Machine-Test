import 'package:flutter/material.dart';
import 'package:machine_test_thiran/screens/user_list/controller/user_list_controller.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
    final userListProvider = Provider.of<UserListController>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userListProvider.checkDataInDatabase();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Users',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade200,
        // forceMaterialTransparency: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userListProvider.refreshData().then((value) {
            String data = value;
            if (value == 'Success') {
              data = 'Data refreshed';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data)),
            );
          });
        },
        child: Consumer<UserListController>(builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (controller.userList.isEmpty) {
            return const Center(
              child: Text('No data found!'),
            );
          } else {
            return ListView.builder(
              itemCount: controller.userList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60.0),
                      child: Image.network(
                          controller.userList[index].avatarUrl ?? ''),
                    ),
                  ),
                  title: Text(controller.userList[index].name ?? ''),
                  subtitle: Text(controller.userList[index].fullName ?? ''),
                );
              },
            );
          }
        }),
      ),
    );
  }
}
