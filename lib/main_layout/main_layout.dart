import 'package:flutter/material.dart';

import '../modules/dynamic_layout/helper/helper.dart';
import 'layout_desktop.dart';

class MainLayout extends StatelessWidget {
  final Widget widget;

  const MainLayout({Key? key, required this.widget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var body = widget;

    if (Layout.isDisplayDesktop(context)) {
      body = LayoutDesktop(widget: widget);
    }

    return Material(child: body);
  }
}
