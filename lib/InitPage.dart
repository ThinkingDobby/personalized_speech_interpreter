import 'package:flutter/material.dart';

import 'dialog/showNameInputDialog.dart';

class InitPage extends StatelessWidget {
  ValueNotifier<int> dialogTrigger = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: dialogTrigger,
        builder: (ctx, value, child) {
          Future.delayed(const Duration(seconds: 0), () {
            showNameInputDialog(context, ctx);
          });
          return Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xffffffff), Color(0xfff2f2f2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
          );
        },
      ),
    );
  }
}