import 'dart:math';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../providers/orders.dart' as orders_provider;

class OrderItem extends StatefulWidget {
  const OrderItem({super.key, required this.order});

  final orders_provider.OrderItem order;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount.toStringAsFixed(2)}'),
            subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => {
                setState(
                  () => _expanded = !_expanded,
                )
              },
            ),
          ),
          if (_expanded)
            SizedBox(
              height: min(widget.order.products.length * 20 + 50, 180),
              child: ListView.builder(
                itemCount: widget.order.products.length,
                itemBuilder: (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                    children: [
                      Text(widget.order.products[index].title),
                      const Spacer(),
                      Text(
                        '${widget.order.products[index].quantity}x \$${widget.order.products[index].price}',
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
