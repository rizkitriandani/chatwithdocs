import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MobileView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: controller.extractPdfText,
              child: const Text('Extract Text from PDF'),
            ),
            const SizedBox(height: 20),
            const Text('Extracted Text:'),
            const SizedBox(height: 20),
            Obx(() => Text(controller.result.value)),
            const SizedBox(height: 20),
            Obx(() => Expanded(
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(controller.text.value),
                  )),
                )),
          ],
        ),
      ),
    );
  }
}
