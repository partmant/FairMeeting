import 'package:flutter/material.dart';

PreferredSizeWidget buildCommonAppBar(BuildContext context, {String? title}) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    centerTitle: true,
    title: title != null
        ? Text(
      title,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    )
        : null, // title 없으면 비워둠
  );
}