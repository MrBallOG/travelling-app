import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({super.key, required this.id});

  static const routeName = '/sample_item';

  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item ${id.toString()} Details'),
      ),
      body: Center(
        child: Text('More Information about Item ${id.toString()} Here'),
      ),
    );
  }
}
