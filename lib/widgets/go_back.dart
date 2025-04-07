import 'package:flutter/material.dart';

AppBar buildCommonAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    toolbarHeight: 28,        // appBar 높이 여기서 수정. 기본 56 -> 28 줄임
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    title: null,
    centerTitle: true,
  );
}
