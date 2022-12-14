import 'package:flutter/material.dart';

List getSearchedList(List list, TextEditingController controller) {
  if (controller.text.isEmpty) {
    return list;
  }
  var newList = list.where((e) =>
      e.toString().toLowerCase().contains(controller.text)
  ).toList();

  return newList;
}