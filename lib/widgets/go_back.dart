import 'package:flutter/material.dart';

AppBar buildCommonAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    title: null,
    centerTitle: true,
  );
}
