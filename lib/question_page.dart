import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:release/widget/common/system_widget.dart';


class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {

  final _editController = TextEditingController();

  // フォームキー
  final _formKey = GlobalKey<FormState>();

  // お問い合わせ内容
  String _message = "";

  /// お問い合せ送信
  Future sendMessage() async {
    final result = await ApiClient().sendContactForm(_message);
    if (result) {
      showDialog(
        context: context,
        builder: (BuildContext context) => alertBuilderForCupertino(
          context,
          'お問い合せ完了',
          'お問合せを行いました'
        )
      );
      // 入力欄クリア
      _editController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "お問い合せ"),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('お問い合せ内容をご入力してください'),
              const SizedBox(height: 5),
              TextFormField(
                maxLines: 5,
                minLines: 5,
                controller: _editController,
                onChanged: (value) => _message = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  hintText: 'お問い合わせ',
                  //この一行
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                      return 'お問い合わせ内容を入力してください';
                    }
                    return null;
                }
              ),
              const SizedBox(height:30),
              ElevatedButton(
                onPressed: (){
                  if (_formKey.currentState!.validate()) {
                    // 成功した場合
                    sendMessage();
                  }
                },
                child: Text('送信する'),
              ),
              Expanded(
                child: const SizedBox(height:30)
              ),
              // バナー広告
              AdModBanner()
            ]
          ),
        ),
      ),
    );
  }
}