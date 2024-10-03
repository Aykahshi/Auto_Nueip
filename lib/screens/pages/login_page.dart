import 'package:flutter/material.dart';
import 'package:gl_nueip/core/utils/assets.dart';
import 'package:gl_nueip/screens/widgets/info_form_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShadImage(
            Assets.header,
            fit: BoxFit.fitHeight,
          ),
          InfoForm(),
        ],
      ),
    );
  }
}
