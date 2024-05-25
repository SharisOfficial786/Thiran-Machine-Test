import 'package:flutter/material.dart';
import 'package:machine_test_thiran/common/providers/app_providers.dart';
import 'package:machine_test_thiran/screens/user_list/view/user_list_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.multiProviders,
      child: MaterialApp(
        title: 'Machine Test Thiran',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const UserListScreen(),
      ),
    );
  }
}
