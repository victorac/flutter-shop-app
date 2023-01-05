import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' as orders_provider;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<orders_provider.Orders>(context);
    final appBar = AppBar(
      title: const Text('Your order'),
    );
    // final maxAvailableOrderHeight = MediaQuery.of(context).size.height -
    //     appBar.preferredSize.height -
    //     MediaQuery.of(context).padding.top -
    //     MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: appBar,
      body: ListView.builder(
        itemCount: ordersData.orders.length,
        itemBuilder: (context, index) => OrderItem(
          order: ordersData.orders[index],
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
