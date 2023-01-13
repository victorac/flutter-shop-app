import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' as orders_provider;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<orders_provider.Orders>(context, listen: false)
        .listOrders();
  }

  @override
  void initState() {
    print("hey");
    super.initState();
    _ordersFuture = _obtainOrdersFuture();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Your orders'),
    );
    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (BuildContext ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: ElevatedButton(
                  onPressed: () => setState(() {
                        _ordersFuture = _obtainOrdersFuture();
                      }),
                  child: const Text('Retry')),
            );
          }
          return Consumer<orders_provider.Orders>(
            builder: (context, ordersData, child) => ListView.builder(
              itemCount: ordersData.orders.length,
              itemBuilder: (context, index) => OrderItem(
                order: ordersData.orders[index],
              ),
            ),
          );
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}
