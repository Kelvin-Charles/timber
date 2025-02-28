import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  final User? user;
  
  const OrdersScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      drawer: AppDrawer(user: user),
      body: const Center(
        child: Text('Orders will be displayed here'),
      ),
    );
  }
} 