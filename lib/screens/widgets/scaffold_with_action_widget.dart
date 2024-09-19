import 'package:flutter/material.dart';
import 'package:gl_nueip/generated/assets.dart';
import 'package:gl_nueip/screens/pages/setting_page.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ScaffoldWithAction extends StatelessWidget {
  final Widget body;

  const ScaffoldWithAction({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ShadImage(
          Assets.header,
          width: 230,
          fit: BoxFit.fitHeight,
        ),
        centerTitle: true,
        toolbarHeight: 100,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: body,
      ),
    );
  }
}
