import 'package:flutter/material.dart';
import './screens/product_overview_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryThemeData =
        ThemeData(primarySwatch: Colors.amber, fontFamily: 'Lato');
    final themeData = primaryThemeData.copyWith(
        colorScheme: primaryThemeData.colorScheme.copyWith(
      secondary: Colors.deepOrange,
    ));
    return MaterialApp(
      title: "MyShop",
      theme: themeData,
      home: ProductOverviewScreen(),
    );
  }
}
