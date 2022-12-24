import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:release/api/api.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/notice.dart';
import 'package:release/notice_detail.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:release/widget/common/system_widget.dart';

import 'package:get/get.dart';


class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  // お知らせ一覧
  List<NoticeModel> _notice = [];

  // お知らせ一覧取得
  Future getNoticeList() async {
    _gameGetx.setLoading(true);
    _notice = await ApiClient().getNoticeList();
    setState(() {});
    _gameGetx.setLoading(false);
  }

    @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNoticeList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children:[ 
          Scaffold(
            appBar: MyAppBar(title: "お知らせ"),  
            body: ListView.builder(
              itemCount: _notice.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => NoticeDetail(notice: _notice[index]),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          _notice[index].noticeDate,
                          style: const TextStyle(
                            color: Colors.grey,
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, top:5),
                          child: Text(
                            '${_notice[index].title}',
                            style: const  TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            )
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              }
            )
          ),
          Obx( // getxで検知するように
            // 全画面ローディング
            () => OverlayLoadingMolecules(
              visible: _gameGetx.isLoading.value,
              isLoading: true
            )
          ),
        ]
      ),
    );
  }
}