import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' as orders_provider;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = false;
  bool _failedLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, tryFetchOrders);
  }

  Future<void> tryFetchOrders() {
    setState(() {
      _isLoading = true;
      _failedLoading = false;
    });
    return Provider.of<orders_provider.Orders>(context, listen: false)
        .listOrders()
        .catchError(
      (error) {
        setState(() {
          _failedLoading = true;
        });
      },
    ).whenComplete(
      () => setState(
        () => _isLoading = false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<orders_provider.Orders>(context);
    final appBar = AppBar(
      title: const Text('Your order'),
    );
    return Scaffold(
      appBar: appBar,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => tryFetchOrders(),
              child: _failedLoading
                  ? Center(
                      child: ElevatedButton(
                          onPressed: () async => await tryFetchOrders(),
                          child: Text('Retry')),
                    )
                  : ListView.builder(
                      itemCount: ordersData.orders.length,
                      itemBuilder: (context, index) => OrderItem(
                        order: ordersData.orders[index],
                      ),
                    ),
            ),
      drawer: const AppDrawer(),
    );
  }
}
