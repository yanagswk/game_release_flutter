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

  final _messageController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();

  // フォームキー
  final _formKey = GlobalKey<FormState>();

  // お問い合わせ内容
  String _message = "";
  // 名前
  String _nickname = "";
  // メールアドレス
  String _email = "";

  /// お問い合せ送信
  Future sendMessage() async {
    final result = await ApiClient().sendContactForm(
      _nickname,
      _email,
      _message
    );
    if (result) {
      showDialog(
        context: context,
        builder: (BuildContext context) => alertBuilderForCupertino(
          context,
          'お問い合せ完了',
          'お問合せありがとうございます。'
        )
      );
      // 入力欄クリア
      _messageController.clear();
      _nicknameController.clear();
      _emailController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "お問い合せ"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle),
                    const Text(
                      'お名前 (10文字以内)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  controller: _nicknameController,
                  onChanged: (value) => _nickname = value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    hintText: 'お名前',
                    //この一行
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'お名前を入力してください';
                      }
                    if (value.length > 10) {
                      return '10文字以内で入力してください';
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Icon(Icons.mail),
                    const Text(
                      'メールアドレス (50文字以内)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  controller: _emailController,
                  onChanged: (value) => _email = value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    hintText: 'メールアドレス',
                    //この一行
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'メールアドレスを入力してください';
                      }
                    if (value.length > 50) {
                      return '50文字以内で入力してください';
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Icon(Icons.description),
                    const Text(
                      'お問い合せ内容 (200文字以内)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                TextFormField(
                  maxLines: 5,
                  minLines: 5,
                  controller: _messageController,
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
                    if (value.length > 200) {
                    return '200文字以内で入力してください';
                    }
                    return null;
                  }
                ),
                const SizedBox(height:30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900], //ボタンの背景色
                    ),
                    onPressed: (){
                      if (_formKey.currentState!.validate()) {
                        // 成功した場合
                        sendMessage();
                      }
                    },
                    child: Text('送信する'),
                  ),
                ),
                // Expanded(
                //   child: const SizedBox(height:30)
                // ),
                // バナー広告
                // AdModBanner()
              ]
            ),
          ),
        ),
      ),
    );
  }
}